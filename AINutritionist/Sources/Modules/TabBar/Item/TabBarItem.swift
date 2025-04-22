//
//  TabBarItem.swift
//  AINutritionist
//
//  Created by muser on 19.03.2025.
//

import SwiftUI

struct TabBarItem: View {
    var title: String
    var image: String
    
    @Binding var selected: String
    
    var body: some View {
        Button {
            withAnimation(.spring) {
                selected = title
            }
        } label: {
            VStack {
                Image(image)
                    .resizable()
                    .scaledToFit()
//                    .frame(width: 35, height: 35)
                    .foregroundStyle(selected == title
                                     ? Color.init(red: 4/255, green: 212/255, blue: 132/255)
                                     : Color.init(red: 235/255, green: 243/255, blue: 241/255)
                    )
            }
        }
        .padding(12)
        .background(selected == title
                    ? Color.init(red: 235/255, green: 243/255, blue: 241/255)
                    : Color.init(red: 4/255, green: 212/255, blue: 132/255))
        .cornerRadius(100)
    }
}

#Preview {
    TabBarItem(title: "sadasfsad", image: "profileIcon", selected: .init(get: {
        ""
    }, set: { _ in
        
    }))
    .background(.black)
}
