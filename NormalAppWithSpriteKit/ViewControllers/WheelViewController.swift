//
//  WheelViewController.swift
//  NormalMapWithSpriteKitBase
//
//  Created by Brian Miller on 2/17/19.
//  Copyright © 2019 Brian Miller. All rights reserved.
//

import UIKit
import SpriteKit

class WheelViewController: UIViewController {
    @IBOutlet private var timerLabel: UILabel!
    @IBOutlet private var winnerLabel: UILabel!
    @IBOutlet private var spinButton: UIButton! {
        didSet {
            spinButton.layer.borderWidth = 2
            spinButton.layer.cornerRadius = 8
            spinButton.layer.borderColor = UIColor(named: "SpinBorder")?.cgColor
            spinButton.backgroundColor = UIColor(named: "SpinBackground")
            spinButton.setTitle("SPIN WHEEL", for: .normal)
        }
    }
    @IBOutlet private var timerView: UIVisualEffectView! {
        didSet {
            timerView.alpha = 0
        }
    }
    private var players: [Player]!
    private var timer: Timer?
    private var wheelScene: WheelScene?
    
    public func configure(with players: [Player]) {
        self.players = players
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let view = view as? SKView {
            if let scene = SKScene(fileNamed: "WheelScene") as? WheelScene {
                let screenScale = UIScreen.main.scale
                scene.size = CGSize(width: view.bounds.width * screenScale, height: view.bounds.height * screenScale)
                scene.scaleMode = .aspectFit
                scene.backgroundColor = .darkGray
                
                let wheelImages = generateWheelSprites()
                scene.configureWith(players: players, wheelImage: wheelImages.wheelImage, wheelNormalImage: wheelImages.wheelNormalImage, delegate: self)
                view.presentScene(scene)
                
                wheelScene = scene
            }
            
            view.ignoresSiblingOrder = true
            view.allowsTransparency = false
            
            //debugging
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    private func generateWheelSprites() -> (wheelImage: UIImage?, wheelNormalImage: UIImage?) {
        let side = (UIScreen.main.bounds.width - 10) * UIScreen.main.scale
        let wheel = WheelView(frame: CGRect(x: 0, y: 0, width: side, height: side))
        wheel.backgroundColor = .clear
        wheel.configure(players: players)
        view.addSubview(wheel)
        
        let wheelImage = generateWheelSprite(wheel: wheel)
        let wheelNormalImage = generateWheelNormalSprite(wheel: wheel)
        wheel.removeFromSuperview()
        
        return (wheelImage: wheelImage, wheelNormalImage: wheelNormalImage)
    }
    
    private func generateWheelSprite(wheel: WheelView) -> UIImage? {
        UIGraphicsBeginImageContext(wheel.bounds.size)
        wheel.layer.render(in: UIGraphicsGetCurrentContext()!)
        let wheelImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return wheelImage
    }
    
    private func generateWheelNormalSprite(wheel: WheelView) -> UIImage? {
        wheel.redrawForNormalMap()
        UIGraphicsBeginImageContext(wheel.bounds.size)
        wheel.layer.render(in: UIGraphicsGetCurrentContext()!)
        let wheelNormalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return wheelNormalImage
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: - Game Actions
private extension WheelViewController {
    @IBAction func spinButtonTapped() {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        navigationController?.navigationBar.tintColor = .lightGray
        countdownAndSpin()
    }
    
    func countdownAndSpin() {
        var countdownValue = 3
        
        timer?.invalidate()
        timer = nil
        
        timerView.alpha = 0
        timerView.isHidden = false
        timerLabel.text = "\(countdownValue)"
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { [weak self] in
            self?.spinButton.alpha = 0
            self?.timerView.alpha = 1
        }) { [weak self] (completed) in
            self?.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                countdownValue = countdownValue - 1
                if countdownValue == 0 {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                        self?.timerView.alpha = 0
                    }, completion: { (completed) in
                        guard let self = self else { return }
                        self.timerView.isHidden = true
                        self.timer?.invalidate()
                        
                        self.wheelScene?.spinWheel()
                    })
                }
                
                self?.timerLabel.text = "\(countdownValue)"
            })
        }
    }
    
    func displayMessageForWinner(_ winner: Player) {
        winnerLabel.text = """
        Congratulations!
        \(winner.name)
        has won!
        """
        winnerLabel.setNeedsDisplay()
        
        perform(#selector(animateWinnerMessage), with: nil, afterDelay: 0.01)
    }
    
    @objc
    func animateWinnerMessage() {
        let winnerImage = UIImage(view: winnerLabel)
        let imageView = UIImageView(image: winnerImage)
        imageView.frame = CGRect.zero
        imageView.center = CGPoint(x: view.center.x, y: view.center.y - 100)
        view.addSubview(imageView)
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.beginFromCurrentState,.calculationModeCubic], animations: { [weak self] in
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.4, animations: {
                imageView.frame.size = CGSize(width: (self?.winnerLabel.frame.size.width ?? 0) / 2, height: (self?.winnerLabel.frame.size.height ?? 0) / 2)
                imageView.center = CGPoint(x: self?.view.center.x ?? 0, y: (self?.view.center.y ?? 0) + 100)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.9, animations: {
                imageView.frame.size = CGSize(width:  (self?.winnerLabel.frame.size.width ?? 0) * 1.2, height: (self?.winnerLabel.frame.size.height ?? 0) * 1.2)
                imageView.center = CGPoint(x: self?.view.center.x ?? 0, y: self?.view.center.y ?? 0)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1, animations: {
                imageView.frame.size = CGSize(width: self?.winnerLabel.frame.size.width ?? 0, height: self?.winnerLabel.frame.size.height ?? 0)
                imageView.center = CGPoint(x: self?.view.center.x ?? 0, y: self?.view.center.y ?? 0)
            })
        }) { [weak self] (completed) in
            self?.navigationController?.navigationBar.isUserInteractionEnabled = true
            self?.navigationController?.navigationBar.tintColor = self?.view.tintColor
        }
    }
    
    func displayErrorMessage() {
        let alertController = UIAlertController.init(title: "Oops", message: "It looks like there was an error. Go ahead and spin again.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension WheelViewController: WheelSceneDelegate {
    func didBeginSpinning() {
        spinButton?.isEnabled = false
    }
    
    func didEndSpinningWithWinner(winner: Player?) {
        if let winner = winner {
            displayMessageForWinner(winner)
        } else {
            navigationController?.navigationBar.isUserInteractionEnabled = true
            navigationController?.navigationBar.tintColor = view.tintColor
            displayErrorMessage()
        }
    }
}
