//
//  BreathingCirclesView.swift
//  AINutritionist
//
//  Created by muser on 04.04.2025.
//

import SwiftUI

struct BreathingCirclesView: View {
    // Состояния для масштабирования каждого круга
    @State private var largeCircleScale: CGFloat = 1.0
    @State private var mediumCircleScale: CGFloat = 1.0
    @State private var smallCircleScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.init(red: 4/255, green: 212/255, blue: 132/255, opacity: 0.6))
                .frame(width: 160, height: 160)
                .scaleEffect(largeCircleScale)
                .offset(x: 30, y: -30)
                .animation(
                    Animation.easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                        .delay(0), // Начинает первым
                    value: largeCircleScale
                )
            
            // Средний круг
            Circle()
                .fill(Color.init(red: 4/255, green: 212/255, blue: 132/255, opacity: 0.4))
                .frame(width: 120, height: 120)
                .scaleEffect(mediumCircleScale)
                .offset(x: -70, y: 30)
                .animation(
                    Animation.easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                        .delay(1), // Начинает вторым
                    value: mediumCircleScale
                )
            
            // Маленький круг
            Circle()
                .fill(Color.init(red: 4/255, green: 212/255, blue: 132/255, opacity: 0.2))
                .frame(width: 80, height: 80)
                .scaleEffect(smallCircleScale)
                .offset(x: 10, y: 70)
                .animation(
                    Animation.easeInOut(duration: 3)
                        .repeatForever(autoreverses: true)
                        .delay(2), // Начинает третьим
                    value: smallCircleScale
                )
        }
        .onAppear {
            // Запускаем анимацию "дыхания" для каждого круга
            largeCircleScale = 1.2
            
            // Немного задерживаем начало анимации для второго круга
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                mediumCircleScale = 1.2
            }
            
            // И еще больше задерживаем для третьего круга
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                smallCircleScale = 1.2
            }
        }
    }
}

#Preview {
    BreathingCirclesView()
}
