//
//  Fork.swift
//  Butter!
//
//  Created by Kadiatou Diallo on 8/3/16.
//  Copyright © 2016 Kadiatou Diallo. All rights reserved.
//

import SpriteKit

class Interference: SKSpriteNode{
    
    //Game Interference Object
    var fork: SKSpriteNode!
    var knife: SKSpriteNode!
    
    //You are required to implement this for your subclass to work
    override init(texture: SKTexture?, color: UIColor, size:CGSize){
        super.init(texture: texture, color: color, size: size)
    }
    //You are required to implement this for your subclass to work
    
    required init? (coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }

    func connectInterference(){
    
        //Connect the objects
        fork = childNodeWithName("Fork") as! SKSpriteNode
        knife = childNodeWithName("Knife") as! SKSpriteNode
        
        // Set the Default side
        object = .None
    }


    var object: Object = .None {
        didSet{
            switch object {
            case .Fork:
                fork.hidden = false
            case .Knife:
                knife.hidden = false
            case .None:
                knife.hidden = true
                fork.hidden = true
            }
        }
    
    
    
    }
}
