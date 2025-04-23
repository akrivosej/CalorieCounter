//
//  TabBarView.swift
//  AINutritionist
//
//  Created by muser on 19.03.2025.
//

import SwiftUI

struct TabBarView: View {
    @Binding private var path: NavigationPath
    @StateObject private var viewModel = TabBarViewModel()
    @ObservedObject var authMain: AuthMain
    
    init(authMain: AuthMain, path: Binding<NavigationPath>) {
        self.authMain = authMain
        self._path = path
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $viewModel.current) {
                MainScreen(viewModel: .init(items: []), authMain: authMain, path: $path)
                    .environmentObject(authMain)
                    .tag("home")
                
                MenuScreen(viewModel: .init(), path: $path)
//                    .environmentObject(authMain)
                    .tag("menu")
                
                ChatScreen(path: $path)
//                    .environmentObject(authMain)
                    .tag("chat")
                
                StatisticsScreen()
                    .environmentObject(authMain)
                    .tag("stat")
                
                AccountScreen(accViewModel: .init(), viewModel: authMain, path: $path)
                    .environmentObject(authMain)
                    .tag("profile")
            }
            
            HStack(spacing: 4) {
                TabBarItem(title: "home", image: "homeIcon", selected: $viewModel.current)
                Spacer()
                TabBarItem(title: "menu", image: "menuIcon", selected: $viewModel.current)
                Spacer()
                TabBarItem(title: "chat", image: "chatIcon", selected: $viewModel.current)
//                Spacer()
//                TabBarItem(title: "stat", image: "statIcon", selected: $viewModel.current)
                Spacer()
                TabBarItem(title: "profile", image: "profileIcon", selected: $viewModel.current)
            }
            .frame(maxWidth: .infinity, maxHeight: 62)
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .background(Color.init(red: 4/255, green: 212/255, blue: 132/255))
            .cornerRadius(100)
            .padding(.horizontal, 12)
            .padding(.bottom, 2)
        }
        .frame(maxWidth: .infinity)
//        .background(viewModel.current == "chat"
//                    ? Color.init(red: 34/255, green: 34/255, blue: 34/255)
//                    : Color.init(red: 235/255, green: 243/255, blue: 241/255)
//        )
    }
}

#Preview {
    TabBarView(authMain: .init(), path: .constant(.init()))
}
