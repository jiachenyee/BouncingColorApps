//
//  AppDelegate.swift
//  BouncingColorApps
//
//  Created by Jia Chen Yee on 28/6/24.
//

import Cocoa
import AppIntents

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        AppDependencyManager.shared.add(dependency: ColorsManager.shared)
        
        IntentProvider.updateAppShortcutParameters()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

