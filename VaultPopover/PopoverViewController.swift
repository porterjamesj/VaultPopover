//
//  PopoverViewController.swift
//  VaultPopover
//
//  Created by James on 4/1/18.
//  Copyright © 2018 porterjamesj. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController {
    
    
    @IBOutlet weak var text: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        NSApplication.shared.activate(ignoringOtherApps: true)
        text.becomeFirstResponder()
    }
    
    @IBAction func go(_ sender: NSButton) {
        // TODO better way to communicate with AppDelegate, or better place to put this code
        let v = text.stringValue
        if let delegate = NSApplication.shared.delegate as? AppDelegate {

            // autotype once we've switched back to the previously active app
            let center = NSWorkspace.shared.notificationCenter
            var token: NSObjectProtocol?
            token = center.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: nil) { (note)  in
                if let info = note.userInfo,
                    let app = info[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                    app == delegate.prevApp {
                    sendString(s: v)
                    center.removeObserver(token!)
                }
            }

            delegate.switchToPrevApp()
            delegate.closePopover(sender: sender)
        }
    }
    
    static func freshController() -> PopoverViewController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier(rawValue: "PopoverViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PopoverViewController else {
            fatalError("Why cant i find PopoverViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
    
}

func sendString(s: String) {
    
    // Create the base keyboard events.
    let source = CGEventSource(stateID: .hidSystemState)
    
    guard let down = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true) else { return }
    guard let up = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) else { return }
    
    // Loop through each character in the UTF16 representation of the string.
    for character in s.utf16 {
        var unichar = character as UniChar
        down.keyboardSetUnicodeString(stringLength: 1, unicodeString: &unichar)
        up.keyboardSetUnicodeString(stringLength: 1, unicodeString: &unichar)
        down.post(tap: .cghidEventTap)
        up.post(tap: .cghidEventTap)
    }
}
