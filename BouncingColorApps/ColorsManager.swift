//
//  ColorsManager.swift
//  BouncingColorApps
//
//  Created by Jia Chen Yee on 29/6/24.
//

import Foundation
import AppKit
import Observation

@MainActor
class ColorsManager {
    
    var colors: [AppColor] = []
    var colorManagerDelegate: ColorManagerDelegate?
    
    init() {
        
    }
    
    func showColor(_ color: AppColor) {
        colors.append(color)
        print(colors)
        colorManagerDelegate?.displayNewColor(color)
    }
    
    static let shared = ColorsManager()
}
