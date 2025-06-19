//
//  Tutorial.swift
//  flappyBird
//
//  Created by Enes Bayri on 19.06.2025.
//

import SpriteKit

class Tutorial{
    static func showTutorialOverlay(frame: CGRect, scene: SKScene , isScale: Bool , isSingle: Bool ) -> SKShapeNode {
        let overlaySize = CGSize(width: frame.width, height: frame.height)
        
        // Ana yarı şeffaf zemin
        let background = SKShapeNode(rectOf: overlaySize)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.fillColor = .black.withAlphaComponent(0.75)
        background.strokeColor = .clear
        background.zPosition = 100
        background.name = "tutorialOverlay"
        
        
        if isSingle {
            // Sol yarı (oyuncu)
            let playerZone = SKShapeNode(rectOf: CGSize(width: frame.width, height: frame.height))
            playerZone.position = CGPoint(x: frame.midX, y: frame.midY)
            playerZone.fillColor = SKColor.systemBlue.withAlphaComponent(0.4)
            playerZone.strokeColor = .clear
            playerZone.zPosition = 101
            background.addChild(playerZone)

        }else{
            // Sol yarı (oyuncu)
            let playerZone = SKShapeNode(rectOf: CGSize(width: frame.width / 2, height: frame.height))
            playerZone.position = CGPoint(x: frame.midX - frame.width / 4, y: frame.midY)
            playerZone.fillColor = SKColor.systemBlue.withAlphaComponent(0.4)
            playerZone.strokeColor = .clear
            playerZone.zPosition = 101
            background.addChild(playerZone)

            // Sağ yarı (rakip)
            let enemyZone = SKShapeNode(rectOf: CGSize(width: frame.width / 2, height: frame.height))
            enemyZone.position = CGPoint(x: frame.midX + frame.width / 4, y: frame.midY)
            enemyZone.fillColor = SKColor.systemRed.withAlphaComponent(0.4)
            enemyZone.strokeColor = .clear
            enemyZone.zPosition = 101
            background.addChild(enemyZone)
        }


        // Açıklama metni
        let label = SKLabelNode(fontNamed: "Chalkduster")
        
        if(isSingle){
            label.text = """
            🌟 How to Play 🌟
            

            🟦 Tap side to FLY your bird

            🧍 Play solo blue side!
            
            👬 Or play together with a friend on the other mode!

            
            🏆 Try to reach the highest score!
            """
        }else{
            label.text = """
            🌟 How to Play 🌟
            

            🟦 Tap the LEFT side to FLY your bird
            
            🔴 Tap the RIGHT side to send BEES to your rival
            

            🧍 Play solo by using only the left side!
            
            👬 Or play together with a friend on the same screen!
            

            🐝 Avoid all obstacles and enemy bees
            
            🏆 Try to reach the highest score!
            """
        }
        

        label.fontSize = 22
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = frame.width - 80
        label.position = CGPoint(x: 0, y: 100)
        label.fontColor = .white
        label.zPosition = 102
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        background.addChild(label)

        // "How to Play" etiketi (alt kısımda simgesel)
        let infoLabel = SKLabelNode(fontNamed: "Chalkduster")
        infoLabel.text = "Tap Anywhere to Start"
        infoLabel.fontSize = 18
        infoLabel.fontColor = .lightGray
        infoLabel.position = CGPoint(x: 0, y: -frame.height / 2 + 50)
        infoLabel.zPosition = 103
        background.addChild(infoLabel)
        
        if isScale {
            let modeLabel = SKLabelNode(fontNamed: "Chalkduster")
            modeLabel.text = "🧍 Single Player or 👬 Two Players!"
            modeLabel.preferredMaxLayoutWidth = frame.width
            modeLabel.numberOfLines = 2
            modeLabel.fontSize = 32
            modeLabel.fontColor = .white
            modeLabel.position = CGPoint(x: 0, y: frame.height / 2 - 120)
            modeLabel.zPosition = 103
            background.addChild(modeLabel)
        }
        

        scene.addChild(background)
        
        return background
        
    }
}
