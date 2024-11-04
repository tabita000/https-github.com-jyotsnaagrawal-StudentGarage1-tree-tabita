//
//  LoginView.swift
//  StudentGarage1
//
//  Created by student on 9/29/24.
//
import SwiftUI
import AVKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import AuthenticationServices
import AppTrackingTransparency


// VideoPlayerViewModel to manage the AVPlayer instance
class VideoPlayerViewModel: ObservableObject {
    @Published var videoPlayer: AVPlayer?

    init() {
        if let videoURL = Bundle.main.url(forResource: "carVideo", withExtension: "mp4") {
            videoPlayer = AVPlayer(url: videoURL)
            videoPlayer?.actionAtItemEnd = .none
            
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: videoPlayer?.currentItem,
                queue: .main
            ) { [weak self] _ in
                self?.videoPlayer?.seek(to: .zero)
                self?.videoPlayer?.play()
            }
        } else {
            print("Error: Video file 'carVideo.mp4' not found in the bundle.")
        }
    }
}

struct ContentView: View {
    // State variables for login and navigation
    @State private var email = ""
    @State private var password = ""
    @State private var adminPassword = ""
    @State private var isAdmin = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false
    @State private var isAdminLoggedIn = false
    @State private var bounceOffset: CGFloat = -UIScreen.main.bounds.width

    @State private var isResetPassword = false
    @State private var resetEmail = ""
    @StateObject private var viewModel = VideoPlayerViewModel()
    let adminAccessPassword = "YourAdminPassword123"

    var body: some View {
        if isAdminLoggedIn {
            AdminDashboardView()
                .onAppear {
                    privacyPopUp()
                }
        } else if isLoggedIn {
            MainTabView()
                .onAppear {
                    privacyPopUp()
                }
        } else {
            loginView
        }
    }

    // Login form view

    private var loginView: some View {
        ZStack {
            Color(red: 253/255, green: 186/255, blue: 49/255)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack(spacing: 10) {
                    Image("MCC_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                    
                    Text("STUDENT GARAGE")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.29, green: 0.19, blue: 0.56))
                        .shadow(color: .gray, radius: 2, x: 1, y: 1)
                }
                .offset(x: bounceOffset)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0)) {
                        bounceOffset = 20
                    }
                    withAnimation(Animation.easeOut(duration: 0.5).delay(1.0)) {
                        bounceOffset = -20
                    }
                    withAnimation(Animation.easeOut(duration: 0.3).delay(1.5)) {
                        bounceOffset = 0
                    }
                }
                .padding(.top, 50)
                
                if let videoPlayer = viewModel.videoPlayer {
                    VideoPlayer(player: videoPlayer)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .onAppear {
                            videoPlayer.play()
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                } else {
                    Text("Video unavailable")
                        .foregroundColor(.red)
                        .padding()
                }
                
                loginForm
                
                Spacer()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // Login form subview
    private var loginForm: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 20)
            
            Toggle("Admin", isOn: $isAdmin)
                .padding(.horizontal, 20)
            
            if isAdmin {
                SecureField("Admin Password", text: $adminPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)
            }
            
            HStack(spacing: 33) {
                Button(action: login) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(red: 74/255, green: 49/255, blue: 144/255))
                        .cornerRadius(10)
                }
                
                Button(action: createAccount) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(red: 74/255, green: 49/255, blue: 144/255))
                        .cornerRadius(10)
                }
            }
            .padding(.top, 20)

            // Google Login Button
            Button(action: {
                // Action for logging in with Google
            }) {
                HStack {
                    Image("google") // Your Google icon asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text("Sign in with Google")
                        .font(.headline)
                        .foregroundColor(Color(red: 74/255, green: 49/255, blue: 144/255))
                        .padding(.vertical, 12)
                }
                .padding(.horizontal, 20)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            
//            // Apple Sign In Button
//            SignInWithAppleButton(
//                onRequest: { request in
//                    request.requestedScopes = [.fullName, .email]
//                },
//                onCompletion: { result in
//                    switch result {
//                    case .success(let authResults):
//                        if let credential = authResults.credential as? ASAuthorizationAppleIDCredential,
//                           let appleIDToken = credential.identityToken,
//                           let tokenString = String(data: appleIDToken, encoding: .utf8) {
//                        
//                            // Sign in with Firebase
//                            let authCredential = OAuthProvider.credential(providerID: "apple.com", idToken: tokenString, accessToken: nil)
//
//                            Auth.auth().signIn(with: authCredential) { authResult, error in
//                                if let error = error {
//                                    alertMessage = error.localizedDescription
//                                    showingAlert = true
//                                } else {
//                                    // User is signed in with Apple
//                                    isLoggedIn = true
//                                }
//                            }
//                        } else {
//                            alertMessage = "Apple sign-in failed. Unable to retrieve token."
//                            showingAlert = true
//                        }
//                        
//                    case .failure(let error):
//                        alertMessage = error.localizedDescription
//                        showingAlert = true
//                    }
//                }
//            )
//            .frame(height: 50)
//            .padding(.horizontal, 60)
//            .cornerRadius(10)
            
            
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        if let credential = authResults.credential as? ASAuthorizationAppleIDCredential,
                           let appleIDToken = credential.identityToken,
                           let tokenString = String(data: appleIDToken, encoding: .utf8) {

                            // Sign in with Firebase
                        
                            let authCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, accessToken: nil)


                            Auth.auth().signIn(with: authCredential) { authResult, error in
                                if let error = error {
                                    alertMessage = error.localizedDescription
                                    showingAlert = true
                                } else {
                                    // User is signed in with Apple
                                    isLoggedIn = true
                                }
                            }
                        } else {
                            alertMessage = "Apple sign-in failed. Unable to retrieve token."
                            showingAlert = true
                        }
                        
                    case .failure(let error):
                        alertMessage = error.localizedDescription
                        showingAlert = true
                    }
                }
            )
            .frame(height: 50)
            .padding(.horizontal, 60)
            .cornerRadius(10)


            
            // Add Forgot Password Button
            Button(action: { isResetPassword = true }) {
                Text("Forgot Password?")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.top, 20)
            }
        }
        .padding(.bottom, 50)
        .sheet(isPresented: $isResetPassword) {
            ResetPasswordView(email: $resetEmail)
        }
    }
    
    // Login function
    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showingAlert = true
                return
            }
            
            guard let user = result?.user else { return }
            
            if isAdmin {
                let db = Firestore.firestore()
                db.collection("admins").document(user.uid).getDocument { document, error in
                    if let document = document, document.exists {
                        isAdminLoggedIn = true
                    } else {
                        alertMessage = "Admin access not found!"
                        showingAlert = true
                    }
                }
            } else {
                let dbRef = Database.database().reference()
                dbRef.child("users").child(user.uid).observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists() {
                        isLoggedIn = true
                    } else {
                        dbRef.child("users").child(user.uid).setValue(["email": email]) { error, _ in
                            if let error = error {
                                alertMessage = error.localizedDescription
                                showingAlert = true
                            } else {
                                isLoggedIn = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Create account function
    private func createAccount() {
        if isAdmin {
            guard adminPassword == adminAccessPassword else {
                alertMessage = "Invalid admin password!"
                showingAlert = true
                return
            }
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showingAlert = true
                return
            }
            // Successfully created user
            if isAdmin {
                // Store admin details in Firestore
                let db = Firestore.firestore()
                if let user = result?.user {
                    db.collection("admins").document(user.uid).setData(["email": email]) { error in
                        if let error = error {
                            alertMessage = error.localizedDescription
                        } else {
                            alertMessage = "Admin account created!"
                        }
                        showingAlert = true
                    }
                }
            } else {
                // Store user details in Realtime Database
                let dbRef = Database.database().reference()
                if let user = result?.user {
                    dbRef.child("users").child(user.uid).setValue(["email": email]) { error, _ in
                        if let error = error {
                            alertMessage = error.localizedDescription
                        } else {
                            alertMessage = "User account created!"
                        }
                        showingAlert = true
                    }
                }
            }
        }
    }
}


private func privacyPopUp() {
    ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
        switch status {
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            break
        @unknown default:
            break
        }
    })
}


// Reset Password View
struct ResetPasswordView: View {
    @Binding var email: String
    @Environment(\.presentationMode) var presentationMode
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            Text("Reset Password")
                .font(.largeTitle)
                .padding()
            
            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: resetPassword) {
                Text("Send Reset Link")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                    presentationMode.wrappedValue.dismiss()
                }))
            }
        }
        .padding()
    }
    
    private func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "Password reset link sent to \(email)"
            }
            showingAlert = true
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
