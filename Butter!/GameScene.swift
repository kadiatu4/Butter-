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

enum Object{
    case None, Fork, Knife
}
class GameScene: SKScene{
    //Game State
    var gameState: GameState = .Menu
    var endGame: Bool = false
    var currentObject: Object = .None
    
    /* UI Objects */
    var fork: SKReferenceNode!
    var interference: Bool = false
    var knife: SKReferenceNode!
    var counterTop: SKSpriteNode!
    var left, right: SKNode!
    var touchedKnife: SKSpriteNode!
    var touchedFork: SKSpriteNode!
    var objectTouched: Bool = false
    
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
                
                //To prevent fork and Knife action from occuring
                objectTouched = true
                
                //Position of the pancake
                let pancakeYposition = previousPancake.position.y
                
                //Moves ForK
                let moveUp = SKAction.moveBy(CGVector(dx: 0, dy: 300), duration: 0.5)
                
                
                let moveLeft = SKAction.moveToX(-120, duration: 0.5)
                
                let sequence = SKAction.sequence([moveUp,moveLeft])
                
                fork.runAction(sequence)
                
                interference = false
                
                
            }
            else if touchedNode.name == "touchedKnife"{
                
                //To prevent fork and Knife action from occuring
                objectTouched = true
                
                //Sets the knife to move off screen
                let moveKnife = SKAction.moveToX(-211, duration: 0.5)
               
                knife.runAction(moveKnife)
                
                interference = false
            }
            else {
                
                //Drops Previous Pancake
                dropPancakes(currentPancake)
    
                //Flip Pancakes Animation
                flipPancakes(currentPancake)
                
                //Depending on the value a Fork or Knife will appear
                getrandomNumber()
               
                if endGame == false &&  interference == false{
                    //Increment the index of the Pancakes
                    prevCount = currCount
                    currCount += 1
                }
        
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
        
        //Allow new Pancakes
        if objectTouched == true {
        
            interference = false
        }
        
        //Stores the previous Pancake
        let previousPancake = pancakeTower[prevCount]
//        
//        print("Current Pancake : \(currentPancake.position) and index: \(currCount)")
//        
//        print("Prev Pancake : \(previousPancake.position) and index: \(prevCount)")
    

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
        
        //Remove Pancake from parent
        Pancake.removeFromParent()
        
        //Reduces points
        points -= 1
        
        if points == 0 {
            gameOver()
        }
    
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
    
    func interferenceContact(){
        
        //Stores the current Pancake
        let currentPancake = pancakeTower[currCount]
        
        //Stores the Position of the Fork
        var checkPositionY: CGFloat!
        var checkPositionX: CGFloat!
        
        if currentObject == .Fork{
            
            //Hids the knife
            knife.hidden = true
            
            /*Gets the Difference between fork and Pancake*/
            
            //Difference for the X-Position
            if fork.position.x > currentPancake.position.x{
                
                var difference  = currentPancake.position.x - fork.position.x
                checkPositionX = currentPancake.position.x - difference
                
            }
            else if fork.position.x < currentPancake.position.x {
                
                var difference = currentPancake.position.x - fork.position.x
                checkPositionX = currentPancake.position.x - difference
            }
            
            //Difference for the Y-Position
            if fork.position.y > currentPancake.position.y{
                
                var difference  = fork.position.y - currentPancake.position.y
                checkPositionY = currentPancake.position.y + difference
                
            }
            else if fork.position.y < currentPancake.position.y {
                
                var difference = currentPancake.position.y - fork.position.y
                checkPositionY = currentPancake.position.y  - difference
            }
            
            print("check Fork Y: \(checkPositionY)")
            print("fork Y: \(fork.position.y)")
            print("check Fork X: \(checkPositionX)")
            print("fork X: \(fork.position.x)")
            
            
            
            //Check if the fork is in contact with the Pancake
            if fork.position.y == checkPositionY && fork.position.x == checkPositionX{
                
                //Set Z positon to 3 (So node is not touchable)
                touchedFork.zPosition = 3
                
                
                //Actions
                let moveUp = SKAction.moveBy(CGVector(dx: 0, dy:300), duration: 0.5)
                
                //Picks up Fork and Pancake
                fork.runAction(moveUp)
                stealPancake(currentPancake)
                
                //Reset fork X-Position
                fork.position.x = -211
                
            }
            
            
        }
            
        else if currentObject == .Knife {
            
            //Hids the fork
            fork.hidden = true
            /*Gets the Difference between fork and Pancake*/
            
            //Difference for the X-Position
            if knife.position.x > currentPancake.position.x{
                
                var difference  = currentPancake.position.x - knife.position.x
                checkPositionX = currentPancake.position.x - difference
                
            }
            else if knife.position.x < currentPancake.position.x {
                
                var difference = currentPancake.position.x - knife.position.x
                checkPositionX = currentPancake.position.x - difference
            }
            
            //Difference for the Y-Position
            if knife.position.y > currentPancake.position.y{
                
                var difference  = knife.position.y - currentPancake.position.y
                checkPositionY = currentPancake.position.y + difference
                
            }
            else if knife.position.y < currentPancake.position.y {
                
                var difference = currentPancake.position.y - knife.position.y
                checkPositionY = currentPancake.position.y  - difference
            }

            print( "check Knife X: \(checkPositionX)")
            print("knife X: \(knife.position.x)")
            print( "check Knife Y: \(checkPositionY)")
            print("knife Y: \(knife.position.y)")
            
            if knife.position.y == checkPositionY && knife.position.x ==  checkPositionX {
                print("equal")
                //Action
                let slicedPancake = SKTexture(imageNamed: "SlicedPancake.png")
                let halfPancake = SKTexture(imageNamed: "cutPancake.png")
                let typeofPancake = [slicedPancake, halfPancake]
                
                let animatePancake = SKAction.animateWithTextures(typeofPancake, timePerFrame: 1)
                
                currentPancake.runAction(animatePancake)
                
            }
            
        }
    }


    func actionFork(){
        if currentObject == .Fork{
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
            
            if objectTouched == false{
                delay(1.5){
                    self.interferenceContact()
                }
            }
            
            interference = false
        
        }
    }
    
    
    func actionKnife(){
        if currentObject == .Knife{
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
            let findPancake = SKAction.moveToX(pancakeXposition - 170, duration: 1)
            
            let dropKnife = SKAction.moveToY(pancakeYposition - 70,
                duration: 1)

            let sequence = SKAction.sequence([findPancake, dropKnife])
            knife.runAction(sequence)
            
            if objectTouched == false{
                delay(1.5){
                    self.interferenceContact()
                }
            }
            interference = false
        }
//        previousPancake.avatar.texture = SKTexture(imageNamed: "cutPancake")
        
    
    }

    func getrandomNumber(){
        //Generates a random value
        let randomNumber = Int(arc4random_uniform(100) + 1)
        print(randomNumber)
        //If the number is dividable by 5
        if randomNumber % 5 == 0 {
            
            //Appear only if game != GameOver
            if endGame == false{
                
                //Track object on Screen
                currentObject = .Fork
                if currentObject == .Fork{
                    fork.hidden = false
                    
                    //Call the Fork
                    actionFork()
                }
               
            }
        }
        
        //If the number is dividable by 8
        else if randomNumber % 8 == 0{
            
            //Appear only if game != GameOver
             if endGame == false{
                
                //Track object on Screen
                currentObject = .Knife
                if currentObject == .Knife{
                    knife.hidden = false
                    
                  //Call the Knife
                   actionKnife()
                }
            }
        }
        else {
            
             //Track object on Screen
            currentObject = .None
            if currentObject == .None{
                
                knife.hidden = true
                fork.hidden = true
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