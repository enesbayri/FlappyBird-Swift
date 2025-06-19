//
//  MainMenuScene.swift
//  flappyBird
//
//  Created by Enes Bayri on 19.06.2025.
//

import UIKit
import SpriteKit

class MainMenuScene: SKScene {
    
    var bg: SKSpriteNode = SKSpriteNode()
    
    var tutorialNode: SKShapeNode?
    
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5) // Merkeze göre konumlama
        setupMainScreen()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = self.atPoint(location)

        // 🎯 1. Tutorial ekranı varsa kaldır
        if let tutorial = tutorialNode {
            tutorial.removeFromParent()
            tutorialNode = nil
            return
        }

        
    }
    
    func setupMainScreen() {
        // Arka plan
        bg.texture = SKTexture(imageNamed: "wall1")
        bg.size = CGSize(width: frame.width, height: frame.height)
        bg.zPosition = -1
        bg.position = CGPoint(x: 0, y: 0)
        addChild(bg)
        
        // Taş duvarlar (köşe direkleri)
        let wallSize = CGSize(width: 50, height: frame.height / 2 - 100)
        
        let wall1 = SKSpriteNode(texture: SKTexture(imageNamed: "stone"))
        wall1.size = wallSize
        wall1.position = CGPoint(x: -frame.width / 2 + 50, y: -frame.height / 2 + frame.height * 0.18)
        
        let wall2 = SKSpriteNode(texture: SKTexture(imageNamed: "stone"))
        wall2.size = wallSize
        wall2.position = CGPoint(x: -frame.width / 2 + 50, y: frame.height / 2 - 100)
        
        let wall3 = SKSpriteNode(texture: SKTexture(imageNamed: "stone"))
        wall3.size = wallSize
        wall3.position = CGPoint(x: frame.width / 2 - 50, y: -frame.height / 2 + frame.height * 0.18)
        
        let wall4 = SKSpriteNode(texture: SKTexture(imageNamed: "stone"))
        wall4.size = wallSize
        wall4.position = CGPoint(x: frame.width / 2 - 50, y: frame.height / 2 - 100)
        
        addChild(wall1)
        addChild(wall2)
        addChild(wall3)
        addChild(wall4)
        
        // Butonları ekle
        addButtons()
    }
    
    func addButtons() {
        let buttonWidth = frame.width * 0.55
        let buttonHeight: CGFloat = 80
        
        let singleGameButton = MenuButton(text: "Single Game", size: CGSize(width: buttonWidth, height: buttonHeight))
        singleGameButton.position = CGPoint(x: 0, y: frame.height * 0.3)
        singleGameButton.onTap = startSingleGame
        
        let duelGameButton = MenuButton(text: "Duel Game", size: CGSize(width: buttonWidth, height: buttonHeight))
        duelGameButton.position = CGPoint(x: 0, y: frame.height * 0.1)
        duelGameButton.onTap = startDuelGame
        
        let timeGameButton = MenuButton(text: "Time Challenge", size: CGSize(width: buttonWidth, height: buttonHeight))
        timeGameButton.position = CGPoint(x: 0, y: -frame.height * 0.1)
        timeGameButton.onTap = timeChallengeGame
        
        let aboutCreditsButton = MenuButton(text: "About/Credits", size: CGSize(width: buttonWidth, height: buttonHeight))
        aboutCreditsButton.onTap = aboutCredits
        
        aboutCreditsButton.position = CGPoint(x: 0, y: -frame.height * 0.3)
        
        addChild(singleGameButton)
        addChild(duelGameButton)
        addChild(timeGameButton)
        addChild(aboutCreditsButton)
    }
    
    func showTutorial() {
        let overlayNode = Tutorial.showTutorialOverlay(frame: frame ,scene: self, isScale: false , isSingle: false)
        tutorialNode = overlayNode

    }
    
    func aboutCredits() {
        showTutorial()
    }
    
    func startDuelGame() {
        let referenceSize = CGSize(width: 750, height: 1334)
        let gameScene = GameScene(size: referenceSize)
        gameScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        gameScene.scaleMode = .aspectFill
        self.view?.presentScene(gameScene, transition: .fade(withDuration: 1.0))
    }
    
    func startSingleGame() {
        let referenceSize = CGSize(width: 750, height: 1334)
        let gameScene = GameScene(size: referenceSize)
        gameScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        gameScene.isDualMode = false
        gameScene.scaleMode = .aspectFill
        self.view?.presentScene(gameScene, transition: .fade(withDuration: 1.0))
    }
    
    func timeChallengeGame() {
        let referenceSize = CGSize(width: 750, height: 1334)
        let gameScene = TimeChallengeScene(size: referenceSize)
        gameScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        gameScene.scaleMode = .aspectFill
        self.view?.presentScene(gameScene, transition: .fade(withDuration: 1.0))
    }
}
