//
//  WheelView.swift
//  NormalAppWithSpriteKitBase
//
//  Created by Brian Miller on 2/17/19.
//  Copyright © 2019 Brian Miller. All rights reserved.
//

import UIKit

class WheelView: UIView {
    private var players: [Player]!
    private var colors: [UIColor] = []
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

// MARK: - Color Helpers
private extension WheelView {
    static private var baseColors: [UIColor] = [UIColor(red: 238.0/255.0, green: 28.0/255.0, blue: 36.0/255.0, alpha: 1.0),
                                                UIColor(red: 0.0, green: 174.0/255.0, blue: 240.0/255.0, alpha: 1.0),
                                                UIColor(red: 248.0/255.0, green: 148.0/255.0, blue: 29.0/255.0, alpha: 1.0),
                                                UIColor(red: 161.0/255.0, green: 134.0/255.0, blue: 190.0/255.0, alpha: 1.0),
                                                UIColor(red: 255.0/255.0, green: 242.0/255.0, blue: 0.0, alpha: 1.0),
                                                UIColor(red: 60.0/255.0, green: 184.0/255.0, blue: 120.0/255.0, alpha: 1.0)]
    
    private func setupColors() {
        var colorPalette = WheelView.baseColors

        for _ in players {
            var color = colorPalette[Int(arc4random_uniform(UInt32(colorPalette.count - 1)))]
            while colorPalette.count == WheelView.baseColors.count, let lastColor = colors.last, lastColor == color {
                color = colorPalette[Int(arc4random_uniform(UInt32(colorPalette.count - 1)))]
            }
            
            colors.append(color)
            
            if let index = colorPalette.index(of: color) {
                colorPalette.remove(at: index)
            }
            
            if colorPalette.count == 0 {
                colorPalette = WheelView.baseColors
            }
        }
    }
    
    private func colorsForIndex(_ index: Int) -> (CGColor, CGColor, CGColor) {
        if colors.isEmpty {
            setupColors()
        }
        
        if index < colors.count {
            let color = colors[index]
            return (color.lighterColor.cgColor, color.cgColor, color.darkerColor.cgColor)
        } else {
            return (UIColor.black.cgColor, UIColor.black.cgColor, UIColor.black.cgColor)
        }
    }
}
