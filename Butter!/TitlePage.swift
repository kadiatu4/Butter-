//
//  Title Page.swift
//  Butter!
//
//  Created by Kadiatou Diallo on 7/22/16.
//  Copyright © 2016 Kadiatou Diallo. All rights reserved.
//

import SpriteKit

class TitleScene: SKScene {
    
    //Time the Intro
    var spawnTimer: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS*/

    override func didMoveToView(view: SKView) {
        //Setup your scene  
        

    }
    override func update(currentTime: NSTimeInterval) {
        
        /*Update time*/
       spawnTimer += fixedDelta
        if spawnTimer >= 0.3{
            
            //grab reference to SpiteKit view
            let skView = self.view as SKView!
            //Load Game scene
            let scene = GameScene(fileNamed: "GameScene") as GameScene!
            
            //Ensure correct aspect mode
            scene.scaleMode = .AspectFill
            
            //Start Game Scene
            skView.presentScene(scene)
            
            
        }
    }
}
