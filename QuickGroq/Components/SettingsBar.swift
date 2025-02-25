//
//  SettingsBar.swift
//  OllamaMacOS
//
//  Created by kartik khorwal on 2/26/25.
//

import SwiftUI

struct SettingsBar: View {
    @Binding var showSettings: Bool
    @State private var apiKey: String = UserDefaults.standard.string(forKey: "customAPIKey") ?? ""
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack {
            HStack {
                TextField("Enter API Key", text: $apiKey)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 14))
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                    .focused($isTextFieldFocused)

                Button(action: {
                    saveAndClose()
                }) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 20))
                        .opacity(0.7)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
        }
        .background(.thinMaterial)
    }

    private func saveAndClose() {
        UserDefaults.standard.set(apiKey, forKey: "customAPIKey")
        isTextFieldFocused = false
        showSettings = false // Close the settings bar
        print("API Key saved: \(apiKey)")
    }
}
