import SwiftUI

struct ContentView: View {
    @State private var userName: String = ""
    @State private var email: String = ""
    @State private var isNavigationActive = false // To trigger navigation

    var body: some View {
        NavigationView {
            VStack {
                // "Register" Text centered at the top
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 130)

                // Text Field to enter the user's name
                TextField("Enter your name", text: $userName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 250)
                    .padding(.bottom, 50)

        
                // Button to navigate to the next screen
                NavigationLink(
                    destination:
                        HomeScreen_2(userName: userName))
                {
//                            if !userName.isEmpty && !email.isEmpty {
//                                isNavigationActive = true
                            Text("Register")
                                .frame(width: 250, height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.top, 20)
                        }
                    }
            .offset(y: -100)
                            }
            .navigationBarHidden(true) // Optionally hide the navigation bar on the register page
        }
    }



#Preview {
    ContentView()
}
