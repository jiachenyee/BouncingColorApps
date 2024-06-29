//
//  ColorManagerDelegate.swift
//  BouncingColorApps
//
//  Created by Jia Chen Yee on 29/6/24.
//

import Foundation
import AppKit

protocol ColorManagerDelegate: NSViewController {
    func displayNewColor(_ color: AppColor)
}
