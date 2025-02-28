//
//  AppDelegate.swift
//  QuickGroq
//
//  Created by kartik khorwal on 2/28/25.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var mainWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            self.mainWindow = window
            self.applyCustomWindowSettings(to: window)
        }
        
        // Listen for new windows and apply settings
        NotificationCenter.default.addObserver(forName: NSWindow.didBecomeMainNotification, object: nil, queue: .main) { _ in
            if let window = NSApplication.shared.windows.first {
                self.mainWindow = window
                self.applyCustomWindowSettings(to: window)
            }
        }
    }
    
    // When clicking the app icon after closing all windows, show the main window instead of creating a new one
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            if let window = mainWindow {
                window.makeKeyAndOrderFront(nil) // Bring the window back to front
                self.applyCustomWindowSettings(to: window)
            }
        }
        return false // Prevent macOS from creating a new window
    }

    // Hide window instead of quitting
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    private func applyCustomWindowSettings(to window: NSWindow) {
        // Ensure this only applies to the main app window
        guard window.isVisible else { return }

        // Hide buttons
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        
        // Remove default window border
        window.styleMask.remove(.titled)
        window.styleMask.insert(.borderless)
        
        // Set border radius and background
        window.isOpaque = false
        window.backgroundColor = .clear
        window.contentView?.wantsLayer = true
        if let layer = window.contentView?.layer {
            layer.cornerRadius = 24
            layer.masksToBounds = true
            layer.borderWidth = 1
            layer.borderColor = NSColor.white.withAlphaComponent(0.2).cgColor
        }

        // Set default width and height if needed
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
