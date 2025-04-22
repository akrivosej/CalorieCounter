//
//  RegistrationScreen.swift
//  AINutritionist
//
//  Created by muser on 27.02.2025.
//

import SwiftUI
import AppsFlyerLib
import TelemetryDeck

struct RegistrationScreen: View {
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var name = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var isNotificationShown = false
    @State private var isAlertShown = false
    
    @ObservedObject var viewModel: AuthMain
    
    init(viewModel: AuthMain, path: Binding<NavigationPath>) {
        self.viewModel = viewModel
        self._path = path
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Registration")
                .font(.custom("D-DIN-PRO-Heavy", size: 46))
                .foregroundStyle(.white)
            TextField("", text: $name, prompt: Text("Name").foregroundColor(Color.init(red: 102/255, green: 102/255, blue: 102/255)))
                .font(.custom("D-DIN-PRO-Light", size: 20))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
                .padding(.vertical, 5)
                .foregroundColor(.black)
                .tint(.black)
                .background {
                    Rectangle()
                        .foregroundColor(.white)
                        .cornerRadius(32)
                }
                .padding(.top, 48)
            
            TextField("", text: $email, prompt: Text("Email").foregroundColor(Color.init(red: 102/255, green: 102/255, blue: 102/255)))
                .font(.custom("D-DIN-PRO-Light", size: 20))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
                .padding(.vertical, 5)
                .foregroundColor(.black)
                .tint(.black)
                .background {
                    Rectangle()
                        .foregroundColor(.white)
                        .cornerRadius(32)
                }
            
            SecureField("", text: $password, prompt: Text("Password").foregroundColor(Color.init(red: 102/255, green: 102/255, blue: 102/255)))
                .font(.custom("D-DIN-PRO-Light", size: 20))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
                .padding(.vertical, 5)
                .foregroundColor(.black)
                .tint(.black)
                .background {
                    Rectangle()
                        .foregroundColor(.white)
                        .cornerRadius(32)
                }
            
            SecureField("", text: $confirmPassword, prompt: Text("Confirm password").foregroundColor(Color.init(red: 102/255, green: 102/255, blue: 102/255)))
                .font(.custom("D-DIN-PRO-Light", size: 20))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
                .padding(.vertical, 5)
                .foregroundColor(.black)
                .tint(.black)
                .background {
                    Rectangle()
                        .foregroundColor(.white)
                        .cornerRadius(32)
                }
            
            Button {
                TelemetryDeck.signal("RegistrationScreen.onTapGetstartedButton")
                if isFormValid {
                    Task {
                        do {
                            try await viewModel.createUser(withEmail: email, password: password, name: name)
                            if !viewModel.text.isEmpty {
                                isAlertShown = true
                            }
                        } catch {
                            isAlertShown = true
                        }
                    }
                } else {
                    isNotificationShown.toggle()
                }
//                if isFormValid {
//                    Task {
//                        do {
//                            try await viewModel.createUser(withEmail: email, password: password, name: name)
//                            
//                            if let userUID = viewModel.userID {
//                                let eventValues: [String: Any] = [
//                                    "name": name,
//                                    "email": email,
//                                    "user_id": userUID
//                                ]
//                                
//                                AppsFlyerLib.shared().logEvent("registration_success", withValues: eventValues)
//                            } else {
//                                let eventValues: [String: Any] = [
//                                    "name": name,
//                                    "email": email
//                                ]
//                                
//                                AppsFlyerLib.shared().logEvent("registration_success", withValues: eventValues)
//                            }
//
//                            DispatchQueue.main.async {
//                                path = NavigationPath()
//                            }
//                        } catch {
//                            isAlertShown = true
//                        }
//                    }
//                } else {
//                    isNotificationShown.toggle()
//                }
            } label: {
                Text("Get started")
                    .font(.custom("D-DIN-PRO-Bold", size: 26))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(Color.init(red: 34/255, green: 34/255, blue: 34/255))
            .cornerRadius(32)
            .padding(.top, 32)
            Spacer()
            Button {
                dismiss()
            } label: {
                HStack {
                    Text("Do you already have an account?")
                        .foregroundStyle(Color.init(red: 66/255, green: 66/255, blue: 66/255))
                    Text("Sign in")
                        .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                }
            }
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.init(red: 4/255, green: 212/255, blue: 132/255)
        )
        .onAppear {
            TelemetryDeck.signal("RegistrationScreen.load")
        }
    }
}

#Preview {
    RegistrationScreen(viewModel: .init(), path: .constant(.init()))
}

extension RegistrationScreen: AuthCoreProtocol {
    var isFormValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
    }
}
