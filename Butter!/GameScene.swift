//
//  GameScene.swift
//  Butter!
//
//  Created by Kadiatou Diallo on 7/13/16.
//  Copyright (c) 2016 Kadiatou Diallo. All rights reserved.
//

import SpriteKit
import Firebase
import FirebaseDatabase
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import AVFoundation

enum GameState{
    case Loading, Active, GameOver
}

enum Object{
    case None, Fork, Knife
}

//Stores the score
var CurrentScore: Int = 0

//Stores the High Score
var highscoreVal: Int = 0

//Stores the Coins
var coinLabel: SKLabelNode!
var Coins: Int = 0 {
didSet{
    coinLabel.text = String(Coins)
    }
}

/* Social profile structure */
struct Profile {
    var name = ""
    var imgURL = ""
    var facebookId = ""
    var score = 0
}

class GameScene: SKScene{
    //Game State
    var gameState: GameState = .Loading{
        didSet{
            if gameState == .Active{
                firstPancake()
            }
        }
    }
    
    //Tracks the object on screen
    var currentObject: Object = .None
    
    /* UI Objects */
    var fork: SKReferenceNode!
    var knife: SKReferenceNode!
    var counterTop: SKSpriteNode!
    var left, right: SKNode!
    var touchedKnife: SKSpriteNode!
    var touchedFork: SKSpriteNode!
    
    //Pancake side
    var pancakeLeft: SKNode!
    var pancakeRight: SKNode!
    
    //Bools
    var objectTouched: Bool = false
    var interference: Bool = false
    var objectDone: Bool = true
    var endGame: Bool = false

    
    //Stores Number of Pancake stacked
    var pancakeTower: [MSReferenceNode] = []
    
    //Stores Number of Pancakes
    var pancakes: [MSReferenceNode] = []
    
    //Stores different Times
    var spawnTimer: CFTimeInterval = 0
    var sinceTouch: CFTimeInterval = 0
    var spawnObject: CFTimeInterval = 0
    
    //Scrolls Background
    var scrollLayer: SKNode!
    let scrollSpeed: CGFloat = 20

    /* Camera */
    var cameraTarget: SKNode?
    
    //Camera Position
    var cameraPosition: SKNode!
    
    /* Variables */
    var addYPosition = 0
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS*/
    var currentZPosition: CGFloat = 0
   
    /*Resource Path for Pancakes */
    let resourcePath = NSBundle.mainBundle().pathForResource("Pancake", ofType: "sks")
    
    //Stores Previous and Current pancake
     var prevCount = 0
     var currCount = 0
    
    //Stores the Score
    var scoreLabel: SKLabelNode!
    var score: Int = 0{
        didSet{
            scoreLabel.text = String(score)
        }
    }
    
    //Stores the images for when knife and pancake come in contact
    var pancakeTextures = [
        SKTexture(imageNamed: "SlicedPancake"),
        SKTexture(imageNamed: "cutPancake1"),
    ]
    
    //Facebook User Profile
    var playerProfile = Profile()

    /* Firebase connection */
    var firebaseRef = FIRDatabase.database().referenceWithPath("/highscore")

    /* High score custom dictionary */
    var scoreTower: [Int:Profile] = [:]
    
    //Pancake creation counter
    var pancakeCounter = 0
    
    override func didMoveToView(view: SKView) {
        
        //Allows User to continue listening to their Music
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            print(error)
        }
        
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
        
        //Reference for the nodes on the Pancake
        pancakeLeft = self.childNodeWithName("//pancakeLeft")
        pancakeRight = self.childNodeWithName("//pancakeRight")
        
        //Reference for Camera position when game ends
        cameraPosition = self.childNodeWithName("cameraPosition")
        
        /* Stores the Players HIGHSCORE */
        let highscoreDefault = NSUserDefaults.standardUserDefaults()
        
        if (highscoreDefault.valueForKey("Highscore") != nil){
            
            highscoreVal = highscoreDefault.valueForKey("Highscore") as! NSInteger
        }

        /* Facebook authentication check */
        if (FBSDKAccessToken.currentAccessToken() == nil) {
            
            /* No access token, begin FB authentication process */
            FBSDKLoginManager().logInWithReadPermissions(["public_profile","email","user_friends"], fromViewController:self.view?.window?.rootViewController, handler: {
                (facebookResult, facebookError) -> Void in
                
                if facebookError != nil {
                    print("Facebook login failed. Error \(facebookError)")
                } else if facebookResult.isCancelled {
                    print("Facebook login was cancelled.")
                } else {
                    let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                    
                    print(accessToken)
                }
            })
        }
        
        /* Facebook profile lookup */
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    
                    /* Update player profile */
                    self.playerProfile.facebookId = result.valueForKey("id") as! String
                    self.playerProfile.name = result.valueForKey("first_name") as! String
                    self.playerProfile.imgURL = "https://graph.facebook.com/\(self.playerProfile.facebookId)/picture?type=small"
                    print(self.playerProfile)
                }
            })
        }
        
        /*  FIREBASE */
        firebaseRef.queryOrderedByChild("score").queryLimitedToLast(5).observeEventType(.Value, withBlock: { snapshot in
            
            /* Check snapshot has results */
            if snapshot.exists() {
                
                /* Loop through data entries */
                for child in snapshot.children {
                    
                    /* Create new player profile */
                    var profile = Profile()
                    
                    /* Assign player name */
                    profile.name = child.key
                    
                    /* Assign profile data */
                    profile.imgURL = child.value.objectForKey("image") as! String
                    profile.facebookId = String(child.value.objectForKey("id")!)
                    profile.score = child.value.objectForKey("score") as! Int
                    
                    /* Add new high score profile to score tower using score as index */
                    self.scoreTower[profile.score] = profile
                }
            }
            //Set game state to active
            self.gameState = .Active
            
        }) { (error) in
            print(error.localizedDescription)
        }
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
                
                if volumeOn == true{
                    let touchedSFX = SKAction.playSoundFileNamed("ForkKnife", waitForCompletion: true)
                    self.runAction(touchedSFX)
                }
                
                //Moves ForK
                let moveUp = SKAction.moveBy(CGVector(dx: 0, dy: 300), duration: 0.5)
                
                
                let moveLeft = SKAction.moveToX(-120, duration: 0.5)
                
                let sequence = SKAction.sequence([moveUp,moveLeft])
                
                fork.runAction(sequence)
                
                objectTouched = true
                objectDone = true
               
                
            }
            else if touchedNode.name == "touchedKnife"{
                
                //To prevent fork and Knife action from occuring
               objectTouched = true
                
                if volumeOn == true {
                    let touchedSFX = SKAction.playSoundFileNamed("ForkKnife", waitForCompletion: true)
                    self.runAction(touchedSFX)
                }
                //Sets the knife to move off screen
                let moveKnife = SKAction.moveToX(-211, duration: 0.5)
               
                knife.runAction(moveKnife)
               
                objectTouched = true
                 objectDone = true
                
            }
            else {
                    //Drops Previous Pancake
                    dropPancakes(currentPancake)
                    
                    //Flip Pancakes Animation
                    flipPancakes(currentPancake)
                
//                    //Depending on the value a Fork or Knife will appear
//                    getrandomNumber()
               
                
                if endGame == false && interference == false{
                    //Increment the index of the Pancakes
                    prevCount = currCount
                    currCount += 1
                }
        
                if sinceTouch > 0.4 && interference == false && endGame == false {
                    
                   //Appear Pancake
                    appearPancake(Pancake)
                    
                    //Add Pancakes
                    addChild(Pancake)
                    
                    //Add Pancakes in Array
                    pancakeTower.append(Pancake)
             
                    //Stack Pancakes on top of each other
                    let startPosition = 160
                    addYPosition += 20
                    let newYPosition = startPosition + addYPosition
                    
                    
                    //Pancakes start off screen
                    if pancakeTower.count % 2 == 0 {
                        //Right Side
                        Pancake.position = CGPoint(x: 390 , y: newYPosition)
                    }
                    else {
                        //Left Side
                        Pancake.position = CGPoint(x: -120 , y: newYPosition)
                        
                    }
                    
                    
                    Pancake.zPosition = currentZPosition + 5
                    
                    //Store Pancake Z position
                    currentZPosition = Pancake.zPosition
                    
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
                
                if interference == true && pancakeTower.count < 7{
                    /* Set camera to follow camera Node */
                    cameraTarget = cameraPosition
                }
                if endGame == false{
                    //Add Pancake to Pancakes Array
                    pancakes.append(Pancake)
                }
                
                //Reset Since Touch
                sinceTouch = 0
                
            }
         
        }
    
    }
    
    override func update(currentTime: CFTimeInterval) {
        //Disable touch if Game is Over
        if endGame == true || gameState == .GameOver{return}
        
        //Executes when the game state is .Active
        if gameState == .Active{
            
            //Stores the current Pancake
            let currentPancake = pancakeTower[currCount]

            //Scroll Background
            if pancakeTower.count >= 7{
                scrollBackground()
            }
            
            /*Update time since Pancake was dropped*/
            sinceTouch += fixedDelta
            
            /*Update time since Object appears*/
            spawnObject += fixedDelta
        
            /* Check we have a valid camera target to follow */
            if let cameraTarget = cameraTarget {
                
                /* Set camera position to follow target vertically, keep horizontal locked */
                camera?.position = CGPoint(x:camera!.position.x, y:cameraTarget.position.y)
            
                /* Clamp camera scrolling to our visible scene area only */
                camera?.position.y.clamp(220, currentPancake.position.y)
            }
         
            if objectTouched == true {
                interference = false
            }
            
            if objectDone == true{
                interference = false
                objectDone = false
            }
            
//            if interference == false{
//                //Generates a random value (10)
//                let randomTime = Double(arc4random_uniform(9) + 1)
//                print(randomTime)
//                if spawnObject > randomTime && spawnObject <= randomTime + 1{
//                    //Depending on the value a Fork or Knife will appear
//                    getrandomNumber()
//                    spawnObject = 0
//
//                }
//                
//            }
            
            //To make sure only one object appears at a time
            if currentObject == .None{
                knife.hidden = true
                fork.hidden = true
                
                //Must sure fork and Knife remain at their position
                knife.position.x = -211
                fork.position.x = -120
            }
            else if currentObject == .Fork{
                knife.hidden = true
                fork.hidden = false
            }
            else if currentObject == .Knife{
                fork.hidden = true
                knife.hidden = false
            }
           
        
            //Updates the highscore
            if score > highscoreVal{
                highscoreVal = score
                let highscoreDefault = NSUserDefaults.standardUserDefaults()
                highscoreDefault.setValue(highscoreVal, forKey: "Highscore")
                highscoreDefault.synchronize()
            }
            
            //Stores the current Score
            CurrentScore = score
        }
    }
    
    func highscoreData(){
        //Stores the previous Pancake
        let previousPancake = pancakeTower[prevCount]

        /* Do we have a social score to add to the current pancake piece? */
        guard let profile = scoreTower[pancakeCounter] else { return }
        
        /* Grab profile image */
        guard let imgURL = NSURL(string: profile.imgURL) else { return }
        
        /* Perform code block asynchronously in background queue */
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            /* Perform image download task */
            guard let imgData = NSData(contentsOfURL: imgURL) else { return }
            guard let img = UIImage(data: imgData) else { return }
            
            /* Perform code block asynchronously in main queue */
            dispatch_async(dispatch_get_main_queue()) {
                
                /* Create texture from image */
                let imgTex = SKTexture(image: img)
                
                /* Create background border */
                let imgNodeBg = SKSpriteNode(color: UIColor.whiteColor(), size: CGSize(width: 57, height: 57))
                
                /* Add as child of pancake piece */
                self.camera!.addChild(imgNodeBg)
                
                imgNodeBg.zPosition = previousPancake.zPosition + 1
                imgNodeBg.position = CGPointMake(118,153)
                
                /* Create a new sprite using profile texture, cap size */
                let imgNode = SKSpriteNode(texture: imgTex, size: CGSize(width: 52, height: 52))
                
                /* Add profile sprite as child of pancake piece */
                imgNodeBg.addChild(imgNode)
                imgNode.zPosition = imgNodeBg.zPosition + 1
                
            }
        }
    }
    
    
    func firstPancake(){
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
        let newYPosition = startPosition + addYPosition
        
        //Position Pancake
        Pancake.position = CGPoint(x: -120 , y: newYPosition)
        
    }
    
    func appearPancake(Pancake: MSReferenceNode){
    
        //Set values for where the pancake should reach on the screen
        let moveFromLeft = SKAction.moveToX(-15, duration: 0.1)
        let moveFromRight = SKAction.moveToX(320, duration: 0.1)
        
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
            var speed: Double = 1.0

            if pancakeTower.count <= 15 && pancakeTower.count > 5{
                speed = 0.8
            }
            if pancakeTower.count <= 25 && pancakeTower.count > 15 {
                speed = 0.7
            }
            if pancakeTower.count <= 35  && pancakeTower.count > 25{
                speed = 0.6
            }
            if pancakeTower.count > 35 {
                speed = 0.5
            }
            //Set values for where the pancake should reach on the screen
            let moveLeft = SKAction.moveToX(-50, duration: speed)
            let moveRight = SKAction.moveToX(380, duration: speed)
            
            //Loops Pancake Movement until touch begins
            let moveBackAndForth = SKAction.repeatActionForever(SKAction.sequence([moveLeft, moveRight]))
            
         
            //Adds the action to the Pancakes
            Pancake.runAction(moveBackAndForth, withKey: "movingPancake")

            
        }
            
        //Pancake from the Left
        else {
            var speed: Double = 1.0
    
            if pancakeTower.count <= 15 && pancakeTower.count > 5{
                speed = 0.8
            }
            if pancakeTower.count <= 25 && pancakeTower.count > 15 {
                speed = 0.7
            }
            if pancakeTower.count <= 35  && pancakeTower.count > 25{
                speed = 0.6
            }
            if pancakeTower.count > 35 {
                speed = 0.5
            }
            //Set values for where the pancake should reach on the screen
            let moveLeft = SKAction.moveToX(-50, duration: speed)
            let moveRight = SKAction.moveToX(380, duration: speed)
            
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
       
        if volumeOn == true {
            let dropSFX = SKAction.playSoundFileNamed("DroppedPancake2", waitForCompletion: true)
            self.runAction(dropSFX)
        }
    }
    
    func checkPancakePosition(){
//        //Stores the previous Pancake
//        let previousPancake = pancakeTower[prevCount]
//        
//        //Stores Current Pancake
//        let currentPancake = pancakeTower[currCount]
//
//        //Stores the left side of Pancake
//        var left: CGFloat!
//        left = pancakeLeft.position.x
//        
//        //Stores the right side of Pancake
//        var right: CGFloat!
//        right = pancakeRight.position.x
//        
//        
//    
    }
    func stealPancake(Pancake: MSReferenceNode){
    
        //Move the pancake up by 250
        Pancake.runAction(SKAction.sequence([
            SKAction.moveBy(CGVector(dx: 0, dy: 300), duration: 0.10)]))
        
        //Remove Pancake from parent
        Pancake.removeFromParent()
        
        //Reduces points
        score -= 1
        
        if score == 0 {
            delay(0.5){
             self.gameOver()
            }
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
        else{
            //Score
            score += 1
            
            //Pancake tracker
            pancakeCounter += 1
            
            highscoreData()
            
        }
        
        //if pancakes are
        if location.x > edgeLeft && location.x < edgeRight{
            
            Coins += 5
            
        }
        //Only executes when endGame == true
        if endGame == true {
            if volumeOn == true {
                //SFX
                let flipSFX = SKAction.playSoundFileNamed("fallingPancake", waitForCompletion: false)
                self.runAction(flipSFX)
            }
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
    
    func forkContact(){
        interference = true
       
        //Stores the previous Pancake
        let previousPancake = pancakeTower[prevCount]
        
        objectDone = false
        
        if currentObject == .Fork {

            if objectTouched == false {
                
            //Actions
            let moveUp = SKAction.moveBy(CGVector(dx: 0, dy:300), duration: 0.5)
          
            //Picks up Fork and Pancake
            fork.runAction(moveUp)
            stealPancake(previousPancake)
                
            if volumeOn == true {
                //SFX
                let stolenSFX = SKAction.playSoundFileNamed("objectContact", waitForCompletion: true)
                self.runAction(stolenSFX)
            }
            //Reset fork X-Position
            fork.position.x = -120
            
            objectDone = true
            }
        }
        
    }



    func actionFork(){
        if currentObject == .Fork{
            
            //Prevent a new pancake from appearing
            interference = true
            
            //Stores Current Pancake
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
            fork.position = CGPoint(x: -120, y: pancakeYposition * 3)

            
            //Moves fork to the pancake
            let findPancake = SKAction.moveToX(pancakeXposition + 18, duration: 1)
            
            //Drops the Fork down
            let dropFork = SKAction.moveToY(pancakeYposition + 100, duration: 1)
            
            //join action
            let sequence = SKAction.sequence([findPancake, dropFork])

            fork.runAction(sequence)
           
            if objectTouched == false{
                 delay(2){
                    
                     //Calls fork Action Function
                    self.forkContact()
                
                }
            }
            interference = false
        
        }
    }
    func animatePancake(Pancake: MSReferenceNode){
          
        //Stores the animation for changing pancake
        let animateAction = SKAction.animateWithTextures(self.pancakeTextures, timePerFrame: 0.5)
        Pancake.avatar.runAction(animateAction)
        
        if volumeOn == true {
            //SFX
            let cutSFX = SKAction.playSoundFileNamed("objectContact", waitForCompletion: true)
            self.runAction(cutSFX)
        }

    }
    
    func knifeContact(){
        
        //Stores the previous Pancake
        let previousPancake = pancakeTower[prevCount]
        
        objectDone = false
        
        if currentObject == .Knife {
            
            if objectTouched == false {
            
            //Action
              animatePancake(previousPancake)
            
                //Sets the knife to move off screen
                let moveKnife = SKAction.moveToX(-211, duration: 0.5)
                
                knife.runAction(moveKnife)

                //Reset Knife X-Position
                knife.position.x = -211
                
                objectDone = true
            }
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
                delay(2){
                    
                    //Calls knife Action Function
                    self.knifeContact()
                    
                }
            }
            interference = false
        
        }
    }

    func getrandomNumber(){
        
        //Set object touched to false
        objectTouched = false
        
        //Generates a random value
        let randomNumber = Int(arc4random_uniform(100) + 1)
    
        //If the number is dividable by 5
        if randomNumber % 5 == 0 {
            interference = true
            
            //Appear only if game != GameOver
            if endGame == false{
                
                //Track object on Screen
                currentObject = .Fork
                    
                //Call the Fork
                actionFork()
               
            }
        }
        
        //If the number is dividable by 8
        else if randomNumber % 8 == 0{
            interference = true
            
            //Appear only if game != GameOver
             if endGame == false{
                
                //Track object on Screen
                currentObject = .Knife
                
                //Call the Knife
                   actionKnife()
                
            }
        }
        else if randomNumber % 8 == 0 && randomNumber % 5 == 0{
            interference = false
             //Track object on Screen
            currentObject = .None
        }
        else{
            interference = false
            //Track object on Screen
            currentObject = .None
        }
    }
    
   func gameOver(){
    
    /* Game over! */
    gameState = .GameOver
    
    /* Check for new high score and has a facebook user id */
    if score > playerProfile.score && !playerProfile.facebookId.isEmpty {
        
        /* Update profile score */
        playerProfile.score = score
        
        /* Build data structure to be saved to firebase */
        let saveProfile = [playerProfile.name :
            ["image" : playerProfile.imgURL,
                "score" : playerProfile.score,
                "id" : playerProfile.facebookId ]]
        
        /* Save to Firebase */
        firebaseRef.updateChildValues(saveProfile, withCompletionBlock: {
            (error:NSError?, ref:FIRDatabaseReference!) in
            if (error != nil) {
                print("Data save failed: ",error)
            } else {
                print("Data saved success")
            }
        })
        
    }
    
    //Reset Score
    score = 0
    
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