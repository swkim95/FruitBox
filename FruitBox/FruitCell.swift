import SpriteKit

class FruitCell: SKSpriteNode {
    
    let value: Int
    private let label: SKLabelNode
    
    // Add this static property to the FruitCell class
    private static var cachedCatImage: UIImage?
    
    // Add this property to the FruitCell class
    var isTimeBonus: Bool = false
    
    init(value: Int) {
        self.value = value
        
        // Create the label for the value with a fancy font
        self.label = SKLabelNode(fontNamed: "Futura-Bold")
        self.label.text = "\(value)"
        self.label.fontSize = 24
        self.label.fontColor = SKColor.white
        self.label.verticalAlignmentMode = .center
        self.label.horizontalAlignmentMode = .center
        
        // Initialize with a clear color first
        super.init(texture: nil, color: .clear, size: CGSize(width: 50, height: 50))
        
        // Create the shape based on the selected option
        createShapeNode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Method to update the size of the cell and its contents
    func updateSize(size: CGFloat) {
        self.size = CGSize(width: size, height: size)
        
        // First, ensure the label is not already added to a parent
        label.removeFromParent()
        
        // Remove existing shape nodes and sprites
        self.children.forEach { node in
            if node is SKShapeNode || (node is SKSpriteNode && node != self) {
                node.removeFromParent()
            }
        }
        
        // Create the appropriate shape with the new size
        switch OptionsScene.cellShape {
        case .roundedSquare:
            let shape = SKShapeNode(rectOf: CGSize(width: size * 0.9, height: size * 0.9), cornerRadius: size * 0.15)
            shape.fillColor = OptionsScene.cellColor
            shape.strokeColor = OptionsScene.cellColor.withAlphaComponent(1.0)
            shape.lineWidth = 2
            shape.position = CGPoint.zero
            shape.name = "squareShape"
            addChild(shape)
            
            // Add the label to the shape
            label.position = CGPoint.zero
            label.fontSize = size * 0.5
            shape.addChild(label)
            
        case .circle:
            let shape = SKShapeNode(circleOfRadius: size * 0.45)
            shape.fillColor = OptionsScene.cellColor
            shape.strokeColor = OptionsScene.cellColor.withAlphaComponent(1.0)
            shape.lineWidth = 2
            shape.position = CGPoint.zero
            shape.name = "circleShape"
            addChild(shape)
            
            // Add the label to the shape
            label.position = CGPoint.zero
            label.fontSize = size * 0.5
            shape.addChild(label)
            
        case .cat:
            // Create a cat sprite using the image from assets
            if let catImage = UIImage(named: "cat_face") {
                let texture = SKTexture(image: catImage)
                let catSprite = SKSpriteNode(texture: texture)
                catSprite.size = CGSize(width: size * 0.9, height: size * 0.9)
                catSprite.color = OptionsScene.cellColor
                catSprite.colorBlendFactor = 0.7 // Blend the image with the cell color
                catSprite.position = CGPoint.zero
                catSprite.name = "catShape"
                addChild(catSprite)
            } else {
                print("Failed to load cat_face image")
                // Fallback to a circle if image loading fails
                let shape = SKShapeNode(circleOfRadius: size * 0.45)
                shape.fillColor = OptionsScene.cellColor
                shape.strokeColor = OptionsScene.cellColor.withAlphaComponent(1.0)
                shape.lineWidth = 2
                shape.position = CGPoint.zero
                shape.name = "catShape"
                addChild(shape)
            }
            
            // Add the label directly on top of the cat
            label.position = CGPoint.zero
            label.fontSize = size * 0.5
            label.zPosition = 1 // Ensure the label is on top
            addChild(label)
        }
    }
    
    func setColors(cellColor: SKColor, fontColor: SKColor) {
        if let shapeNode = self.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
            shapeNode.fillColor = cellColor
            shapeNode.strokeColor = cellColor.withAlphaComponent(1.0)
        } else if let spriteNode = self.children.first(where: { $0 is SKSpriteNode && $0 != self }) as? SKSpriteNode {
            // For cat sprite
            spriteNode.color = cellColor
            spriteNode.colorBlendFactor = 0.7
        }
        
        // Update the label color
        label.fontColor = fontColor
    }
    
    func highlight() {
        // Visual indication of selection - change both fill and border
        if let shapeNode = self.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
            shapeNode.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
            shapeNode.strokeColor = SKColor.red
            shapeNode.lineWidth = 3
        } else if let spriteNode = self.children.first(where: { $0 is SKSpriteNode && $0 != self }) as? SKSpriteNode {
            // For cat sprite
            spriteNode.color = SKColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
            spriteNode.colorBlendFactor = 0.7
        }
    }
    
    func unhighlight() {
        // Remove selection indication
        if let shapeNode = self.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
            shapeNode.fillColor = OptionsScene.cellColor
            shapeNode.strokeColor = OptionsScene.cellColor.withAlphaComponent(1.0)
            shapeNode.lineWidth = 2
        } else if let spriteNode = self.children.first(where: { $0 is SKSpriteNode && $0 != self }) as? SKSpriteNode {
            // For cat sprite
            spriteNode.color = OptionsScene.cellColor
            spriteNode.colorBlendFactor = 0.7
        }
    }
    
    func updateShape() {
        // First, ensure the label is not already added to a parent
        label.removeFromParent()
        
        // Remove existing shape nodes and sprites
        self.children.forEach { node in
            if node is SKShapeNode || (node is SKSpriteNode && node != self) {
                node.removeFromParent()
            }
        }
        
        // Get the current size
        let currentSize = self.size.width
        
        // Create the appropriate shape based on the selected option
        switch OptionsScene.cellShape {
        case .roundedSquare:
            let shape = SKShapeNode(rectOf: CGSize(width: currentSize * 0.9, height: currentSize * 0.9), cornerRadius: currentSize * 0.15)
            shape.fillColor = OptionsScene.cellColor
            shape.strokeColor = OptionsScene.cellColor.withAlphaComponent(1.0)
            shape.lineWidth = 2
            shape.position = CGPoint.zero
            shape.name = "squareShape"
            addChild(shape)
            
            // Add the label to the shape
            label.position = CGPoint.zero
            shape.addChild(label)
            
        case .circle:
            let shape = SKShapeNode(circleOfRadius: currentSize * 0.45)
            shape.fillColor = OptionsScene.cellColor
            shape.strokeColor = OptionsScene.cellColor.withAlphaComponent(1.0)
            shape.lineWidth = 2
            shape.position = CGPoint.zero
            shape.name = "circleShape"
            addChild(shape)
            
            // Add the label to the shape
            label.position = CGPoint.zero
            shape.addChild(label)
            
        case .cat:
            // Create a cat sprite using the image from assets
            if let catImage = UIImage(named: "cat_face") {
                let texture = SKTexture(image: catImage)
                let catSprite = SKSpriteNode(texture: texture)
                catSprite.size = CGSize(width: currentSize * 0.9, height: currentSize * 0.9)
                catSprite.color = OptionsScene.cellColor
                catSprite.colorBlendFactor = 0.7 // Blend the image with the cell color
                catSprite.position = CGPoint.zero
                catSprite.name = "catShape"
                addChild(catSprite)
            } else {
                print("Failed to load cat_face image")
                // Fallback to a circle if image loading fails
                let shape = SKShapeNode(circleOfRadius: currentSize * 0.45)
                shape.fillColor = OptionsScene.cellColor
                shape.strokeColor = OptionsScene.cellColor.withAlphaComponent(1.0)
                shape.lineWidth = 2
                shape.position = CGPoint.zero
                shape.name = "catShape"
                addChild(shape)
            }
            
            // Add the label directly on top of the cat
            label.position = CGPoint.zero
            label.zPosition = 1 // Ensure the label is on top
            addChild(label)
        }
    }
    
    private func createShapeNode() {
        // First, ensure the label is not already added to a parent
        label.removeFromParent()
        
        // Remove existing shape nodes and sprites
        self.children.forEach { node in
            if node is SKShapeNode || (node is SKSpriteNode && node != self) {
                node.removeFromParent()
            }
        }
        
        // Create the shape based on the selected option
        switch OptionsScene.cellShape {
        case .roundedSquare:
            let shape = SKShapeNode(rectOf: CGSize(width: 50, height: 50), cornerRadius: 10)
            shape.fillColor = SKColor.red.withAlphaComponent(0.7)
            shape.strokeColor = SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
            shape.lineWidth = 2
            shape.position = CGPoint.zero
            shape.name = "squareShape"
            addChild(shape)
            
            // Add the label to the shape
            label.position = CGPoint.zero
            shape.addChild(label)
            
        case .circle:
            let shape = SKShapeNode(circleOfRadius: 25)
            shape.fillColor = SKColor.red.withAlphaComponent(0.7)
            shape.strokeColor = SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
            shape.lineWidth = 2
            shape.position = CGPoint.zero
            shape.name = "circleShape"
            addChild(shape)
            
            // Add the label to the shape
            label.position = CGPoint.zero
            shape.addChild(label)
            
        case .cat:
            // Create a cat sprite using the image from assets
            if let catImage = UIImage(named: "cat_face") {
                let texture = SKTexture(image: catImage)
                let catSprite = SKSpriteNode(texture: texture)
                catSprite.size = CGSize(width: 50, height: 50)
                catSprite.color = OptionsScene.cellColor
                catSprite.colorBlendFactor = 0.7 // Blend the image with the cell color
                catSprite.position = CGPoint.zero
                catSprite.name = "catShape"
                addChild(catSprite)
            } else {
                print("Failed to load cat_face image")
                // Fallback to a circle if image loading fails
                let shape = SKShapeNode(circleOfRadius: 25)
                shape.fillColor = SKColor.red.withAlphaComponent(0.7)
                shape.strokeColor = SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
                shape.lineWidth = 2
                shape.position = CGPoint.zero
                shape.name = "catShape"
                addChild(shape)
            }
            
            // Add the label directly on top of the cat
            label.position = CGPoint.zero
            label.zPosition = 1 // Ensure the label is on top
            addChild(label)
        }
    }
    
    private func createCatShapedCellWithSFSymbol(size: CGSize, color: SKColor? = nil) -> SKSpriteNode {
        let cellColor = color ?? OptionsScene.cellColor
        
        // Create a simple colored circle as the background
        let backgroundNode = SKShapeNode(circleOfRadius: size.width * 0.45)
        backgroundNode.fillColor = cellColor
        backgroundNode.strokeColor = cellColor.withAlphaComponent(1.0)
        backgroundNode.lineWidth = 2
        
        // Render the background to a texture
        let renderer = UIGraphicsImageRenderer(size: size)
        let finalImage = renderer.image { _ in
            // Draw a filled circle
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(cellColor.cgColor)
            context.fillEllipse(in: CGRect(x: size.width * 0.05, y: size.height * 0.05, 
                                          width: size.width * 0.9, height: size.height * 0.9))
        }
        
        // Create a sprite node with the background
        let catNode = SKSpriteNode(texture: SKTexture(image: finalImage))
        catNode.size = size
        catNode.name = "catShape"
        
        return catNode
    }
} 