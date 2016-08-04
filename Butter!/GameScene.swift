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

class GameScene: SKScene {
    //Game State
    var gameState: GameState = .Menu
    var endGame: Bool = false
    
    /* UI Objects */
    var fork: SKReferenceNode!
    var forkTip: SKNode!
    var interference: Bool = false
    var knife: SKReferenceNode!
    var counterTop: SKSpriteNode!
    var left, right: SKNode!
    
    //Stores Number of Pancake stacked
    var pancakeTower: [MSReferenceNode] = []
    
    //Stores Number of Pancakes
    var pancakes: [MSReferenceNode] = []
    
    //Stores different Times
    var spawnTimer: CFTimeInterval = 0
    var sinceTouch: CFTimeInterval = 0
    var startTouch: CFTimeInterval = 0
    var startGameOver: CFTimeInterval = 0
    
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
        counterTop = self.childNodeWithName("counterTop") as! SKSpriteNode
        
        //Reference for Left and Right Nodes of Screen
        left = self.childNodeWithName("left")
        right = self.childNodeWithName("right")
        
        //Reference for Scroll Layer
        scrollLayer = self.childNodeWithName("scrollLayer")
        
        //Reference for Score Label
        scoreLabel = childNodeWithName("//scoreLabel") as! SKLabelNode
        
        //Reference for Fork
        fork = childNodeWithName("//fork") as! SKReferenceNode
        
        //Reference for Fork Tip
        forkTip = self.childNodeWithName("//forkTip")
        
        //Reference for Knife
        knife = childNodeWithName("//knife") as! SKReferenceNode
        
        //Creates Pancake
        let Pancake = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
        
        //Add Pancakes in Array
        pancakeTower.append(Pancake)

        //Add Pancakes
        addChild(Pancake)
        
        //Appear Pancake
        appearPancake(Pancake)
        
        //Stack Pancakes on top of each other
        let startPosition = 180
        addYPosition += 20
        var newYPosition = startPosition + addYPosition
        
        //Position Pancake
        Pancake.position = CGPoint(x: -120 , y: newYPosition)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        if startTouch < 0.4 { return }
        
        if gameState == .GameOver{ return }

        for touch in touches {
        
            //Grab scene position of touch
            let location = touch.locationInNode(self)
            
            //Get node reference if we're touching a node
            let touchedNode = nodeAtPoint(location)
            
            if touchedNode.name == "touchedFork" {
                
                    let moveForkUp = SKAction.moveToY(400, duration: 0.5)
                    fork.runAction(moveForkUp)
                
                }
                if touchedNode.name == "touchedKnife"{
                    
                    
                    
                    }
                else {
                    
                    //Stores the previous Pancake
                    let previousPancake = pancakeTower[prevCount]
                    
                    //Drops Previous Pancake
                    dropPancakes(previousPancake)
                    
                    //Steals Pancake that has stopped
                    actionFork()
                    
                    //Cuts Pancakes
                    //  actionKnife()
                    
                    //Flip Pancakes Animation
                    flipPancakes()
                    
                    //Reset Start Touch
                    startTouch = 0
                    
                    //Creates new Pancakes
                    let Pancake = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
                    
                    //Add Pancakes in Array
                    pancakeTower.append(Pancake)
                    
                    //Stores Current Pancake
                    let currentPancake = pancakeTower[currCount]
                    
                    if sinceTouch > 0.4 && interference == false && endGame == false{
                        
                        //Appear Pancake
                        appearPancake(Pancake)
                        
                        //Add Pancakes
                        addChild(Pancake)
                        
                        //Stack Pancakes on top of each other
                        let startPosition = 200
                        addYPosition += 20
                        var newYPosition = startPosition + addYPosition
                        
                        
                        //Pancakes start off screen
                        if pancakeTower.count % 2 == 0 {
                            //Right Side
                            Pancake.position = CGPoint(x: 390 , y: newYPosition)
                        }
                        else {
                            //Left Side
                            Pancake.position = CGPoint(x: -120 , y: newYPosition)
                            
                        }
                        //Pancakes Zposition
                        Pancake.zPosition += 5
                        
                    }
                    
                    //Checks to see if it is a new pancake
                    if currentPancake != previousPancake{
                        previousPancake.removeActionForKey("movingPancake")
                    }
                    
                    if endGame == false {
                        /* Set camera to follow pancake */
                        cameraTarget = currentPancake
                    }
                    else if endGame == true{
                        cameraTarget = previousPancake
                    }
                    
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
            }
    
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
        
        /* Check we have a valid camera target to follow */
        if let cameraTarget = cameraTarget {
            
            /* Set camera position to follow target vertically, keep horizontal locked */
            camera?.position = CGPoint(x:camera!.position.x, y:cameraTarget.position.y)
        
            /* Clamp camera scrolling to our visible scene area only */
            camera?.position.y.clamp(283, previousPancake.position.y)
        }
    }
    
    func appearPancake(Pancake: MSReferenceNode){
    
        //Set values for where the pancake should reach on the screen
        let moveFromLeft = SKAction.moveToX(-15, duration: 0.5)
        let moveFromRight = SKAction.moveToX(320, duration: 0.5)
        
        //Pancakes Appear from Right
        if pancakeTower.count % 2 == 0 {
            
            //Adds the action to the Pancakes
            Pancake.runAction(moveFromLeft)
        }
        //Pancakes Appear from Left
        else {
            
            //Adds the action to the Pancakes
            Pancake.runAction(moveFromRight)
        }
        
            //Move Pancake
           movePancake(Pancake)
    }
    
    func movePancake(Pancake: MSReferenceNode ){
       
        //Pancake from the Right
        if pancakeTower.count % 2 == 0 {
            
            //Set values for where the pancake should reach on the screen
            let moveLeft = SKAction.moveToX(-50, duration: 1)
            let moveRight = SKAction.moveToX(380, duration: 1)
            
            //Loops Pancake Movement until touch begins
            let moveBackAndForth = SKAction.repeatActionForever(SKAction.sequence([moveLeft, moveRight]))
            
            //Adds the action to the Pancakes
            Pancake.runAction(moveBackAndForth, withKey: "movingPancake")

            
        }
            
        //Pancake from the Left
        else {
            
            //Set values for where the pancake should reach on the screen
            let moveLeft = SKAction.moveToX(-50, duration: 1)
            let moveRight = SKAction.moveToX(380, duration: 1)
            
            //Loops Pancake Movement until touch begins
            let moveBackAndForth = SKAction.repeatActionForever(SKAction.sequence([moveRight, moveLeft]))
            
            //Adds the action to the Pancakes
            Pancake.runAction(moveBackAndForth, withKey: "movingPancake")

        }
    }
    
    func dropPancakes(Pancake: MSReferenceNode){
        //Drops the pancake down by 50
        Pancake.runAction(SKAction.sequence([
            SKAction.moveBy(CGVector(dx: 0, dy: -50), duration: 0.10)]))
        print("drop: \(Pancake.position.y)")
        }
    
    func flipPancakes(){
    
        //Stores the location of the edges of the Screen
        var location: CGPoint!
        var edgeLeft, edgeRight: CGFloat!

        //Stores the previous Pancake
        var previousPancake = pancakeTower[prevCount]
        
        //Converts the Points of the Pancake's Position
        location = previousPancake.position
        
        //Converts the Point of the Left Node Position of Screen
        edgeLeft = left.position.x
        
        //Converts the Point of the Right Node Position of Screen
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
            endGame = true
            
        }
        else if location.x  < edgeLeft {
            let sequence = SKAction.sequence([DropLeft, remove])
            previousPancake.runAction(sequence)
            endGame = true
        }
        
        //Only executes when endGame == true
        if endGame == true {
            
            //Delays the Game Over Scene until after animation
            delay(1.8){
                self.gameOver()
            }
        }
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
    
    func actionFork(){
        //Stores the previous Pancake
        let previousPancake = pancakeTower[prevCount]
        
        //Stores Values
        let pancakeYposition = previousPancake.position.y
        let pancakeXposition = previousPancake.position.x
        let xpositionFork = pancakeXposition + 15
        let ypositionFork = pancakeYposition - 120
        let startForkPosition = pancakeYposition * 2
        let distance = startForkPosition - ypositionFork
        
        //Get the Pancake Z-position
        let pancakeZposition = previousPancake.zPosition
        
        //Set Fork Z-Position higher than Pancake Z-Position
        let forkZposition = pancakeZposition + 2
        
        //Fork Z-Position will be higher than Pancake's
        fork.zPosition = forkZposition
        
        //Position Knife off Screen
        fork.position = CGPoint(x: xpositionFork , y: startForkPosition)
        
        //Drops the Fork down
        let dropFork = SKAction.moveToY(ypositionFork, duration: 2)
        fork.runAction(dropFork)
        
        if fork.position.y == distance{
            
            //Actions
            let moveUp = SKAction.moveToY(startForkPosition, duration: 1)
            
             //Picks up Fork and Pancake
                fork.runAction(moveUp)
                previousPancake.runAction(moveUp)
            
            //Remove both Fork and Pancake from screen
            if fork.position.y == startForkPosition || previousPancake.position.y == startForkPosition{
                fork.removeFromParent()
                previousPancake.removeFromParent()
            }
            
        }
    }
    

    
    func actionKnife(){
        //Prevent a new pancake from appearing
        interference = true
        
        //Stores the previous Pancake
        let previousPancake = pancakeTower[prevCount]
        
        //Gets the previous Pancake
        let pancakeYposition = previousPancake.position.y
        let pancakeXposition = previousPancake.position.x
        
        //Get the Pancake Z-position
        let pancakeZposition = previousPancake.zPosition
        
        //Set Knife Z-Position higher than Pancake Z-Position
        let knifeZposition = pancakeZposition + 2
        
        //Knife Z-Position will be higher than Pancake's
        knife.zPosition = knifeZposition
        
        //Position Knife off Screen
        knife.position = CGPoint(x: -393, y:pancakeYposition * 2)
        
        //Brings the Knife on Screen and drops it on Pancake
        let findPancake = SKAction.moveToX(pancakeXposition - 370, duration: 2)
        let dropKnife = SKAction.moveToY(pancakeYposition - 130, duration: 2)
        let sequence = SKAction.sequence([findPancake, dropKnife])
        knife.runAction(sequence)
        
        interference = false
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    func gameOver(){
        
        /* Game over! */
        gameState = .GameOver
    
        //grab reference to SpiteKit view
        let skView = self.view as SKView!
        
        //Load Game scene
        let scene = GameOverScene(fileNamed: "GameOverScene") as GameOverScene!
        
        //Ensure correct aspect mode
        scene.scaleMode = .AspectFill
        
        //Start Game Scene
        skView.presentScene(scene)
    
    }
    
  }