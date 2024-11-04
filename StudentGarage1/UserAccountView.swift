//
//  ProfileView.swift
//  StudentGarage1
//
//  Created by student on 10/26/24.
//

import SwiftUI
struct UserAccountView: View {
    var body: some View {
        VStack {
            Image("ProfileImage") // Replace with your converted image name
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                .padding()
            Text("User Name")
                .font(.title)
                .fontWeight(.bold)
            Text("user@example.com")
                .font(.subheadline)
                .foregroundColor(.gray)
            Divider()
            List {
                NavigationLink(destination: SettingsView()) {
                    Text("Account Settings")
                }
                NavigationLink(destination: SupportFormView()) {
                    Text("Repair History")
                }
                // Add more sections as needed
            }
        }
        .navigationBarTitle("Account", displayMode: .inline)
    }
}
struct UserAccountView_Previews: PreviewProvider {
    static var previews: some View {
        UserAccountView() // This is your view name
    }
}



















