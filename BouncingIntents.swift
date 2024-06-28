//
//  BouncingIntents.swift
//  BouncingColorApps
//
//  Created by Jia Chen Yee on 28/6/24.
//

import AppIntents

struct IntentProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [AppShortcut(intent: RedIntent(), phrases: ["Show red things"], shortTitle: "Red", systemImageName: "paintpalette")]
    }
}


struct RedIntent: AppIntent {
    static var title: LocalizedStringResource = "Red"
    static var description = IntentDescription("Show red icons")
    
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some ReturnsValue {
        // run the function to do red
        
        return .result(value: "")
    }
}
