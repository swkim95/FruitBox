import SpriteKit

class StartScene: SKScene {
    
    override func didMove(to view: SKView) {
        // Set background color from options
        backgroundColor = OptionsScene.backgroundColor
        
        setupUI()
    }
    
    private func setupUI() {
        // Game title with fancy font
        let titleShadowLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleShadowLabel.text = "Ruga Box"
        titleShadowLabel.fontSize = 60
        titleShadowLabel.fontColor = SKColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        titleShadowLabel.position = CGPoint(x: size.width/2 - 5, y: size.height * 0.7 - 5)
        addChild(titleShadowLabel)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Ruga Box"
        titleLabel.fontSize = 60
        titleLabel.fontColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7)
        titleLabel.position = CGPoint(x: size.width/2, y: size.height * 0.7)
        addChild(titleLabel)
        
        // Start button
        let startButton = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 10)
        startButton.fillColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.3)
        startButton.strokeColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7)
        startButton.lineWidth = 3
        startButton.position = CGPoint(x: size.width/2, y: size.height * 0.5)
        startButton.name = "startButton"
        
        let startLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        startLabel.text = "Start Game"
        startLabel.fontSize = 24
        startLabel.fontColor = SKColor.black
        startLabel.verticalAlignmentMode = .center
        startLabel.horizontalAlignmentMode = .center
        startButton.addChild(startLabel)
        
        addChild(startButton)
        
        // Options button
        let optionsButton = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 10)
        optionsButton.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 0.3)
        optionsButton.strokeColor = SKColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 0.7)
        optionsButton.lineWidth = 3
        optionsButton.position = CGPoint(x: size.width/2, y: size.height * 0.35)
        optionsButton.name = "optionsButton"
        
        let optionsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        optionsLabel.text = "Options"
        optionsLabel.fontSize = 24
        optionsLabel.fontColor = SKColor.black
        optionsLabel.verticalAlignmentMode = .center
        optionsLabel.horizontalAlignmentMode = .center
        optionsButton.addChild(optionsLabel)
        
        addChild(optionsButton)
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
            } else if node.name == "optionsButton" {
                // Transition to options scene
                let optionsScene = OptionsScene(size: self.size)
                optionsScene.scaleMode = .aspectFill
                
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(optionsScene, transition: transition)
                break
            }
        }
    }
}