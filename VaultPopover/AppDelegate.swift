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
import MASShortcut

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    let popover = NSPopover()
    
    // TODO more sensible default? seems weird to grab this nonsense
    var prevApp = NSWorkspace.shared.frontmostApplication
    
    func printQuote(s: String) {
        print(s)
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
    }

    func savePreviousApp() {
        prevApp = NSWorkspace.shared.frontmostApplication
    }
    
    func switchToPrevApp() {
        if let prev = prevApp {
            prev.activate(options: [.activateIgnoringOtherApps])
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarLock"))
            //button.action = #selector(togglePopover(_:))
        }
        popover.contentViewController = PopoverViewController.freshController()
    
        let shortcut = MASShortcut.init(keyCode: UInt(kVK_ANSI_J), modifierFlags: UInt(NSEvent.ModifierFlags.command.rawValue + NSEvent.ModifierFlags.shift.rawValue))
        
        MASShortcutMonitor.shared().register(shortcut, withAction: {
            self.savePreviousApp()
            self.togglePopover("foo")
        })
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

