//
//  WeightDataCollectionScreen.swift
//  AINutritionist
//
//  Created by muser on 28.02.2025.
//

import SwiftUI
import TelemetryDeck

struct WeightDataCollectionScreen: View {
    @State private var weight: CGFloat = 94
    @State private var draggedOffset: CGFloat = 0
    @State private var previousWeight: CGFloat = 94
    @State private var isDragging: Bool = false
    
    let minWeight: CGFloat = 40
    let maxWeight: CGFloat = 250
    let step: CGFloat = 1
    let majorTickInterval: CGFloat = 10
    
    // Increase sensitivity to match visual position better
    let sensitivityFactor: CGFloat = 1.0
    
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    private let itemWidth: CGFloat = 8
    private let spacing: CGFloat = 4
    
    var body: some View {
        VStack {
            SegmentedProgressBar(currentSegment: 1)
                .padding(.top, 24)
            
            Text("Set your weight")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-ExtraBold", size: 38))
                .foregroundColor(Color(red: 34/255, green: 34/255, blue: 34/255))
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
                // Central indicator
                Rectangle()
                    .foregroundColor(Color(red: 4/255, green: 212/255, blue: 132/255))
                    .frame(width: 3, height: 110)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Transparent background for interaction area
                        Color.clear
                        
                        let screenWidth = geo.size.width
                        let initialOffset = screenWidth / 2 - itemWidth / 2
                        
                        // Calculate offset based on current weight
                        let weightOffset = ((weight - minWeight) / step) * (itemWidth + spacing)
                        
                        // Base offset positions weight in center
                        let baseOffset = initialOffset - weightOffset
                        
                        // When dragging, apply visual drag (without changing base position)
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
                    // Apply gesture to whole GeometryReader area
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 5)
                            .onChanged { value in
                                // Set drag flag
                                isDragging = true
                                
                                // Save initial weight at first touch
                                if draggedOffset == 0 {
                                    previousWeight = weight
                                }
                                
                                // Current drag offset
                                draggedOffset = value.translation.width
                                
                                // Calculate weight change - direct mapping instead of reduced sensitivity
                                let dragDistance = -draggedOffset
                                let draggedItems = dragDistance / (itemWidth + spacing)
                                
                                // Remove the max weight change limitation
                                let newWeight = previousWeight + draggedItems * step
                                
                                // Clamp and round weight
                                let roundedWeight = round(newWeight / step) * step
                                let clampedWeight = max(minWeight, min(roundedWeight, maxWeight))
                                
                                // Apply new weight only if changed
                                if weight != clampedWeight {
                                    weight = clampedWeight
                                    
                                    // Haptic feedback
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }
                            }
                            .onEnded { _ in
                                // Reset drag flag and offset
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
            
            NavigationButtons {
                path.append(Router.heightDataCollection)
                UserDefaults.standard.set(weight, forKey: "weightDataCollection")
            }
        }
        .padding(.horizontal, 18)
        .background(Color(red: 235/255, green: 243/255, blue: 241/255))
        .onAppear {
            TelemetryDeck.signal("WeightDataCollectionScreen.load")
            if let savedWeight = UserDefaults.standard.object(forKey: "weightDataCollection") as? CGFloat {
                weight = savedWeight
                previousWeight = savedWeight
            }
        }
    }
}

struct NavigationButtons: View {
    var action: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack(spacing: 24) {
            Button {
                dismiss()
            } label: {
                Image(.arrow)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color(red: 34/255, green: 34/255, blue: 34/255))
            }
            
            Button(action: action) {
                Text("Next")
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .font(.custom("D-DIN-PRO-Bold", size: 26))
                    .foregroundStyle(Color(red: 235/255, green: 243/255, blue: 241/255))
            }
            .background(Color(red: 34/255, green: 34/255, blue: 34/255))
            .cornerRadius(32)
        }
        .padding(.bottom, 32)
    }
}

#Preview {
    WeightDataCollectionScreen(path: .constant(.init()))
}

struct TickMark: View {
    let value: Int
    let major: Bool
    let width: CGFloat = 8 // Ширина одной отметки
    
    var body: some View {
        VStack {
            if major {
                Text("\(value)")
                    .font(.custom("D-DIN-PRO-Regular", size: 18))
                    .foregroundColor(Color(red: 34/255, green: 34/255, blue: 34/255))
                    .frame(width: 50, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Rectangle()
                .foregroundColor(Color(red: 34/255, green: 34/255, blue: 34/255))
                .frame(width: major ? 1.5 : 0.5, height: major ? 80 : 60)
        }
        .frame(width: width, alignment: .center) // Фиксируем ширину отметки
    }
}
