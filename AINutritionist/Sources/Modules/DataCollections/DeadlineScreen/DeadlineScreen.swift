//
//  DeadlineScreen.swift
//  AINutritionist
//
//  Created by muser on 19.03.2025.
//

import SwiftUI
import TelemetryDeck
import AppsFlyerLib
import RevenueCat

struct DeadlineScreen: View {
    @ObservedObject var authMain: AuthMain
    @State private var selectedDate = Date()
    @State private var isPresented = false
    @State private var showSubscription = false
    
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    init(authMain: AuthMain, path: Binding<NavigationPath>) {
        self.authMain = authMain
        self._path = path
    }
    
    var body: some View {
        ZStack {
            VStack {
                SegmentedProgressBar(currentSegment: 8)
                    .padding(.top, 24)
                
                Text("Deadline - set your date when you want your body to be perfect")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("D-DIN-PRO-ExtraBold", size: 38))
                    .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    .padding(.top, 24)
                Spacer()
                Text(selectedDate.formatted(.dateTime.day().month().year()))
                    .font(.custom("D-DIN-PRO-Regular", size: 70))
                    .foregroundStyle(Color.init(red: 4/255, green: 212/255, blue: 132/255))
                    .onTapGesture {
                        isPresented.toggle()
                    }
                    .sheet(isPresented: $isPresented) {
                        DatePicker("Select date", selection: $selectedDate, in: Date()...Calendar.current.date(byAdding: .year, value: 3, to: Date())!,
                                   displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .padding()
                    }
                
                Spacer()
                HStack(spacing: 24) {
                    Button {
                        dismiss()
                    } label: {
                        Image(.arrow)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    }
                    
                    Button {
                        checkSubscriptionAndProceed()
//                        path.append(Router.dataProcessing)
                    } label: {
                        Text("Next")
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .font(.custom("D-DIN-PRO-Bold", size: 26))
                            .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                    }
                    .background(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    .cornerRadius(32)
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.init(red: 235/255, green: 243/255, blue: 241/255))
            
//             Показываем экран подписки при необходимости
            if showSubscription {
                SubscriptionView(
                    authMain: authMain, onTap: {
                        // Закрыть экран подписки
                        showSubscription = false
                    },
                    onConfirmTap: {
                        // Подписка успешно оформлена, переходим на следующий экран
                        showSubscription = false
                        proceedToNextScreen()
                    },
                    onRestoreTap: {
                        showSubscription = false
                        proceedToNextScreen()
                    }
                )
            }
        }
        .onAppear {
            TelemetryDeck.signal("DeadlineScreen.load")
            
//             Добавляем слушателя для отслеживания изменений подписки
            setupSubscriptionObserver()
        }
    }
    
    // Настраиваем наблюдателя за изменениями подписки
    private func setupSubscriptionObserver() {
        // Наблюдаем за успешно завершенными покупками
        NotificationCenter.default.addObserver(
            forName: Notification.Name("PurchaseCompletedNotification"),
            object: nil,
            queue: .main
        ) { _ in
            proceedToNextScreen()
        }
    }
    
    private func checkSubscriptionAndProceed() {
        print("DEBUG: Проверяем статус подписки...")
            
        SubscriptionManager.shared.checkPremiumAccess { hasPremium in
            print("DEBUG: Результат проверки премиум-доступа: \(hasPremium)")
            
            DispatchQueue.main.async {
                if hasPremium {
                    print("DEBUG: У пользователя есть премиум, переходим на следующий экран")
                    proceedToNextScreen()
                } else {
                    print("DEBUG: У пользователя нет премиума, показываем экран подписки")
                    showSubscription = true
                }
            }
        }
    }
        
    private func proceedToNextScreen() {
        print("DEBUG: Переходим на следующий экран")
        // Сохраняем выбранную дату дедлайна
        UserDefaults.standard.set(selectedDate.timeIntervalSince1970, forKey: "deadline")
        // Переходим на следующий экран
        path.append(Router.dataProcessing)
        print("DEBUG: Перешли на экран обработки данных")
    }
}

//struct DeadlineScreen: View {
//    @State private var selectedDate = Date()
//    @State private var isPresented = false
//    @State private var showSubscription = false
//    
//    @Binding var path: NavigationPath
//    @Environment(\.dismiss) var dismiss
//
//    
//    init(path: Binding<NavigationPath>) {
//        self._path = path
//    }
//    
//    var body: some View {
//        ZStack {
//            VStack {
//                SegmentedProgressBar(currentSegment: 8)
//                    .padding(.top, 24)
//                
//                Text("Deadline - set your date when you want your body to be perfect")
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .font(.custom("D-DIN-PRO-ExtraBold", size: 38))
//                    .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
//                    .padding(.top, 24)
//                Spacer()
//                Text(selectedDate.formatted(.dateTime.day().month().year()))
//                    .font(.custom("D-DIN-PRO-Regular", size: 70))
//                    .foregroundStyle(Color.init(red: 4/255, green: 212/255, blue: 132/255))
//                    .onTapGesture {
//                        isPresented.toggle()
//                    }
//                    .sheet(isPresented: $isPresented) {
//                        DatePicker("Select date", selection: $selectedDate, in: Date()...Calendar.current.date(byAdding: .year, value: 3, to: Date())!,
//                                   displayedComponents: .date)
//                        .datePickerStyle(.wheel)
//                        .labelsHidden()
//                        .padding()
//                    }
//                
//                Spacer()
//                HStack(spacing: 24) {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Image(.arrow)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30, height: 30)
//                            .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
//                    }
//                    
//                    Button {
////                        path.append(Router.dataProcessing)
////                        UserDefaults.standard.set(selectedDate.timeIntervalSince1970, forKey: "deadline")
//                    checkSubscriptionAndProceed()
//                    } label: {
//                        Text("Next")
//                            .padding(.vertical, 16)
//                            .frame(maxWidth: .infinity)
//                            .font(.custom("D-DIN-PRO-Bold", size: 26))
//                            .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
//                    }
//                    .background(Color.init(red: 34/255, green: 34/255, blue: 34/255))
//                    .cornerRadius(32)
//                }
//                .padding(.bottom, 32)
//            }
//            .padding(.horizontal, 18)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color.init(red: 235/255, green: 243/255, blue: 241/255))
//            
//            if showSubscription {
//                SubscriptionView(
//                    onTap: {
//                        showSubscription = false
//                    },
//                    onConfirmTap: {
//                        showSubscription = false
//                        proceedToNextScreen()
//                    }
//                )
//            }
//        }
//        .onAppear {
//            TelemetryDeck.signal("DeadlineScreen.load")
//        }
//    }
//    
//    private func checkSubscriptionAndProceed() {
//        SubscriptionManager.shared.checkPremiumAccess { hasPremium in
//            if hasPremium {
//                proceedToNextScreen()
//            } else {
//                DispatchQueue.main.async {
//                    showSubscription = true
//                }
//            }
//        }
//    }
//    
//    private func proceedToNextScreen() {
//        UserDefaults.standard.set(selectedDate.timeIntervalSince1970, forKey: "deadline")
//        path.append(Router.dataProcessing)
//    }
//}

#Preview {
    DeadlineScreen(authMain: .init(), path: .constant(.init()))
}

//
//SubscriptionManager.shared.checkPremiumAccess { [weak self] hasPremium in
//    if hasPremium {
//        // У користувача є підписка - показати преміум-контент
//        
//    } else {
//        // У користувача немає підписки - показати стандартний контент
//        
//    }
//}
