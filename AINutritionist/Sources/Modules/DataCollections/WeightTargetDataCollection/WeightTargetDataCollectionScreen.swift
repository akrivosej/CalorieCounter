//
//  WeightTargetDataCollectionScreen.swift
//  AINutritionist
//
//  Created by muser on 19.03.2025.
//

import SwiftUI
import TelemetryDeck

struct WeightTargetDataCollectionScreen: View {
    @State private var weight: CGFloat = 94
    @State private var draggedOffset: CGFloat = 0
    @State private var previousWeight: CGFloat = 94
    @State private var isDragging: Bool = false
    
    let minWeight: CGFloat = 40
    let maxWeight: CGFloat = 250
    let step: CGFloat = 1
    let majorTickInterval: CGFloat = 10

    let sensitivityFactor: CGFloat = 1.0
    
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    private let itemWidth: CGFloat = 8
    private let spacing: CGFloat = 4
    
    var body: some View {
        VStack {
            SegmentedProgressBar(currentSegment: 7)
                .padding(.top, 24)

            Text("Set your weight target")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-ExtraBold", size: 38))
                .foregroundStyle(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                .padding(.top, 24)
            
            Spacer()
            Spacer()
            HStack {
                Text("\(Int(weight))")
                    .font(.custom("D-DIN-PRO-Regular", size: 80))
                    .foregroundColor(Color(red: 4/255, green: 212/255, blue: 132/255))
                
                Text("kg")
                    .font(.custom("D-DIN-PRO-Regular", size: 60))
                    .foregroundColor(Color(red: 4/255, green: 212/255, blue: 132/255))
            }
            Spacer()
            
            ZStack {
                Rectangle()
                    .foregroundColor(Color(red: 4/255, green: 212/255, blue: 132/255))
                    .frame(width: 3, height: 110)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Color.clear
                        
                        let screenWidth = geo.size.width
                        let initialOffset = screenWidth / 2 - itemWidth / 2
                        
                        let weightOffset = ((weight - minWeight) / step) * (itemWidth + spacing)
                        
                        let baseOffset = initialOffset - weightOffset
                        
                        let currentOffset = isDragging ? baseOffset + (draggedOffset * sensitivityFactor) : baseOffset
                        
                        HStack(spacing: spacing) {
                            ForEach(Int(minWeight)...Int(maxWeight), id: \.self) { value in
                                if value % Int(step) == 0 {
                                    TickMark(value: value, major: value % Int(majorTickInterval) == 0)
                                        .id(value)
                                        .frame(width: itemWidth)
                                }
                            }
                        }
                        .offset(x: currentOffset)
                        .animation(isDragging ? .none : .spring(response: 0.3), value: weight)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDragging = true
                                
                                if draggedOffset == 0 {
                                    previousWeight = weight
                                }
                                
                                draggedOffset = value.translation.width
                                
                                let dragDistance = -draggedOffset
                                let draggedItems = dragDistance / (itemWidth + spacing)
                                
                                let newWeight = previousWeight + draggedItems * step
                                
                                let roundedWeight = round(newWeight / step) * step
                                let clampedWeight = max(minWeight, min(roundedWeight, maxWeight))
                                
                                if weight != clampedWeight {
                                    weight = clampedWeight
                                    
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }
                            }
                            .onEnded { _ in
                                isDragging = false
                                draggedOffset = 0
                            }
                    )
                }
                .frame(height: 110)
                .clipped()
            }
            .padding(.horizontal, -18)
            
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
                    path.append(Router.deadlineDataCollection)
                    UserDefaults.standard.set(weight, forKey: "weightTargetDataCollection")
                } label: {
                    Text("Next")
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .font(.custom("D-DIN-PRO-Bold", size: 26))
                        .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                        .font(.system(size: 28, weight: .medium, design: .default))
                }
                .background(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                .cornerRadius(32)
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 18)
        .background(Color(red: 235/255, green: 243/255, blue: 241/255))
        .onAppear {
            TelemetryDeck.signal("WeightTargetDataCollectionScreen.load")
            if let savedWeight = UserDefaults.standard.object(forKey: "weightDataCollection") as? CGFloat {
                weight = savedWeight
                previousWeight = savedWeight
            }
        }
    }
}

#Preview {
    WeightTargetDataCollectionScreen(path: .constant(.init()))
}


