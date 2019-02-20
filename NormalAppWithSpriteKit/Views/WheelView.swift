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
    private var isForNormalMap = false
    
    public func configure(players: [Player]) {
        backgroundColor = .clear
        self.players = players
    }
    
    public func redrawForNormalMap() {
        isForNormalMap = true
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let screenScale = UIScreen.main.scale
        let radius = min(rect.width - 5, rect.height - 5) / 2.0
        let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        var ticketCount = players.reduce(0) {$0 + $1.tickets}
        if ticketCount == 0 {
            ticketCount = UInt(players.count)
        }
        
        var startAngle = -CGFloat(Double.pi * 0.5)
        
        for (index, player) in players.enumerated() {
            context.setStrokeColor(isForNormalMap ? UIColor.white.cgColor : UIColor.black.cgColor)
            context.setLineWidth(2 * screenScale)
            
            let playerTickets = player.tickets > 0 ? player.tickets : 1
            let endAngle = startAngle + CGFloat(Double.pi * 2) * (CGFloat(playerTickets)/CGFloat(ticketCount))
            
            context.move(to: center)
            context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            
            //Draw the gradients
            let path = context.path?.copy()
            
            context.saveGState()
            let rgb = CGColorSpaceCreateDeviceRGB()
            let colors = colorsForIndex(index)
            if let gradient = CGGradient(colorsSpace: rgb, colors: [colors.1, colors.2] as CFArray, locations: [0.4, 1.0]) {
                
                context.clip()
                context.drawRadialGradient(gradient, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: radius, options: CGGradientDrawingOptions(rawValue: 0))
            }
            context.restoreGState()
            
            if let path = path {
                context.addPath(path)
            }
            context.strokePath()
            
            startAngle = endAngle
        }
        
        context.move(to: center)
        context.addLine(to: CGPoint(x: center.x, y: center.y - radius))
        context.strokePath()
        
        // Label Prep
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right
        
        var nameTextAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 19.0 * screenScale),
                                                                 .paragraphStyle: paragraphStyle,
                                                                 .foregroundColor: isForNormalMap ? UIColor.white : UIColor(white: 242.0/255.0, alpha: 1.0)]
        startAngle = -CGFloat(Double.pi * 0.5)
        context.translateBy(x: self.bounds.width / 2.0, y: self.bounds.height / 2)
        
        for player in players {
            context.saveGState()
            
            let playerTickets = player.tickets > 0 ? player.tickets : 1
            let wholeAngle = CGFloat(Double.pi * 2) * (CGFloat(playerTickets) / CGFloat(ticketCount))
            let name = player.name
            
            context.rotate(by: startAngle + (wholeAngle / 2))
            
            var stringSize = (name as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 19 * screenScale), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: nameTextAttributes, context: nil)
            while stringSize.size.width > radius - (25 * screenScale) {
                let font = nameTextAttributes[NSAttributedString.Key.font] as! UIFont
                nameTextAttributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: font.pointSize - 1) as Any
                
                stringSize = (name as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 19 * screenScale), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: nameTextAttributes, context: nil)
            }
            let font = nameTextAttributes[NSAttributedString.Key.font] as! UIFont
            let y: CGFloat = (-12.0 * screenScale) + (0.375 * ((19 * screenScale) - font.pointSize))
            name.draw(in: CGRect(x: 20 * screenScale, y: y, width: radius - (25 * screenScale), height: 38 * screenScale), withAttributes: nameTextAttributes)
            
            
            startAngle += wholeAngle
    
            context.restoreGState()
        }
    }

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
