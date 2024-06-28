//
//  AppRecord.swift
//  BouncingColorApps
//
//  Created by Jia Chen Yee on 28/6/24.
//

import Foundation
import SwiftData
import AppKit

struct AppRecord {
    
    /*@Attribute(.unique)*/ var url: URL
    var name: String {
        var name = url.lastPathComponent
        
        #warning("there has got to be a better way")
        for _ in 0..<4 {
            name.removeLast()
        }
        
        return name
    }
    var image: NSImage
    
    var colors: [AppColor]
}

