//
//  AccountScreen.swift
//  AINutritionist
//
//  Created by muser on 21.03.2025.
//

import SwiftUI
import AppsFlyerLib
import TelemetryDeck

struct AccountScreen: View {
    @ObservedObject var accViewModel: AccountViewModel
    @ObservedObject var viewModel: AuthMain
    @Binding var path: NavigationPath
    @Environment(\ .dismiss) var dismiss
    @State private var showAlert = false
    @State private var isWeightAlertPresented = false
    @State private var isShowSubView: Bool = false
    @State private var newWeight: String = ""
    @State private var currentWeight: String = UserDefaults.standard.string(forKey: "currentWeight") ?? "0"
    let weight = UserDefaults.standard.string(forKey: "weightDataCollection") ?? "0"
    
    init(accViewModel: AccountViewModel, viewModel: AuthMain, path: Binding<NavigationPath>) {
        self.accViewModel = accViewModel
        self.viewModel = viewModel
        self._path = path
    }
    
    var body: some View {
        ZStack {
            VStack {
                Image(.icon2)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(24)
                    .padding(.horizontal, 100)
                
                Text(viewModel.currentuser?.name ?? "")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.custom("D-DIN-PRO-Regular", size: 28))
                    .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
                
                HStack {
                    HStack {
                        Image(.kgIcon)
                            .resizable()
                            .scaledToFit()
                            .padding(14)
                            .background(Color(red: 4/255, green: 212/255, blue: 132/255))
                            .cornerRadius(100)
                        
                        VStack {
                            Text("Current weight")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom("D-DIN-PRO-Regular", size: 12))
                                .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
                            Spacer()
                            HStack(alignment: .bottom, spacing: 0) {
                                Text(currentWeight)
                                    .font(.custom("D-DIN-PRO-SemiBold", size: 28))
                                    .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
                                Text("kg")
                                    .font(.custom("D-DIN-PRO-SemiBold", size: 18))
                                    .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(6)
                    .background(.white)
                    .cornerRadius(100)
                    .frame(maxHeight: 80)
                    .onTapGesture {
                        isWeightAlertPresented = true
                    }
                    
                    AccountItem(title: "Start weight", value: weight, target: true, minus: "")
                        .frame(maxHeight: 80)
                }
                .padding(.top, 24)
                
                Button {
                    TelemetryDeck.signal("AccountScreen.onTapGetUnlimitedAccessButton")
                    isShowSubView = true
                } label: {
                    Text("Get unlimited Access")
                        .padding(.vertical, 18)
                        .frame(maxWidth: .infinity)
                        .font(.custom("D-DIN-PRO-Bold", size: 26))
                        .foregroundStyle(Color(red: 235/255, green: 243/255, blue: 241/255))
                        .font(.system(size: 28, weight: .medium, design: .default))
                }
                .background(Color(red: 4/255, green: 212/255, blue: 132/255))
                .cornerRadius(32)
                .padding(.top, 24)
                
                Spacer()
                Spacer()
                
                Button {
                    viewModel.signOut()
//                    dismiss()
                    path.removeLast(path.count - 1)
                } label: {
                    Text("Log out")
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                        .font(.custom("D-DIN-PRO-Bold", size: 26))
                }
                .background(Color.init(red: 245/255, green: 78/255, blue: 0/255))
                .cornerRadius(24)
                
                Button {
                    showAlert = true
                } label: {
                    Text("Delete account")
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                        .font(.custom("D-DIN-PRO-Bold", size: 26))
                }
                .background(Color.init(red: 245/255, green: 78/255, blue: 0/255))
                .cornerRadius(24)
                .alert("Are you sure?", isPresented: $showAlert) {
                    Button("Delete", role: .destructive) {
                        viewModel.deleteUserAccount { result in
                            switch result {
                            case .success():
                                print("Account deleted successfully.")
                                viewModel.userSession = nil
                                viewModel.currentuser = nil
                                UserDefaults.standard.set("0", forKey: "currentWeight")
                                accViewModel.deleteAcc()
                                path.removeLast(path.count - 1)
                            case .failure(let error):
                                print("ERROR DELETING: \(error.localizedDescription)")
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you want to delete the account?")
                }
                
                Spacer()
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 235/255, green: 243/255, blue: 241/255))
            .alert("Enter your weight", isPresented: $isWeightAlertPresented) {
                VStack {
                    TextField("Weight", text: $newWeight)
                        .keyboardType(.decimalPad)
                    Button("Save") {
                        if let weight = Double(newWeight) {
                            currentWeight = String(format: "%g", weight)
                            UserDefaults.standard.set(currentWeight, forKey: "currentWeight")
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                }
            }
            
            if isShowSubView {
                SubscriptionView(authMain: viewModel) {
                    isShowSubView = false
                } onConfirmTap: {
                    if let userUID = viewModel.userID {
                        AppsFlyerLib.shared().logEvent(name: "subscription_button_tap",
                                                       values: [
                                                        "screen": "subscription_view",
                                                        "action": "confirm_purchase",
                                                        "user_id": userUID
                                                       ])
                        print("Подтверждение покупки для користувача з ID: \(userUID)")
                    } else {
                        print("Не вдалося отримати userID")
                    }
                } onRestoreTap: {
                    print("onRestoreTap")
                }
            }

        }
        .animation(.easeInOut, value: isShowSubView)
        .onAppear {
            TelemetryDeck.signal("AccountScreen.load")
        }
    }
}


#Preview {
    AccountScreen(accViewModel: .init(), viewModel: .init(), path: .constant(.init()))
}

struct AccountItem: View {
    let title: String
    let value: String
    let target: Bool
    let minus: String
    
    var body: some View {
        HStack {
            Image(.kgIcon)
                .resizable()
                .scaledToFit()
                .padding(14)
                .background(target
                            ? Color.init(red: 255/255, green: 184/255, blue: 84/255)
                            : Color.init(red: 4/255, green: 212/255, blue: 132/255)
                )
                .cornerRadius(100)
            
            VStack {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("D-DIN-PRO-Regular", size: 12))
                    .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    Text(value)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.custom("D-DIN-PRO-SemiBold", size: 28))
                        .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    Text("kg")
                        .frame(alignment: .bottom)
                        .font(.custom("D-DIN-PRO-SemiBold", size: 18))
                        .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    Text(minus)
                        .frame(alignment: .top)
                        .font(.custom("D-DIN-PRO-SemiBold", size: 12))
                        .foregroundStyle(Color.init(red: 4/255, green: 212/255, blue: 132/255))
                        .padding(.leading, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(6)
        .background(.white)
        .cornerRadius(100)
    }
}
