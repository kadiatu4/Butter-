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
    var pancakeLeft, pancakeRight: SKNode!
    
    //Stores the location of the edges of the Screen
    var edgeLeft, edgeRight: CGFloat!
    
    //Stores the location of the edges of the Pancake
    var pancakeEdgeLeft, pancakeEdgeRight: CGFloat!
    
    //Stores Number of Pancake stacked
    var pancakeTower: [MSReferenceNode] = []
    
    //Stores Number of Pancakes
    var pancakes: [MSReferenceNode] = []
    var spawnTimer: CFTimeInterval = 0
    var sinceTouch: CFTimeInterval = 0
    var startTouch: CFTimeInterval = 0
    
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
        
        //Reference for Left and Right Nodes of Screen
        left = self.childNodeWithName("left")
        right = self.childNodeWithName("right")
        
        
        //Reference for Left and Right Nodes of Pancake
//        pancakeLeft = self.childNodeWithName("//pancakeLeft")
//        pancakeRight = self.childNodeWithName("//pancakeRight")
        
        //Reference for Scroll Layer
        scrollLayer = self.childNodeWithName("scrollLayer")
        
        //Reference for Score Label
        scoreLabel = childNodeWithName("//scoreLabel") as! SKLabelNode
    
        //Creates Pancake
        let Pancake = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
        
        //Add Pancakes in Array
        pancakeTower.append(Pancake)

        //Add Pancakes
        addChild(Pancake)
        
        //Appear Pancake
        appearPancake(Pancake)
        
        //Stack Pancakes on top of each other
        let startPosition = 120
        addYPosition += 20
        var newYPosition = startPosition + addYPosition
        
        //Position Pancake
        Pancake.avatar.position = CGPoint(x: -120 , y: newYPosition)
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self

        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        //Stores the previous Pancake
        let previousPancake = pancakeTower[prevCount]
        
        //Drops Previous Pancake
         dropPancakes(previousPancake)
        
        //Reset Start Touch
        startTouch = 0
        
        //Creates new Pancakes
        let Pancake = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
     
        //Add Pancakes in Array
        pancakeTower.append(Pancake)
        
        //Stores Current Pancake
        let currentPancake = pancakeTower[currCount]
        
        if sinceTouch > 0.4 {
            
            //Appear Pancake
            appearPancake(Pancake)
            
            //Add Pancakes
            addChild(Pancake)
            
            //Stack Pancakes on top of each other
            let startPosition = 120
            addYPosition += 20
            var newYPosition = startPosition + addYPosition
            
            
            //Pancakes start off screen
            
            if pancakeTower.count % 2 == 0 {
                //Right Side
                Pancake.avatar.position = CGPoint(x: 390 , y: newYPosition)
            }
            else {
                //Left Side
                Pancake.avatar.position = CGPoint(x: -120 , y: newYPosition)

            }
            //Pancakes Zposition
            Pancake.zPosition += 5
        
        }
        
       
        //Checks to see if it is a new pancake
        if currentPancake != previousPancake{
          previousPancake.removeActionForKey("movingPancake")
        }
        
        //Drop Animation
        //FlipPancakes(Pancake)
        
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
        
        //update when Touch begins
        startTouch += fixedDelta
        
        print(startTouch)

        /* Check we have a valid camera target to follow */
        if let cameraTarget = cameraTarget {
            
            /* Set camera position to follow target vertically, keep horizontal locked */
            camera?.position = CGPoint(x:camera!.position.x, y:cameraTarget.position.y)
            
            /* Clamp camera scrolling to our visible scene area only */
            camera?.position.y.clamp(283, previousPancake.avatar.position.y)
            }
    }
    
    func appearPancake(Pancake: MSReferenceNode){
    
        //Set values for where the pancake should reach on the screen
        let moveFromLeft = SKAction.moveToX(-350, duration: 0.5)
        let moveFromRight = SKAction.moveToX(390, duration: 0.5)
        
        //Pancakes Appear from Right
        if pancakeTower.count == 1 {
            
            //Disables Touch until Pancake Enters
            self.userInteractionEnabled = false
            
            //Adds the action to the Pancakes
            Pancake.runAction(moveFromRight)
            
            //Move Pancake
            movePancake(Pancake)
           
        }
        if pancakeTower.count % 2 == 0 {
            
            //Disables Touch until Pancake Enters
            self.userInteractionEnabled = false
            
            //Adds the action to the Pancakes
            Pancake.runAction(moveFromLeft)
            
            //Move Pancake
            movePancake(Pancake)
            
        }
            //Pancakes Appear from Left
        else {
            //Disables Touch until Pancake Enters
            self.userInteractionEnabled = false
            
            //Adds the action to the Pancakes
            Pancake.runAction(moveFromRight)
            
            //Move Pancake
            movePancake(Pancake)
            
        }
    
    }
    
    func movePancake(Pancake: MSReferenceNode ){
       
        //Starts the first Pancake from the Left
        if pancakeTower.count == 1{
            
            //Set values for where the pancake should reach on the screen
            let moveLeft = SKAction.moveToX(195, duration: 1)
            let moveRight = SKAction.moveToX(420, duration: 1)
            
            //Loops Pancake Movement until touch begins
            let moveBackAndForth = SKAction.repeatActionForever(SKAction.sequence([moveRight, moveLeft]))
            
            //Adds the action to the Pancakes
            Pancake.runAction(moveBackAndForth, withKey: "movingPancake")
            
            //Allows Touch after 4 seconds
            if startTouch <= 0.4 {
             self.userInteractionEnabled = true
                
            }
           

        }
        
        //Pancake from the Right
        if pancakeTower.count % 2 == 0 {
            
            //Set values for where the pancake should reach on the screen
            let moveLeft = SKAction.moveToX(-350, duration: 1)
            let moveRight = SKAction.moveToX(-50, duration: 1)
            
            //Loops Pancake Movement until touch begins
            let moveBackAndForth = SKAction.repeatActionForever(SKAction.sequence([moveLeft, moveRight]))
            
            //Adds the action to the Pancakes
            Pancake.runAction(moveBackAndForth, withKey: "movingPancake")
            
            //Allows Touch after 4 seconds
            if startTouch <= 0.4 {
                self.userInteractionEnabled = true
            }

            
        }
            
        //Pancake from the Left
        else {
            
            //Set values for where the pancake should reach on the screen
            let moveLeft = SKAction.moveToX(195, duration: 1)
            let moveRight = SKAction.moveToX(420, duration: 1)
            
            //Loops Pancake Movement until touch begins
            let moveBackAndForth = SKAction.repeatActionForever(SKAction.sequence([moveRight, moveLeft]))
            
            //Adds the action to the Pancakes
            Pancake.runAction(moveBackAndForth, withKey: "movingPancake")
            
            //Allows Touch after 4 seconds
            if startTouch <= 0.4 {
                self.userInteractionEnabled = true
            }

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
       // location = previousPancake.convertPoint(previousPancake.position, toNode: self)
        
//        prevPancakelocation = previousPancake.position / 3
//        currPancakelocation = currentPancake.position / 3
        //location = previousPancake.position
        //Converts the Point of the Left Node Position of Screen
        edgeLeft = left.position.x
        
        //Converts the Point of the Right Node Position of Screen
        edgeRight = right.position.x
       
        //Converts the Point of the Right Node Position of Pancake
        //pancakeEdgeRight = pancakeRight.position.x
        
        //Converts the Point of the Left Node Position of Pancake
       // pancakeEdgeLeft = pancakeLeft.position.x
        
        
        //Calls DropLeft Animation
        let DropLeft = SKAction(named: "DropLeft")!
        
        //Calls DropRight Animation
       let DropRight = SKAction(named: "DropRight")!
        
        //Remove the Pancake from Parent
        let remove = SKAction.removeFromParent()
        
        //Checks where the Pancake has landed
        if pancakeEdgeRight > edgeRight{
            print(pancakeEdgeRight)
            print("This is the Right Edge: \(edgeRight)")
            let sequence = SKAction.sequence([DropRight, remove])
            previousPancake.runAction(sequence)
        }
        else if pancakeEdgeLeft < edgeLeft {
            print(pancakeEdgeLeft)
            print("This is the Left Edge: \(edgeLeft)")
            let sequence = SKAction.sequence([DropLeft, remove])
            previousPancake.runAction(sequence)
       }
//        else if location.x > edgeLeft && location.x < edgeRight{
//            removeAllActions()
//            print("In the center of Counter \(location) ")
//        }
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