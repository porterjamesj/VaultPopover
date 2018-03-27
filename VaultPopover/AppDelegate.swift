//
//  AppDelegate.swift
//  VaultPopover
//
//  Created by James on 3/25/18.
//  Copyright © 2018 porterjamesj. All rights reserved.
//

import Cocoa
import Foundation
import CoreGraphics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    func sendString(s: String) {
        
        // Create the base keyboard events.
        let source = CGEventSource(stateID: .hidSystemState)
        
        guard let down = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true) else { return }
        guard let up = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) else { return }
        
        // Loop through each character in the UTF16 representation of the string.
        for character in s.utf16 {
            
            // We can now cast it directly to a UniChar, update the events and post.
            var unichar = character as UniChar
            down.keyboardSetUnicodeString(stringLength: 1, unicodeString: &unichar)
            up.keyboardSetUnicodeString(stringLength: 1, unicodeString: &unichar)
            down.post(tap: .cghidEventTap)
            up.post(tap: .cghidEventTap)
        }
    }
    
    @objc func printQuote(_ sender: Any?) {
        sendString(s: "asda$%$%**&U::+››‡€")
    }
    
    func keyboardKeyDown(key: CGKeyCode) {
        let source = CGEventSource(stateID: .hidSystemState)
        if let cgevent = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: true) {
            if let nsevent = NSEvent(cgEvent: cgevent) {
                if cgevent.type == .keyDown && nsevent.characters!.count > 0 {
                    print(nsevent.characters!)
                }
            }
        }
        //event?.post(tap: .cghidEventTap)
    }
    
    func keyboardKeyUp(key: CGKeyCode) {
        let source = CGEventSource(stateID: .hidSystemState)
        let event = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: false)
        event?.post(tap: .cghidEventTap)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarLock"))
            button.action = #selector(printQuote(_:))
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

