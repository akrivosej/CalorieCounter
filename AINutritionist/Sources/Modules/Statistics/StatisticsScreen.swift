//
//  StatisticsScreen.swift
//  AINutritionist
//
//  Created by muser on 24.03.2025.
//

import SwiftUI
import Charts

struct WeightData: Identifiable {
    let id = UUID()
    let date: Date
    let weightChange: Double
}

struct StatisticsScreen: View {
    let weight = UserDefaults.standard.string(forKey: "weightDataCollection") ?? "0"
    
    let data: [WeightData] = [
        WeightData(date: DateComponents(calendar: .current, year: 2024, month: 4, day: 11).date!, weightChange: 0.2),
        WeightData(date: DateComponents(calendar: .current, year: 2024, month: 4, day: 12).date!, weightChange: 0.6),
        WeightData(date: DateComponents(calendar: .current, year: 2024, month: 4, day: 13).date!, weightChange: 0.4),
        WeightData(date: DateComponents(calendar: .current, year: 2024, month: 4, day: 14).date!, weightChange: -0.22),
        WeightData(date: DateComponents(calendar: .current, year: 2024, month: 4, day: 15).date!, weightChange: -0.5),
        WeightData(date: DateComponents(calendar: .current, year: 2024, month: 4, day: 16).date!, weightChange: 0.8),
        WeightData(date: DateComponents(calendar: .current, year: 2024, month: 4, day: 17).date!, weightChange: -0.7),
        WeightData(date: DateComponents(calendar: .current, year: 2024, month: 4, day: 18).date!, weightChange: -0.4)
    ]
    @State private var selectedOption: TimeOption = .day
    
    enum TimeOption: String, CaseIterable {
        case day = "D"
        case week = "W"
        case month = "M"
        case sixMonths = "6M"
        case year = "Y"
    }
    
    var body: some View {
        VStack {
            HStack {
                AccountItem(title: "Current weight", value: "", target: false, minus: "")
                    .frame(maxHeight: 80)
                AccountItem(title: "Start weight", value: weight, target: true, minus: "")
                    .frame(maxHeight: 80)
            }
            .padding(.top, 72)
            .padding(.bottom, 22)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .background(Color.init(red: 34/255, green: 34/255, blue: 34/255))
            .clipShape(RoundedCorner(radius: 42, corners: [.bottomLeft, .bottomRight]))
            
            HStack {
                ForEach(TimeOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                        .font(.custom("D-DIN-PRO-Regular", size: 18))
                        .foregroundStyle(Color.init(red: 138/255, green: 138/255, blue: 138/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                if selectedOption == option {
                                    Capsule()
                                        .fill(Color.init(red: 218/255, green: 218/255, blue: 218/255))
                                        .matchedGeometryEffect(id: "selection", in: animation)
                                }
                            }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring()) {
                                selectedOption = option
                            }
                            fetchData(for: option)
                        }
                }
            }
            .background(
                Capsule()
                    .stroke(Color.init(red: 138/255, green: 138/255, blue: 138/255), lineWidth: 1)
            )
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            
            Text("Today")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-Regular", size: 28))
                .foregroundStyle(Color.init(red: 86/255, green: 86/255, blue: 86/255))
                .padding(.horizontal, 18)
            
            HStack {
                Text("-0,8")
//                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("D-DIN-PRO-Bold", size: 38))
                    .foregroundStyle(Color.init(red: 4/255, green: 212/255, blue: 132/255))
//                    .padding(.horizontal, 18)
                
                Text("kg")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("D-DIN-PRO-SemiBold", size: 32))
                    .foregroundStyle(Color.init(red: 4/255, green: 212/255, blue: 132/255))
//                    .padding(.horizontal, 18)
            }
            .padding(.horizontal, 18)
            
            Text("17.03.2025")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-Regular", size: 22))
                .foregroundStyle(Color.init(red: 86/255, green: 86/255, blue: 86/255))
                .padding(.horizontal, 18)

            Chart(data) { item in
                BarMark(
                    x: .value("Дата", item.date, unit: .day),
                    y: .value("Изменение веса", item.weightChange)
                )
                .foregroundStyle(item.weightChange < 0 ? .green : .red)
                .cornerRadius(10)
                .annotation(position: item.weightChange < 0 ? .bottom : .top) {
                    Text("\(item.weightChange, specifier: "%.1f")kg")
                        .padding(12)
                        .background(Circle().fill(Color.white).shadow(radius: 2))
                        .foregroundColor(item.weightChange < 0
                                         ? Color.init(red: 4/255, green: 212/255, blue: 132/255)
                                         : Color.init(red: 245/255, green: 78/255, blue: 0/255)
                        )
                        .padding(item.weightChange < 0 ? .top : .bottom, -38)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.day().month(.twoDigits),
                                  centered: true)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let doubleValue = value.as(Double.self), doubleValue == 0 {
                        AxisGridLine()
                            .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    }
                }
            }
            .background(Color.init(red: 250/255, green: 255/255, blue: 255/255))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.init(red: 195/255, green: 196/255, blue: 195/255), lineWidth: 1)
            )
            .cornerRadius(24)
            .padding(.horizontal, 18)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.init(red: 235/255, green: 243/255, blue: 241/255))
        .ignoresSafeArea(.all, edges: .top)
    }
    
    @Namespace private var animation
    
    func fetchData(for option: TimeOption) {
        // Здесь подгружаем данные в зависимости от выбранного периода
        print("Загружаем данные для: \(option.rawValue)")
    }
}

#Preview {
    StatisticsScreen()
}
