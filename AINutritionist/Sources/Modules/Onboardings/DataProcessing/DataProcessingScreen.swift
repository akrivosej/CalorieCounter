//
//  DataProcessingScreen.swift
//  AINutritionist
//
//  Created by muser on 18.03.2025.
//

import SwiftUI
import TelemetryDeck

struct DataProcessingScreen: View {
    @ObservedObject var viewModel: DataProcessingViewModel
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    @State private var isPresented = false
    
    init(viewModel: DataProcessingViewModel, path: Binding<NavigationPath>) {
        self.viewModel = viewModel
        self._path = path
    }
    
    var body: some View {
        VStack {
            SegmentedProgressBar(currentSegment: 9)
                .padding(.top, 24)
            Spacer()
            
            BreathingCirclesView()
            
            Spacer()
            Text("Data \nprocessing")
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.custom("D-DIN-PRO-Regular", size: 58))
                .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
                .multilineTextAlignment(.center)
//            Spacer()
            Spacer()
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 235/255, green: 243/255, blue: 241/255))
        .onAppear {
            TelemetryDeck.signal("DataProcessingScreen.load")
            let deadlineTimestamp = UserDefaults.standard.value(forKey: "deadline") as? TimeInterval
            let deadlineString: String = {
                if let timestamp = deadlineTimestamp {
                    let date = Date(timeIntervalSince1970: timestamp)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    return formatter.string(from: date)
                } else {
                    return "Отсутствует"
                }
            }()
            
            let requestData = DietRequest(
                deadline: deadlineString,
                height: UserDefaults.standard.string(forKey: "heightDataCollectionScreen") ?? "Нет данных",
                allergies: UserDefaults.standard.string(forKey: "allergiesDataCollection") ?? "Нет данных",
                listAllegries: UserDefaults.standard.string(forKey: "allirgiesListScreen") ?? "Нет данных",
                age: UserDefaults.standard.string(forKey: "ageDataCollection") ?? "Не указано",
                foodPreferences: UserDefaults.standard.string(forKey: "foodPreferencesDataCollection") ?? "Не указано",
                weightTarget: UserDefaults.standard.string(forKey: "weightTargetDataCollection") ?? "Не указано",
                physicalLevel: UserDefaults.standard.string(forKey: "physicalLevelDataCollection") ?? "Не указано",
                weight: UserDefaults.standard.string(forKey: "weightDataCollection") ?? "Не указано"
            )
            
            viewModel.generateDietPlan(requestData: requestData)
        }
        .onChange(of: viewModel.isLoading) { isLoading in
            if !isLoading && !viewModel.dietPlan.isEmpty {
                DispatchQueue.main.async {
                    print(viewModel.dietPlan)
                    path.append(Router.tabBarView)
                }
            }
        }
    }
}

#Preview {
    DataProcessingScreen(viewModel: .init(), path: .constant(.init()))
}
