import SpriteKit

class StartScene: SKScene {
    
    override func didMove(to view: SKView) {
        // Set a matching background color
        backgroundColor = SKColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0) // Light blue-ish background
        
        setupUI()
    }
    
    private func setupUI() {
        // Game title with fancy font
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Fruit Box"
        titleLabel.fontSize = 56
        titleLabel.fontColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7)
        titleLabel.position = CGPoint(x: size.width/2, y: size.height * 0.7)
        addChild(titleLabel)
        
        // Start button
        let startButton = SKShapeNode(rectOf: CGSize(width: 220, height: 70), cornerRadius: 15)
        startButton.fillColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7)
        startButton.strokeColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7)
        startButton.lineWidth = 3
        startButton.position = CGPoint(x: size.width/2, y: size.height * 0.4)
        startButton.name = "startButton"
        
        let startLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        startLabel.text = "Start Game"
        startLabel.fontSize = 30
        startLabel.fontColor = SKColor.white
        startLabel.verticalAlignmentMode = .center
        startLabel.horizontalAlignmentMode = .center
        startButton.addChild(startLabel)
        
        // Add a simple animation to the button
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.5)
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.5)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        startButton.run(SKAction.repeatForever(pulse))
        
        addChild(startButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "startButton" {
                // Transition to game scene
                let gameScene = GameScene(size: self.size)
                gameScene.scaleMode = .aspectFill
                
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(gameScene, transition: transition)
                break
            }
        }
    }
} 