//
//  ChatManager.swift
//  OllamaMacOS
//
//  Created by kartik khorwal on 2/24/25.
//

import SwiftUI


class ChatManager: ObservableObject {
    @Published var messages: [ChatMessage] = [ // Stores chat messages
        ChatMessage(id: UUID(), text: "Hello! Welcome to Groq Chat. How can I help you today?", isUser: false, timestamp: Date()),
    ] // Default messages for testing
    
    private var apiKey: String {
        return UserDefaults.standard.string(forKey: "customAPIKey") ?? "YOUR_DEFAULT_API_KEY"
    }

    
    // Function to add a user message and call Groq API
    func sendMessage(_ text: String) {
        // Append user message
        let userMessage = ChatMessage(id: UUID(), text: text, isUser: true, timestamp: Date())
        DispatchQueue.main.async {
            self.messages.append(userMessage)
        }
        
        // Call Groq API for response
        Task {
//            await fetchGroqResponse(userMessage: text)
            await streamGroqResponse(userMessage: text)
        }
    }
    
    func resetMessages(){
        DispatchQueue.main.async {
            self.messages.removeAll()
        }
    }
    
    // Function to call Groq API
    private func fetchGroqResponse(userMessage: String) async {
        let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
        
        let payload: [String: Any] = [
            "messages": [
                ["role": "user", "content": userMessage]
            ],
            "model": "llama-3.1-8b-instant",
            "stream": false
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("Failed to encode payload")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let response = try? JSONDecoder().decode(GroqResponse.self, from: data) {
                print(response);
                if let reply = response.choices.first?.message.content {
                    let botMessage = ChatMessage(id: UUID(), text: reply, isUser: false, timestamp: Date())
                    DispatchQueue.main.async {
                        self.messages.append(botMessage)
                    }
                }
            }
        } catch {
            print("Error fetching Groq response: \(error)")
        }
    }
    
    // Function to call Groq API and stream response word-by-word
    private func streamGroqResponse(userMessage: String) async {
        let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
        
        let payload: [String: Any] = [
            "messages": [
                ["role": "user", "content": userMessage]
            ],
            "model": "llama3-70b-8192",
            "stream": true // Enable streaming
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("Failed to encode payload")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (stream, response) = try await URLSession.shared.bytes(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error: Invalid response from server")
                return
            }
            
            // Append bot message safely within the main thread
            DispatchQueue.main.async {
                self.messages.append(ChatMessage(id: UUID(), text: "", isUser: false, timestamp: Date()))
            }
            
            // Read stream word-by-word
            var buffer = ""
            for try await byte in stream {
                guard let character = String(bytes: [byte], encoding: .utf8) else { continue }
                buffer.append(character)
                
                // Process each line
                if character == "\n" {
                    print("Stream Line: \(buffer)")
                    buffer = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
                       if !buffer.isEmpty {
                           print("Stream Line: \(buffer)") // Debugging
                           if buffer.hasPrefix("data: ") {
                               buffer.removeFirst(6) // Remove the "data: " prefix
                           }
                           do {
                               if let data = buffer.data(using: .utf8) {
                                   let chunk = try JSONDecoder().decode(GroqStreamResponse.self, from: data)
                                   print("Decoded chunk: \(chunk)")
                                   if let content = chunk.choices.first?.delta.content {
                                       DispatchQueue.main.async {
                                           if let lastIndex = self.messages.indices.last {
                                               self.messages[lastIndex].text += content // Append words as they come
                                           }
                                       }
                                   }
                               }
                           } catch {
                               print("Decoding error: \(error)")
                           }
                       }
                    buffer = ""
                }
            }
            
        } catch {
            print("Error fetching Groq response: \(error)")
        }
    }
}



// Model to decode Groq response
struct GroqResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}

// Model to decode streaming response
struct GroqStreamResponse: Codable {
    struct Choice: Codable {
        struct Delta: Codable {
            let content: String?
        }
        let delta: Delta
    }
    let choices: [Choice]
}


// ChatMessage Model
struct ChatMessage: Identifiable {
    let id: UUID
    var text: String
    let isUser: Bool
    let timestamp: Date
}
