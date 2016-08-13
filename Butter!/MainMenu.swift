//
//  MainMenu.swift
//  Butter!
//
//  Created by Kadiatou Diallo on 7/23/16.
//  Copyright © 2016 Kadiatou Diallo. All rights reserved.
//


import SpriteKit
import AVFoundation

//For the music
var volumeOn: Bool = true
var volumeOff: Bool = false

class MainMenu: SKScene {
    /* UI Connection */
   var buttonPlay: MSButtonNode!
   var buttonPressed: Bool = false
    
    var onVolume: MSButtonNode!
    var offVolume: MSButtonNode!
    
    var info: MSButtonNode!
    
    //Time the Intro
    var spawnTimer: CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS*/
  
    
    override func didMoveToView(view: SKView) {
        
        //Allows User to continue listening to their Music
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            print(error)
        }

        //Reference for Play Button
        buttonPlay = childNodeWithName("buttonPlay") as! MSButtonNode
        
        //Reference for Volume button
        onVolume = childNodeWithName("onVolume") as! MSButtonNode
        
        offVolume = childNodeWithName("offVolume") as! MSButtonNode
        
        //Reference for Info Button 
        info = childNodeWithName("info") as! MSButtonNode
        
        if volumeOn == true{
            offVolume.hidden = true
        }
        else if volumeOff == true{
            onVolume.hidden = true
        }
        
        //Set restart button selection handler
        buttonPlay.selectedHandler = {
            self.buttonPressed = false
            //SFX
            let playSFX = SKAction.playSoundFileNamed("PlayClicked", waitForCompletion: true)
            self.runAction(playSFX)
            
            
             self.buttonPressed = true
            
            
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
        
        //Set Info button
        info.selectedHandler = {
            let sceneAction = SKAction.runBlock({
                
                //Load info Scene
                let infoScene = InfoPage(fileNamed: "Info") as InfoPage!
                
                //Ensure correct aspect mode
                infoScene.scaleMode = .AspectFill
               
                let transition = SKTransition.doorsOpenVerticalWithDuration(1.0)
                infoScene.scaleMode = SKSceneScaleMode.AspectFill
                self.scene!.view?.presentScene(infoScene, transition: transition)
        })
              self.info.runAction(sceneAction)
            
        }
        
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        if buttonPressed == true{
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
