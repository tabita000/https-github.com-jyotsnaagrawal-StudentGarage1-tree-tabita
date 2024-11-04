//
//  AdminDashboardView.swift
//  StudentGarage1
//
//  Created by student on 10/7/24.
//

import SwiftUI
import Firebase
import FirebaseAuth 


// Define the Booking struct to represent booking information
struct Booking: Identifiable, Hashable {
    let id: String // Unique identifier for each booking
    let name: String // Name of the person who made the booking
    let address: String // Address related to the booking
    let city: String // City related to the booking
    let phoneNumber: String // Contact phone number for the booking
    let vehicleMake: String // The make of the vehicle (e.g., Toyota, Ford)
    let vehicleModel: String // The model of the vehicle (e.g., Corolla, Mustang)
    let vehicleYear: String // The year of the vehicle's manufacture
    let vinNumber: String // The Vehicle Identification Number (VIN) for the vehicle
    let mileage: String // Mileage of the vehicle at the time of the booking
    let complaint: String // Description of the issue or service request
    let date: String // Date the booking was made
}


struct AdminDashboardView: View {
    @State private var bookings: [Booking] = []
    @State private var isLoggedOut = false // State to track if the user is logged out

    var body: some View {
        if isLoggedOut {
            // Navigate to LoginView when logged out
            ContentView()
        } else {
            NavigationView {
                VStack {
                    Text("Admin Dashboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()

                    Section(header: Text("Booking Submissions").font(.headline)) {
                        List(bookings) { booking in
                            NavigationLink(destination: BookingDetailView(booking: booking)) {
                                VStack(alignment: .leading) {
                                    Text("Name: \(booking.name)")
                                    Text("Date: \(booking.date)")
                                }
                                .padding(.vertical)
                            }
                        }
                    }
                    .padding()

                    Spacer()
                }
                .onAppear(perform: fetchBookings)
                .navigationTitle("Admin Dashboard")
                .navigationBarItems(trailing: Button(action: logout) {
                    Text("Logout")
                        .foregroundColor(.red)
                })
                .padding()
            }
        }
    }

    private func fetchBookings() {
        let db = Database.database().reference().child("bookings")
        db.observe(.value) { snapshot in
            var fetchedBookings: [Booking] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let bookingData = snapshot.value as? [String: Any],
                   let name = bookingData["name"] as? String,
                   let address = bookingData["address"] as? String,
                   let city = bookingData["city"] as? String,
                   let phoneNumber = bookingData["phoneNumber"] as? String,
                   let vehicleMake = bookingData["vehicleMake"] as? String,
                   let vehicleModel = bookingData["vehicleModel"] as? String,
                   let vehicleYear = bookingData["vehicleYear"] as? String,
                   let vinNumber = bookingData["vinNumber"] as? String,
                   let mileage = bookingData["mileage"] as? String,
                   let complaint = bookingData["complaint"] as? String,
                   let date = bookingData["date"] as? String {
                    let id = snapshot.key
                    let booking = Booking(id: id, name: name, address: address, city: city, phoneNumber: phoneNumber, vehicleMake: vehicleMake, vehicleModel: vehicleModel, vehicleYear: vehicleYear, vinNumber: vinNumber, mileage: mileage, complaint: complaint, date: date)
                    fetchedBookings.append(booking)
                }
            }
            self.bookings = fetchedBookings
        }
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            self.isLoggedOut = true // Update the state to log out
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}
