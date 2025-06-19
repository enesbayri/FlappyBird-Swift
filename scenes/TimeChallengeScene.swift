//
//  TimeChallengeScene.swift
//  flappyBird
//
//  Created by Enes Bayri on 19.06.2025.
//

//
//  GameScene.swift
//  flappyBird
//
//  Created by Enes Bayri on 6.03.2025.
//

import SpriteKit
import GameplayKit
import UIKit




class TimeChallengeScene: SKScene, SKPhysicsContactDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var moveAction: SKAction?
    var bird = SKSpriteNode()
    
    var gameStarted = false
    var isGameActive = false  // Zaman challenge için oyun aktif mi?
    
    var originalBirdPosition: CGPoint!
    var walls: [SKSpriteNode] = []
    
    var scoreLabel: SKLabelNode!
    var bestScoreLabel: SKLabelNode!
    var score = 0
    var bestScore = 0
    
    var infoLabel: SKLabelNode!
    var changeButton = SKNode()
    
    var tutorialNode: SKShapeNode?
    
    
    var viewController: UIViewController!
    
    var timerLabel: SKLabelNode!
    var gameTimer: Timer?
    var timeRemaining = 60
    
    enum CollisionCategory: UInt32 {
        case bird = 1
        case wall = 2
        case enemyObstacle = 4
    }
    
    override func didMove(to view: SKView) {
        print("Scene frame size: \(self.frame.size)")
        
        self.physicsWorld.contactDelegate = self
        self.scaleMode = .fill
        
        // Arka plan
        let bg = SKSpriteNode(texture: SKTexture(imageNamed: "wall"))
        bg.size = CGSize(width: self.frame.width, height: self.frame.height)
        bg.zPosition = -1
        bg.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(bg)
        
        // Kuş
        bird = SKSpriteNode(imageNamed: "bird")
        bird.size = CGSize(width: 100, height: 80)
        bird.position = CGPoint(x: -self.frame.width/2 + 150 , y: self.frame.midY)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: 45)
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.mass = 0.13
        bird.zPosition = 0
        
        bird.physicsBody?.categoryBitMask = CollisionCategory.bird.rawValue
        bird.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue | CollisionCategory.enemyObstacle.rawValue
        bird.physicsBody?.collisionBitMask = CollisionCategory.wall.rawValue
        
        self.addChild(bird)
        
        originalBirdPosition = bird.position
        
        // Skor Label
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = ""
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 350)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        // Best Skor Label
        bestScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        bestScoreLabel.text = "Best Score: \(bestScore)"
        bestScoreLabel.fontSize = 36
        bestScoreLabel.fontColor = .white
        bestScoreLabel.position = CGPoint(x: self.frame.minX + 170, y: self.frame.maxY - 120)
        bestScoreLabel.zPosition = 1
        self.addChild(bestScoreLabel)
        
        // Info Label
        infoLabel = SKLabelNode(fontNamed: "Chalkduster")
        infoLabel.text = "Tap to Start"
        infoLabel.fontSize = 36
        infoLabel.fontColor = .white
        infoLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 120)
        infoLabel.horizontalAlignmentMode = .center
        infoLabel.zPosition = 1
        self.addChild(infoLabel)
        
        // Change Button
        let changeIcon = SKSpriteNode(imageNamed: "change")
        changeIcon.position = CGPoint(x: self.frame.maxX - 80, y: self.frame.maxY - 120)
        changeIcon.size = CGSize(width: 80, height: 80)
        changeIcon.zPosition = 3
        changeIcon.name = "changeButton"
        
        let changeLabel = SKLabelNode(fontNamed: "Chalkduster")
        changeLabel.fontColor = .yellow
        changeLabel.fontSize = 24
        changeLabel.colorBlendFactor = 2
        changeLabel.text = "Character"
        changeLabel.position = CGPoint(x: self.frame.maxX - 80, y: self.frame.maxY - 180)
        
        changeButton = SKNode()
        changeButton.addChild(changeLabel)
        changeButton.addChild(changeIcon)
        self.addChild(changeButton)
        
        // Timer Label
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.fontSize = 40
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 300)
        timerLabel.zPosition = 2
        timerLabel.text = "Time: 60"
        addChild(timerLabel)
        
        bestScoreControl()
        startInfoAnimation()
        
        showTutorial()
        addBackButton()
    }
    
    func addBackButton() {
        let backButton = SKLabelNode(text: "◀ Back")
        backButton.fontName = "Chalkduster"
        backButton.fontSize = 24
        backButton.fontColor = .white
        backButton.position = CGPoint(x: frame.minX + 60, y: frame.minY + 40)
        backButton.zPosition = 500
        backButton.name = "backButton"
        addChild(backButton)
    }
    
    func startGame() {
        // Eğer zaten zamanlayıcı çalışıyorsa, zamanı sıfırlama
        if gameTimer == nil {
            timeRemaining = 60
            timerLabel.text = "Time: \(timeRemaining)"

            gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                self.timeRemaining -= 1
                self.timerLabel.text = "Time: \(self.timeRemaining)"
                
                if self.timeRemaining <= 0 {
                    timer.invalidate()
                    self.gameTimer = nil
                    self.endGameChallenge()
                }
            }
        }

        gameStarted = true
        isGameActive = true

        startObjectMovement()
        bird.physicsBody?.affectedByGravity = true
        bird.physicsBody?.isDynamic = true
        infoLabel.isHidden = true
        stopInfoAnimation()
        changeButton.isHidden = true
    }
    func resetGame() {
        bird.position = originalBirdPosition
        bird.zRotation = 0

        bird.physicsBody = SKPhysicsBody(circleOfRadius: 45)
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.mass = 0.13
        bird.physicsBody?.categoryBitMask = CollisionCategory.bird.rawValue
        bird.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue | CollisionCategory.enemyObstacle.rawValue
        bird.physicsBody?.collisionBitMask = CollisionCategory.wall.rawValue

        startGame()
    }

    func endGameChallenge() {
        isGameActive = false
        gameStarted = false
        gameTimer?.invalidate()
        gameTimer = nil

        bird.physicsBody = nil
        stopObjectMovement()
        walls.removeAll()

        // ✅ Best skor kontrol
        bestScoreControl()

        // ✅ Oyun bitti mesajı göster
        let overlay = SKShapeNode(rectOf: CGSize(width: frame.width * 0.8, height: 300), cornerRadius: 20)
        overlay.fillColor = .black.withAlphaComponent(0.8)
        overlay.strokeColor = .white
        overlay.lineWidth = 3
        overlay.position = CGPoint(x: frame.midX, y: frame.midY)
        overlay.zPosition = 200
        overlay.name = "gameOverOverlay"

        let message = SKLabelNode(fontNamed: "Chalkduster")
        message.text = "Time's Up! 🎯"
        message.fontSize = 36
        message.fontColor = .white
        message.position = CGPoint(x: 0, y: 40)
        message.zPosition = 201
        overlay.addChild(message)

        let scoreInfo = SKLabelNode(fontNamed: "Chalkduster")
        scoreInfo.text = "Score: \(score)"
        scoreInfo.fontSize = 28
        scoreInfo.fontColor = .yellow
        scoreInfo.position = CGPoint(x: 0, y: -10)
        scoreInfo.zPosition = 201
        overlay.addChild(scoreInfo)

        let restartLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLabel.text = "▶ Tap to Restart"
        restartLabel.fontSize = 20
        restartLabel.fontColor = .gray
        restartLabel.position = CGPoint(x: 0, y: -60)
        restartLabel.zPosition = 201
        restartLabel.name = "restartButton" // ✅ önemli
        overlay.addChild(restartLabel)


        addChild(overlay)

        // Skor sıfırlanır ama oyun başlamaz
        score = 0
        scoreLabel.text = ""
    }

    
    func resetBirdPosition() {
        bird.position = originalBirdPosition
        bird.zRotation = 0
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.angularVelocity = 0
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = false
    }
    
    func gameOver() {
        // Oyun durur, skor durur sıfırlanmaz
        isGameActive = false
        gameStarted = false
        
        stopObjectMovement()
        resetBirdPosition()
        
        infoLabel.text = "Game Over! Tap to Continue"
        infoLabel.isHidden = false
        startInfoAnimation()
        
        changeButton.isHidden = false
    }
    
    func startInfoAnimation() {
        let fadeOut = SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.fadeOut(withDuration: 0.5)])
        let fadeIn = SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.fadeIn(withDuration: 0.5)])
        let run = SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn]))
        infoLabel.run(run)
    }
    
    func stopInfoAnimation() {
        infoLabel.removeAllActions()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = self.atPoint(location)

        if let tutorial = tutorialNode {
            tutorial.removeFromParent()
            tutorialNode = nil
            return
        }

        if let gameOverOverlay = childNode(withName: "gameOverOverlay") {
            if tappedNode.name == "restartButton" || tappedNode.name == "restartButtonText" {
                gameOverOverlay.removeFromParent()
                resetGame()
            }
            return
        }

        if tappedNode.name == "changeButton" || tappedNode.name == "changeIcon" {
            openPhotoLibrary()
            return
        }
        
        if tappedNode.name == "backButton" {
            
            let mainMenuScene = MainMenuScene(size: UIScreen.main.bounds.size)
            mainMenuScene.scaleMode = .aspectFill
            self.view?.presentScene(mainMenuScene, transition: SKTransition.fade(withDuration: 0.5))
            return
        }

        if tappedNode.name == "infoButton" || tappedNode.name == "infoButtonBackground" {
            if tutorialNode == nil {
                showTutorial()
            }
            return
        }

        // ✅ Normal oyun başlangıcı
        if !gameStarted {
            startGame()
        }

        if isGameActive {
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70))
        }
    }



    
    override func update(_ currentTime: TimeInterval) {
        if isGameActive {
            if bird.position.y < self.frame.minY || bird.position.x < (self.frame.minX - 80) {
                gameOver()
            }
            
            if gameStarted && walls.count > 0 {
                if let firstWall = walls.first, firstWall.position.x < bird.position.x {
                    score += 1
                    scoreLabel.text = "Score: \(score)"
                    walls.removeFirst()
                }
            }
        }
    }
    
    func bestScoreControl() {
        if UserDefaults.standard.integer(forKey: "bestScore") > score {
            bestScore = UserDefaults.standard.integer(forKey: "bestScore")
            bestScoreLabel.text = "Best Score: \(bestScore)"
        } else {
            bestScore = score
            bestScoreLabel.text = "Best Score: \(bestScore)"
            UserDefaults.standard.set(bestScore, forKey: "bestScore")
        }
    }
    
    // Oyun objelerinin hareketini başlat
    func startObjectMovement() {
        // Obje üretme döngüsü
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnMovingObject()
        }
        
        let delayAction = SKAction.wait(forDuration: 2.0) // 2 saniyede bir yeni obje ekle
        let sequence = SKAction.sequence([spawnAction, delayAction])
        let repeatAction = SKAction.repeatForever(sequence)
        
        run(repeatAction, withKey: "spawnObjects")
    }
    
    func stopObjectMovement() {
        self.removeAction(forKey: "spawnObjects")
        self.enumerateChildNodes(withName: "//") { node, _ in
            node.removeAllActions()
        }
    }
    
    func spawnMovingObject() {
        // Rastgele yükseklik
        let minHeight: Int = 200
        let maxHeight: Int = Int(self.frame.height) - 300
        
        let objHeight = Int.random(in: minHeight...maxHeight)
        let obj2Height = Int(self.frame.height) - objHeight - 100
        
        let object = SKSpriteNode(imageNamed: "stone")
        object.size = CGSize(width: 50, height: objHeight)
        let object2 = SKSpriteNode(imageNamed: "stone")
        object2.size = CGSize(width: 50, height: obj2Height)
        
        object.physicsBody = SKPhysicsBody(rectangleOf: object.size)
        object.physicsBody?.isDynamic = false
        object.physicsBody?.affectedByGravity = false
        
        object2.physicsBody = SKPhysicsBody(rectangleOf: object2.size)
        object2.physicsBody?.isDynamic = false
        object2.physicsBody?.affectedByGravity = false
        
        walls.append(object)
        
        let startX = self.frame.width / 2
        let startY = self.frame.size.height / 2 - object.size.height / 2
        
        object.position = CGPoint(x: startX, y: startY)
        addChild(object)
        
        object2.position = CGPoint(x: startX, y: -self.frame.size.height / 2 + object2.size.height / 2 - 100)
        addChild(object2)
        
        let endX = self.frame.width / -2
        let duration: TimeInterval = 3.0
        
        let moveAction = SKAction.moveTo(x: endX, duration: duration)
        let removeAction = SKAction.removeFromParent()
        
        object.run(SKAction.sequence([moveAction, removeAction]))
        object2.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    func showTutorial() {
        tutorialNode = Tutorial.showTutorialOverlay(frame: frame, scene: self, isScale: true, isSingle: true)
    }
    
    func openPhotoLibrary() {
        guard let viewController = self.view?.window?.rootViewController else {
            print("viewController bulunamadı!")
            return
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            DispatchQueue.main.async {
                viewController.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            print("Fotoğraf galerisi kullanılamıyor.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            DispatchQueue.main.async {
                self.updateBirdTexture(with: selectedImage)
                print("Görsel seçildi.")
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        DispatchQueue.main.async {
            picker.dismiss(animated: true, completion: nil)
            print("Görsel seçme işlemi iptal edildi.")
        }
    }
    
    func updateBirdTexture(with image: UIImage) {
        let roundedImage = makeRoundedImage(image: image, cornerRadius: 100)
        let texture = SKTexture(image: roundedImage)
        bird.texture = texture
    }
    
    func makeRoundedImage(image: UIImage, cornerRadius: CGFloat) -> UIImage {
        let rect = CGRect(origin: .zero, size: image.size)
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        image.draw(in: rect)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage ?? image
    }
    
    // Physics Contact Delegate
    func didBegin(_ contact: SKPhysicsContact) {
        if !isGameActive { return }
        
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.categoryBitMask == CollisionCategory.bird.rawValue &&
            secondBody.categoryBitMask == CollisionCategory.enemyObstacle.rawValue {
            gameOver()
        }
    }
}
