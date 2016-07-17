//
//  GameScene.swift
//  Butter!
//
//  Created by Kadiatou Diallo on 7/13/16.
//  Copyright (c) 2016 Kadiatou Diallo. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /* UI Objects */
    var counterTop: SKSpriteNode!
    var pancakeTower: [MSReferenceNode] = []
    var addYPosition = 0
    var sinceTouch : CFTimeInterval = 0
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS*/
    let resourcePath = NSBundle.mainBundle().pathForResource("Pancake", ofType: "sks")
    
    //Stores Previous and Current pancake
     var prevCount = 0
     var currCount = 1


    
    override func didMoveToView(view: SKView) {
        
        //Reference for Counter Top
        counterTop = childNodeWithName("counterTop") as! SKSpriteNode
      
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
    
        let Pancake = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
        
        //Add Pancakes
        addChild(Pancake)
        
        //Stack Pancakes on top of each other
        let startPosition = 100
        addYPosition += 20
        var newYPosition = startPosition + addYPosition
        

        //Position Pancakes
        Pancake.avatar.position = CGPoint(x:151 , y: newYPosition)

        //Move Pancake
        movePancake(Pancake)
        
        //Add Pancakes in Array
        pancakeTower.append(Pancake)
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Stores the current Pancake
        var previousPancake = pancakeTower[prevCount]
        
        //Creates new Pancakes
        let Pancake = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
        
        //Add Pancakes in Array
        pancakeTower.append(Pancake)
        
        //Stores Current Pancake
        var currentPancake = pancakeTower[currCount]

        //Add Pancakes
        addChild(Pancake)
        
        //Stack Pancakes on top of each other
        let startPosition = 140
        addYPosition += 20
        var newYPosition = startPosition + addYPosition
        
        
        //Position Pancakes
        Pancake.avatar.position = CGPoint(x:151 , y: newYPosition)
        
        //Pancakes Zposition
        Pancake.zPosition += 5
        
        //Moves Pancakes
        movePancake(Pancake)
        
        //Drop Pancakes
        dropPancakes(Pancake)
        
        //Checks to see if it is a new pancake
        if currentPancake != previousPancake{
            previousPancake.removeActionForKey("movingPancake")
        }
        
        //Increment the index of the Pancakes
         prevCount += 1
         currCount += 1
       


    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    

    }
    
    func movePancake(Pancake: MSReferenceNode ){
        //Set values for where the pancake should reach on the screen
        let moveLeft = SKAction.moveToX(-150, duration: 1)
        let moveRight = SKAction.moveToX(150, duration: 1)
        
        //Joins the moveLeft and moveRight and loops forever
        let moveBackAndForth = SKAction.repeatActionForever(SKAction.sequence([moveRight, moveLeft]))
        
        //Adds the action to the Pancakes
        Pancake.runAction(moveBackAndForth, withKey: "movingPancake")
    }
    
    func dropPancakes(Pancake: MSReferenceNode){
        /*FINISH THIS LATER
            To drop pancakes straight down if it does not land on top of a pancake or countertop
         */
       // if Pancake.avatar.size  {
            Pancake.runAction(SKAction.moveBy(CGVector(dx: 0, dy: -50), duration: 0.10))
        //   }
      //  else

    }
//    
//    func didBeginContact(contact: SKPhysicsContact){
//
//        /* Get references to bodies involved in collision */
//        let contactA:SKPhysicsBody = contact.bodyA
//        let contactB:SKPhysicsBody = contact.bodyB
//        
//        /* Get references to the physics body parent nodes */
//        let nodeA = contactA.node!
//        let nodeB = contactB.node!
//        
//        /* Did our hero pass through the 'goal'? */
//        if nodeA.name == "onCounter" || nodeB.name == "onCounter" {
//            print("on counter")
//            
//            //Gets the current pancake
//            var currentPancake = pancakeTower[0]
//            
//            //Remove Action from Pancakes
//             currentPancake.removeActionForKey("movingPancake")
//            
//              return
//            
//        }
//        else if nodeA.name == "onPancake" || nodeB.name == "onPancake"{
//            print("on pancake")
//            
//            //Gets the current pancake
//            var currentPancake = pancakeTower.last
//            
//            //Remove Action from Pancakes
//        currentPancake!.removeActionForKey("movingPancake")
//            //return
//        }
//        else {
//            return
//        }
//        
//    }
    
}