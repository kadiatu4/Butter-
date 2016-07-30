//
//  GameOverScene.swift
//  Butter!
//
//  Created by Kadiatou Diallo on 7/24/16.
//  Copyright © 2016 Kadiatou Diallo. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    //Time the Intro
    var spawnTimer: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS*/
    
    //Pancakes on Screen
    var pancake1: SKSpriteNode!
//     var pancake2: SKSpriteNode!
//     var pancake3: SKSpriteNode!
//     var pancake4: SKSpriteNode!
//     var pancake5: SKSpriteNode!
//     var pancake6: SKSpriteNode!
//     var pancake7: SKSpriteNode!
//     var pancake8: SKSpriteNode!
//     var pancake9: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        //Setup your scene
        
        //Pancake 1
        pancake1 = childNodeWithName("pancake1") as! SKSpriteNode
        if spawnTimer <= 0.5{
            pancake1.position = CGPoint(x: 229, y: 179)
            pancake1.size = CGSize(width: 98, height: 85)
        }
        if spawnTimer == 0.5 {
            pancake1.position = CGPoint(x: 218, y: 209)
            pancake1.size = CGSize(width: 119, height: 103)
        }
        if spawnTimer == 1.0 {
            pancake1.position = CGPoint(x: 178, y: 242)
            pancake1.size = CGSize(width: 143, height: 118)
        }
        if spawnTimer == 1.5 {
            pancake1.position = CGPoint(x: 141, y: 281)
            pancake1.size = CGSize(width: 171, height: 148)
        }
        if spawnTimer == 2.0 {
            pancake1.position = CGPoint(x: 122, y: 329)
            pancake1.size = CGSize(width: 208, height: 194)
        }
        if spawnTimer == 2.5 {
            pancake1.position = CGPoint(x: 81, y: 392)
            pancake1.size = CGSize(width: 249, height: 242)
        }
        if spawnTimer == 3.0 {
            pancake1.position = CGPoint(x: 33, y: 434)
            pancake1.size = CGSize(width: 295, height: 265)
        }
        if spawnTimer == 3.5 {
            pancake1.position = CGPoint(x: -0.84, y: 528)
            pancake1.size = CGSize(width: 295, height: 265)
        }
        if spawnTimer == 4.0 {
            pancake1.position = CGPoint(x: 160, y: 634)
            pancake1.size = CGSize(width: 366, height: 309)
        }
        
        
    }
    override func update(currentTime: NSTimeInterval) {
        
        //Update Time 
        spawnTimer += fixedDelta
        
       
    }
}
