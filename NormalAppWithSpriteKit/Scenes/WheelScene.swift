//
//  WheelScene.swift
//  NormalAppWithSpriteKit
//
//  Created by Brian Miller on 2/19/19.
//  Copyright © 2019 Brian Miller. All rights reserved.
//

import UIKit
import SpriteKit

protocol WheelSceneDelegate: class {
    func didBeginSpinning()
    func didEndSpinningWithWinner(winner: Player?)
}

class WheelScene: SKScene {
    private let wheelCategory: UInt32 = 0x1 << 1
    private let lightCategory: UInt32 = 0x1 << 2
    
    private var wheel: SKSpriteNode?
    private var light: SKLightNode?
    private var pointer: SKSpriteNode?
    
    private var wheelTexture: SKTexture!
    private var wheelNormalTexture: SKTexture!
    private var pointerTexture: SKTexture!
    private var players: [Player]!
    private weak var wheelDelegate: WheelSceneDelegate?
    
    private var isSpinning: Bool = false
    private var atRestTimeInterval: TimeInterval?
    
    private let fireworkEmitter = SKEmitterNode(fileNamed: "Firework.sks")
    
    public func configureWith(players: [Player], wheelImage: UIImage?, wheelNormalImage: UIImage?, delegate: WheelSceneDelegate?) {
        guard let wheelImage = wheelImage,
            let wheelNormalImage = wheelNormalImage,
            let pointerImage = UIImage(named: "Pointer") else {
            assertionFailure("Required Texture Images Invalid")
            return
        }
        
        wheelTexture = SKTexture(image: wheelImage)
        wheelNormalTexture = SKTexture(image: wheelNormalImage)
        pointerTexture = SKTexture(image: pointerImage)
        
        self.players = players
        wheelDelegate = delegate
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        addWheel()
        addLight()
        addPointer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        guard let wheel = wheel else { return }
        
        if isSpinning && nearlyAtRest(node: wheel) {
            if let atRestTimeInterval = atRestTimeInterval {
                if atRestTimeInterval + 2 <= currentTime {
                    debugPrint("stopping: \(currentTime)")
                    isSpinning = false
                    self.atRestTimeInterval = nil
                    wheel.physicsBody?.angularVelocity = 0.0
                    wheel.physicsBody?.velocity = .zero
                    
                    wheelDelegate?.didEndSpinningWithWinner(winner: determinedWinner())
                    fadeSceneComponents()
                    displayFireworks(numberOfFireworks: 20)
                }
            } else {
                debugPrint("nearlyAtRest: \(currentTime)")
                atRestTimeInterval = currentTime
            }
        } else {
            atRestTimeInterval = nil
        }
    }
    
    func spinWheel() {
        guard let wheel = wheel else { return }
        
        let spinVelocity = -CGFloat(arc4random_uniform(3000) + 4000)
        debugPrint("Spin Velocity: \(spinVelocity)")
        wheel.physicsBody?.applyAngularImpulse(spinVelocity)
        wheelDelegate?.didBeginSpinning()
        isSpinning = true
        atRestTimeInterval = nil
    }
    
    private func fadeSceneComponents() {
        wheel?.run(SKAction.fadeAlpha(to: 0.3, duration: 0.2))
        pointer?.run(SKAction.fadeOut(withDuration: 0.2))
    }
    
    private func determinedWinner() -> Player? {
        if let winningAngle = wheel?.zRotation {
            let normalizedWinningAngle = normalizedDegress(GLKMathRadiansToDegrees(Float(winningAngle)))
            var ticketCount = players.reduce(0) { $0 + $1.tickets }
            if ticketCount == 0 {
                ticketCount = UInt(players.count)
            }
            
            var startingAngle: CGFloat = 0
            for player in players {
                let playerTickets = player.tickets > 0 ? player.tickets : 1
                
                let endAngle = startingAngle + CGFloat(Double.pi * 2) * (CGFloat(playerTickets) / CGFloat(ticketCount))
                
                let normalizedStartingAngle = normalizedDegress(GLKMathRadiansToDegrees(Float(startingAngle)))
                let normalizedEndingAngle = normalizedDegress(GLKMathRadiansToDegrees(Float(endAngle)))
                if normalizedWinningAngle > normalizedStartingAngle &&
                    normalizedWinningAngle < normalizedEndingAngle {
                    return player
                }
                
                startingAngle = endAngle
            }
        }
        
        return nil
    }
    
    private func addWheel() {
        let wheel = SKSpriteNode(texture: wheelTexture)
        wheel.normalTexture = wheelNormalTexture.generatingNormalMap()
        wheel.lightingBitMask = lightCategory
        wheel.position = .zero
        wheel.physicsBody = SKPhysicsBody(circleOfRadius: wheelTexture.size().width / 2, center: wheel.position)
        wheel.physicsBody?.categoryBitMask = wheelCategory
        wheel.physicsBody?.isDynamic = true
        wheel.physicsBody?.allowsRotation = true
        wheel.physicsBody?.affectedByGravity = false
        wheel.physicsBody?.angularDamping = 0.9
        wheel.physicsBody?.pinned = true
        addChild(wheel)
        
        self.wheel = wheel
    }
    
    private func addLight() {
        let lightNode = SKLightNode()
        lightNode.zPosition = 1
        lightNode.position = .zero
        lightNode.ambientColor = UIColor(white: 0.4, alpha: 1.0)
        lightNode.categoryBitMask = lightCategory
        addChild(lightNode)
        
        self.light = lightNode
    }
    
    private func addPointer() {
        let pointer = SKSpriteNode(texture: pointerTexture)
        pointer.zPosition = 2
        pointer.position = CGPoint(x: 0, y: (wheelTexture.size().width / 2) + (pointerTexture.size().height / 2))
        pointer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
        pointer.lightingBitMask = lightCategory
        addChild(pointer)
        
        self.pointer = pointer
    }
    
    private func displayFireworks(numberOfFireworks: UInt) {
        let colors: [UIColor] = [.red, .orange, .yellow, .white, .green, .blue, .purple]
        
        for _ in 0..<numberOfFireworks {
            let x: CGFloat = CGFloat(arc4random_uniform(UInt32(frame.width))) - abs(frame.minX)
            let y: CGFloat = CGFloat(arc4random_uniform(UInt32(frame.height))) - abs(frame.minY)
            let position = CGPoint(x: x, y: y)
            let delay = CGFloat(arc4random_uniform(UInt32(20))) / 10.0
            let colorIndex = Int(arc4random_uniform(UInt32(colors.count)))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(delay)) { [weak self] in
                if let emitterToAdd = self?.fireworkEmitter?.copy() as? SKEmitterNode {
                    let colorValues: [UIColor] = [colors[colorIndex], .white]
                    let times: [NSNumber] = [0.3, 1.0]
                    emitterToAdd.particleColorSequence = SKKeyframeSequence(keyframeValues: colorValues, times: times)
                    emitterToAdd.position = position
                    
                    let addEmitterAction = SKAction.run {
                        self?.addChild(emitterToAdd)
                    }
                    let emitterDuration = emitterToAdd.particleLifetime
                    let waitAction = SKAction.wait(forDuration: TimeInterval(emitterDuration))
                    let removeAction = SKAction.run({
                        emitterToAdd.removeFromParent()
                    })
                    
                    let sequence = SKAction.sequence([addEmitterAction, waitAction, removeAction])
                    self?.run(sequence)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchPosition = touch.location(in: self)
        
        light?.position = touchPosition
    }
}

// MARK: - Helpers
private extension WheelScene {
    func angularSpeed(velocity: CGFloat) -> Float {
        return fabsf(Float(velocity))
    }
    
    func normalizedDegress(_ degrees: Float) -> Float {
        var normalizedDegress = degrees
        while normalizedDegress < 0 {
            normalizedDegress += 360.0
        }
        
        return normalizedDegress
    }
    
    func nearlyAtRest(node: SKNode) -> Bool {
        guard let physicsBody = node.physicsBody else {
            return false
        }
        
        let angularVelocity = angularSpeed(velocity: physicsBody.angularVelocity)
        //print(angularVelocity)
        return angularVelocity < 0.2
    }
}
