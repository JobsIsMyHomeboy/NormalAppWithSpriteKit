//
//  ConfigurationViewController.swift
//  NormalMapWithSpriteKitBase
//
//  Created by Brian Miller on 2/17/19.
//  Copyright © 2019 Brian Miller. All rights reserved.
//

import UIKit

class ConfigurationViewController: UIViewController {
    @IBOutlet private var numberOfPlayersLabel: UILabel!
    @IBOutlet private var useTicketsSwitch: UISwitch!
    @IBOutlet private var numberOfPlayersStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberOfPlayersDidChange()
    }
    
    @IBAction func numberOfPlayersDidChange() {
        numberOfPlayersLabel.text = "\(UInt(numberOfPlayersStepper.value))"
    }
    
    @IBAction func goToWheelTapped() {
        let players = createPlayers()
        performSegue(withIdentifier: "ToWheel", sender: players)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueIdentifier = segue.identifier else { return }
        
        if segueIdentifier == "ToWheel",
            let wheelViewController = segue.destination as? WheelViewController,
            let players = sender as? [Player] {
            wheelViewController.configure(with: players)
        }
    }
    
    private func createPlayers() -> [Player] {
        var players: [Player] = []
        for _ in 0..<UInt(numberOfPlayersStepper.value) {
            let name = NameGenerator.randomName()
            let tickets = useTicketsSwitch.isOn ? UInt(arc4random_uniform(41) + 20) : 0
            players.append(Player(name: name, tickets: tickets))
        }
        
        return players
    }
}
