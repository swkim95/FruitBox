import SpriteKit

class PauseMenu: SKNode {
    
    private var backgroundPanel: SKShapeNode!
    private var resumeButton: SKShapeNode!
    private var optionsButton: SKShapeNode!
    private var menuButton: SKShapeNode!
    
    var onResume: (() -> Void)?
    var onOptions: (() -> Void)?
    var onMenu: (() -> Void)?
    
    override init() {
        super.init()
        setupMenu()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMenu() {
        // Semi-transparent background that covers the entire screen
        let screenSize = UIScreen.main.bounds.size
        let background = SKShapeNode(rectOf: CGSize(width: screenSize.width * 2, height: screenSize.height * 2))
        background.fillColor = SKColor.black.withAlphaComponent(0.5)
        background.strokeColor = SKColor.clear
        background.zPosition = 100
        addChild(background)
        
        // Panel background
        backgroundPanel = SKShapeNode(rectOf: CGSize(width: 300, height: 350), cornerRadius: 20)
        backgroundPanel.fillColor = SKColor.white.withAlphaComponent(0.9)
        backgroundPanel.strokeColor = SKColor.black
        backgroundPanel.lineWidth = 2
        backgroundPanel.position = CGPoint(x: 0, y: 0)
        backgroundPanel.zPosition = 101
        addChild(backgroundPanel)
        
        // Title
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Game Paused"
        titleLabel.fontSize = 32
        titleLabel.fontColor = SKColor.black
        titleLabel.position = CGPoint(x: 0, y: 120)
        titleLabel.zPosition = 102
        backgroundPanel.addChild(titleLabel)
        
        // Resume button
        resumeButton = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 10)
        resumeButton.fillColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7)
        resumeButton.strokeColor = SKColor.black
        resumeButton.lineWidth = 1
        resumeButton.position = CGPoint(x: 0, y: 50)
        resumeButton.zPosition = 102
        resumeButton.name = "resumeButton"
        
        let resumeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        resumeLabel.text = "Resume"
        resumeLabel.fontSize = 24
        resumeLabel.fontColor = SKColor.white
        resumeLabel.verticalAlignmentMode = .center
        resumeLabel.horizontalAlignmentMode = .center
        resumeButton.addChild(resumeLabel)
        
        backgroundPanel.addChild(resumeButton)
        
        // Options button
        optionsButton = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 10)
        optionsButton.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.8, alpha: 0.7)
        optionsButton.strokeColor = SKColor.black
        optionsButton.lineWidth = 1
        optionsButton.position = CGPoint(x: 0, y: -30)
        optionsButton.zPosition = 102
        optionsButton.name = "optionsButton"
        
        let optionsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        optionsLabel.text = "Options"
        optionsLabel.fontSize = 24
        optionsLabel.fontColor = SKColor.white
        optionsLabel.verticalAlignmentMode = .center
        optionsLabel.horizontalAlignmentMode = .center
        optionsButton.addChild(optionsLabel)
        
        backgroundPanel.addChild(optionsButton)
        
        // Menu button
        menuButton = SKShapeNode(rectOf: CGSize(width: 200, height: 60), cornerRadius: 10)
        menuButton.fillColor = SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 0.7)
        menuButton.strokeColor = SKColor.black
        menuButton.lineWidth = 1
        menuButton.position = CGPoint(x: 0, y: -110)
        menuButton.zPosition = 102
        menuButton.name = "menuButton"
        
        let menuLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        menuLabel.text = "Main Menu"
        menuLabel.fontSize = 24
        menuLabel.fontColor = SKColor.white
        menuLabel.verticalAlignmentMode = .center
        menuLabel.horizontalAlignmentMode = .center
        menuButton.addChild(menuLabel)
        
        backgroundPanel.addChild(menuButton)
    }
    
    func handleTouch(at location: CGPoint) -> Bool {
        let localLocation = convert(location, from: parent!)
        
        if resumeButton.contains(localLocation) {
            onResume?()
            return true
        } else if optionsButton.contains(localLocation) {
            onOptions?()
            return true
        } else if menuButton.contains(localLocation) {
            onMenu?()
            return true
        }
        
        return false
    }
}