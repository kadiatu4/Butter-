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

class GameScene: SKScene{
    //Game State
    var gameState: GameState = .Menu
    var endGame: Bool = false
    
    /* UI Objects */
    var fork: SKReferenceNode!
    var interference: Bool = false
    var knife: SKReferenceNode!
    var counterTop: SKSpriteNode!
    var left, right: SKNode!
    var touchedKnife: SKSpriteNode!
    var touchedFork: SKSpriteNode!
    
    //Stores Number of Pancake stacked
    var pancakeTower: [MSReferenceNode] = []
    
    //Stores Number of Pancakes
    var pancakes: [MSReferenceNode] = []
    
    //Stores different Times
    var spawnTimer: CFTimeInterval = 0
    var sinceTouch: CFTimeInterval = 0
    
    //Scrolls Background
    var scrollLayer: SKNode!
    let scrollSpeed: CGFloat = 20

    /* Camera */
    var cameraTarget: SKNode?
    
    //Camera Position
    var cameraPosition: SKNode!
    
    //Timer 
    var timer = NSTimer()
    
    /* Variables */
    var addYPosition = 0
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS*/
   
    /*Resource Path for Pancakes */
    let resourcePath = NSBundle.mainBundle().pathForResource("Pancake", ofType: "sks")
    
    //Stores Previous and Current pancake
     var prevCount = 0
     var currCount = 0
    
    //Stores the Score
    var scoreLabel: SKLabelNode!
    var points: Int = 0{
        didSet{
        scoreLabel.text = String(points)
        }
    }
    //Stores the Coins
    var coinLabel: SKLabelNode!
    var Coins: Int = 0 {
        didSet{
            coinLabel.text = String(Coins)
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
        
        //Reference  for Coins Label
        coinLabel = childNodeWithName("//coinLabel") as! SKLabelNode
        
        //Reference for Fork
        fork = childNodeWithName("//fork") as! SKReferenceNode
        
        //Reference for Knife
        knife = childNodeWithName("//knife") as! SKReferenceNode
        
        //Reference for the touched Nodes
        touchedFork = childNodeWithName("//touchedFork") as!  SKSpriteNode
        touchedKnife = childNodeWithName("//touchedKnife") as! SKSpriteNode
        
        //Reference for Camera position when game ends
        cameraPosition = self.childNodeWithName("cameraPosition")
        
        //Creates Pancake
        let Pancake = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
        
        //Add Pancakes in Array
        pancakeTower.append(Pancake)

        //Add Pancakes
        addChild(Pancake)
        
        //Appear Pancake
        appearPancake(Pancake)
        
        //Stack Pancakes on top of each other
        let startPosition = 160
        addYPosition += 20
        var newYPosition = startPosition + addYPosition
        
        //Position Pancake
        Pancake.position = CGPoint(x: -120 , y: newYPosition)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Enables touch after 0.4 seconds or if game is active
        if sinceTouch <= 0.4{ return }
        if gameState == .GameOver{ return }
        
        //Stores the previous Pancake
        let previousPancake = pancakeTower[prevCount]
        
        //Stores Current Pancake
        let currentPancake = pancakeTower[currCount]
        
        //Creates new Pancakes
        let Pancake = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))

        for touch in touches {
        
            //Grab scene position of touch
            let location = touch.locationInNode(self)
            
            //Get node reference if we're touching a node
            let touchedNode = nodeAtPoint(location)
            
            if touchedNode.name == "touchedFork" {
                
                //Position of the pancake
                let pancakeYposition = previousPancake.position.y
                
                //Sets the fork to move off screen
                let startForkPosition = pancakeYposition * 5
                
                //Moves ForK
                let moveUp = SKAction.moveToY(startForkPosition ,duration: 0.5)
                let moveLeft = SKAction.moveToX(-120, duration: 0.5)
                
                let sequence = SKAction.sequence([moveUp,moveLeft])
                
                fork.runAction(sequence)
            }
            else if touchedNode.name == "touchedKnife"{
                
                //Sets the knife to move off screen
                let moveKnife = SKAction.moveToX(-211, duration: 0.5)
               
                knife.runAction(moveKnife)
            }
            else {
                
                //Drops Previous Pancake
                dropPancakes(currentPancake)
                
                //Flip Pancakes Animation
                flipPancakes(currentPancake)
                
                //Depending on the value a Fork or Knife will appear
                getrandomNumber()
                
                if sinceTouch > 0.4 && interference == false && endGame == false{
                    
                   //Appear Pancake
                    appearPancake(Pancake)
                    
                    //Add Pancakes
                    addChild(Pancake)
                    
                    //Add Pancakes in Array
                    pancakeTower.append(Pancake)
             
                    //Stack Pancakes on top of each other
                    let startPosition = 160
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
                if currentPancake == previousPancake || currentPancake != previousPancake{
                    currentPancake.removeActionForKey("movingPancake")
                    
                }
                
                if endGame == false &&  interference == false{
                    //Increment the index of the Pancakes
                    prevCount = currCount
                    currCount += 1
                }
                
                
                if endGame == false {
                    /* Set camera to follow pancake */
                    cameraTarget = previousPancake
                }
                else if endGame == true {
                   
                    /* Set camera to follow camera Node */
                    cameraTarget = cameraPosition
                }
                
                if interference == true && pancakeTower.count < 10{
                    /* Set camera to follow camera Node */
                    cameraTarget = cameraPosition
                }
                if endGame == false{
                    //Add Pancake to Pancakes Array
                    pancakes.append(Pancake)
                }
                
                //Reset Since Touch
                sinceTouch = 0
                
                //Score
                points = pancakes.count
                
            }
         
        }
    
    }
    
    override func update(currentTime: CFTimeInterval) {
        //Disable touch if Game is Over
        if endGame == true || gameState == .GameOver{return}

        
        //Stores the current Pancake
        let currentPancake = pancakeTower[currCount]

        //Scroll Background
        if pancakeTower.count >= 9{
            scrollBackground()
        }
        
        /*Update time since Pancake was dropped*/
        sinceTouch += fixedDelta
        
        /* Check we have a valid camera target to follow */
        if let cameraTarget = cameraTarget {
            
            /* Set camera position to follow target vertically, keep horizontal locked */
            camera?.position = CGPoint(x:camera!.position.x, y:cameraTarget.position.y)
        
            /* Clamp camera scrolling to our visible scene area only */
            camera?.position.y.clamp(220, currentPancake.position.y)
        }
        
        
               //Only Executes if interference is true
        if interference == true{
            var checkPositionY = (currentPancake.position.y + 100) + 100
            var checkPositionX = (currentPancake.position.x + 18)
            
           
            if fork.position.y == checkPositionY && fork.position.x == checkPositionX{
                print("hello")
                //Set Z positon to 3 (So node is not touchable)
                touchedFork.zPosition = 3
                
                
                //Actions
                let moveUp = SKAction.moveBy(CGVector(dx: 0, dy:300), duration: 0.5)
                
                //Picks up Fork and Pancake
                fork.runAction(moveUp)
                stealPancake(currentPancake)
                points -= 1
                
                //Remove both Fork and Pancake from screen
                //            if fork.position.y == previousPancake.position.y * 3 || previousPancake.position.y == previousPancake.position.y * 3{
                //
                //                fork.position.x = -211
                //                previousPancake.removeFromParent()
                //
                //                interference = false
                //            }
            }

        //if knife.position.y == previousPancake.position.y{
                
                //Action
        //            let slicedPancake = SKTexture(imageNamed: "SlicedPancake")
        //            let halfPancake = SKTexture(imageNamed: "cutPancake")
        //            let typeofPancake = [slicedPancake, halfPancake]
        //            
        //            let animatePancake = SKAction.animateWithTextures(typeofPancake, timePerFrame: 1)
        //            
        //            previousPancake.avatar.texture = SKTexture(imageNamed: "cutPancake")
                    //previousPancake.runAction(animatePancake)
                
           // }
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
        //Drops the pancake down by 100
        Pancake.runAction(SKAction.sequence([
            SKAction.moveBy(CGVector(dx: 0, dy: -100), duration: 0.10)]))
       
    }
    
    func stealPancake(Pancake: MSReferenceNode){
    
        //Move the pancake up by 250
        Pancake.runAction(SKAction.sequence([
            SKAction.moveBy(CGVector(dx: 0, dy: 300), duration: 0.10)]))
    
    }
    
    func delay(delay:Double, closure:()->()) {
        //Used to delay the Game Over Scene
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }

    func flipPancakes(Pancake: MSReferenceNode){
    
        //Stores the location of the edges of the Screen
        var location: CGPoint!
        var edgeLeft, edgeRight: CGFloat!
        
        //Converts the Points of the Pancake's Position
        location =  Pancake.position
        
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
           Pancake.runAction(sequence)
            endGame = true
            
        }
        else if location.x  < edgeLeft {
            let sequence = SKAction.sequence([DropLeft, remove])
            Pancake.runAction(sequence)
            endGame = true
        }
        
        //Only executes when endGame == true
        if endGame == true {

        //Delays the Game Over Scene until after animation
        self.delay(1.8){
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
        //Prevent a new pancake from appearing
        interference = true
        
        //Stores the current Pancake
        let currentPancake = pancakeTower[currCount]
        
        //Stores Values
        let pancakeYposition =  currentPancake.position.y
        let pancakeXposition =  currentPancake.position.x
        
        //Get the Pancake Z-position
        let pancakeZposition =  currentPancake.zPosition
        
        //Set Fork Z-Position higher than Pancake Z-Position
        let forkZposition = pancakeZposition + 2
        
        //Set touch node Z-Position
        touchedFork.zPosition = 5
        
        //Fork Z-Position will be higher than Pancake's
        fork.zPosition = forkZposition
        
    
        //Position Fork off Screen
        fork.position = CGPoint(x: -120, y: pancakeYposition * 2)

        
        //Moves fork to the pancake
        let findPancake = SKAction.moveToX(pancakeXposition + 18, duration: 1)
        
        //Drops the Fork down
        let dropFork = SKAction.moveToY(pancakeYposition + 100, duration: 1)
        
        //join action
        let sequence = SKAction.sequence([findPancake, dropFork])
    
        fork.runAction(sequence)
        
        
        
        // interference = false
    }
    
    
    func actionKnife(){
        //Prevent a new pancake from appearing
        interference = true
        
        //Stores the current Pancake
        let currentPancake = pancakeTower[currCount]
        
        //Gets the previous Pancake
        let pancakeYposition = currentPancake.position.y
        let pancakeXposition = currentPancake.position.x
        
        //Get the Pancake Z-position
        let pancakeZposition = currentPancake.zPosition
        
        //Set Knife Z-Position higher than Pancake Z-Position
        let knifeZposition = pancakeZposition + 2
        
        //Knife Z-Position will be higher than Pancake's
        knife.zPosition = knifeZposition
        
        //Position Knife off Screen
        knife.position = CGPoint(x: -211, y:pancakeYposition * 2)
        
        //Brings the Knife on Screen and drops it on Pancake
        let findPancake = SKAction.moveToX(pancakeXposition - 180, duration: 1)
        
        let dropKnife = SKAction.moveToY(pancakeYposition + 20,
            duration: 1)

        let sequence = SKAction.sequence([findPancake, dropKnife])
        knife.runAction(sequence)
        
//        previousPancake.avatar.texture = SKTexture(imageNamed: "cutPancake")
    
     //   interference = false
    }

    func getrandomNumber(){
        //Generates a random value
        let randomNumber = Int(arc4random_uniform(10) + 1)
        
        //If the number is dividable by 5
        if randomNumber % 5 == 0 {
            //Appear only if game != GameOver
            if endGame == false{
                //Call the Fork
                actionFork()
            }
        }
        
        //If the number is dividable by 8
        else if randomNumber % 8 == 0{
            
            //Appear only if game != GameOver
             if endGame == false{
                //Call the Knife
              // actionKnife()
            }
        }
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