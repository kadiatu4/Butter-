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
    
      override func didMoveToView(view: SKView) {
        //Setup your scene
        
  
        
    }
    override func update(currentTime: NSTimeInterval) {
        
        //Update Time 
        spawnTimer += fixedDelta
        
       
    }
}
