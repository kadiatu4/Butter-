//
//  GameScene.swift
//  Butter!
//
//  Created by Kadiatou Diallo on 7/13/16.
//  Copyright (c) 2016 Kadiatou Diallo. All rights reserved.
//

import SpriteKit

enum GameState{
    case Menu, Active, GameOver
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    //Game State
    var gameState: GameState = .Menu
    
    /* UI Objects */
    var counterTop: SKSpriteNode!
    var left, right: SKNode!
    
    //Stores the location of the edges of the Pancake
    var location: CGPoint!
    var edgeLeft, edgeRight: CGFloat!
    
    //Stores Number of Pancake stacked
    var pancakeTower: [MSReferenceNode] = []
    
    //Stores Number of Pancakes
    var pancakes: [MSReferenceNode] = []
    var spawnTimer: CFTimeInterval = 0
    var sinceTouch: CFTimeInterval = 0
    
    //Scrolls Background
    var scrollLayer: SKNode!
    let scrollSpeed: CGFloat = 20
    
    /* Camera */
    var cameraTarget: SKNode?
    
    /* Variables */
    var addYPosition = 0
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS*/
   
    /*Resource Path for Pancakes */
    let resourcePath = NSBundle.mainBundle().pathForResource("Pancake", ofType: "sks")
    
    //Stores Previous and Current pancake
     var prevCount = 0
     var currCount = 1
    
    //Stores the Score
    var scoreLabel: SKLabelNode!
    var points: Int = 0{
        didSet{
        scoreLabel.text = String(points)
        }
        
    }
    
    override func didMoveToView(view: SKView) {
        
        //Reference for Counter Top
        counterTop = self.childNodeWithName("//counterTop") as! SKSpriteNode
        
        //Reference for Left and Right Nodes
        left = self.childNodeWithName("left")
        right = self.childNodeWithName("right")
        
        //Reference for Scroll Layer
        scrollLayer = self.childNodeWithName("scrollLayer")
        
        //Reference for Score Label
        scoreLabel = childNodeWithName("//scoreLabel") as! SKLabelNode
    
        //Creates Pancake
        let Pancake = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
        
        //Add Pancakes
        addChild(Pancake)
        
        //Stack Pancakes on top of each other
        let startPosition = 120
        addYPosition += 20
        var newYPosition = startPosition + addYPosition
        
        
//        //Position Pancakes
//        Pancake.avatar.position = CGPoint(x: 151, y: newYPosition)
        
        //Move Pancake
        movePancake(Pancake)
        
        //Add Pancakes in Array
        pancakeTower.append(Pancake)
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self

        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Disable touch if game state is not active */
        //if gameState != .Active {return}

        //Stores the previous Pancake
        let previousPancake = pancakeTower[prevCount]
        
        //Drops Previous Pancake
         dropPancakes(previousPancake)
        
        //Creates new Pancakes
        let Pancake = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
     
        //Add Pancakes in Array
        pancakeTower.append(Pancake)
        
        //Stores Current Pancake
        let currentPancake = pancakeTower[currCount]
        print(sinceTouch)
        
        //Moves Pancakes
        movePancake(Pancake)
        
        if sinceTouch > 0.4 {

            //Add Pancakes
            addChild(Pancake)
            
            //Stack Pancakes on top of each other
            let startPosition = 120
            addYPosition += 20
            var newYPosition = startPosition + addYPosition
            
            
//            //Positions Pancakes when dropped
//            Pancake.avatar.position = CGPoint(x:151, y: newYPosition)
            
            //Pancakes Zposition
            Pancake.zPosition += 5
        }
        
//        while sinceTouch <= 1.0{
//
//             print("Inside while loop, sinceTouch = \(sinceTouch)")
//            if sinceTouch > 1.0 {
//                
//                //Add Pancakes
//                addChild(Pancake)
//                
//                //Stack Pancakes on top of each other
//                let startPosition = 120
//                addYPosition += 20
//                var newYPosition = startPosition + addYPosition
//                
//                
//                //Positions Pancakes when dropped
//                Pancake.avatar.position = CGPoint(x:151, y: newYPosition)
//                
//                //Pancakes Zposition
//                Pancake.zPosition += 5
//            }
//        }
     
        
      
        
        //Drop Animation
        FlipPancakes(Pancake)
        
        //Checks to see if it is a new pancake
        if currentPancake != previousPancake{
          previousPancake.removeActionForKey("movingPancake")
        }
        
        /* Set camera to follow pancake */
        cameraTarget = currentPancake.avatar
        
        //Increment the index of the Pancakes
         prevCount += 1
         currCount += 1
       
        //Add Pancake to Pancakes Array
        pancakes.append(Pancake)
        
        //Reset Since Touch
        sinceTouch = 0
        
        //Score
        points = pancakes.count

    }
    
    override func update(currentTime: CFTimeInterval) {
   
        //Stores the previous Pancake
        let previousPancake = pancakeTower[prevCount]

        //Scroll Background
        if pancakeTower.count >= 10{
            scrollBackground()
        }
        
        /*Update time since Pancake was dropped*/
        sinceTouch += fixedDelta

        /* Check we have a valid camera target to follow */
        if let cameraTarget = cameraTarget {
            
            /* Set camera position to follow target vertically, keep horizontal locked */
            camera?.position = CGPoint(x:camera!.position.x, y:cameraTarget.position.y)
            
            /* Clamp camera scrolling to our visible scene area only */
            camera?.position.y.clamp(283, previousPancake.avatar.position.y)
            }
       
    }

    func movePancake(Pancake: MSReferenceNode ){
        //Set values for where the pancake should reach on the screen
        let moveLeft = SKAction.moveToX(-20, duration: 1)
        let moveRight = SKAction.moveToX(180, duration: 1)
        let appearLeft = SKAction.moveToX(-120, duration: 0.5)
        let appearRight = SKAction.moveToX(250, duration: 0.5)
        
        //First Pancake Appears  From Right
        if pancakeTower.count == 1 {
            //Enter Pancake From the Right Side (OFF-SCREEN)
            Pancake.runAction(appearRight)
            //Joins the moveLeft and moveRight and loops forever
            let moveBackAndForth = SKAction.repeatActionForever(SKAction.sequence([moveLeft, moveRight]))
            //Adds the action to the Pancakes
            Pancake.runAction(moveBackAndForth, withKey: "movingPancake")
        }

        //Pancakes Appear from Left
        else if pancakeTower.count % 2 == 0 {
            Pancake.avatar.position.x = -120
            //Enter Pancake From the Left Side (OFF-SCREEN)
            Pancake.runAction(appearRight)
            //Joins the moveLeft and moveRight and loops forever
            let moveBackAndForth = SKAction.repeatActionForever(SKAction.sequence([moveRight, moveLeft]))
            //Adds the action to the Pancakes
            Pancake.runAction(moveBackAndForth, withKey: "movingPancake")
        }
            //Pancakes Appear from Right
        else {
            
            Pancake.avatar.position.x = 250
            //Enter Pancake From the Right Side (OFF-SCREEN)
            Pancake.runAction(appearLeft)
            //Joins the moveLeft and moveRight and loops forever
            let moveBackAndForth = SKAction.repeatActionForever(SKAction.sequence([moveLeft, moveRight]))
            //Adds the action to the Pancakes
            Pancake.runAction(moveBackAndForth, withKey: "movingPancake")
        }
    }
    
    func dropPancakes(Pancake: MSReferenceNode){
        //Drops the pancake down by 50
        Pancake.runAction(SKAction.sequence([
            SKAction.moveBy(CGVector(dx: 0, dy: -50), duration: 0.10)]))
        }
    
    func FlipPancakes(Pancake: MSReferenceNode){
        //Stores the previous Pancake
        var previousPancake = pancakeTower[prevCount]
        
        //Stores the current Pancake 
        var currentPancake = pancakeTower[currCount]
        
        //Converts the Points of the Pancake's Position
        location = previousPancake.convertPoint(previousPancake.position, toNode: self)
        
        //Converts the Point of the Left Node Position
        edgeLeft = left.position.x
        
        //Converts the Point of the Right Node Position
        edgeRight = right.position.x
        
        //Calls DropLeft Animation
        let DropLeft = SKAction(named: "DropLeft")!
        
        //Calls DropRight Animation
       let DropRight = SKAction(named: "DropRight")!
        
        //Remove the Pancake from Parent
        let remove = SKAction.removeFromParent()
        
        //Checks where the Pancake has landed
        if location.x > edgeRight{
            
            let sequence = SKAction.sequence([DropRight, remove])
            previousPancake.runAction(sequence)
        }
        else if location.x < edgeLeft {
            let sequence = SKAction.sequence([DropLeft, remove])
            previousPancake.runAction(sequence)
        }
        
        gameState = .GameOver
        //gameOver()

    }
    
    func scrollBackground(){
        
        //Scroll World
        scrollLayer.position.y -= scrollSpeed * CGFloat(fixedDelta)
        
        //Loop through Background Node
        for background in scrollLayer.children as! [SKSpriteNode]{
            
            //Get ground node position, convert node position to scene space
            let backgroundPosition = background.convertPoint(CGPoint(x: 0, y: 0), toNode: camera!)
            
            //Check if background sprite has left the scene
            if backgroundPosition.y + background.size.height * 0.5 <= self.size.height * -0.5  {
                background.position.y += self.size.height * 2
                
            }
        }
    }
    
    func gameOver(){
        
        /* Game over! */
        gameState = .GameOver
        
        return
    
    }
}