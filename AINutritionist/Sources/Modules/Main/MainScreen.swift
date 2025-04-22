//
//  MainScreen.swift
//  AINutritionist
//
//  Created by muser on 24.03.2025.
//

import SwiftUI
import TelemetryDeck

struct MainScreen: View {
    @ObservedObject private var viewModel: MainViewModel
    @ObservedObject var authMain: AuthMain
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    @State private var selectedIndex: Int? = 0
    @State private var isShowAddDish: Bool = false
    @State private var isShowAddWater: Bool = false
    
    var dates: [(day: String, date: String)] = {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let numberFormatter = DateFormatter()
        numberFormatter.dateFormat = "d" 

        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = (weekday == 1 ? 6 : weekday - 2)
        
        guard let thisMonday = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else { return [] }

        return (0..<7).compactMap { i in
            if let date = calendar.date(byAdding: .day, value: i, to: thisMonday) {
                return (formatter.string(from: date), numberFormatter.string(from: date))
            }
            return nil
        }
    }()
    
    init(viewModel: MainViewModel, authMain: AuthMain, path: Binding<NavigationPath>) {
        self.viewModel = viewModel
        self.authMain = authMain
        self._path = path
    }
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    HStack {
                        VStack {
                            Text("Hello \(authMain.currentuser?.name ?? "")!")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom("D-DIN-PRO-SemiBold", size: 32))
                                .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                            
                            Text("March 2025")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom("D-DIN-PRO-Regular", size: 22))
                                .foregroundStyle(Color.init(red: 138/255, green: 138/255, blue: 138/255))
                        }
                        
                        Image(.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    }
                    
                    HStack {
                        ForEach(dates.indices, id: \.self) { index in
                            DateItem(
                                isSelected: selectedIndex == index,
                                day: dates[index].day,
                                date: dates[index].date
                            ) {
                                selectedIndex = index
                                
                                let calendar = Calendar.current
                                let today = Date()
                                let weekday = calendar.component(.weekday, from: today)
                                let daysToSubtract = (weekday == 1 ? 6 : weekday - 2)
                                
                                if let thisMonday = calendar.date(byAdding: .day, value: -daysToSubtract, to: today),
                                   let date = calendar.date(byAdding: .day, value: index, to: thisMonday) {
                                    viewModel.selectedDate = date
                                    viewModel.loadData()
                                }
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 18)
                }
                .padding(.top, 52)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity)
                .background(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                .clipShape(RoundedCorner(radius: 42, corners: [.bottomLeft, .bottomRight]))
                
                HStack {
                    MainNormsItem(title: "Water balance", value: (Double(viewModel.water) / 1000), category: "L", max: "\(viewModel.maxWater)", image: .normOfWaterIcon)
                        .frame(maxHeight: 80)
                    MainNormsItem(title: "Kcal balance", value: Double(viewModel.kcal), category: "C", max: "\(viewModel.maxKcal)", image: .normOfFoodIcon)
                        .frame(maxHeight: 80)
                }
                .padding(.horizontal, 18)
                
                HStack {
                    Button {
                        TelemetryDeck.signal("MainScreen.onTapAddWaterButton")
                        isShowAddWater = true
                    } label: {
                        Text("+")
                            .frame(maxWidth: .infinity)
                            .font(.custom("D-DIN-PRO-Regular", size: 60))
                            .foregroundStyle(.white)
                    }
                    .background(Color.init(red: 4/255, green: 202/255, blue: 212/255))
                    .cornerRadius(100)
                    
                    Button {
                        TelemetryDeck.signal("MainScreen.onTapAddDishButton")
                        isShowAddDish = true
                    } label: {
                        Text("+")
                            .frame(maxWidth: .infinity)
                            .font(.custom("D-DIN-PRO-Regular", size: 60))
                            .foregroundStyle(.white)
                    }
                    .background(Color.init(red: 255/255, green: 184/255, blue: 84/255))
                    .cornerRadius(100)
                    
                }
                .padding(.horizontal, 18)
                Spacer()
                
                ScrollView {
                    ForEach(viewModel.items, id: \.self) { item in
                        MainFoodItemView(viewModel: item)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(.white)
                .cornerRadius(32)
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .scrollIndicators(.hidden)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 80)
            .background(Color.init(red: 235/255, green: 243/255, blue: 241/255))
            .ignoresSafeArea(.all, edges: .top)
            .onAppear {
                viewModel.loadData()
                setupDates()
            }
            
            if isShowAddDish {
                AddDishView {
                    isShowAddDish = false
                } onConfirmTap: { name, weight, kcal in
                    viewModel.addDish(name: name, weight: weight, kcal: kcal)
                    isShowAddDish = false
                }
            }
            
            if isShowAddWater {
                AddWaterView {
                    isShowAddWater = false
                } onConfirmTap: { water in
                    viewModel.addWater(water: water)
                    isShowAddWater = false
                }
            }
        }
        .animation(.easeInOut, value: isShowAddDish)
        .animation(.easeInOut, value: isShowAddWater)
        .onAppear {
            TelemetryDeck.signal("MainScreen.load")
        }
    }
    
    private func setupDates() {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let numberFormatter = DateFormatter()
        numberFormatter.dateFormat = "d"

        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        selectedIndex = weekday == 1 ? 6 : weekday - 2
    }
}


#Preview {
    MainScreen(viewModel: .init(items: []), authMain: .init(), path: .constant(.init()))
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 10
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


struct DateItem: View {
    var isSelected: Bool
    var day: String
    var date: String
    var onTap: () -> Void

    var body: some View {
        VStack {
            Text(day)
                .font(.custom("D-DIN-PRO-Regular", size: 18))
                .foregroundStyle(Color(red: 235/255, green: 243/255, blue: 241/255))
            Text(date)
                .frame(width: 20, height: 20)
                .font(.custom("D-DIN-PRO-SemiBold", size: 20))
                .foregroundStyle(isSelected
                    ? Color(red: 34/255, green: 34/255, blue: 34/255)
                    : Color(red: 235/255, green: 243/255, blue: 241/255)
                )
                .padding(6)
                .background(isSelected
                    ? Color(red: 4/255, green: 212/255, blue: 132/255)
                    : Color(red: 64/255, green: 64/255, blue: 64/255)
                )
                .cornerRadius(100)
        }
        .padding(6)
        .background(isSelected
            ? Color(red: 94/255, green: 94/255, blue: 94/255)
            : Color(red: 54/255, green: 54/255, blue: 54/255)
        )
        .cornerRadius(100)
        .onTapGesture {
            onTap()
        }
    }
}

struct MainNormsItem: View {
    let title: String
    let value: Double
    let category: String
    let max: String
    let image: ImageResource

    var body: some View {
        HStack {
            Image(image)
                .resizable()
                .scaledToFit()
                .cornerRadius(100)
            
            VStack {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("D-DIN-PRO-Regular", size: 12))
                    .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                Spacer()
                
                HStack {
                    Text("\(formattedValue)\(category)")
                        .frame(maxHeight: .infinity, alignment: .leading)
                        .font(.custom("D-DIN-PRO-SemiBold", size: 26))
                        .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    
//                    Text("Max:\n\(max)\(category)")
                    Text("")
                        .frame(alignment: .top)
                        .font(.custom("D-DIN-PRO-Regular", size: 12))
                        .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
//                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(6)
        .background(.white)
        .cornerRadius(100)
    }
    
    private var formattedValue: String {
        let string = String(format: "%g", value)
        return string.replacingOccurrences(of: ".0", with: "")
    }
}
