//
//  ChatBubble.swift
//  QuickGroq
//
//  Created by kartik khorwal on 2/28/25.
//

import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage

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
                VStack{
                    Text(message.formattedText)
                        .padding(.vertical, 10)
                        .cornerRadius(10)
                    Spacer()
                }
                
            }
        }
    }
}

#Preview {
//    ChatBubble()
}
