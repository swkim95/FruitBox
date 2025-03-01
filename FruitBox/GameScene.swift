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
    
    // Pause menu properties
    private var pauseMenu: PauseMenu?
    private var gamePaused = false
    private var menuButton: SKShapeNode!
    
    // Bonus properties
    private var bonusCells: [FruitCell] = []
    private var bonusCatSize: CGSize = CGSize(width: 50, height: 50)
    
    override func didMove(to view: SKView) {
        // Set a nicer background color that complements red
        backgroundColor = OptionsScene.backgroundColor
        
        setupGame()
        setupTimerBar()
        setupMenuButton()
        setupHintButton()
    }
    
    private func setupGame() {
        // Calculate safe area for gameplay
        let safeAreaTop: CGFloat = 150 // Increased to make room for timer
        let safeAreaBottom: CGFloat = 80 // Space at bottom
        let availableHeight = size.height - safeAreaTop - safeAreaBottom
        let availableWidth = size.width - 40 // 20 points padding on each side
        
        // Get board dimensions from options
        boardWidth = OptionsScene.boardSize.dimensions.width
        boardHeight = OptionsScene.boardSize.dimensions.height
        
        // Calculate cell size based on available space and board dimensions
        // Use the same calculation for all board sizes to maintain consistent total board size
        let maxBoardWidth = 9 // Maximum board width (large size)
        let maxBoardHeight = 18 // Maximum board height (large size)
        
        // Calculate cell size based on the maximum board dimensions
        let cellWidthByWidth = availableWidth / CGFloat(maxBoardWidth)
        let cellHeightByHeight = availableHeight / CGFloat(maxBoardHeight)
        cellSize = min(cellWidthByWidth, cellHeightByHeight)
        
        // Calculate the total board size
        let totalBoardWidth = cellSize * CGFloat(boardWidth) + cellSpacing * CGFloat(boardWidth - 1)
        let totalBoardHeight = cellSize * CGFloat(boardHeight) + cellSpacing * CGFloat(boardHeight - 1)
        
        // Calculate the origin to center the board
        boardOriginX = (size.width - totalBoardWidth) / 2
        boardOriginY = safeAreaBottom + (availableHeight - totalBoardHeight) / 2
        
        // Create the game board
        createBoard()
        
        // Mark random cells as bonus cells
        setupBonusCells()
        
        // Create score label
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: size.width/2, y: size.height - 120)
        addChild(scoreLabel)
        
        // Add hint button
        setupHintButton()
    }
    
    private func setupTimerBar() {
        // Set the game time from options
        gameTime = OptionsScene.timeLimit
        timeRemaining = gameTime
        
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
        
        // Format the time as minutes:seconds
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        timerLabel.text = String(format: "%d:%02d", minutes, seconds)
        
        timerLabel.fontSize = 20
        timerLabel.fontColor = SKColor.white
        timerLabel.position = CGPoint(x: size.width/2, y: size.height - 80)
        timerLabel.verticalAlignmentMode = .center
        addChild(timerLabel)
    }
    
    private func createBoard() {
        // Initialize the board array with the correct dimensions
        board = Array(repeating: Array(repeating: nil, count: boardWidth), count: boardHeight)
        
        // Create cells for the board
        for row in 0..<boardHeight {
            for col in 0..<boardWidth {
                // Create a cell with a random value (1-9)
                let value = Int.random(in: 1...9)
                let cell = FruitCell(value: value)
                
                // Position the cell on the board
                let x = boardOriginX + CGFloat(col) * (cellSize + cellSpacing) + cellSize/2
                let y = boardOriginY + CGFloat(row) * (cellSize + cellSpacing) + cellSize/2
                cell.position = CGPoint(x: x, y: y)
                
                // Update the cell size
                cell.updateSize(size: cellSize)
                
                // Apply the cell color from options
                cell.setColors(cellColor: OptionsScene.cellColor, fontColor: OptionsScene.fontColor)
                
                // Apply the cell shape from options
                cell.updateShape()
                
                addChild(cell)
                
                // Store the cell in the board array
                board[row][col] = cell
            }
        }
    }
    
    // Generate a balanced pool of numbers that favors lower numbers to make the game easier
    private func generateBalancedNumberPool() -> [Int] {
        let totalCells = boardWidth * boardHeight
        var numberPool: [Int] = []
        
        // Create pairs that sum to 10, but favor lower numbers
        let pairsNeeded = totalCells / 2
        
        // Define weights for each number (higher weight = more frequent)
        let weights: [Int: Int] = [
            1: 20,  // Most common
            2: 18,
            3: 16,
            4: 14,
            5: 12,  // 5 is special since it pairs with itself
            6: 10,
            7: 8,
            8: 6,
            9: 4    // Least common
        ]
        
        // Calculate total weight
        let totalWeight = weights.values.reduce(0, +)
        
        for _ in 0..<pairsNeeded {
            // Select a number based on weights
            var randomWeight = Int.random(in: 1...totalWeight)
            var selectedNumber = 1
            
            for (number, weight) in weights {
                randomWeight -= weight
                if randomWeight <= 0 {
                    selectedNumber = number
                    break
                }
            }
            
            // Add the selected number and its complement
            let complement = 10 - selectedNumber
            
            numberPool.append(selectedNumber)
            numberPool.append(complement)
        }
        
        // If we have an odd number of cells, add one more random number
        // Favor lower numbers for the extra cell too
        if totalCells % 2 != 0 {
            var randomWeight = Int.random(in: 1...totalWeight)
            var selectedNumber = 1
            
            for (number, weight) in weights {
                randomWeight -= weight
                if randomWeight <= 0 {
                    selectedNumber = number
                    break
                }
            }
            
            numberPool.append(selectedNumber)
        }
        
        // Shuffle the pool to randomize positions
        numberPool.shuffle()
        
        return numberPool
    }
    
    private func setupMenuButton() {
        // Menu button
        menuButton = SKShapeNode(rectOf: CGSize(width: 80, height: 40), cornerRadius: 10)
        menuButton.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7)
        menuButton.strokeColor = SKColor.black
        menuButton.lineWidth = 1
        menuButton.position = CGPoint(x: 60, y: size.height - 40)
        menuButton.name = "menuButton"
        
        let menuLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        menuLabel.text = "Menu"
        menuLabel.fontSize = 18
        menuLabel.fontColor = SKColor.white
        menuLabel.verticalAlignmentMode = .center
        menuLabel.horizontalAlignmentMode = .center
        menuButton.addChild(menuLabel)
        
        addChild(menuButton)
    }
    
    // Add a hint button to the game
    private func setupHintButton() {
        let hintButton = SKShapeNode(rectOf: CGSize(width: 80, height: 40), cornerRadius: 10)
        hintButton.fillColor = SKColor(red: 0.3, green: 0.6, blue: 0.3, alpha: 0.7)
        hintButton.strokeColor = SKColor.black
        hintButton.lineWidth = 1
        hintButton.position = CGPoint(x: size.width - 60, y: size.height - 40)
        hintButton.name = "hintButton"
        
        let hintLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        hintLabel.text = "Hint"
        hintLabel.fontSize = 18
        hintLabel.fontColor = SKColor.white
        hintLabel.verticalAlignmentMode = .center
        hintLabel.horizontalAlignmentMode = .center
        hintButton.addChild(hintLabel)
        
        addChild(hintButton)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // If the game is paused, handle pause menu touches
        if gamePaused {
            if let pauseMenu = pauseMenu, pauseMenu.handleTouch(at: location) {
                return
            }
            return
        }
        
        // Check for menu button touch
        let nodes = self.nodes(at: location)
        for node in nodes {
            if node.name == "menuButton" {
                showPauseMenu()
                return
            } else if node.name == "restartButton" {
                // Restart the game
                let newGameScene = GameScene(size: self.size)
                newGameScene.scaleMode = .aspectFill
                
                let transition = SKTransition.fade(withDuration: 0.5)
                self.view?.presentScene(newGameScene, transition: transition)
                return
            } else if node.name == "hintButton" {
                // Show a hint
                showHint()
                return
            }
        }
        
        // Only handle game touches if the game is active and not paused
        if !isGameActive || gamePaused { return }
        
        // Handle selection start
        startPoint = location
        currentPoint = location
        
        // Create selection box if it doesn't exist
        if selectionBox == nil {
            selectionBox = SKShapeNode(rectOf: CGSize.zero)
            selectionBox?.strokeColor = SKColor.blue.withAlphaComponent(0.5)
            selectionBox?.lineWidth = 1
            selectionBox?.fillColor = SKColor.blue.withAlphaComponent(0.1)
            addChild(selectionBox!)
        }
        
        // Clear previous selection
        for cell in selectedCells {
            cell.unhighlight()
        }
        selectedCells.removeAll()
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
        // Only update if the game is active and not paused
        if isGameActive && !gamePaused {
            // Calculate delta time
            if lastUpdateTime == 0 {
                lastUpdateTime = currentTime
            }
            let dt = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
            
            // Update time remaining
            timeRemaining -= dt
            
            // Update the timer display
            updateTimerDisplay()
            
            // Check if time is up
            if timeRemaining <= 0 {
                gameOver()
            }
        }
    }
    
    private func updateTimerDisplay() {
        // Update the timer bar width
        let progress = timeRemaining / gameTime
        let newWidth = timerBarWidth * CGFloat(progress)
        timerBar.xScale = CGFloat(progress)
        
        // Update the timer label
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        timerLabel.text = String(format: "%d:%02d", minutes, seconds)
        
        // Change color based on time remaining
        if timeRemaining < 30 {
            timerBar.fillColor = SKColor.red.withAlphaComponent(0.7)
        } else if timeRemaining < 60 {
            timerBar.fillColor = SKColor.yellow.withAlphaComponent(0.7)
        } else {
            timerBar.fillColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7) // Green
        }
    }
    
    private func endGameDueToTimeUp() {
        // Only run this once
        if !isGameActive { return }
        
        isGameActive = false
        
        // Create a semi-transparent background panel
        let panelBackground = SKShapeNode(rectOf: CGSize(width: size.width - 60, height: 300), cornerRadius: 20)
        panelBackground.fillColor = SKColor.black.withAlphaComponent(0.9)
        panelBackground.strokeColor = SKColor.white.withAlphaComponent(0.3)
        panelBackground.lineWidth = 2
        panelBackground.position = CGPoint(x: size.width/2, y: size.height/2)
        panelBackground.zPosition = 10
        addChild(panelBackground)
        
        // Display time up message
        let timeUpLabel = SKLabelNode(fontNamed: "Futura-Bold")
        timeUpLabel.text = "Time's Up!"
        timeUpLabel.fontSize = 48
        timeUpLabel.fontColor = SKColor.white
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
        
        if sum == 10 {  // Check for exactly 10, not a multiple of 10
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
            
            // Check if any of the selected cells are bonus cells
            for cell in selectedCells {
                if cell.isTimeBonus {
                    // Create a bonus cat at the cell's position
                    createBonusCat(at: cell.position)
                    
                    // Remove from the bonus cells array
                    if let index = bonusCells.firstIndex(of: cell) {
                        bonusCells.remove(at: index)
                    }
                }
            }
        } else {
            // Invalid selection - unhighlight cells
            for cell in selectedCells {
                cell.unhighlight()
            }
        }
    }
    
    private func checkGameState() {
        // Get all remaining cells
        var remainingCells: [FruitCell] = []
        for row in board {
            for cell in row {
                if let cell = cell {
                    remainingCells.append(cell)
                }
            }
        }
        
        // If no cells left, game is won
        if remainingCells.isEmpty {
            gameWon()
            return
        }
        
        // First, check if there are any possible combinations left
        var possibleCombinations = false
        
        // Create a frequency map of values
        var valueFrequency: [Int: Int] = [:]
        for cell in remainingCells {
            valueFrequency[cell.value, default: 0] += 1
        }
        
        // Check for pairs that sum to 10
        for value in 1...9 {
            let complement = 10 - value
            
            if value == complement { // For value 5
                if valueFrequency[value, default: 0] >= 2 {
                    possibleCombinations = true
                    break
                }
            } else {
                if valueFrequency[value, default: 0] > 0 && valueFrequency[complement, default: 0] > 0 {
                    possibleCombinations = true
                    break
                }
            }
        }
        
        // If no combinations are possible, game is over
        if !possibleCombinations {
            gameOver()
            return
        }
        
        // If there are possible combinations, check if they can be selected with rectangles
        let fullySolvable = isFullySolvable()
        
        if !fullySolvable {
            // If the board is not fully solvable, end the game
            gameOver()
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
    
    // Check if the board is solvable considering rectangular selection constraint
    private func isFullySolvable() -> Bool {
        // Get all remaining cells with their positions
        var cellsWithPositions: [(cell: FruitCell, row: Int, col: Int)] = []
        
        for row in 0..<board.count {
            for col in 0..<board[row].count {
                if let cell = board[row][col] {
                    cellsWithPositions.append((cell, row, col))
                }
            }
        }
        
        // If no cells left, the board is solved
        if cellsWithPositions.isEmpty {
            return true
        }
        
        // Check for all possible rectangular selections
        for i in 0..<cellsWithPositions.count {
            for j in (i+1)..<cellsWithPositions.count {
                let cell1 = cellsWithPositions[i]
                let cell2 = cellsWithPositions[j]
                
                // Check if the sum is 10
                if cell1.cell.value + cell2.cell.value == 10 {
                    // Check if they can be selected with a rectangle
                    if canSelectWithRectangle(cell1: (cell1.row, cell1.col), cell2: (cell2.row, cell2.col)) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // Check if two cells can be selected with a rectangle
    private func canSelectWithRectangle(cell1: (row: Int, col: Int), cell2: (row: Int, col: Int)) -> Bool {
        // Calculate the rectangle that would be formed
        let minRow = min(cell1.row, cell2.row)
        let maxRow = max(cell1.row, cell2.row)
        let minCol = min(cell1.col, cell2.col)
        let maxCol = max(cell1.col, cell2.col)
        
        // Count how many cells with values 10-sum are in the rectangle
        var targetCellCount = 0
        var otherCellCount = 0
        
        for row in minRow...maxRow {
            for col in minCol...maxCol {
                if let cell = board[row][col] {
                    if (row == cell1.row && col == cell1.col) || (row == cell2.row && col == cell2.col) {
                        targetCellCount += 1
                    } else {
                        otherCellCount += 1
                    }
                }
            }
        }
        
        // If the rectangle contains exactly our two target cells and no others,
        // then they can be selected with a rectangle
        return targetCellCount == 2 && otherCellCount == 0
    }
    
    // Show a hint by highlighting a valid pair
    private func showHint() {
        // Find a valid pair that can be selected with a rectangle
        for i in 0..<board.count {
            for j in 0..<board[i].count {
                if let cell1 = board[i][j] {
                    // Look for a matching cell
                    for k in 0..<board.count {
                        for l in 0..<board[k].count {
                            if let cell2 = board[k][l], cell1 !== cell2 {
                                if cell1.value + cell2.value == 10 && canSelectWithRectangle(cell1: (i, j), cell2: (k, l)) {
                                    // Highlight these cells temporarily
                                    cell1.highlight()
                                    cell2.highlight()
                                    
                                    // Unhighlight after a delay
                                    let unhighlightAction = SKAction.run {
                                        cell1.unhighlight()
                                        cell2.unhighlight()
                                    }
                                    let delayAction = SKAction.wait(forDuration: 1.0)
                                    let sequence = SKAction.sequence([delayAction, unhighlightAction])
                                    self.run(sequence)
                                    
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Add this method to show the pause menu
    private func showPauseMenu() {
        if gamePaused { return }
        
        gamePaused = true
        
        // Create and configure the pause menu
        pauseMenu = PauseMenu()
        pauseMenu?.position = CGPoint(x: size.width/2, y: size.height/2)
        pauseMenu?.zPosition = 1000
        
        // Set up callbacks
        pauseMenu?.onResume = { [weak self] in
            self?.resumeGame()
        }
        
        pauseMenu?.onOptions = { [weak self] in
            guard let self = self else { return }
            
            // Transition to options scene
            let optionsScene = OptionsScene(size: self.size)
            optionsScene.scaleMode = .aspectFill
            
            let transition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(optionsScene, transition: transition)
        }
        
        pauseMenu?.onMenu = { [weak self] in
            guard let self = self else { return }
            
            // Transition to start scene
            let startScene = StartScene(size: self.size)
            startScene.scaleMode = .aspectFill
            
            let transition = SKTransition.fade(withDuration: 0.5)
            self.view?.presentScene(startScene, transition: transition)
        }
        
        addChild(pauseMenu!)
    }
    
    // Add this method to resume the game
    private func resumeGame() {
        if !gamePaused { return }
        
        gamePaused = false
        
        // Remove the pause menu
        pauseMenu?.removeFromParent()
        pauseMenu = nil
    }
    
    // Add this method to mark random cells as bonus cells
    private func setupBonusCells() {
        // Get all cells in a flat array
        var allCells: [FruitCell] = []
        for row in board {
            for cell in row {
                if let cell = cell {
                    allCells.append(cell)
                }
            }
        }
        
        // Shuffle the array and pick the first 10 cells (or fewer if there aren't enough cells)
        allCells.shuffle()
        let bonusCount = min(10, allCells.count)
        
        for i in 0..<bonusCount {
            allCells[i].isTimeBonus = true
            bonusCells.append(allCells[i])
        }
        
        // Set the bonus cat size based on cell size
        bonusCatSize = CGSize(width: cellSize * 0.9, height: cellSize * 0.9)
    }
    
    // Add this method to create a bonus cat
    private func createBonusCat(at position: CGPoint) {
        let bonusCat = BonusCat(at: position, size: bonusCatSize)
        
        // Set the callback for when the bonus is collected
        bonusCat.onCollect = { [weak self] in
            self?.addTimeBonus()
        }
        
        addChild(bonusCat)
    }
    
    // Add this method to add time to the timer
    private func addTimeBonus() {
        // Add 10 seconds to the timer
        timeRemaining += BonusCat.bonusTime
        
        // Make sure we don't exceed the original game time
        timeRemaining = min(timeRemaining, gameTime)
        
        // Update the timer display
        updateTimerDisplay()
        
        // Play a sound or visual effect to indicate the bonus
        let flash = SKAction.sequence([
            SKAction.colorize(with: .green, colorBlendFactor: 0.3, duration: 0.2),
            SKAction.colorize(with: .clear, colorBlendFactor: 0.0, duration: 0.2)
        ])
        timerBar.run(flash)
    }
} 