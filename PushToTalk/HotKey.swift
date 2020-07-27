//
//  HotKey.swift
//  PushToTalk
//
//  Created by Jeremy Ellison on 5/14/20.
//  Copyright © 2020 yulrizka. All rights reserved.
//

import Foundation
import AppKit

class HotKey {
    
    var enabled = true
    let microphone: Microphone
    let menuItem: NSMenuItem
    var keyCode: UInt16 = 55
    var modifierFlags = NSEvent.ModifierFlags.command
    var recordingHotKey = false;
    
    init(microphone: Microphone, menuItem: NSMenuItem) {
        self.menuItem = menuItem
        self.menuItem.title = "Change HotKey (\(keyCode))"
        
        self.microphone = microphone
        // handle when application is on background
        NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.flagsChanged, handler: self.handleFlagChangedEvent)
        
        // handle when application is on foreground
        NSEvent.addLocalMonitorForEvents(matching: NSEvent.EventTypeMask.flagsChanged, handler: { (theEvent) -> NSEvent? in
            self.handleFlagChangedEvent(theEvent)
            return theEvent
        })
    }
    
    func toggle() {
        if (self.enabled == true) {
            microphone.status = MicrophoneStatus.Speaking
            self.enabled = false
        } else {
            microphone.status = MicrophoneStatus.Muted
            self.enabled = true
        }
    }
    
    func recordNewHotKey() {
        recordingHotKey = true;
    }
    
    internal func handleFlagChangedEvent(_ theEvent: NSEvent!) {
        if self.recordingHotKey {
            self.recordingHotKey = false
            self.keyCode = theEvent.keyCode
            self.modifierFlags = theEvent.modifierFlags
            self.menuItem.title = "Change HotKey (\(keyCode))"
            return;
        }
        guard theEvent.keyCode == self.keyCode else { return }
        guard self.enabled else { return }
        microphone.status = (theEvent.modifierFlags.contains(self.modifierFlags)) ? .Speaking : .Muted
    }
}
