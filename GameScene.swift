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
    
    // for pick image
    var viewController: UIViewController!
    
    
    enum CollisionCategory: UInt32 {
        case bird = 1
        case wall = 2
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
        bird.physicsBody?.contactTestBitMask = CollisionCategory.bird.rawValue
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
        
        
        
    
        
        
        bestScoreControl()
        
        startInfoAnimation()
        
   
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
            for touch in touches {
                let location = touch.location(in: self)
                
                // Butonun üzerine tıklanıp tıklanmadığını kontrol et
                if let tappedNode = self.atPoint(location) as? SKSpriteNode {
                    if tappedNode.name == "changeButton" {
                        print("Basıldı")
                        openPhotoLibrary()
                        
                    }else {
                        if gameStarted == false {
                            
                            // bilgi metni gizleme
                            stopInfoAnimation()
                            infoLabel.isHidden = true
                            
                            // Duvarları başlatma
                            startObjectMovement()
                            
                            // Kuş yerçekimi başlatma
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
            stopObjectMovement()  // KAYAN DUVARLARI DURDURMA
            walls.removeAll() // SKOR SİSTEMİ İÇN DUVARLARI SIFIRLAMA
            
            // Oyunu Durdurma
            gameStarted = false
            
            // Bilgi metni gösterme
            startInfoAnimation()
            infoLabel.isHidden = false
            infoLabel.text = "Game Over! Tap to play again"
            
            // KUŞU RESETLEME
            bird.physicsBody?.affectedByGravity = false
            bird.physicsBody?.isDynamic = false
            bird.position = originalBirdPosition
            
            
            // en iyi skor kontrolü
            bestScoreControl()
            
            
            // skor sıfırlama
            score = 0
            
            // değişim butonu gösterme
            changeButton.isHidden = false
            
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
