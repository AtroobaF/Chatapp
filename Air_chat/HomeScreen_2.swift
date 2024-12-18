import Foundation
import SwiftUI
import CoreBluetooth
import UIKit

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    @Published var discoveredPeripherals: [CBPeripheral] = []
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            // Handle Bluetooth off or unavailable
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
    }
    
    func pairWithDevice(_ peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
}

struct HomeScreen_2: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    @State private var isPopoverPresented = false
    @State private var typedMessage: String = "" // Stores the typed message
    @State private var messages: [Message] = []   // List of sent messages
    @State private var isCameraPresented = false
    @State private var isPhotosPresented = false
    @State private var capturedImage: UIImage? = nil
    var userName: String
    
    var body: some View {
        NavigationView {
            VStack {
                // Display the user's name
                Text("Welcome, \(userName)")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding()

                Text("Chat")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Display sent messages
                List(messages, id: \.id) { message in
                    if let image = message.image {
                        // Display image message
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .cornerRadius(8)
                            .padding(8)
                    } else {
                        // Display text message
                        Text(message.text)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom)

                Spacer()
                
                // Bottom Text Bar and Buttons
                HStack {
                    Button(action: {
                        isPopoverPresented.toggle()
                    }) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                            .font(.title2)
                    }
                    .overlay(
                        Group {
                            if isPopoverPresented {
                                VStack(alignment: .leading, spacing: 16) {
                                    // Camera Button
                                    Button(action: {
                                        isCameraPresented.toggle()
                                    }) {
                                        HStack {
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(.blue)
                                                .font(.title2)
                                            Text("Camera")
                                                .font(.headline)
                                            Spacer()
                                        }
                                    }
                                    
                                    // Photos Button
                                    Button(action: {
                                        isPhotosPresented.toggle()
                                    }) {
                                        HStack {
                                            Image(systemName: "photo.fill")
                                                .foregroundColor(.green)
                                                .font(.title2)
                                            Text("Photos")
                                                .font(.headline)
                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .shadow(radius: 8)
                                .frame(width: 180)
                                .offset(x: 70, y: -80)
                                .transition(.move(edge: .bottom))
                            }
                        }
                    )
                    
                    TextField("Type a message", text: $typedMessage)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity)

                    Button(action: {
                        if !typedMessage.isEmpty {
                            messages.append(Message(id: UUID(), text: typedMessage, image: nil)) // Add the typed message
                            typedMessage = ""  // Clear the input field
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 8)
                }
                .padding()
            }
            .onAppear {
                bluetoothManager.startScanning()
            }
            .onDisappear {
                bluetoothManager.stopScanning()
            }
            .background(Color(.systemBackground))
            
            // Camera Picker
            .sheet(isPresented: $isCameraPresented) {
                CameraPicker(isPresented: $isCameraPresented) { image in
                    capturedImage = image
                    if let capturedImage = capturedImage {
                        messages.append(Message(id: UUID(), text: "", image: capturedImage))
                    }
                }
            }

            // Photos Picker
            .sheet(isPresented: $isPhotosPresented) {
                PhotoPicker(isPresented: $isPhotosPresented) { image in
                    capturedImage = image
                    if let capturedImage = capturedImage {
                        messages.append(Message(id: UUID(), text: "", image: capturedImage))
                    }
                }
            }
        }
    }
}

// Message model that holds either a text or an image
struct Message: Identifiable {
    var id: UUID
    var text: String
    var image: UIImage?
}

// Camera Picker for capturing images
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var didCaptureImage: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraPicker
        init(parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.didCaptureImage(image)
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

// Photo Picker for selecting images
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var didPickImage: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: PhotoPicker
        init(parent: PhotoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.didPickImage(image)
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

struct HomeScreen_2_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen_2(userName: "Atrooba")
    }
}
