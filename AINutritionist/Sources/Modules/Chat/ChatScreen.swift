//
//  ChatScreen.swift
//  AINutritionist
//
//  Created by muser on 24.03.2025.
//

import SwiftUI
import TelemetryDeck

struct ChatScreen: View {
    @State private var userInput = ""
    @State private var chatHistory: [String] = UserDefaults.standard.stringArray(forKey: "chatHistory") ?? []
    @Binding var path: NavigationPath
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ChatViewModel()
    
    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
    var body: some View {
        VStack {
            VStack {
                Image(.innerChatIcon)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 160)
                    .cornerRadius(100)
                Text("AI nutritionist")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.custom("D-DIN-PRO-Regular", size: 18))
                    .foregroundStyle(Color.init(red: 224/255, green: 224/255, blue: 224/255))
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(Color.init(red: 24/255, green: 24/255, blue: 24/255))
            Spacer()
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(chatHistory, id: \.self) { message in
                        Text(message)
                            .padding(8)
                            .foregroundStyle(Color.init(red: 235/255, green: 243/255, blue: 241/255))
                            .background(message.starts(with: "AI:")
                                        ? Color.init(red: 86/255, green: 86/255, blue: 86/255)
                                        : Color.init(red: 4/255, green: 212/255, blue: 132/255)
                            )
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity, alignment: message.starts(with: "AI:") ? .trailing : .leading)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, 18)
            HStack {
                TextField("Write your message", text: $userInput, prompt: Text("Ask about nutrition and diet!").foregroundColor(.white))
                    .font(.custom("D-DIN-PRO-Regular", size: 18))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(16)
                    .foregroundColor(.white)
                    .padding(.trailing, 32)
                    .disabled(viewModel.isLoading)
                Button {
                    if !userInput.isEmpty {
                        viewModel.sendMessage(userInput) { response in
                            // Добавляем в историю сообщения пользователя и AI
                            chatHistory.append("You: \(userInput)")
                            chatHistory.append("AI: \(response)")
                        
                            // Сохраняем историю
                            UserDefaults.standard.set(chatHistory, forKey: "chatHistory")
                        
                            // Очищаем поле ввода
                            userInput = ""
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(10)
                    } else {
                        Image(.chatIcc)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .disabled(userInput.isEmpty || viewModel.isLoading)
                .padding(2)
            }
            .frame(height: 50)
            .background {
                Rectangle()
                    .foregroundColor(Color(red: 24/255, green: 24/255, blue: 24/255, opacity: 0.6))
                    .cornerRadius(32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.white, lineWidth: 0.5)
                    )
            }
            .padding(.horizontal, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 80)
        .background(Color.init(red: 34/255, green: 34/255, blue: 34/255))
        .onAppear {
            TelemetryDeck.signal("ChatScreen.load")
            if chatHistory.isEmpty {
                let welcomeMessage = "AI: Hi, I am your personal nutritionist assistant. Ask me about nutrition, diets, calories or healthy recipes!"
                chatHistory.append(welcomeMessage)
                UserDefaults.standard.set(chatHistory, forKey: "chatHistory")
            }
        }
    }
}


#Preview {
    ChatScreen(path: .constant(.init()))
}
