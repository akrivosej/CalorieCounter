//
//  FirstOnboardingScreen.swift
//  AINutritionist
//
//  Created by muser on 17.03.2025.
//

import SwiftUI
import TelemetryDeck

struct FirstOnboardingScreen: View {
    @ObservedObject private var viewModel: FirstOnboardingViewModel
    @State private var path: NavigationPath = .init()
    @StateObject private var authMain = AuthMain()
    
    init(viewModel: FirstOnboardingViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            onbView
            .navigationDestination(for: Router.self) { router in
                switch router {
                case .secondOnboarding:
                    SecondOnboardingScreen(path: $path)
                        .navigationBarBackButtonHidden(true)
                case .thirdOnboarding:
                    ThirdOnboardingScreen(path: $path)
                        .navigationBarBackButtonHidden(true)
                case .fouthOnboadring:
                    FouthOnboadringScreen(path: $path)
                        .navigationBarBackButtonHidden(true)
                case .dataProcessing:
                    DataProcessingScreen(viewModel: .init(), path: $path)
                        .navigationBarBackButtonHidden(true)
                case .weightDataCollection:
                    WeightDataCollectionScreen(path: $path)
                        .navigationBarBackButtonHidden(true)
                case .heightDataCollection:
                    HeightDataCollectionScreen(path: $path)
                        .navigationBarBackButtonHidden(true)
                case .ageDataCollection:
                    AgeDataCollectionScreen(path: $path)
                        .navigationBarBackButtonHidden(true)
                case .physicalLevelDataCollection:
                    PhysicalLevelDataCollectionScreen(path: $path)
                        .navigationBarBackButtonHidden(true)
                case .foodPreferencesDataCollection:
                    FoodPreferencesDataCollectionScreen(path: $path)
                        .navigationBarBackButtonHidden(true)
                case .allergiesDataCollection:
                    AllergiesDataCollectionScreen(path: $path)
                        .navigationBarBackButtonHidden(true)
                case .weightTargetDataCollection:
                    WeightTargetDataCollectionScreen(path: $path)
                        .navigationBarBackButtonHidden(true)
                case .deadlineDataCollection:
                    DeadlineScreen(authMain: authMain, path: $path)
                        .navigationBarBackButtonHidden(true)
                case .main:
                    MainScreen(viewModel: .init(items: []), authMain: authMain, path: $path)
                        .navigationBarBackButtonHidden(true)
                case .menu:
                    MenuScreen(viewModel: .init(), path: $path)
                        .navigationBarBackButtonHidden(true)
                case .menuDetails(let item):
                    MenuDetailsView(viewModel: .init(id: item.id, image: item.image, title: item.title, calories: item.calories, ingredients: item.ingredients, description: item.description))
                        .navigationBarBackButtonHidden(true)
                case .chat:
                    ChatScreen(path: $path)
                        .navigationBarBackButtonHidden(true)
                case .stats:
                    StatisticsScreen()
                        .navigationBarBackButtonHidden(true)
                case .account:
                    AccountScreen(accViewModel: .init(), viewModel: authMain, path: $path)
                        .navigationBarBackButtonHidden(true)
                case .tabBarView:
                    TabBarView(authMain: authMain, path: $path)
                        .navigationBarBackButtonHidden(true)
                case .allirgiesList:
                    AllirgiesListScreen(path: $path)
                        .navigationBarBackButtonHidden(true)
                case .root:
                    RootScreen(viewModel: authMain, path: $path)
                        .navigationBarBackButtonHidden(true)
                case .registration:
                    RegistrationScreen(viewModel: authMain, path: $path)
                        .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
    
    var onbView: some View {
        VStack(alignment: .center) {
            Text("Learn to live")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-Regular", size: 32))
                .foregroundStyle(Color.init(red: 66/255, green: 66/255, blue: 66/255))
                .padding(.top, 24)
            Text("a healthy life")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.custom("D-DIN-PRO-Heavy", size: 46))
                .textCase(.uppercase)
                .foregroundStyle(Color.init(red: 4/255, green: 212/255, blue: 132/255))
            Spacer()
            Button {
                path.append(Router.root)
            } label: {
                Text("Get started")
                    .font(.custom("D-DIN-PRO-Bold", size: 26))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .background(Color.init(red: 4/255, green: 212/255, blue: 132/255))
            .cornerRadius(32)
            .padding(.bottom, 32)

            Button {
                path.append(Router.root)
            } label: {
                HStack {
                    Text("Already have an account? ")
                        .foregroundStyle(Color.init(red: 66/255, green: 66/255, blue: 66/255))
                        .font(.custom("D-DIN-PRO-Regular", size: 18))
                    Text("Sign in")
                        .foregroundStyle(Color.init(red: 4/255, green: 212/255, blue: 132/255))
                        .font(.custom("D-DIN-PRO-SemiBold", size: 18))
                }
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image(.firstOnbBackground)
                .resizable()
                .scaledToFill()
                .scaleEffect(1.2)
        )
        .onAppear {
            TelemetryDeck.signal("FirstOnboardingScreen.load")
            viewModel.loadData()
        }
    }
}

#Preview {
    FirstOnboardingScreen(viewModel: .init())
}
