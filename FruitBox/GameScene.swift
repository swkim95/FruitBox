//
//  GameScene.swift
//  FruitBox
//
//  Created by 김성원 on 3/1/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Game board properties
    private var boardWidth = 9 // Number of columns
    private var boardHeight = 18 // Number of rows
    private var cellSize: CGFloat = 0
    private var cellSpacing: CGFloat = 2 // Small spacing between cells
    private var board: [[FruitCell?]] = [] // Changed to optional to allow for nil cells
    private var boardOriginY: CGFloat = 0
    private var boardOriginX: CGFloat = 0
    
    // Selection properties
    private var selectionBox: SKShapeNode?
    private var startPoint: CGPoint?
    private var currentPoint: CGPoint?
    private var selectedCells: [FruitCell] = []
    
    // Game state
    private var score = 0
    private var scoreLabel: SKLabelNode!
    
    // Timer properties
    private var gameTime: TimeInterval = 60.0 // 1 minute in seconds
    private var timeRemaining: TimeInterval = 60.0
    private var lastUpdateTime: TimeInterval = 0
    private var timerBar: SKShapeNode!
    private var timerBarWidth: CGFloat = 0
    private var timerLabel: SKLabelNode!
    private var isGameActive = true
    
    override func didMove(to view: SKView) {
        // Set a nicer background color that complements red
        backgroundColor = SKColor(red: 0.7, green: 0.95, blue: 0.7, alpha: 0.8) // Light blue-ish background
        
        setupGame()
        setupTimerBar()
        setupBackButton()
    }
    
    private func setupGame() {
        // Calculate safe area for gameplay
        let safeAreaTop: CGFloat = 150 // Increased to make room for timer
        let safeAreaBottom: CGFloat = 80 // Space at bottom
        let availableHeight = size.height - safeAreaTop - safeAreaBottom
        let availableWidth = size.width - 40 // 20 points padding on each side
        
        // Calculate cell size based on available space
        // Account for spacing between cells
        let totalHorizontalSpacing = cellSpacing * CGFloat(boardWidth - 1)
        let totalVerticalSpacing = cellSpacing * CGFloat(boardHeight - 1)
        
        let maxCellWidth = (availableWidth - totalHorizontalSpacing) / CGFloat(boardWidth)
        let maxCellHeight = (availableHeight - totalVerticalSpacing) / CGFloat(boardHeight)
        
        // Use the smaller dimension to ensure cells fit
        cellSize = min(maxCellWidth, maxCellHeight)
        
        // Calculate board dimensions
        let totalBoardWidth = (cellSize * CGFloat(boardWidth)) + (cellSpacing * CGFloat(boardWidth - 1))
        let totalBoardHeight = (cellSize * CGFloat(boardHeight)) + (cellSpacing * CGFloat(boardHeight - 1))
        
        // Center the board horizontally
        boardOriginX = (size.width - totalBoardWidth) / 2
        
        // Position board in the middle of the screen, slightly lower
        let middleY = size.height / 2
        boardOriginY = middleY - (totalBoardHeight / 2) - 30 // Shift down by 30 points
        
        // Create the game board
        createBoard()
        
        // Setup score display with fancy font
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = SKColor(red: 0.1, green: 0.6, blue: 0.3, alpha: 0.8) // Darker blue
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - 120)
        addChild(scoreLabel)
    }
    
    private func setupTimerBar() {
        // Create the background bar
        let barHeight: CGFloat = 20
        timerBarWidth = size.width - 40 // 20 points padding on each side
        
        let barBackground = SKShapeNode(rectOf: CGSize(width: timerBarWidth, height: barHeight), cornerRadius: 5)
        barBackground.fillColor = SKColor.lightGray.withAlphaComponent(0.5)
        barBackground.strokeColor = SKColor.darkGray
        barBackground.lineWidth = 1
        barBackground.position = CGPoint(x: size.width/2, y: size.height - 80)
        addChild(barBackground)
        
        // Create the timer bar
        timerBar = SKShapeNode(rectOf: CGSize(width: timerBarWidth, height: barHeight), cornerRadius: 5)
        timerBar.fillColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7) // Green
        timerBar.strokeColor = SKColor.clear
        timerBar.position = CGPoint(x: size.width/2, y: size.height - 80)
        addChild(timerBar)
        
        // Create timer label
        timerLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        timerLabel.text = "1:00"
        timerLabel.fontSize = 20
        timerLabel.fontColor = SKColor.white
        timerLabel.position = CGPoint(x: size.width/2, y: size.height - 80)
        timerLabel.verticalAlignmentMode = .center
        addChild(timerLabel)
    }
    
    private func createBoard() {
        // Initialize the board array with optionals
        board = Array(repeating: Array(repeating: nil, count: boardWidth), count: boardHeight)
        
        // Create cells with random values (1-9)
        for row in 0..<boardHeight {
            for col in 0..<boardWidth {
                let value = Int.random(in: 1...9)
                let cell = FruitCell(value: value)
                
                // Position the cell with minimal spacing
                let x = boardOriginX + (CGFloat(col) * (cellSize + cellSpacing)) + cellSize/2
                let y = boardOriginY + (CGFloat(boardHeight - 1 - row) * (cellSize + cellSpacing)) + cellSize/2
                cell.position = CGPoint(x: x, y: y)
                
                // Set the size of the cell and its contents
                cell.size = CGSize(width: cellSize, height: cellSize)
                cell.updateSize(size: cellSize)
                
                addChild(cell)
                board[row][col] = cell
            }
        }
    }
    
    private func setupBackButton() {
        // Back button
        let backButton = SKShapeNode(rectOf: CGSize(width: 80, height: 40), cornerRadius: 10)
        backButton.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7)
        backButton.strokeColor = SKColor.black
        backButton.lineWidth = 1
        backButton.position = CGPoint(x: 60, y: size.height - 40)
        backButton.name = "backButton"
        
        let backLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        backLabel.text = "Back"
        backLabel.fontSize = 18
        backLabel.fontColor = SKColor.white
        backLabel.verticalAlignmentMode = .center
        backLabel.horizontalAlignmentMode = .center
        backButton.addChild(backLabel)
        
        addChild(backButton)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "backButton" {
                // Transition back to start scene
                let startScene = StartScene(size: self.size)
                startScene.scaleMode = .aspectFill
                
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(startScene, transition: transition)
                return
            } else if node.name == "restartButton" {
                // Restart the game
                let newGameScene = GameScene(size: self.size)
                newGameScene.scaleMode = .aspectFill
                
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(newGameScene, transition: transition)
                return
            }
        }
        
        // Continue with normal touch handling for game
        startPoint = touch.location(in: self)
        currentPoint = startPoint
        
        // Create selection box
        selectionBox = SKShapeNode(rectOf: CGSize.zero)
        selectionBox?.strokeColor = SKColor.blue.withAlphaComponent(0.5)
        selectionBox?.lineWidth = 1
        selectionBox?.fillColor = SKColor.blue.withAlphaComponent(0.1)
        addChild(selectionBox!)
        
        updateSelectionBox()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        currentPoint = touch.location(in: self)
        
        updateSelectionBox()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if the selection forms a valid group (sum = 10)
        checkSelection()
        
        // Clear selection
        selectionBox?.removeFromParent()
        selectionBox = nil
        startPoint = nil
        currentPoint = nil
        selectedCells = []
    }
    
    private func updateSelectionBox() {
        guard let start = startPoint, let current = currentPoint, let box = selectionBox else { return }
        
        // Calculate the rectangle between start and current points
        let minX = min(start.x, current.x)
        let maxX = max(start.x, current.x)
        let minY = min(start.y, current.y)
        let maxY = max(start.y, current.y)
        
        let width = maxX - minX
        let height = maxY - minY
        
        // Update the selection box
        let rect = CGRect(x: minX, y: minY, width: width, height: height)
        let path = CGPath(rect: rect, transform: nil)
        box.path = path
        
        // Find cells within the selection - check for intersection instead of just containing the center
        selectedCells = []
        for row in board {
            for cell in row {
                if let cell = cell {
                    // Create a rect for the cell (accounting for its size)
                    let cellRect = CGRect(
                        x: cell.position.x - cellSize/2,
                        y: cell.position.y - cellSize/2,
                        width: cellSize,
                        height: cellSize
                    )
                    
                    // Check if selection rect intersects with cell rect
                    if rect.intersects(cellRect) {
                        selectedCells.append(cell)
                        cell.highlight()
                    } else {
                        cell.unhighlight()
                    }
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // First frame, just set lastUpdateTime
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
            return
        }
        
        // Only update timer if game is active
        if isGameActive {
            // Calculate delta time
            let deltaTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
            
            // Update time remaining
            timeRemaining -= deltaTime
            if timeRemaining <= 0 {
                timeRemaining = 0
                endGameDueToTimeUp()
            }
            
            // Update timer bar width
            let percentage = CGFloat(timeRemaining / gameTime)
            let newWidth = timerBarWidth * percentage
            timerBar.path = CGPath(roundedRect: CGRect(x: -newWidth/2, y: -10, width: newWidth, height: 20), cornerWidth: 5, cornerHeight: 5, transform: nil)
            
            // Update timer label
            let minutes = Int(timeRemaining) / 60
            let seconds = Int(timeRemaining) % 60
            timerLabel.text = String(format: "%d:%02d", minutes, seconds)
            
            // Change color as time gets low
            if timeRemaining < 10 {
                timerBar.fillColor = SKColor.red.withAlphaComponent(0.7)
            } else if timeRemaining < 30 {
                timerBar.fillColor = SKColor.orange.withAlphaComponent(0.7)
            }
        }
    }
    
    private func endGameDueToTimeUp() {
        // Only run this once
        if !isGameActive { return }
        
        isGameActive = false
        
        // Create a semi-transparent background panel
        let panelBackground = SKShapeNode(rectOf: CGSize(width: size.width - 60, height: 240), cornerRadius: 20)
        panelBackground.fillColor = SKColor.black.withAlphaComponent(0.7)
        panelBackground.strokeColor = SKColor.white.withAlphaComponent(0.3)
        panelBackground.lineWidth = 2
        panelBackground.position = CGPoint(x: size.width/2, y: size.height/2)
        panelBackground.zPosition = 10
        addChild(panelBackground)
        
        // Display time up message
        let timeUpLabel = SKLabelNode(fontNamed: "Futura-Bold")
        timeUpLabel.text = "Time's Up!"
        timeUpLabel.fontSize = 48
        timeUpLabel.fontColor = SKColor.red
        timeUpLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
        timeUpLabel.zPosition = 11
        addChild(timeUpLabel)
        
        // Display final score
        let finalScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        finalScoreLabel.text = "Final Score: \(score)"
        finalScoreLabel.fontSize = 36
        finalScoreLabel.fontColor = SKColor(red: 0.1, green: 0.6, blue: 0.3, alpha: 1.0)
        finalScoreLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        finalScoreLabel.zPosition = 11
        addChild(finalScoreLabel)
        
        // Add restart button
        let restartButton = SKShapeNode(rectOf: CGSize(width: 160, height: 50), cornerRadius: 10)
        restartButton.fillColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7)
        restartButton.strokeColor = SKColor.black
        restartButton.lineWidth = 1
        restartButton.position = CGPoint(x: size.width/2, y: size.height/2 - 60)
        restartButton.name = "restartButton"
        restartButton.zPosition = 11
        
        let restartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartLabel.text = "Play Again"
        restartLabel.fontSize = 22
        restartLabel.fontColor = SKColor.white
        restartLabel.verticalAlignmentMode = .center
        restartLabel.horizontalAlignmentMode = .center
        restartButton.addChild(restartLabel)
        
        addChild(restartButton)
    }
    
    private func checkSelection() {
        // Only process selections if game is active
        if !isGameActive { return }
        
        // Calculate sum of selected cells
        let sum = selectedCells.reduce(0) { $0 + $1.value }
        
        if sum == 10 {
            // Valid selection - remove cells and update score
            for cell in selectedCells {
                score += cell.value
                
                // Animate removal
                let scaleAction = SKAction.scale(to: 0, duration: 0.2)
                let removeAction = SKAction.removeFromParent()
                cell.run(SKAction.sequence([scaleAction, removeAction]))
                
                // Set the cell to nil in the board array instead of replacing it
                if let rowCol = getCellRowCol(cell) {
                    board[rowCol.row][rowCol.col] = nil
                }
            }
            
            // Update score display
            scoreLabel.text = "Score: \(score)"
            
            // Check if game is over (no more possible combinations)
            checkGameState()
        } else {
            // Invalid selection - unhighlight cells
            for cell in selectedCells {
                cell.unhighlight()
            }
        }
    }
    
    private func checkGameState() {
        // Check if there are any possible combinations left
        var possibleCombinations = false
        
        // Get all remaining cells
        var remainingCells: [FruitCell] = []
        for row in board {
            for cell in row {
                if let cell = cell {
                    remainingCells.append(cell)
                }
            }
        }
        
        // Check all possible combinations
        for i in 0..<remainingCells.count {
            for j in (i+1)..<remainingCells.count {
                let sum = remainingCells[i].value + remainingCells[j].value
                if sum == 10 {
                    possibleCombinations = true
                    break
                }
            }
            if possibleCombinations {
                break
            }
        }
        
        // If no combinations are possible and there are cells left, game is over
        if !possibleCombinations && !remainingCells.isEmpty {
            gameOver()
        }
        
        // If no cells left, game is won
        if remainingCells.isEmpty {
            gameWon()
        }
    }
    
    private func gameOver() {
        // Only run this once
        if !isGameActive { return }
        
        isGameActive = false
        
        // Create a semi-transparent background panel
        let panelBackground = SKShapeNode(rectOf: CGSize(width: size.width - 60, height: 240), cornerRadius: 20)
        panelBackground.fillColor = SKColor.black.withAlphaComponent(0.7)
        panelBackground.strokeColor = SKColor.white.withAlphaComponent(0.3)
        panelBackground.lineWidth = 2
        panelBackground.position = CGPoint(x: size.width/2, y: size.height/2)
        panelBackground.zPosition = 10
        addChild(panelBackground)
        
        // Display game over message with fancy font
        let gameOverLabel = SKLabelNode(fontNamed: "Futura-Bold")
        gameOverLabel.text = "Game Over!"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = SKColor.red
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 50)
        gameOverLabel.zPosition = 11
        addChild(gameOverLabel)
        
        // Display final score
        let finalScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        finalScoreLabel.text = "Final Score: \(score)"
        finalScoreLabel.fontSize = 36
        finalScoreLabel.fontColor = SKColor(red: 0.1, green: 0.6, blue: 0.3, alpha: 1.0)
        finalScoreLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        finalScoreLabel.zPosition = 11
        addChild(finalScoreLabel)
        
        // Add restart button
        let restartButton = SKShapeNode(rectOf: CGSize(width: 160, height: 50), cornerRadius: 10)
        restartButton.fillColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7)
        restartButton.strokeColor = SKColor.black
        restartButton.lineWidth = 1
        restartButton.position = CGPoint(x: size.width/2, y: size.height/2 - 60)
        restartButton.name = "restartButton"
        restartButton.zPosition = 11
        
        let restartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartLabel.text = "Play Again"
        restartLabel.fontSize = 22
        restartLabel.fontColor = SKColor.white
        restartLabel.verticalAlignmentMode = .center
        restartLabel.horizontalAlignmentMode = .center
        restartButton.addChild(restartLabel)
        
        addChild(restartButton)
    }
    
    private func gameWon() {
        // Only run this once
        if !isGameActive { return }
        
        isGameActive = false
        
        // Calculate bonus points based on remaining time
        let timeBonus = Int(timeRemaining * 10)
        let totalScore = score + timeBonus
        
        // Create a semi-transparent background panel
        let panelBackground = SKShapeNode(rectOf: CGSize(width: size.width - 60, height: 320), cornerRadius: 20)
        panelBackground.fillColor = SKColor.black.withAlphaComponent(0.7)
        panelBackground.strokeColor = SKColor.white.withAlphaComponent(0.3)
        panelBackground.lineWidth = 2
        panelBackground.position = CGPoint(x: size.width/2, y: size.height/2)
        panelBackground.zPosition = 10
        addChild(panelBackground)
        
        // Display win message with fancy font
        let winLabel = SKLabelNode(fontNamed: "Futura-Bold")
        winLabel.text = "You Win!"
        winLabel.fontSize = 48
        winLabel.fontColor = SKColor.green
        winLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 80)
        winLabel.zPosition = 11
        addChild(winLabel)
        
        // Display score breakdown
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Base Score: \(score)"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = SKColor(red: 0.1, green: 0.6, blue: 0.3, alpha: 1.0)
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 30)
        scoreLabel.zPosition = 11
        addChild(scoreLabel)
        
        let bonusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        bonusLabel.text = "Time Bonus: \(timeBonus)"
        bonusLabel.fontSize = 28
        bonusLabel.fontColor = SKColor(red: 0.1, green: 0.6, blue: 0.3, alpha: 1.0)
        bonusLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        bonusLabel.zPosition = 11
        addChild(bonusLabel)
        
        let totalLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        totalLabel.text = "Total Score: \(totalScore)"
        totalLabel.fontSize = 32
        totalLabel.fontColor = SKColor(red: 0.1, green: 0.6, blue: 0.3, alpha: 1.0)
        totalLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 30)
        totalLabel.zPosition = 11
        addChild(totalLabel)
        
        // Add restart button
        let restartButton = SKShapeNode(rectOf: CGSize(width: 160, height: 50), cornerRadius: 10)
        restartButton.fillColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7)
        restartButton.strokeColor = SKColor.black
        restartButton.lineWidth = 1
        restartButton.position = CGPoint(x: size.width/2, y: size.height/2 - 80)
        restartButton.name = "restartButton"
        restartButton.zPosition = 11
        
        let restartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartLabel.text = "Play Again"
        restartLabel.fontSize = 22
        restartLabel.fontColor = SKColor.white
        restartLabel.verticalAlignmentMode = .center
        restartLabel.horizontalAlignmentMode = .center
        restartButton.addChild(restartLabel)
        
        addChild(restartButton)
    }
    
    private func getCellRowCol(_ cell: FruitCell) -> (row: Int, col: Int)? {
        for row in 0..<board.count {
            for col in 0..<board[row].count {
                if board[row][col] === cell {
                    return (row, col)
                }
            }
        }
        return nil
    }
} 