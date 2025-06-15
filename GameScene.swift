//
//  GameScene.swift
//  flappyBird
//
//  Created by Enes Bayri on 6.03.2025.
//

import SpriteKit
import GameplayKit
import UIKit



class GameScene: SKScene , SKPhysicsContactDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var moveAction: SKAction?
    
    var bird = SKSpriteNode()
    
    var gameStarted = false
    
    var originalBirdPosition: CGPoint!
    
    var walls: [SKSpriteNode] = []
    
    var scoreLabel: SKLabelNode!
    var bestScoreLabel: SKLabelNode!
    
    var bestScore = 0
    var score = 0
    
    var infoLabel: SKLabelNode!
    
    var changeButton = SKNode()
    
    var tutorialNode: SKShapeNode?
    
    var lastEnemySpawnTime: TimeInterval = 0
    let enemySpawnCooldown: TimeInterval = 3.0 // saniye
    
    // for pick image
    var viewController: UIViewController!
    
    
    enum CollisionCategory: UInt32 {
        case bird = 1
        case wall = 2
        case enemyObstacle = 4  // yeni eklenen düşman objesi
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self  // Çarpışma Algılama
        self.scaleMode = .fill
        
        
        let bg = SKSpriteNode()
        bg.texture = SKTexture(imageNamed: "wall")
        bg.size = CGSize(width: self.frame.width, height: self.frame.height)
        bg.zPosition = -1
        
        self.addChild(bg)
        
        bird = SKSpriteNode(imageNamed: "bird")
        bird.size = CGSize(width: 100, height: 80)
        bird.position = CGPoint(x: -self.frame.width/2 + 150 , y: self.frame.midY)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: 45)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.mass = 0.13
        bird.zPosition = 0
        
        
        // Çarpışma Algılama : KUŞ
        bird.physicsBody?.categoryBitMask = CollisionCategory.bird.rawValue
        bird.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue | CollisionCategory.enemyObstacle.rawValue   // Kuş rakip engeline çarparsa
        bird.physicsBody?.collisionBitMask = CollisionCategory.wall.rawValue
        

        
        
        self.addChild(bird)
        
        originalBirdPosition = bird.position
        
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = ""
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 350)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        

        bestScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        bestScoreLabel.text = "Best Score: \(bestScore)"
        bestScoreLabel.fontSize = 36
        bestScoreLabel.fontColor = .white
        bestScoreLabel.position = CGPoint(x: self.frame.minX + 170, y: self.frame.maxY - 120)
        bestScoreLabel.zPosition = 1
        self.addChild(bestScoreLabel)
        
        
        infoLabel = SKLabelNode(fontNamed: "Chalkduster")
        infoLabel.text = "Tap to Start"
        infoLabel.fontSize = 36
        infoLabel.fontColor = .white
        infoLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 120)
        infoLabel.horizontalAlignmentMode = .center
        infoLabel.zPosition = 1
        
        self.addChild(infoLabel)
        
        
        // change button
        
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
        
        
        // Arka plan dairesi
        let infoBackground = SKShapeNode(circleOfRadius: 30)
        infoBackground.fillColor = SKColor(red: 0.2, green: 0.2, blue: 0.25, alpha: 0.8) // koyu gri/siyah
        infoBackground.strokeColor = .clear
        infoBackground.position = CGPoint(x: frame.maxX - 50, y: frame.minY + 60)
        infoBackground.zPosition = 5
        infoBackground.name = "infoButtonBackground" // dokunma için istenirse kullanılabilir

        // ❓ simgesi
        let infoLabel = SKLabelNode(fontNamed: "Chalkduster")
        infoLabel.name = "infoButton"
        infoLabel.text = "❓"
        infoLabel.fontSize = 50
        infoLabel.fontColor = .white
        infoLabel.position = CGPoint(x: 0, y: -18) // Arka plan merkezine hizalanır
        infoLabel.zPosition = 6

        infoBackground.addChild(infoLabel)
        addChild(infoBackground)
        
        
        bestScoreControl()
        
        startInfoAnimation()
        
        
        showTutorialOverlay()
   
    }
    
    
    func showTutorialOverlay() {
        let overlaySize = CGSize(width: frame.width, height: frame.height)
        
        // Ana yarı şeffaf zemin
        let background = SKShapeNode(rectOf: overlaySize)
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.fillColor = .black.withAlphaComponent(0.75)
        background.strokeColor = .clear
        background.zPosition = 100
        background.name = "tutorialOverlay"

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

        // Açıklama metni
        let label = SKLabelNode(fontNamed: "Chalkduster")
        
        label.text = """
        🌟 How to Play 🌟

        🟦 Tap the LEFT side to FLY your bird
        🔴 Tap the RIGHT side to send BEES to your rival

        🧍 Play solo by using only the left side!
        👬 Or play together with a friend on the same screen!

        🐝 Avoid all obstacles and enemy bees
        🏆 Try to reach the highest score!
        """
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
        
        let modeLabel = SKLabelNode(fontNamed: "Chalkduster")
        modeLabel.text = "🧍 Single Player or 👬 Two Players!"
        modeLabel.fontSize = 32
        modeLabel.fontColor = .white
        modeLabel.position = CGPoint(x: 0, y: frame.height / 2 - 120)
        modeLabel.zPosition = 103
        background.addChild(modeLabel)

        addChild(background)
        tutorialNode = background
    }
    
    
    func spawnObstacleFromRight(at yPosition: CGFloat) {
        let enemy = SKSpriteNode(imageNamed: "bee") // Projeye 'bee' resmi ekleyin
        enemy.size = CGSize(width: 50, height: 50)
        enemy.position = CGPoint(x: self.frame.maxX + 30, y: yPosition)
        enemy.zPosition = 1
        enemy.name = "enemyObstacle"

        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.categoryBitMask = CollisionCategory.enemyObstacle.rawValue
        enemy.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue
        enemy.physicsBody?.collisionBitMask = 0 // temas var, fiziksel tepki yok

        addChild(enemy)

        let move = SKAction.moveTo(x: self.frame.minX - 60, duration: 3.0)
        let remove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([move, remove]))
    }
    
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        self.viewController = self.view?.window?.rootViewController
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
    
    func bestScoreControl(){
        if UserDefaults.standard.integer(forKey: "bestScore") > score {
            bestScore = UserDefaults.standard.integer(forKey: "bestScore")
            bestScoreLabel.text = "Best Score : \(bestScore)"
        }
        else {
            bestScore = score
            bestScoreLabel.text = "Best Score : \(bestScore)"
            UserDefaults.standard.set(bestScore, forKey: "bestScore")
        }
    }
    
    func startSpawningObjects() {
            let spawnAction = SKAction.run { [weak self] in
                self?.spawnMovingObject()
            }
            
            let delayAction = SKAction.wait(forDuration: 2.0) // 2 saniyede bir yeni obje ekle
            let sequence = SKAction.sequence([spawnAction, delayAction])
            let repeatAction = SKAction.repeatForever(sequence)
            
            run(repeatAction, withKey: "spawnObjects") // Sürekli obje üretme işlemini başlat
        }
        
        func spawnMovingObject() {
            let objHeight = Int.random(in: 200...(Int(self.frame.height) - 300))
            let obj2Height = Int(self.frame.height) - objHeight - 100
            
            let object = SKSpriteNode(imageNamed: "stone") //self.frame.height/2 - 100)
            object.size = CGSize(width: 50, height: objHeight) //self.frame.height/2 - 100)
            let object2 = SKSpriteNode(imageNamed: "stone") //self.frame.height/2 - 100)
            object2.size = CGSize(width: 50, height: obj2Height)
            
            
            // Çarpışma algılama konfigürasyonları
            
            object.physicsBody = SKPhysicsBody(rectangleOf: object.size)
            object.physicsBody?.isDynamic = false
            object.physicsBody?.affectedByGravity = false
            
            
            object2.physicsBody = SKPhysicsBody(rectangleOf: object2.size)
            object2.physicsBody?.affectedByGravity = false
            object2.physicsBody?.isDynamic = false
            
            
            walls.append(object) // Skorlama için gerekli
            
            let startX = self.frame.width/2
            let startY = self.frame.size.height/2 - object.size.height/2
            
            object.position = CGPoint(x: startX, y: startY)
            addChild(object)
            object2.position = CGPoint(x: startX, y: -self.frame.size.height/2 + object2.size.height/2 - 100)
            addChild(object2)
            
            let endX = self.frame.width/2 * -1
            let duration: TimeInterval = 3.0 // Hareket süresi
            
            let moveAction = SKAction.moveTo(x: endX, duration: duration)
            let removeAction = SKAction.removeFromParent()
            
            self.moveAction = moveAction // Hareketi bir değişkene kaydediyoruz
            object.run(SKAction.sequence([moveAction, removeAction]))
            object2.run(SKAction.sequence([moveAction, removeAction]))
        }
        
        func stopObjectMovement() {
            // Objelerin hareketini durdur
            self.removeAction(forKey: "spawnObjects")
            self.enumerateChildNodes(withName: "//") { node, _ in
                node.removeAllActions() // Tüm hareketleri durdur
            }
        }
        
        func startObjectMovement() {
            // Objelerin hareketini yeniden başlat
            startSpawningObjects()
        }
    
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint) {

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if contactMask == (CollisionCategory.bird.rawValue | CollisionCategory.wall.rawValue) ||
           contactMask == (CollisionCategory.bird.rawValue | CollisionCategory.enemyObstacle.rawValue) {
            // oyun biter
            gameOver()
        }
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

        // 🎯 2. Butonlara öncelik ver (changeButton + infoButton)
        if tappedNode.name == "changeButton" || tappedNode.name == "changeIcon" {
            openPhotoLibrary()
            return
        }

        if tappedNode.name == "infoButton" || tappedNode.name == "infoButtonBackground" {
            if tutorialNode == nil {
                showTutorialOverlay()
            }
            return
        }

        // 🎯 3. Oyun kontrolleri (sol/sağ tıklamalar)
        let currentTime = CACurrentMediaTime()

        if location.x > self.frame.midX {
            // Sağ taraf → rakip saldırı (arı gönderme)
            if currentTime - lastEnemySpawnTime >= enemySpawnCooldown {
                spawnObstacleFromRight(at: location.y)
                lastEnemySpawnTime = currentTime
            } else {
                // Cooldown uyarısı göster
                let waitLabel = SKLabelNode(fontNamed: "Chalkduster")
                waitLabel.text = "Wait 3 sec!"
                waitLabel.fontSize = 24
                waitLabel.fontColor = .red
                waitLabel.position = CGPoint(x: location.x, y: location.y + 40)
                waitLabel.zPosition = 10
                waitLabel.alpha = 0.0

                addChild(waitLabel)

                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.2)
                let wait = SKAction.wait(forDuration: 1.0)
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()

                waitLabel.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
            }
        } else {
            // Sol taraf → kuş zıplatma ve oyun başlatma
            if gameStarted == false {
                stopInfoAnimation()
                infoLabel.isHidden = true
                startObjectMovement()
                bird.physicsBody?.affectedByGravity = true
                bird.physicsBody?.isDynamic = true
                gameStarted = true
            }
            if changeButton.isHidden == false {
                changeButton.isHidden = true
            }
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 70))
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    
    override func update(_ currentTime: TimeInterval) {
        if (bird.position.y < self.frame.minY || bird.position.x < (self.frame.minX - 80 )) && gameStarted == true {
            gameOver()
            
        }
        if gameStarted == true && walls.count > 0{  // SKOR SİSTEMİ İÇİN KONTROL YAPILIR VE SKOR EKLENİR
            if (walls.first?.position.x)! < bird.position.x {
                print("+1 Puannn")
                score += 1
                scoreLabel.text = "Score: \(score)"
                walls.removeFirst()
            }
        }
        
    }
    
    func gameOver() {
        // Kuşun tüm etkilerini kaldır
        bird.removeAllActions()
        bird.physicsBody = nil // önce fiziksel etkileşimi tamamen kaldır

        // Pozisyonu sıfırla
        bird.position = originalBirdPosition
        bird.zRotation = 0

        // Yeni physics body tanımla
        bird.physicsBody = SKPhysicsBody(circleOfRadius: 45)
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.mass = 0.13
        bird.physicsBody?.categoryBitMask = CollisionCategory.bird.rawValue
        bird.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue | CollisionCategory.enemyObstacle.rawValue
        bird.physicsBody?.collisionBitMask = CollisionCategory.wall.rawValue

        // Objeleri durdur
        stopObjectMovement()
        walls.removeAll()

        // Skor işlemleri
        score = 0
        scoreLabel.text = ""

        // UI
        gameStarted = false
        infoLabel.text = "Game Over! Tap to Play Again"
        infoLabel.isHidden = false
        startInfoAnimation()
        changeButton.isHidden = false

        // Best skor
        bestScoreControl()
    }
    
    func openPhotoLibrary() {
        guard let viewController = self.view?.window?.rootViewController else {
                print("viewController bulunamadı!")
                return
            }
            // UIImagePickerController'ı açmak için kontrol et
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                DispatchQueue.main.async{
                    viewController.present(imagePicker, animated: true, completion: nil)
                }
            } else {
                print("Fotoğraf galerisi kullanılamıyor.")
            }
        }
        
        // Seçilen fotoğrafı aldığınızda
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                DispatchQueue.main.async{
                    self.updateBirdTexture(with: selectedImage)
                    print("Görsel seçildi.")
                }
                // Burada görseli kullanabilir ve SpriteKit sahnesine ekleyebilirsiniz
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        // Fotoğraf seçme işlemi iptal edildiğinde
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            DispatchQueue.main.async{
                picker.dismiss(animated: true, completion: nil)
                print("Görsel seçme işlemi iptal edildi.")
            }
        }
    
  
    
    func updateBirdTexture(with image: UIImage) {
            let roundedImage = makeRoundedImage(image: image, cornerRadius: 100)
            let texture = SKTexture(image: roundedImage)
            
            bird.texture = texture

        }

        // Yuvarlatılmış UIImage oluştur
        func makeRoundedImage(image: UIImage, cornerRadius: CGFloat) -> UIImage {
            let rect = CGRect(origin: .zero, size: image.size)
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
            image.draw(in: rect)
            let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return roundedImage ?? image
        }


}
