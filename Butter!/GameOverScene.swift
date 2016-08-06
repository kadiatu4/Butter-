//
//  GameOverScene.swift
//  Butter!
//
//  Created by Kadiatou Diallo on 7/24/16.
//  Copyright © 2016 Kadiatou Diallo. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    //Stores Stores and Bonus Points
    var highScore: SKLabelNode!
    var highscoreVal:Int  = 0 {
        didSet{
            highScore.text = String(highscoreVal)
        }
    }
    var currentScore: SKLabelNode!
    var point: Int = 0{
        didSet{
            currentScore.text = String(point)
        }}
    var currentCoins: SKLabelNode!
    var bonus: SKLabelNode!
    
    override func didMoveToView(view: SKView) {
        //Setup your scene
       
        //Reference for highScore
        var highScore = childNodeWithName("highScore") as! SKLabelNode
        
        //Reference for current score
        var currentScore = childNodeWithName("currentScore") as! SKLabelNode
        
        //Reference for current coins
        var currentCoins = childNodeWithName("currentCoins") as! SKLabelNode
           
        
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        //grab reference to SpiteKit view
        let skView = self.view as SKView!
        //Load Game scene
        let scene = GameScene(fileNamed: "GameScene") as GameScene!
        
        //Ensure correct aspect mode
        scene.scaleMode = .AspectFill
        
        //Start Game Scene
        skView.presentScene(scene)
        

    }
    override func update(currentTime: NSTimeInterval) {
        
      
    }
}
