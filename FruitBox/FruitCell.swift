import SpriteKit

class FruitCell: SKSpriteNode {
    
    let value: Int
    private let label: SKLabelNode
    private var roundedRect: SKShapeNode!
    
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
        
        // Create a fancy rounded square
        roundedRect = SKShapeNode(rectOf: CGSize(width: 50, height: 50), cornerRadius: 10)
        roundedRect.fillColor = SKColor.red.withAlphaComponent(0.7)
        roundedRect.strokeColor = SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        roundedRect.lineWidth = 2
        addChild(roundedRect)
        
        // Add the label
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Method to update the size of the cell and its contents
    func updateSize(size: CGFloat) {
        self.size = CGSize(width: size, height: size)
        
        // Update the rounded rect
        roundedRect.removeFromParent()
        roundedRect = SKShapeNode(rectOf: CGSize(width: size * 0.9, height: size * 0.9), cornerRadius: size * 0.15)
        roundedRect.fillColor = SKColor.red
        roundedRect.strokeColor = SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        roundedRect.lineWidth = 2
        addChild(roundedRect)
        
        // Update the label size
        label.fontSize = size * 0.5 // Make the number a bit larger
    }
    
    func highlight() {
        // Visual indication of selection - change both fill and border
        roundedRect.fillColor = SKColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
        roundedRect.strokeColor = SKColor.red
        roundedRect.lineWidth = 3
    }
    
    func unhighlight() {
        // Remove selection indication
        roundedRect.fillColor = SKColor.red
        roundedRect.strokeColor = SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        roundedRect.lineWidth = 2
    }
} 