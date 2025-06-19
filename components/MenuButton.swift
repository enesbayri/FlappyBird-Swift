




import SpriteKit

class MenuButton: SKSpriteNode {

    let label = SKLabelNode()
    var onTap: (() -> Void)?

    init(text: String, size: CGSize) {
        let texture = SKTexture(imageNamed: "buttonBg")
        super.init(texture: texture, color: .clear, size: size)
        
        self.isUserInteractionEnabled = true

        self.zPosition = 1
        self.name = "button"

        label.text = text
        label.fontName = "Chalkduster"
        label.fontSize = 24
        label.fontColor = .yellow
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 2

        // Gölge etiketi
        let shadowLabel = SKLabelNode(text: text)
        shadowLabel.fontName = label.fontName
        shadowLabel.fontSize = label.fontSize
        shadowLabel.fontColor = UIColor.black
        shadowLabel.position = CGPoint(x: label.position.x + 1, y: label.position.y - 8)
        shadowLabel.zPosition = label.zPosition - 1

        addChild(shadowLabel)
        addChild(label)    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Dokunma başladığında küçültme animasyonu
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
            self.run(scaleDown)
        }
        
        // Dokunma iptal veya bırakıldığında eski haline dön ve action tetikle
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
            self.run(scaleUp)

            // Eğer dokunma gerçekten bu buton üzerindeyse
            print("Çalıştı")
            onTap?()
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
            self.run(scaleUp)
        }
}
