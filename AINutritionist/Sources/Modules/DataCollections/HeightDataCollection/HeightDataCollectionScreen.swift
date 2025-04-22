//
//  HeightDataCollectionScreen.swift
//  AINutritionist
//
//  Created by muser on 19.03.2025.
//

import SwiftUI
import TelemetryDeck

struct HeightDataCollectionScreen: View {
    @State private var selectedHeight: Int = 180
    @State private var draggedOffset: CGFloat = 0
    @State private var previousHeight: Int = 180
    @State private var isDragging: Bool = false
    
    let minHeight: Int = 140
    let maxHeight: Int = 250
    let step: Int = 1
    let majorTickInterval: Int = 10
    
    // Increase sensitivity to match visual position better
    let sensitivityFactor: CGFloat = 1.0
    
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    
    private let itemHeight: CGFloat = 20
    private let spacing: CGFloat = 0
    
    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24)
                .foregroundColor(Color(red: 4/255, green: 212/255, blue: 132/255))
                .frame(width: 120, height: 3)
                
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Transparent background for interaction area
                    Color.clear
                    
                    let screenHeight = geo.size.height
                    let initialOffset = screenHeight / 2 - itemHeight / 2
                    
                    // Calculate offset based on current height
                    let heightOffset = CGFloat((selectedHeight - minHeight) / step) * (itemHeight + spacing)
                    
                    // Base offset positions height in center
                    let baseOffset = initialOffset - heightOffset
                    
                    // When dragging, apply visual drag (without changing base position)
                    let currentOffset = isDragging ? baseOffset + (draggedOffset * sensitivityFactor) : baseOffset
                    
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(minHeight...maxHeight, id: \.self) { height in
                            HeightTickMark(height: height, isSelected: height == selectedHeight, isMajor: height % majorTickInterval == 0)
                                .id(height)
                        }
                    }
                    .offset(y: currentOffset)
                    .animation(isDragging ? .none : .spring(response: 0.3), value: selectedHeight)
                }
                // Apply gesture to whole GeometryReader area
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            // Set drag flag
                            isDragging = true
                            
                            // Save initial height at first touch
                            if draggedOffset == 0 {
                                previousHeight = selectedHeight
                            }
                            
                            // Current drag offset
                            draggedOffset = value.translation.height
                            
                            // Calculate height change
                            let dragDistance = -draggedOffset
                            let draggedItems = dragDistance / itemHeight
                            
                            // Calculate new height
                            let newHeight = Double(previousHeight) + Double(draggedItems) * Double(step)
                            
                            // Clamp and round height
                            let roundedHeight = Int(round(newHeight / Double(step))) * step
                            let clampedHeight = max(minHeight, min(roundedHeight, maxHeight))
                            
                            // Apply new height only if changed
                            if selectedHeight != clampedHeight {
                                selectedHeight = clampedHeight
                                
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
            
            VStack(alignment: .leading) {
                SegmentedProgressBar(currentSegment: 2)
                    .padding(.top, 24)
                    .padding(.horizontal, 18)
                
                Text("Set your height")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.custom("D-DIN-PRO-ExtraBold", size: 38))
                    .foregroundColor(Color(red: 34/255, green: 34/255, blue: 34/255))
                    .padding(.top, 24)
                    .padding(.horizontal, 18)
                
                Spacer()
                HStack {
                    Text("\(selectedHeight)")
                        .font(.custom("D-DIN-PRO-Regular", size: 90))
                        .foregroundColor(Color(red: 4/255, green: 212/255, blue: 132/255))
                    
                    Text("cm")
                        .font(.custom("D-DIN-PRO-Regular", size: 60))
                        .foregroundColor(Color(red: 4/255, green: 212/255, blue: 132/255))
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 18)
                
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
                        UserDefaults.standard.set(selectedHeight, forKey: "heightDataCollectionScreen")
                        path.append(Router.secondOnboarding)
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
                .padding(.horizontal, 18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 235/255, green: 243/255, blue: 241/255))
        .onAppear {
            TelemetryDeck.signal("HeightDataCollectionScreen.load")
            if let savedHeight = UserDefaults.standard.object(forKey: "heightDataCollectionScreen") as? Int {
                selectedHeight = savedHeight
                previousHeight = savedHeight
            }
        }
    }
}

struct HeightTickMark: View {
    let height: Int
    let isSelected: Bool
    let isMajor: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isMajor {
                HStack {
                    RoundedRectangle(cornerRadius: 24)
                        .foregroundColor(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                        .frame(width: 80, height: 2, alignment: .leading)
                    Text("\(height)")
                        .font(.custom("D-DIN-PRO-Regular", size: 20))
                        .foregroundColor(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                }
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundColor(Color.init(red: 34/255, green: 34/255, blue: 34/255))
                    .frame(width: 60, height: 1, alignment: .leading)
            }
        }
        .frame(height: 20, alignment: .leading)
    }
}

#Preview {
    HeightDataCollectionScreen(path: .constant(.init()))
}
