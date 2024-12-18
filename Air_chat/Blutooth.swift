import Foundation
import UIKit
import CoreBluetooth

class BluetoothViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var discoveredPeripherals: [CBPeripheral] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            central.scanForPeripherals(withServices: nil, options: nil)
            print("Bluetooth is powered on. Scanning...")
        case .poweredOff:
            print("Bluetooth is turned off.")
        case .unauthorized:
            print("Bluetooth permissions not granted.")
        case .unsupported:
            print("Bluetooth not supported on this device.")
        case .resetting:
            print("Bluetooth is resetting.")
        case .unknown:
            print("Bluetooth state is unknown.")
        @unknown default:
            print("Unhandled Bluetooth state.")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
            print("Discovered: \(peripheral.name ?? "Unknown Device")")
        }
    }

    func connectToDevice(_ peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self // Assign delegate before connecting
        centralManager.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown Device")")
        peripheral.discoverServices(nil) // Discover services
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown Device"). Error: \(error?.localizedDescription ?? "Unknown error")")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unknown Device"). Error: \(error?.localizedDescription ?? "No error")")
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        for service in peripheral.services ?? [] {
            print("Discovered service: \(service.uuid)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        for characteristic in service.characteristics ?? [] {
            print("Discovered characteristic: \(characteristic.uuid)")
        }
    }
}
