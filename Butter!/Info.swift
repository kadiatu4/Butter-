//
//  info.swift
//  Butter!
//
//  Created by Kadiatou Diallo on 8/12/16.
//  Copyright © 2016 Kadiatou Diallo. All rights reserved.
//

import SpriteKit

class InfoPage: SKScene {
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let sceneAction = SKAction.runBlock({
            
            //Load info Scene
            let mainMenuScene = MainMenu(fileNamed: "MainMenu") as MainMenu!
            
            //Ensure correct aspect mode
            mainMenuScene.scaleMode = .AspectFill
            
            let transition = SKTransition.doorsCloseVerticalWithDuration(1.0)
            
            mainMenuScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene!.view?.presentScene(mainMenuScene, transition: transition)
        })
        self.runAction(sceneAction)
        
    }


}
