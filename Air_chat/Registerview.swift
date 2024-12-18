//
//  RegisterView 2.swift
//  Air_chat
//
//  Created by Atrooba Fahim on 16/12/24.
//


import SwiftUI

struct RegisterView: View {
    @State private var userName: String = "" // Variable to store the user's name

    var body: some View {
        ZStack {
            // Background and content
            VStack {
                // "Register" Text centered at the top
                Text("Sign up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 130)

                // Text Field to enter the user's name
                TextField("Enter your name", text: $userName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 250) // Adjust the width of the text field
                    .padding(.bottom, 50) // Add space below the text field

                // Spacer to push the content to the top
                Spacer()

            }

            // Done Button at the top right corner
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // Action for the Done button
                        print("Registration completed!")
                    }) {
                        Text("Done")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Make the view fill the entire screen
        .background(Color.white) // Background color
        .padding() // Padding around the edges of the view
    }
}

#Preview{
RegisterView()
    }
