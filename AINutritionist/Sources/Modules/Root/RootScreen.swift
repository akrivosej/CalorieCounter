//
//  RootScreen.swift
//  AINutritionist
//
//  Created by muser on 25.03.2025.
//

import SwiftUI

struct RootScreen: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Binding var path: NavigationPath
    @ObservedObject var viewModel: AuthMain

    init(viewModel: AuthMain, path: Binding<NavigationPath>) {
        self.viewModel = viewModel
        self._path = path
    }

    var body: some View {
        if viewModel.userSession != nil {
            if viewModel.isNewUser {
                WeightDataCollectionScreen(path: $path)
            } else {
                DeadlineScreen(authMain: viewModel, path: $path)
            }
        } else {
            AuthorizationScreen(viewModel: viewModel, path: $path)
        }
    }
}


#Preview {
    RootScreen(viewModel: .init(), path: .constant(.init()))
}
