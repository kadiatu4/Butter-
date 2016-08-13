//
//  GameOverScene.swift
//  Butter!
//
//  Created by Kadiatou Diallo on 7/24/16.
//  Copyright © 2016 Kadiatou Diallo. All rights reserved.
//
import Foundation
import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    //Stores Stores and Bonus Points
    var highscoreLabel: SKLabelNode!
    var highscore: Int = highscoreVal
    
    var currentScore: SKLabelNode!
    
    var points: Int = CurrentScore
    
    var currentCoins: SKLabelNode!
    var bonus: SKLabelNode!
    
    //Volume
    var onVolume: MSButtonNode!
    var offVolume: MSButtonNode!
    
    //Homepage
    var home: MSButtonNode!
    
    //Share
    var share: MSButtonNode!
    

    override func didMoveToView(view: SKView) {
        //Setup your scene
        
        //Reference for highScore
         highscoreLabel = childNodeWithName("highscoreLabel") as! SKLabelNode
        
        //Changes value of High Score
        highscoreLabel.text = String(highscore)
        
        //Reference for current score
        currentScore = childNodeWithName("currentScore") as! SKLabelNode
        
        //Changes value of Current Score
        currentScore.text = String(points)
        
        //Reference for Volume button
        onVolume = childNodeWithName("onVolume") as! MSButtonNode
        offVolume = childNodeWithName("offVolume") as! MSButtonNode
        
        //Reference for Home page
        home = childNodeWithName("home") as! MSButtonNode
        
        //Reference for Share button
        share = childNodeWithName("share") as! MSButtonNode
        
        //Executes when button is pressed
        home.selectedHandler = {
            //grab reference to SpiteKit view
            let skView = self.view as SKView!
            //Load Game scene
            let scene = MainMenu(fileNamed: "MainMenu") as MainMenu!
            
            //Ensure correct aspect mode
            scene.scaleMode = .AspectFill
            
            //Start Game Scene
            skView.presentScene(scene)

        }
        
        
        if volumeOn == true{
            offVolume.hidden = true
        }
        else if volumeOff == true{
            onVolume.hidden = true
        }
        //Set On Volume button
        onVolume.selectedHandler = {
            self.onVolume.hidden = true
            self.offVolume.hidden = false
            volumeOn = false
            volumeOff = true
        }
        
        //Set Off Volume button
        offVolume.selectedHandler = {
            self.offVolume.hidden = true
            self.onVolume.hidden = false
            volumeOn = true
            volumeOff = false
        }
        
        //Set Share button
        share.selectedHandler = {
            self.shareScore(self.scene!)
        }

        

        //Reference for current coins
        // currentCoins = childNodeWithName("currentCoins") as! SKLabelNode
           
        
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
    func shareScore(scene: SKScene) {
        let postText: String = "Check out my score! Can you beat it? #BUTTER!"
        let postImage: UIImage = getScreenshot(scene)
        let activityItems = [postText, postImage]
        let activityController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        let controller: UIViewController = scene.view!.window!.rootViewController!
        
        controller.presentViewController(
            activityController,
            animated: true,
            completion: nil
        )
    }
    
    func getScreenshot(scene: SKScene) -> UIImage {
        let snapshotView = scene.view!.snapshotViewAfterScreenUpdates(true)
        let bounds = UIScreen.mainScreen().bounds
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
        
        snapshotView.drawViewHierarchyInRect(bounds, afterScreenUpdates: true)
        
        let screenshotImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return screenshotImage;
    }

}
