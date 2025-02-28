//
//  ContentView.swift
//  QuickGroq
//
//  Created by kartik khorwal on 2/26/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var chatManager: ChatManager // Access shared state
    
    var body: some View {
        VStack{
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(chatManager.messages) { message in
                            ChatBubble(message: message)
                                .id(message.id) // Assign an ID to each message
                        }
                    }
                    .padding()
                    .padding(.top, 46)
                    .onChange(of: chatManager.messages.count) { _ in
                        withAnimation {
                            proxy.scrollTo(chatManager.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }


            InputBar()
            
        }
    }
}



#Preview {
    ContentView()
        .frame(minWidth: 200)
        .environmentObject(ChatManager())
}

