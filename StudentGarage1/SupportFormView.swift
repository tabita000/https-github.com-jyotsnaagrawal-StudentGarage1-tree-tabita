//
//  Support.swift
//  StudentGarage1
//
//  Created by student on 10/26/24.
//
import SwiftUI
import Firebase

struct SupportFormView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var subject = ""
    @State private var message = ""
    @State private var priority = "Low"
    
    let priorities = ["Low", "Medium", "High"]
    
    var body: some View {
        Form {
            Section(header: Text("Your Information")) {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                TextField("Phone Number", text: $phoneNumber)
            }
            
            Section(header: Text("Support Request")) {
                TextField("Subject", text: $subject)
                Picker("Priority", selection: $priority) {
                    ForEach(priorities, id: \.self) { priority in
                        Text(priority)
                    }
                }
                TextEditor(text: $message)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
            }
            
            Button("Submit") {
                submitSupportRequest()
            }
        }
        .navigationTitle("Support")
    }
    
    private func submitSupportRequest() {
        // Handle the submission logic
    }
}
