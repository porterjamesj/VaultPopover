//
//  PopoverViewController.swift
//  VaultPopover
//
//  Created by James on 4/1/18.
//  Copyright © 2018 porterjamesj. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var passInput: NSTextField!
    
    @IBOutlet weak var serviceInput: NSTextField!
    
    @IBOutlet weak var button: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passInput.delegate = self
        serviceInput.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        // TODO probably a cleaner way to just set the first responder in interface builder
        serviceInput.becomeFirstResponder()
    }
    
    public override func controlTextDidChange(_ obj: Notification) {
        if passInput.stringValue.isEmpty || serviceInput.stringValue.isEmpty {
            button.isEnabled = false
        } else {
            button.isEnabled = true
        }
    }
    
    @IBAction func activateAndSend(_ sender: Any) {
        // TODO better way to communicate with AppDelegate, or better place to put this code
        let v = passInput.stringValue
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
            // TODO really what I'm trying to do here is "reset" the UI. I don't just want to close the popover, I want to get an entirely new instance of the view / viewcontroller maybe? I'm sort of manually doing this now but there's probably a cleaner way to just discard everything and start again.
            passInput.stringValue = ""
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
