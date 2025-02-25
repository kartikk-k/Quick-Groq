//
//  InputBar.swift
//  OllamaMacOS
//
//  Created by kartik khorwal on 2/24/25.
//

import SwiftUI

struct InputBar: View {
    
    @EnvironmentObject var chatManager: ChatManager // Access shared state
    @State private var searchText = ""
    @State private var selectedOption = 0
    @State private var filteredOptions: [(title: String, iconName: String)] = []
    @FocusState private var isTextFieldFocused: Bool
    
    
    var body: some View {
        VStack{
            VStack{
                TextField("Ask me anything...", text: $searchText, onCommit: {
                    sendMessage()
                })
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14))
                    .onChange(of: searchText) {oldValue, newValue in}
                    .focused($isTextFieldFocused)
                    .onAppear {
                        isTextFieldFocused = true // Automatically focus the field when the view appears
                    }.padding(.horizontal, 2)
                
                HStack(alignment: .center){
                        Button(action: {
                            print("Submit button clicked")
                        }) {
                            
                            HStack(alignment: .center, spacing: 12){
                                Text("llama3.2 7b")
                                    .font(.system(size: 13))
                                    .fontWeight(.medium)
                                    .opacity(0.7)
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .fontWeight(.semibold)
                                    .opacity(0.7)
                            }
                        }.buttonStyle(PlainButtonStyle())
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(
                                HoverEffectView()
                            )
                            .mask(RoundedRectangle(cornerRadius: 8))
                        
                    
                    
                    Spacer()
                    
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 20))
                            .fontWeight(.medium)
                            .opacity(0.5)
                    }.buttonStyle(PlainButtonStyle())
                    
                }.padding(.top, 8)
                
            }
            .padding(10)
            .padding(.top, 2)
            .padding(.bottom, 0)
            .background(.white.opacity(0.1))
            .mask(RoundedRectangle(cornerRadius: 16))

        }.padding(16)
    }
    
    private func sendMessage() {
       guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
       chatManager.sendMessage(searchText)
       searchText = "" // clear the input
   }
}

struct HoverEffectView: View {
    @State private var isHovered = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.white.opacity(isHovered ? 0.3 : 0.1))
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

#Preview {
    InputBar().environmentObject(ChatManager())
}
