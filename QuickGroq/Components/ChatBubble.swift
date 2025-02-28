//
//  ChatBubble.swift
//  QuickGroq
//
//  Created by kartik khorwal on 2/28/25.
//

import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    @EnvironmentObject var chatManager: ChatManager // Access chat manager

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                Text(message.formattedText)
                    .padding(10)
                    .padding(.horizontal, 6)
                    .background(Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(18)
            } else {
                VStack(alignment: .leading) {
                    HStack{
                        Text(message.formattedText)
                            .padding(.vertical, 10)
                            .cornerRadius(10)
                        Spacer()
                    }
                    
                    if message.isCompleted {
                        HStack {
                            Button(action: {
                                if let index = chatManager.messages.firstIndex(where: { $0.id == message.id }) {
                                    chatManager.deleteMessagePair(at: index) // Delete user + bot message pair
                                }
                            }) {
                                Image(systemName: "trash")
                                    .font(.system(size: 11))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .opacity(0.5)
                            .padding(.trailing, 4)

                            Button(action: {
                                if let index = chatManager.messages.firstIndex(where: { $0.id == message.id }) {
                                    chatManager.regenerateMessage(at: index) // Regenerate response
                                }
                            }) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 11))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .opacity(0.5)
                            .padding(.trailing, 4)
                            
                            
                            Button(action: {
                                chatManager.copyMessage(message) // Copy message
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 11))
                            }
                            .buttonStyle(PlainButtonStyle())
                            .opacity(0.5)
                            .padding(.trailing, 4)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ChatBubble(message: ChatMessage(id: UUID(), text: "This is a bot response.", isUser: false, timestamp: Date(), isCompleted: true))
        .environmentObject(ChatManager())
}
