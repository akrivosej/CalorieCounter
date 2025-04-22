//
//  SubscriptionView.swift
//  AINutritionist
//
//  Created by muser on 31.03.2025.
//

import SwiftUI
import AppsFlyerLib
import TelemetryDeck

struct SubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @ObservedObject var authMain: AuthMain
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isPresentWebViewTerms = false
    @State private var isPresentWebViePrivacy = false
    
    var onTap: (() -> Void)?
    var onConfirmTap: (() -> Void)?
    var onRestoreTap: (() -> Void)?
    
    var body: some View {
        ZStack {
            VStack(alignment: .trailing) {
                Button {
                    onTap?()
                } label: {
                    Image(.closeButton)
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 50, height: 50, alignment: .trailing)
                
                VStack {
                    Text("Get unlimited access")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.custom("D-DIN-PRO-SemiBold", size: 36))
                        .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                        .padding(.top, 32)
                    
                    if viewModel.packages.count >= 2 {
                        HStack {
                            // Годовая подписка (пакет с индексом 0)
                            SubscriptionOption(
                                title: "12 months",
                                price: viewModel.packages[0].storeProduct.localizedPriceString,
                                isSelected: viewModel.selectedPackageIndex == 0
                            )
                            .onTapGesture {
                                viewModel.selectedPackageIndex = 0
                            }
                            
                            // Месячная подписка (пакет с индексом 1)
                            SubscriptionOption(
                                title: "1 months",
                                price: viewModel.packages[1].storeProduct.localizedPriceString,
                                isSelected: viewModel.selectedPackageIndex == 1
                            )
                            .onTapGesture {
                                viewModel.selectedPackageIndex = 1
                            }
                        }
                        .padding(18)
                    } else {
                        // Fallback для отображения заглушек, если пакеты еще не загружены
                        HStack {
                            SubscriptionOption(title: "12 months", price: "34.99$/year", isSelected: viewModel.selectedPackageIndex == 0)
                                .onTapGesture {
                                    viewModel.selectedPackageIndex = 0
                                }
                            
                            SubscriptionOption(title: "1 months", price: "5.99$/months", isSelected: viewModel.selectedPackageIndex == 1)
                                .onTapGesture {
                                    viewModel.selectedPackageIndex = 1
                                }
                        }
                        .padding(18)
                    }

                    HStack {
                        Image(.okIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text("Smart Calorie Tracking")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom("D-DIN-PRO-Regular", size: 18))
                            .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    }
                    .padding(.horizontal, 18)
                    
                    HStack {
                        Image(.okIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text("Easily Add Meals with Your Camera")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom("D-DIN-PRO-Regular", size: 18))
                            .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    }
                    .padding(.horizontal, 18)
                    
                    HStack {
                        Image(.okIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        Text("Achieve Your Dream Body")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.custom("D-DIN-PRO-Regular", size: 18))
                            .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    }
                    .padding(.horizontal, 18)
                    
                    // Кнопка покупки
                    Button {
                        viewModel.purchaseSelectedPackage { success in
                            if success {
                                onConfirmTap?()
                            }
                        }
                        if !authMain.email.isEmpty {
                            AppsFlyerLib.shared().logEvent(name: "subscription_button_tap",
                                                           values: [
                                                            "screen": "subscription_view",
                                                            "action": "confirm_purchase",
                                                            "email": authMain.email
                                                           ])
                            print("Подтверждение покупки для користувача з ID: \(authMain.email)")
                        } else {
                            print("Не вдалося отримати userID")
                        }
                    } label: {
                        Text("Get")
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity)
                            .font(.custom("D-DIN-PRO-Bold", size: 26))
                            .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                    }
                    .background(Color.init(red: 4/255, green: 212/255, blue: 132/255))
                    .cornerRadius(32)
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    
                    Button {
                        viewModel.restorePurchases { success in
                            if success {
                                onRestoreTap?()
                            }
                        }
                    } label: {
                        Text("Restore Purchases")
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity)
                            .font(.custom("D-DIN-PRO-Bold", size: 26))
                            .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                    }
                    .background(Color.init(red: 4/255, green: 212/255, blue: 132/255))
                    .cornerRadius(32)
                    .padding(.horizontal, 18)
                    .padding(.top, 4)
                    
                    Text("Cancel anytime")
                        .frame(maxWidth: .infinity)
                        .font(.custom("D-DIN-PRO-Regular", size: 18))
                        .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                        .padding(.bottom, 8)
                    
                    HStack(spacing: 18) {
                        Spacer()
                        Button {
                            isPresentWebViePrivacy = true
                        } label: {
                            Text("Privacy policy")
//                                .frame(maxWidth: .infinity)
                                .font(.custom("D-DIN-PRO-SemiBold", size: 18))
                                .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                                .underline()
                        }
                        .sheet(isPresented: $isPresentWebViePrivacy) {
                            NavigationStack {
                                WebView(url: URL(string: "https://sites.google.com/view/eatifyai/privacy-policy")!)
                                    .ignoresSafeArea()
                                    .navigationTitle("Privacy Policy")
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                        }
                        
                        Button {
                            isPresentWebViewTerms = true
                        } label: {
                            Text("Terms of use")
//                                .frame(maxWidth: .infinity)
                                .font(.custom("D-DIN-PRO-SemiBold", size: 18))
                                .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                                .underline()
                        }
                        .sheet(isPresented: $isPresentWebViewTerms) {
                            NavigationStack {
                                WebView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                    .ignoresSafeArea()
                                    .navigationTitle("Terms of use")
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                        }
                        Spacer()
                    }
                    .padding(.bottom, 18)
                }
                .background(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                .cornerRadius(32)
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.init(red: 34/255, green: 34/255, blue: 34/255, opacity: 0.6))
            
            // Индикатор загрузки
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.4))
                            .frame(width: 100, height: 100)
                    )
            }
        }
        .onAppear {
            viewModel.loadSubscriptions()
            TelemetryDeck.signal("SubscriptionView.load")
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

// Расширение для отображения алертов
extension SubscriptionViewModel {
    func showAlert(title: String, message: String) {
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowSubscriptionAlert"),
            object: nil,
            userInfo: ["title": title, "message": message]
        )
    }
}


extension SubscriptionView {
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowSubscriptionAlert"),
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let title = userInfo["title"] as? String,
                  let message = userInfo["message"] as? String else {
                return
            }
            
            alertTitle = title
            alertMessage = message
            showAlert = true
        }
    }
}

//struct SubscriptionView: View {
//    @State private var selectedIndex: Int = 0
//    var onTap: (() -> Void)?
//    var onConfirmTap: (() -> Void)?
//    
//    var body: some View {
//        VStack(alignment: .trailing) {
//            Button {
//                onTap?()
//            } label: {
//                Image(.closeButton)
//                    .resizable()
//                    .scaledToFit()
//            }
//            .frame(width: 50, height: 50, alignment: .trailing)
//            
//            VStack {
//                Text("Get unlimited access")
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .font(.custom("D-DIN-PRO-SemiBold", size: 36))
//                    .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
//                    .padding(.top, 32)
//                
//                HStack {
//                    SubscriptionOption(title: "12 months", price: "34.99$/year", isSelected: selectedIndex == 0)
//                        .onTapGesture {
//                            selectedIndex = 0
//                        }
//                    
//                    SubscriptionOption(title: "6 months", price: "5.99$/months", isSelected: selectedIndex == 1)
//                        .onTapGesture {
//                            selectedIndex = 1
//                        }
//                }
//                .padding(18)
//                
//                HStack {
//                    Image(.okIcon)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 30, height: 30)
//                    Text("Smart Calorie Tracking")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .font(.custom("D-DIN-PRO-Regular", size: 18))
//                        .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
//                }
//                .padding(.horizontal, 18)
//                
//                HStack {
//                    Image(.okIcon)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 30, height: 30)
//                    Text("Easily Add Meals with Your Camera")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .font(.custom("D-DIN-PRO-Regular", size: 18))
//                        .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
//                }
//                .padding(.horizontal, 18)
//                
//                HStack {
//                    Image(.okIcon)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 30, height: 30)
//                    Text("Achieve Your Dream Body")
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .font(.custom("D-DIN-PRO-Regular", size: 18))
//                        .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
//                }
//                .padding(.horizontal, 18)
//                
//                
//                Button {
//                    print(selectedIndex)
//                    onConfirmTap?()
//                } label: {
//                    Text("Get")
//                        .padding(.vertical, 18)
//                        .frame(maxWidth: .infinity)
//                        .font(.custom("D-DIN-PRO-Bold", size: 26))
//                        .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
//                }
//                .background(Color.init(red: 4/255, green: 212/255, blue: 132/255))
//                .cornerRadius(32)
//                .padding(.horizontal, 18)
//                .padding(.top, 18)
//                
//                Text("Cancel anytime")
//                    .frame(maxWidth: .infinity)
//                    .font(.custom("D-DIN-PRO-Regular", size: 18))
//                    .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
//                    .padding(.bottom, 18)
//            }
//            .background(Color.init(red: 235/255, green: 243/255, blue: 241/255))
//            .cornerRadius(32)
//
//        }
//        .padding(.horizontal, 18)
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.init(red: 34/255, green: 34/255, blue: 34/255, opacity: 0.6))
//        .onAppear {
//            TelemetryDeck.signal("SubscriptionView.load")
//        }
//    }
//}

#Preview {
    SubscriptionView(authMain: .init())
}


struct SubscriptionOption: View {
    var title: String
    var price: String
    var isSelected: Bool

    var body: some View {
        VStack {
            Text(title)
                .frame(maxWidth: .infinity)
                .font(.custom("D-DIN-PRO-SemiBold", size: 28))
                .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
            
            Text(price)
                .frame(maxWidth: .infinity)
                .font(.custom("D-DIN-PRO-Medium", size: 20))
                .foregroundStyle(Color.init(red: 86/255, green: 86/255, blue: 86/255))
        }
        .padding(18)
        .padding(.vertical, 12)
        .background(isSelected
                    ? Color.init(red: 200/255, green: 246/255, blue: 228/255)
                    : Color.init(red: 235/255, green: 243/255, blue: 241/255)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected
                        ? Color.init(red: 34/255, green: 34/255, blue: 34/255)
                        : Color.init(red: 138/255, green: 138/255, blue: 138/255),
                        lineWidth: isSelected ? 2 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .cornerRadius(12)
    }
}
