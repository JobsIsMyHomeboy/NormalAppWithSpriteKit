//
//  UIColor+Additions.swift
//  NormalMapWithSpriteKitBase
//
//  Created by Brian Miller on 2/17/19.
//  Copyright © 2019 Brian Miller. All rights reserved.
//

import UIKit

extension UIColor {
    
    var lighterColor: UIColor {
        return lighterColor(removeSaturation: 0.5, resultAlpha: -1)
    }
    
    func lighterColor(removeSaturation val: CGFloat, resultAlpha alpha: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}
        
        return UIColor(hue: h,
                       saturation: max(s - val, 0.0),
                       brightness: b,
                       alpha: alpha == -1 ? a : alpha)
    }
    
    var darkerColor: UIColor {
        return darkerColor(addSaturation: 0.5, resultAlpha: -1)
    }
    
    func darkerColor(addSaturation val: CGFloat, resultAlpha alpha: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0
        
        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}
        
        return UIColor(hue: h,
                       saturation: max(s + val, 1.0),
                       brightness: b,
                       alpha: alpha == -1 ? a : alpha)
    }
}
