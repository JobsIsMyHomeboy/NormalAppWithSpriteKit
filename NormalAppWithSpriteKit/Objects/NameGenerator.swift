//
//  NameGenerator.swift
//  NormalMapWithSpriteKitBase
//
//  Created by Brian Miller on 2/17/19.
//  Copyright © 2019 Brian Miller. All rights reserved.
//

import Foundation

struct NameGenerator {
    static let firstNames = ["James","David","Christopher","George","Ronald","John","Richard","Daniel","Kenneth","Anthony","Robert","Charles","Paul","Steven","Kevin","Michael","Joseph","Mark","Edward","Jason","William","Thomas","Donald","Brian","Jeff","Mary","Jennifer","Lisa","Sandra","Michelle","Patricia","Maria","Nancy","Donna","Laura","Linda","Susan","Karen","Carol","Sarah","Barbara","Margaret","Betty","Ruth","Kimberly","Elizabeth","Dorothy","Helen","Sharon","Deborah"]
    static let lastNames = ["Smith","Anderson","Clark","Wright","Mitchell","Johnson","Thomas","Rodriguez","Lopez","Perez","Williams","Jackson","Lewis","Hill","Roberts","Jones","White","Lee","Scott","Turner","Brown","Harris","Walker","Green","Phillips","Davis","Martin","Hall","Adams","Campbell","Miller","Thompson","Allen","Baker","Parker","Wilson","Garcia","Young","Gonzalez","Evans","Moore","Martinez","Hernandez","Nelson","Edwards","Taylor","Robinson","King","Carter","Collins"]
    
    static func randomName() -> String {
        let firstName = firstNames[Int(arc4random_uniform(UInt32(firstNames.count)))]
        let lastName = lastNames[Int(arc4random_uniform(UInt32(lastNames.count)))]
        
        return "\(firstName) \(lastName)"
    }
}
