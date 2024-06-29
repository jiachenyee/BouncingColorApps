//
//  BouncingIntent.swift
//  BouncingColorApps
//
//  Created by Jia Chen Yee on 29/6/24.
//

import Foundation
import AppIntents

struct IntentProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [AppShortcut(intent: BouncingIntent(),
                            phrases: ["Show app icons"],
                            shortTitle: "Show app icons", systemImageName: "paintpalette")]
    }
}


struct BouncingIntent: AppIntent {
    static var title: LocalizedStringResource = "Red"
    static var description = IntentDescription("Show red icons")
    
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Color")
    var color: AppColor
    
    @Dependency
    private var colorsToDisplay: ColorsManager
    
    func perform() async throws -> some ReturnsValue {
        // run the function to do red
        
        return .result()
    }
}
