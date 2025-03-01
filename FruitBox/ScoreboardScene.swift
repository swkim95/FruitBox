import SpriteKit

class ScoreboardScene: SKScene {
    
    private var currentBoardSize: OptionsScene.BoardSize = .small
    private var pageControl: SKNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = OptionsScene.backgroundColor
        
        setupUI()
        showScores(for: currentBoardSize)
    }
    
    private func setupUI() {
        // Title
        let titleLabel = SKLabelNode(fontNamed: "Futura-Bold")
        titleLabel.text = "High Scores"
        titleLabel.fontSize = 40
        titleLabel.fontColor = SKColor.black
        titleLabel.position = CGPoint(x: size.width/2, y: size.height - 150)
        addChild(titleLabel)
        
        // Back button
        let backButton = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 10)
        backButton.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7)
        backButton.strokeColor = SKColor.black
        backButton.lineWidth = 1
        backButton.position = CGPoint(x: 70, y: size.height - 40)
        backButton.name = "backButton"
        
        let backLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        backLabel.text = "Back"
        backLabel.fontSize = 18
        backLabel.fontColor = SKColor.white
        backLabel.verticalAlignmentMode = .center
        backLabel.horizontalAlignmentMode = .center
        backButton.addChild(backLabel)
        
        addChild(backButton)
        
        // Page control
        setupPageControl()
    }
    
    private func setupPageControl() {
        pageControl = SKNode()
        pageControl.position = CGPoint(x: size.width/2, y: 120)
        addChild(pageControl)
        
        // Small board button
        let smallButton = createPageButton(title: "Small", position: CGPoint(x: -120, y: 0), selected: true)
        smallButton.name = "smallButton"
        pageControl.addChild(smallButton)
        
        // Medium board button
        let mediumButton = createPageButton(title: "Medium", position: CGPoint(x: 0, y: 0), selected: false)
        mediumButton.name = "mediumButton"
        pageControl.addChild(mediumButton)
        
        // Large board button
        let largeButton = createPageButton(title: "Large", position: CGPoint(x: 120, y: 0), selected: false)
        largeButton.name = "largeButton"
        pageControl.addChild(largeButton)
    }
    
    private func createPageButton(title: String, position: CGPoint, selected: Bool) -> SKNode {
        let button = SKNode()
        button.position = position
        
        let background = SKShapeNode(rectOf: CGSize(width: 100, height: 40), cornerRadius: 10)
        background.fillColor = selected ? 
            SKColor(red: 0.1, green: 0.6, blue: 0.3, alpha: 0.7) : 
            SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7)
        background.strokeColor = SKColor.black
        background.lineWidth = 1
        button.addChild(background)
        
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = title
        label.fontSize = 18
        label.fontColor = SKColor.white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        button.addChild(label)
        
        return button
    }
    
    private func showScores(for boardSize: OptionsScene.BoardSize) {
        // Remove existing score nodes
        self.enumerateChildNodes(withName: "scoreNode") { node, _ in
            node.removeFromParent()
        }
        
        // Update page control
        updatePageControl(for: boardSize)
        
        // Get scores for the selected board size
        let scores = ScoreManager.shared.getScores(for: boardSize)
        
        // Create score table
        let tableNode = SKNode()
        tableNode.name = "scoreNode"
        tableNode.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(tableNode)
        
        // Table header
        let rankHeader = createLabel(text: "Rank", position: CGPoint(x: -150, y: 200), fontSize: 20)
        let scoreHeader = createLabel(text: "Score", position: CGPoint(x: -50, y: 200), fontSize: 20)
        let dateHeader = createLabel(text: "Date", position: CGPoint(x: 100, y: 200), fontSize: 20)
        
        tableNode.addChild(rankHeader)
        tableNode.addChild(scoreHeader)
        tableNode.addChild(dateHeader)
        
        // Add horizontal line below header
        let headerLine = SKShapeNode()
        let headerPath = CGMutablePath()
        headerPath.move(to: CGPoint(x: -200, y: 180))
        headerPath.addLine(to: CGPoint(x: 200, y: 180))
        headerLine.path = headerPath
        headerLine.strokeColor = SKColor.black
        headerLine.lineWidth = 1
        tableNode.addChild(headerLine)
        
        // Display scores
        if scores.isEmpty {
            let noScoresLabel = createLabel(text: "No scores yet", position: CGPoint(x: 0, y: 100), fontSize: 20)
            tableNode.addChild(noScoresLabel)
        } else {
            for (index, score) in scores.prefix(10).enumerated() {
                let yPos = 150 - CGFloat(index * 35)
                
                let rankLabel = createLabel(text: "\(index + 1)", position: CGPoint(x: -150, y: yPos), fontSize: 18)
                let scoreLabel = createLabel(text: "\(score.score)", position: CGPoint(x: -50, y: yPos), fontSize: 18)
                let dateLabel = createLabel(text: score.formattedDate(), position: CGPoint(x: 100, y: yPos), fontSize: 16)
                
                tableNode.addChild(rankLabel)
                tableNode.addChild(scoreLabel)
                tableNode.addChild(dateLabel)
            }
        }
        
        // // Board size title
        // let boardSizeText: String
        // switch boardSize {
        // case .small: boardSizeText = "Small"
        // case .medium: boardSizeText = "Medium"
        // case .large: boardSizeText = "Large"
        // }
        
        // let boardSizeTitle = createLabel(
        //     text: "Board Size: \(boardSizeText)",
        //     position: CGPoint(x: 0, y: 250),
        //     fontSize: 24
        // )
        // tableNode.addChild(boardSizeTitle)
    }
    
    private func createLabel(text: String, position: CGPoint, fontSize: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = fontSize
        label.fontColor = SKColor.black
        label.position = position
        return label
    }
    
    private func updatePageControl(for boardSize: OptionsScene.BoardSize) {
        // Reset all buttons
        if let smallButton = pageControl.childNode(withName: "smallButton") {
            if let background = smallButton.children.first as? SKShapeNode {
                background.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7)
            }
        }
        
        if let mediumButton = pageControl.childNode(withName: "mediumButton") {
            if let background = mediumButton.children.first as? SKShapeNode {
                background.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7)
            }
        }
        
        if let largeButton = pageControl.childNode(withName: "largeButton") {
            if let background = largeButton.children.first as? SKShapeNode {
                background.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7)
            }
        }
        
        // Highlight selected button
        let buttonName: String
        switch boardSize {
        case .small:
            buttonName = "smallButton"
        case .medium:
            buttonName = "mediumButton"
        case .large:
            buttonName = "largeButton"
        }
        
        if let selectedButton = pageControl.childNode(withName: buttonName) {
            if let background = selectedButton.children.first as? SKShapeNode {
                background.fillColor = SKColor(red: 0.1, green: 0.6, blue: 0.3, alpha: 0.7)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "backButton" || node.parent?.name == "backButton" {
                // Go back to start scene
                let startScene = StartScene(size: self.size)
                startScene.scaleMode = .aspectFill
                
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(startScene, transition: transition)
                return
            } else if node.name == "smallButton" || node.parent?.name == "smallButton" {
                currentBoardSize = .small
                showScores(for: currentBoardSize)
                return
            } else if node.name == "mediumButton" || node.parent?.name == "mediumButton" {
                currentBoardSize = .medium
                showScores(for: currentBoardSize)
                return
            } else if node.name == "largeButton" || node.parent?.name == "largeButton" {
                currentBoardSize = .large
                showScores(for: currentBoardSize)
                return
            }
        }
    }
} 