//
//  AppDelegate.swift
//
//  Created by Majid Jamali with ❤️ on 2/27/25.
//
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBarItem: NSStatusItem? = nil
//    var engine = AudioEngine()
    var speechRecognizer = SpeechRecognizer()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        defineStatusBarView()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func defineStatusBarView() {
        let statusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusBarItem = statusBar
        if let button = statusBar.button {
            let image = NSImage(systemSymbolName: "waveform", variableValue: 0.0, accessibilityDescription: "Status Bar Icon")
            button.image = image
            button.action = #selector(statusBarClicked)
        }
        
        // Create a menu for the status bar item
        let menu = NSMenu()
        
        // Add menu items
        menu.addItem(NSMenuItem(title: "Show Preferences", action: #selector(showPreferences), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: ""))
        
        // Assign the menu to the status bar item
        statusBar.menu = menu
    }
    
    @objc func statusBarClicked() {
        print("Status bar item clicked!")
        // You can show a menu or perform other actions here
    }
    
    @objc func showPreferences() {
        print("Show preferences...")
        // Implement your preferences logic here
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
}

