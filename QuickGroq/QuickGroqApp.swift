//
//  QuickGroqApp.swift
//  QuickGroq
//
//  Created by kartik khorwal on 2/26/25.
//

import SwiftUI
import AppKit

@main
struct QuickGroqApp: App {
    @StateObject private var chatManager = ChatManager() // Centralized State
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(chatManager)
                    .ignoresSafeArea()
                    .containerBackground(
                        .ultraThickMaterial, for: .window
                    )
                
                VStack(spacing: 0) {
                    CustomNavBar()
                        .environmentObject(chatManager)
                    Spacer()
                }
            }
            .ignoresSafeArea()
//            .onAppear {
//                customizeWindowAppearance()
//                
//                // Listen for new windows and apply settings
//               NotificationCenter.default.addObserver(forName: NSWindow.didBecomeMainNotification, object: nil, queue: .main) { _ in
//                   customizeWindowAppearance()
//               }
//            }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
    
    private func customizeWindowAppearance() {
        DispatchQueue.main.async {
            for window in NSApplication.shared.windows {
                applyCustomWindowSettings(to: window)
            }
        }
    }
    
    // Helper function to apply custom settings
    private func applyCustomWindowSettings(to window: NSWindow) {
        // Hide buttons
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        
        // Remove default window border
        window.styleMask.remove(.titled)
        window.styleMask.insert(.borderless)
        
        // Set border radius
        window.isOpaque = true
        window.backgroundColor = .clear
        window.contentView?.wantsLayer = true
        if let layer = window.contentView?.layer {
            layer.cornerRadius = 24
            layer.masksToBounds = true
            layer.borderWidth = 1
            layer.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
        }

        // Set default width and height
        let screenSize = NSScreen.main?.frame.size ?? CGSize(width: 1280, height: 800)
        let defaultWidth: CGFloat = 520
        let defaultHeight: CGFloat = 600
        let x = (screenSize.width - defaultWidth) / 2
        let y = (screenSize.height - defaultHeight) / 2
        
        window.setFrame(NSRect(x: x, y: y, width: defaultWidth, height: defaultHeight), display: true)
        
        // Round the outer window frame
        window.hasShadow = true
    }
}

struct CustomNavBar: View {
    @EnvironmentObject var chatManager: ChatManager
    @State private var showSettings = false // Toggle for settings bar

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        if let window = NSApplication.shared.windows.first {
                            window.orderOut(nil) // Hide the window instead of closing
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .opacity(0.7)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 2)
                    
                    Text("Quick Groq")
                    
                    Spacer()
                    
                    Button(action: {
                        chatManager.resetMessages()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16))
                            .opacity(0.7)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 2)
                    
                    Button(action: {
                        showSettings.toggle() // Toggle settings bar
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16))
                            .opacity(0.7)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading, 2)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(.ultraThinMaterial)
                .ignoresSafeArea(edges: .top)
                .onDragGestureForWindow()

                // SettingsBar appears here
                if showSettings {
                    SettingsBar(showSettings: $showSettings)
                        .zIndex(1) // Ensure SettingsBar is above other elements
                }
            }
            
        }
    }
}

// Window Drag Extension
extension View {
    func onDragGestureForWindow() -> some View {
        self.gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if let window = NSApplication.shared.windows.first,
                       let event = NSApp.currentEvent {
                        window.performDrag(with: event)
                    }
                }
        )
    }
}
