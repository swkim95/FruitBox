import SpriteKit

class BonusCat: SKSpriteNode {
    
    // Time bonus amount in seconds
    static var bonusTime: TimeInterval {
        return OptionsScene.bonusCatTimeBonus
    }
    
    // Callback for when the bonus is collected
    var onCollect: (() -> Void)?
    
    // Create a new bonus cat at the specified position
    init(at position: CGPoint, size: CGSize) {
        // Load the bonus cat image
        let texture = SKTexture(imageNamed: "bonus_cat")
        
        super.init(texture: texture, color: .white, size: size)
        
        self.position = position
        self.zPosition = 100 // Ensure it appears above other game elements
        self.name = "bonusCat"
        
        // Add a subtle animation to make it noticeable
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.5)
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        self.run(repeatPulse)
        
        // Make it interactive
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Handle touch events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Call the collect callback
        onCollect?()
        
        // Play a collection animation
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([scaleUp, fadeOut, remove])
        self.run(sequence)
        
        // Add a "+Xs" text that floats up (where X is the actual bonus amount)
        let bonusText = SKLabelNode(fontNamed: "AvenirNext-Bold")
        bonusText.text = "+\(Int(OptionsScene.bonusCatTimeBonus))s"
        bonusText.fontSize = 24
        bonusText.fontColor = SKColor.green
        bonusText.position = CGPoint(x: 0, y: 0)
        bonusText.zPosition = 101
        self.addChild(bonusText)
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        let textFade = SKAction.fadeOut(withDuration: 1.0)
        let textRemove = SKAction.removeFromParent()
        let textSequence = SKAction.sequence([SKAction.group([moveUp, textFade]), textRemove])
        bonusText.run(textSequence)
    }
} 