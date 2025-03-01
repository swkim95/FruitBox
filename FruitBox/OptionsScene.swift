import SpriteKit

class OptionsScene: SKScene {
    
    // Default settings
    static var backgroundColor = SKColor(red: 0.7, green: 0.95, blue: 0.7, alpha: 0.8)
    static var cellColor = SKColor.red.withAlphaComponent(0.7)
    static var fontColor = SKColor.white
    static var timeLimit: TimeInterval = 120.0
    static var boardSize = BoardSize.large // Default to 9x18
    static var cellShape: CellShape = .roundedSquare // Default shape
    
    // Board size options
    enum BoardSize: String, CaseIterable {
        case small = "Small (5x14)"
        case medium = "Medium (7x16)"
        case large = "Large (9x18)"
        
        var dimensions: (width: Int, height: Int) {
            switch self {
            case .small: return (5, 14)
            case .medium: return (7, 16)
            case .large: return (9, 18)
            }
        }
    }
    
    // Cell shape options
    enum CellShape: String, CaseIterable {
        case roundedSquare = "Square"
        case circle = "Circle"
        case cat = "Ruga"
        
        var description: String {
            return self.rawValue
        }
    }
    
    // UI Elements
    private var backButton: SKShapeNode!
    private var saveButton: SKShapeNode!
    private var colorWheelBackground: SKSpriteNode!
    private var colorWheel: SKSpriteNode!
    private var colorPreview: SKShapeNode!
    private var colorTypeSegment: SKShapeNode!
    private var bgColorButton: SKLabelNode!
    private var cellColorButton: SKLabelNode!
    private var fontColorButton: SKLabelNode!
    private var timeSlider: SKShapeNode!
    private var timeSliderKnob: SKShapeNode!
    private var timeLabel: SKLabelNode!
    private var boardSizeButtons: [SKShapeNode] = []
    private var brightnessSlider: SKShapeNode!
    private var brightnessSliderKnob: SKShapeNode!
    private var isDraggingBrightnessSlider = false
    private var isDraggingBonusCatCountSlider = false
    private var isDraggingBonusCatTimeSlider = false
    private var currentBrightness: CGFloat = 1.0  // Default to full brightness
    
    // State tracking
    private var selectedColorType: ColorType = .background
    private var isDraggingSlider = false
    private var isDraggingColorWheel = false
    private var colorWheelCenter: CGPoint = .zero
    
    enum ColorType {
        case background
        case cell
        case font
    }
    
    // Add these properties to the OptionsScene class
    private var currentPage = 0
    private let totalPages = 3
    private var pageIndicators: [SKShapeNode] = []
    private var pageContainers: [SKNode] = []
    private var lastTouchLocation: CGPoint?
    private var isSwipingPage = false
    
    // Add this property to the OptionsScene class
    private var shapeButtons: [SKShapeNode] = []
    
    // Add this static property to the OptionsScene class
    private static var cachedCatImage: UIImage?
    
    // Add these static properties to the OptionsScene class
    static var bonusCatCount: Int = 10 // Default: 10 bonus cats
    static var bonusCatTimeBonus: TimeInterval = 10.0 // Default: 10 seconds
    
    // Add these properties for the UI controls
    private var bonusCatCountSlider: SKShapeNode!
    private var bonusCatCountSliderKnob: SKShapeNode!
    private var bonusCatCountLabel: SKLabelNode!
    private var bonusCatTimeSlider: SKShapeNode!
    private var bonusCatTimeSliderKnob: SKShapeNode!
    private var bonusCatTimeLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        // Set background color
        backgroundColor = OptionsScene.backgroundColor
        
        setupUI()
    }
    
    private func setupUI() {
        // Setup common UI elements (back and save buttons)
        setupCommonUI()
        
        // Setup page navigation
        setupPageNavigation()
        
        // Setup page 0 content (Colors and Time)
        setupColorAndTimePage()
        
        // Setup page 1 content (Cell Shape)
        setupCellShapePage()
        
        // Setup page 2 content (Bonus Cat)
        setupBonusCatPage()
        
        // Show the first page by default
        showPage(0)
    }
    
    private func setupCommonUI() {
        // Back button
        backButton = SKShapeNode(rectOf: CGSize(width: 100, height: 50), cornerRadius: 10)
        backButton.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7)
        backButton.strokeColor = SKColor.black
        backButton.lineWidth = 1
        backButton.position = CGPoint(x: 70, y: size.height - 50)
        backButton.name = "backButton"
        
        let backLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        backLabel.text = "Back"
        backLabel.fontSize = 20
        backLabel.fontColor = SKColor.white
        backLabel.verticalAlignmentMode = .center
        backLabel.horizontalAlignmentMode = .center
        backButton.addChild(backLabel)
        
        addChild(backButton)
        
        // Save button
        saveButton = SKShapeNode(rectOf: CGSize(width: 100, height: 50), cornerRadius: 10)
        saveButton.fillColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7)
        saveButton.strokeColor = SKColor.black
        saveButton.lineWidth = 1
        saveButton.position = CGPoint(x: size.width - 70, y: size.height - 50)
        saveButton.name = "saveButton"
        
        let saveLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        saveLabel.text = "Save"
        saveLabel.fontSize = 20
        saveLabel.fontColor = SKColor.white
        saveLabel.verticalAlignmentMode = .center
        saveLabel.horizontalAlignmentMode = .center
        saveButton.addChild(saveLabel)
        
        addChild(saveButton)
    }
    
    private func updateColorTypeSelection() {
        // Reset all buttons
        bgColorButton.fontColor = SKColor.black
        cellColorButton.fontColor = SKColor.black
        fontColorButton.fontColor = SKColor.black
        
        // Highlight selected button
        switch selectedColorType {
        case .background:
            bgColorButton.fontColor = SKColor.blue
        case .cell:
            cellColorButton.fontColor = SKColor.blue
        case .font:
            fontColorButton.fontColor = SKColor.blue
        }
        
        // Update the preview
        updateColorPreview()
        
        // Update brightness slider position based on current color
        // Make sure brightnessSlider is initialized
        guard brightnessSlider != nil && brightnessSliderKnob != nil else { return }
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getCurrentColorForType().getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        currentBrightness = brightness
        
        // Update slider knob position
        let sliderWidth: CGFloat = 180
        let sliderLeft = brightnessSlider.position.x - sliderWidth/2
        let newX = sliderLeft + (sliderWidth * currentBrightness)
        brightnessSliderKnob.position = CGPoint(x: newX, y: brightnessSlider.position.y)
        
        // Update gradient
        if let gradientNode = brightnessSlider.children.first as? SKSpriteNode,
           let gradientImage = createBrightnessGradientImage() {
            gradientNode.texture = SKTexture(image: gradientImage)
        }
    }
    
    private func updateColorPreview() {
        // Update the background color of the preview
        colorPreview.fillColor = OptionsScene.backgroundColor
        
        // Find and update the cell preview
        if let previewCell = colorPreview.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
            previewCell.fillColor = OptionsScene.cellColor
            previewCell.strokeColor = OptionsScene.cellColor.withAlphaComponent(1.0)
            
            // Find and update the number preview
            if let previewNumber = previewCell.children.first(where: { $0 is SKLabelNode }) as? SKLabelNode {
                previewNumber.fontColor = OptionsScene.fontColor
            }
        }
    }
    
    private func getCurrentColorForType() -> SKColor {
        switch selectedColorType {
        case .background:
            return OptionsScene.backgroundColor
        case .cell:
            return OptionsScene.cellColor
        case .font:
            return OptionsScene.fontColor
        }
    }
    
    private func setCurrentColorForType(_ color: SKColor) {
        switch selectedColorType {
        case .background:
            OptionsScene.backgroundColor = color
            backgroundColor = color // Update the current scene's background
        case .cell:
            OptionsScene.cellColor = color
        case .font:
            OptionsScene.fontColor = color
        }
        
        // Update the preview
        updateColorPreview()
    }
    
    private func createColorWheelTexture() -> SKTexture? {
        let size = CGSize(width: 180, height: 180)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let center = CGPoint(x: size.width/2, y: size.height/2)
        let radius = min(size.width, size.height)/2
        
        // Draw color wheel with proper HSB mapping
        for y in 0..<Int(size.height) {
            for x in 0..<Int(size.width) {
                // Calculate distance from center
                let dx = CGFloat(x) - center.x
                // let dy = center.y - CGFloat(y)  // Invert y to match standard coordinates
                let dy = CGFloat(y) - center.y  // Invert y to match standard coordinates
                let distance = sqrt(dx*dx + dy*dy)
                
                // Skip pixels outside the circle
                if distance > radius {
                    continue
                }
                
                // Calculate normalized distance (0 to 1)
                let normalizedDistance = distance / radius
                
                // Calculate hue directly - standard HSB color wheel has:
                // Red at right (0 degrees), Green at top (120 degrees), Blue at bottom (240 degrees)
                let hue = (atan2(dy, dx) / (2 * .pi)) + 0.5
                
                // Create color with full saturation and brightness
                let color = UIColor(hue: CGFloat(hue), saturation: normalizedDistance, brightness: 1.0, alpha: 1.0)
                
                // Set pixel color
                context.setFillColor(color.cgColor)
                context.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image != nil ? SKTexture(image: image!) : nil
    }
    
    private func colorAtPoint(_ point: CGPoint) -> SKColor {
        // Calculate the angle and distance from center
        let dx = point.x - colorWheelCenter.x
        let dy = colorWheelCenter.y - point.y  // Invert y to match standard coordinates
        let distance = sqrt(dx*dx + dy*dy)
        
        // Calculate the radius of the color wheel
        let radius = colorWheel.size.width / 2
        
        // Normalize distance to 0-1 range (0 at center, 1 at edge)
        let normalizedDistance = min(distance / radius, 1.0)
        
        // Calculate hue directly - standard HSB color wheel has:
        // Red at right (0 degrees), Green at top (120 degrees), Blue at bottom (240 degrees)
        let hue = (atan2(dy, dx) / (2 * .pi)) + 0.5
        
        // Create color with saturation based on distance from center
        // and full brightness
        return SKColor(hue: CGFloat(hue), saturation: normalizedDistance, brightness: 1.0, alpha: 1.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchLocation = location
        isSwipingPage = false
        
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "backButton" || node.name == "saveButton" {
                // Visual feedback
                if let button = node as? SKShapeNode {
                    button.fillColor = button.fillColor.withAlphaComponent(0.5)
                }
                
                if node.name == "backButton" {
                    // Go back without saving
                    let startScene = StartScene(size: self.size)
                    startScene.scaleMode = .aspectFill
                    
                    let transition = SKTransition.fade(withDuration: 0.5)
                    self.view?.presentScene(startScene, transition: transition)
                    return
                } else if node.name == "saveButton" {
                    // Save settings and go back
                    saveSettings()
                    
                    let startScene = StartScene(size: self.size)
                    startScene.scaleMode = .aspectFill
                    
                    let transition = SKTransition.fade(withDuration: 0.5)
                    self.view?.presentScene(startScene, transition: transition)
                    return
                }
            }
            else if node.name == "colorWheel" || node.name == "page0_colorWheel" {
                isDraggingColorWheel = true
                let color = colorAtPoint(location)
                setCurrentColorForType(color)
                return
            }
            else if node.name == "timeSliderKnob" || node.name == "page0_timeSliderKnob" || node.name == "timeSlider" || node.name == "page0_timeSlider" {
                isDraggingSlider = true
                updateTimeSlider(at: location)
                return
            }
            else if node.name == "brightnessSliderKnob" || node.name == "page0_brightnessSliderKnob" || node.name == "brightnessSlider" || node.name == "page0_brightnessSlider" {
                isDraggingBrightnessSlider = true
                updateBrightnessSlider(at: location)
                return
            }
            else if node.name == "page2_countSliderKnob" || node.name == "page2_countSlider" {
                isDraggingBonusCatCountSlider = true
                updateBonusCatCountSlider(at: location)
                return
            }
            else if node.name == "page2_timeSliderKnob" || node.name == "page2_timeSlider" {
                isDraggingBonusCatTimeSlider = true
                updateBonusCatTimeSlider(at: location)
                return
            }
            else if node.name == "bgColorButton" || node.name == "page0_bgColorButton" {
                selectedColorType = .background
                updateColorTypeSelection()
                return
            }
            else if node.name == "cellColorButton" || node.name == "page0_cellColorButton" {
                selectedColorType = .cell
                updateColorTypeSelection()
                return
            }
            else if node.name == "fontColorButton" || node.name == "page0_fontColorButton" {
                selectedColorType = .font
                updateColorTypeSelection()
                return
            }
            else if node.name?.starts(with: "boardSize_") == true || node.name?.starts(with: "page0_boardSize_") == true {
                // Extract the index from the name
                let nameComponents = node.name?.split(separator: "_")
                if let indexStr = nameComponents?.last,
                   let index = Int(indexStr),
                   index < BoardSize.allCases.count {
                    // Update the selected board size
                    OptionsScene.boardSize = BoardSize.allCases[index]
                    
                    // Update button appearances
                    for (i, button) in boardSizeButtons.enumerated() {
                        button.fillColor = i == index ? SKColor.green.withAlphaComponent(0.3) : SKColor.lightGray.withAlphaComponent(0.3)
                    }
                }
                return
            }
            else if node.name?.starts(with: "page1_cellShape_") == true {
                // Extract the index from the name
                if let indexStr = node.name?.split(separator: "_").last,
                   let index = Int(indexStr),
                   index < CellShape.allCases.count {
                    // Update the selected cell shape
                    OptionsScene.cellShape = CellShape.allCases[index]
                    
                    // Update button appearances
                    for (i, button) in shapeButtons.enumerated() {
                        button.fillColor = i == index ? SKColor.green.withAlphaComponent(0.3) : SKColor.lightGray.withAlphaComponent(0.3)
                    }
                    
                    // Update the preview
                    updateShapePreview()
                }
                return
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let startLocation = lastTouchLocation else { return }
        let currentLocation = touch.location(in: self)
        
        // If we're already interacting with a specific UI element, handle that first
        if isDraggingColorWheel {
            let color = colorAtPoint(currentLocation)
            setCurrentColorForType(color)
            return
        }
        else if isDraggingSlider {
            updateTimeSlider(at: currentLocation)
            return
        }
        else if isDraggingBrightnessSlider {
            updateBrightnessSlider(at: currentLocation)
            return
        }
        else if isDraggingBonusCatCountSlider {
            updateBonusCatCountSlider(at: currentLocation)
            return
        }
        else if isDraggingBonusCatTimeSlider {
            updateBonusCatTimeSlider(at: currentLocation)
            return
        }
        // Only check for horizontal swipe if we're not interacting with other UI elements
        let horizontalDelta = currentLocation.x - startLocation.x
        let verticalDelta = abs(currentLocation.y - startLocation.y)
        
        // If horizontal movement is significant and greater than vertical movement, it's a swipe
        if abs(horizontalDelta) > 30 && abs(horizontalDelta) > verticalDelta && !isSwipingPage {
            isSwipingPage = true
            
            // Move page containers with the swipe
            for (i, container) in pageContainers.enumerated() {
                let baseX = CGFloat(i - currentPage) * size.width
                container.position.x = baseX + horizontalDelta
            }
        }
        
        // Add these cases to handle the bonus cat sliders
        let touchedNode = atPoint(currentLocation)
        
        // Handle bonus cat count slider dragging
        if touchedNode.name?.hasPrefix("page2_countSliderKnob") == true {
            updateBonusCatCountSlider(at: currentLocation)
            return
        }
        
        // Handle bonus cat time slider dragging
        if touchedNode.name?.hasPrefix("page2_timeSliderKnob") == true {
            updateBonusCatTimeSlider(at: currentLocation)
            return
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let startLocation = lastTouchLocation else { 
            resetTouchStates()
            return 
        }
        
        // If we were interacting with a specific UI element, just reset states
        if isDraggingColorWheel || isDraggingSlider || isDraggingBrightnessSlider || isDraggingBonusCatCountSlider || isDraggingBonusCatTimeSlider {
            resetTouchStates()
            return
        }
        
        // Only handle page swiping if we were actually swiping
        if isSwipingPage {
            let endLocation = touch.location(in: self)
            let horizontalDelta = endLocation.x - startLocation.x
            
            // Determine which page to show based on swipe direction
            let pageChange = horizontalDelta > 0 ? -1 : 1
            let targetPage = max(0, min(totalPages - 1, currentPage + pageChange))
            showPage(targetPage, animated: true)
        }
        
        resetTouchStates()
    }
    
    private func resetTouchStates() {
        // Reset button appearances
        if let backButton = self.backButton {
            backButton.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.7)
        }
        
        if let saveButton = self.saveButton {
            saveButton.fillColor = SKColor(red: 0.1, green: 0.8, blue: 0.3, alpha: 0.7)
        }
        
        isDraggingColorWheel = false
        isDraggingSlider = false
        isDraggingBrightnessSlider = false
        isDraggingBonusCatCountSlider = false
        isDraggingBonusCatTimeSlider = false
        lastTouchLocation = nil
        isSwipingPage = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetTouchStates()
        lastTouchLocation = nil
        isSwipingPage = false
    }
    
    // Static method to load saved settings when the app starts
    static func loadSavedSettings() {
        let defaults = UserDefaults.standard
        
        // Load background color
        if let colorData = defaults.data(forKey: "backgroundColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            // Convert UIColor to SKColor components
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            backgroundColor = SKColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        
        // Load cell color
        if let colorData = defaults.data(forKey: "cellColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            // Convert UIColor to SKColor components
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            cellColor = SKColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        
        // Load font color
        if let colorData = defaults.data(forKey: "fontColor"),
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            // Convert UIColor to SKColor components
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            fontColor = SKColor(red: red, green: green, blue: blue, alpha: alpha)
        }
        
        // Load time limit
        if defaults.object(forKey: "timeLimit") != nil {
            timeLimit = defaults.double(forKey: "timeLimit")
        }
        
        // Load board size
        if let sizeIndex = defaults.object(forKey: "boardSizeIndex") as? Int,
           sizeIndex < BoardSize.allCases.count {
            boardSize = BoardSize.allCases[sizeIndex]
        }
        
        // Load cell shape
        if let shapeIndex = defaults.object(forKey: "cellShapeIndex") as? Int,
           shapeIndex < CellShape.allCases.count {
            cellShape = CellShape.allCases[shapeIndex]
        }
    }
    
    // Method to save current settings
    private func saveSettings() {
        let defaults = UserDefaults.standard
        
        // Save background color
        do {
            // Convert SKColor to UIColor components
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            OptionsScene.backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let uiColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
            defaults.set(colorData, forKey: "backgroundColor")
        } catch {
            print("Failed to save background color: \(error)")
        }
        
        // Save cell color
        do {
            // Convert SKColor to UIColor components
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            OptionsScene.cellColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let uiColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
            defaults.set(colorData, forKey: "cellColor")
        } catch {
            print("Failed to save cell color: \(error)")
        }
        
        // Save font color
        do {
            // Convert SKColor to UIColor components
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            OptionsScene.fontColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let uiColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
            defaults.set(colorData, forKey: "fontColor")
        } catch {
            print("Failed to save font color: \(error)")
        }
        
        // Save time limit
        defaults.set(OptionsScene.timeLimit, forKey: "timeLimit")
        
        // Save board size (as index)
        if let index = BoardSize.allCases.firstIndex(of: OptionsScene.boardSize) {
            defaults.set(index, forKey: "boardSizeIndex")
        }
        
        // Save cell shape
        if let index = CellShape.allCases.firstIndex(of: OptionsScene.cellShape) {
            defaults.set(index, forKey: "cellShapeIndex")
        }
        
        // Force UserDefaults to save immediately
        defaults.synchronize()
    }
    
    private func createBrightnessGradientImage() -> UIImage? {
        let width: CGFloat = 170
        let height: CGFloat = 6
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Get the current color based on selected type
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let currentColor = getCurrentColorForType()
        currentColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Create gradient from black to full color
        let colors = [UIColor.black.cgColor, UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations) else {
            return nil
        }
        
        context.drawLinearGradient(gradient, 
                                  start: CGPoint(x: 0, y: 0), 
                                  end: CGPoint(x: width, y: 0), 
                                  options: [])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private func updateBrightnessSlider(at location: CGPoint) {
        // Calculate slider bounds
        let sliderWidth: CGFloat = 180
        let sliderLeft = brightnessSlider.position.x - sliderWidth/2
        let sliderRight = brightnessSlider.position.x + sliderWidth/2
        
        // Constrain x position to slider bounds
        let newX = max(sliderLeft, min(sliderRight, location.x))
        brightnessSliderKnob.position = CGPoint(x: newX, y: brightnessSlider.position.y)
        
        // Calculate brightness value (0 to 1)
        currentBrightness = (newX - sliderLeft) / sliderWidth
        
        // Update the current color with new brightness
        updateColorWithBrightness()
    }
    
    private func updateColorWithBrightness() {
        // Get the current color
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        let currentColor = getCurrentColorForType()
        currentColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Create new color with adjusted brightness
        let newColor = SKColor(hue: hue, saturation: saturation, brightness: currentBrightness, alpha: alpha)
        
        // Update the color
        setCurrentColorForType(newColor)
    }
    
    private func updateShapePreview() {
        // Find the shape preview in the second page container
        guard pageContainers.count > 1,
              let previewBackground = pageContainers[1].childNode(withName: "page1_preview_bg") else {
            return
        }
        
        // Remove any existing preview
        pageContainers[1].children.forEach { node in
            if node.name == "page1_shape_preview" || node.name == "page1_preview_number" {
                node.removeFromParent()
            }
        }
        
        // Create a new preview with the selected shape
        let previewSize = CGSize(width: 150, height: 150)
        
        switch OptionsScene.cellShape {
        case .roundedSquare:
            let shapePreview = SKShapeNode(rectOf: previewSize, cornerRadius: previewSize.width * 0.15)
            shapePreview.fillColor = OptionsScene.cellColor
            shapePreview.strokeColor = OptionsScene.cellColor.withAlphaComponent(1.0)
            shapePreview.lineWidth = 2
            shapePreview.position = previewBackground.position
            shapePreview.name = "page1_shape_preview"
            pageContainers[1].addChild(shapePreview)
            
            // Add a number to the preview
            let numberLabel = SKLabelNode(fontNamed: "Futura-Bold")
            numberLabel.text = "7"
            numberLabel.fontSize = previewSize.width * 0.5
            numberLabel.fontColor = OptionsScene.fontColor
            numberLabel.verticalAlignmentMode = .center
            numberLabel.horizontalAlignmentMode = .center
            numberLabel.position = previewBackground.position
            numberLabel.name = "page1_preview_number"
            pageContainers[1].addChild(numberLabel)
            
        case .circle:
            let shapePreview = SKShapeNode(circleOfRadius: previewSize.width / 2)
            shapePreview.fillColor = OptionsScene.cellColor
            shapePreview.strokeColor = OptionsScene.cellColor.withAlphaComponent(1.0)
            shapePreview.lineWidth = 2
            shapePreview.position = previewBackground.position
            shapePreview.name = "page1_shape_preview"
            pageContainers[1].addChild(shapePreview)
            
            // Add a number to the preview
            let numberLabel = SKLabelNode(fontNamed: "Futura-Bold")
            numberLabel.text = "5"
            numberLabel.fontSize = previewSize.width * 0.5
            numberLabel.fontColor = OptionsScene.fontColor
            numberLabel.verticalAlignmentMode = .center
            numberLabel.horizontalAlignmentMode = .center
            numberLabel.position = previewBackground.position
            numberLabel.name = "page1_preview_number"
            pageContainers[1].addChild(numberLabel)
            
        case .cat:
            // Create a cat-shaped preview
            let catPreview = createCatShapedPreview(size: previewSize)
            catPreview.position = previewBackground.position
            catPreview.name = "page1_shape_preview"
            pageContainers[1].addChild(catPreview)
            
            // Add a number to the preview
            let numberLabel = SKLabelNode(fontNamed: "Futura-Bold")
            numberLabel.text = "3"
            numberLabel.fontSize = previewSize.width * 0.5
            numberLabel.fontColor = OptionsScene.fontColor
            numberLabel.verticalAlignmentMode = .center
            numberLabel.horizontalAlignmentMode = .center
            numberLabel.position = previewBackground.position
            numberLabel.name = "page1_preview_number"
            numberLabel.zPosition = 1 // Ensure the number is on top
            pageContainers[1].addChild(numberLabel)
        }
    }
    
    // Update the createCatShapedPreview method to use the cat face image
    private func createCatShapedPreview(size: CGSize) -> SKSpriteNode {
        // Try to load the cat face image from assets
        if let catImage = UIImage(named: "cat_face") {
            // Create a texture from the image
            let texture = SKTexture(image: catImage)
            
            // Create a sprite with the cat face texture
            let catSprite = SKSpriteNode(texture: texture)
            catSprite.size = size
            catSprite.color = OptionsScene.cellColor
            catSprite.colorBlendFactor = 0.7 // Blend with the cell color
            
            return catSprite
        } else {
            print("Failed to load cat_face image for preview")
            
            // Fallback to a colored circle if image loading fails
            let renderer = UIGraphicsImageRenderer(size: size)
            let circleImage = renderer.image { context in
                let rect = CGRect(origin: .zero, size: size)
                context.cgContext.setFillColor(OptionsScene.cellColor.cgColor)
                context.cgContext.fillEllipse(in: rect)
            }
            
            return SKSpriteNode(texture: SKTexture(image: circleImage))
        }
    }
    
    // Add this method to setup the page navigation
    private func setupPageNavigation() {
        // Create page containers
        for i in 0..<totalPages {
            let container = SKNode()
            container.position = CGPoint(x: i == 0 ? 0 : size.width, y: 0)
            container.name = "pageContainer_\(i)"
            addChild(container)
            pageContainers.append(container)
        }
        
        // Create page indicators (dots)
        let indicatorSize: CGFloat = 10
        let indicatorSpacing: CGFloat = 20
        let totalWidth = (indicatorSize * CGFloat(totalPages)) + (indicatorSpacing * CGFloat(totalPages - 1))
        let startX = (size.width - totalWidth) / 2 + indicatorSize / 2
        
        for i in 0..<totalPages {
            let indicator = SKShapeNode(circleOfRadius: indicatorSize / 2)
            indicator.fillColor = i == currentPage ? 
                SKColor.white.withAlphaComponent(0.8) : 
                SKColor.gray.withAlphaComponent(0.5)
            indicator.strokeColor = SKColor.clear
            indicator.position = CGPoint(
                x: startX + (indicatorSize + indicatorSpacing) * CGFloat(i),
                y: 50 // Position near bottom of screen
            )
            indicator.name = "pageIndicator_\(i)"
            addChild(indicator)
            pageIndicators.append(indicator)
        }
    }
    
    private func showPage(_ pageIndex: Int, animated: Bool = false) {
        guard pageIndex >= 0 && pageIndex < totalPages else { return }
        
        // Update page indicators
        for (i, indicator) in pageIndicators.enumerated() {
            indicator.fillColor = i == pageIndex ? 
                SKColor.white.withAlphaComponent(0.8) : 
                SKColor.gray.withAlphaComponent(0.5)
        }
        
        // Move page containers
        if animated {
            let duration: TimeInterval = 0.3
            
            for (i, container) in pageContainers.enumerated() {
                let targetX = CGFloat(i - pageIndex) * size.width
                let moveAction = SKAction.moveTo(x: targetX, duration: duration)
                moveAction.timingMode = .easeInEaseOut
                container.run(moveAction)
            }
        } else {
            for (i, container) in pageContainers.enumerated() {
                container.position.x = CGFloat(i - pageIndex) * size.width
            }
        }
        
        currentPage = pageIndex
    }
    
    private func hideAllPageContent() {
        // Hide all nodes with page-specific tags
        enumerateChildNodes(withName: "page0_*") { node, _ in
            node.isHidden = true
        }
        
        enumerateChildNodes(withName: "page1_*") { node, _ in
            node.isHidden = true
        }
    }
    
    private func showColorAndTimePage() {
        // Show all nodes for page 0
        enumerateChildNodes(withName: "page0_*") { node, _ in
            node.isHidden = false
        }
    }
    
    private func showCellShapePage() {
        // Show all nodes for page 1
        enumerateChildNodes(withName: "page1_*") { node, _ in
            node.isHidden = false
        }
    }
    
    private func setupCellShapePage() {
        guard pageContainers.count > 1 else { return }
        let container = pageContainers[1]
        
        // Shape preview
        let previewBackground = SKShapeNode(rectOf: CGSize(width: 200, height: 200), cornerRadius: 10)
        previewBackground.fillColor = SKColor.lightGray.withAlphaComponent(0.2)
        previewBackground.strokeColor = SKColor.black
        previewBackground.lineWidth = 1
        previewBackground.position = CGPoint(x: size.width/2, y: size.height - 200)
        previewBackground.name = "page1_preview_bg"
        container.addChild(previewBackground)
        
        // Shape selection buttons
        let shapeButtonWidth: CGFloat = 280
        let shapeButtonHeight: CGFloat = 60
        let shapeButtonSpacing: CGFloat = 20
        let shapeStartY: CGFloat = size.height - 400
        
        shapeButtons.removeAll()
        
        for (index, shape) in CellShape.allCases.enumerated() {
            let button = SKShapeNode(rectOf: CGSize(width: shapeButtonWidth, height: shapeButtonHeight), cornerRadius: 10)
            button.fillColor = shape == OptionsScene.cellShape ? 
                SKColor.green.withAlphaComponent(0.3) : 
                SKColor.lightGray.withAlphaComponent(0.3)
            button.strokeColor = SKColor.black
            button.lineWidth = 1
            button.position = CGPoint(x: size.width/2, y: shapeStartY - CGFloat(index) * (shapeButtonHeight + shapeButtonSpacing))
            button.name = "page1_cellShape_\(index)"
            
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = shape.description
            label.fontSize = 24
            label.fontColor = SKColor.black
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            button.addChild(label)
            
            container.addChild(button)
            shapeButtons.append(button)
        }
        
        // Create the initial shape preview
        updateShapePreview()
    }
    
    // Add this method to setup the color and time page
    private func setupColorAndTimePage() {
        guard let container = pageContainers.first else { return }
        
        // Section: Color Selection
        let colorSectionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        colorSectionLabel.text = "Color Selection"
        colorSectionLabel.fontSize = 24
        colorSectionLabel.fontColor = SKColor.black
        colorSectionLabel.position = CGPoint(x: size.width/2, y: size.height - 120)
        container.addChild(colorSectionLabel)
        
        // Color type selection
        bgColorButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        bgColorButton.text = "Background"
        bgColorButton.fontSize = 18
        bgColorButton.fontColor = SKColor.black
        bgColorButton.verticalAlignmentMode = .center
        bgColorButton.position = CGPoint(x: size.width/2 - 120, y: size.height - 160)
        bgColorButton.name = "bgColorButton"
        bgColorButton.name = "page0_bgColorButton"
        container.addChild(bgColorButton)
        
        cellColorButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        cellColorButton.text = "Ruga"
        cellColorButton.fontSize = 18
        cellColorButton.fontColor = SKColor.black
        cellColorButton.verticalAlignmentMode = .center
        cellColorButton.position = CGPoint(x: size.width/2 + 5, y: size.height - 160)
        cellColorButton.name = "cellColorButton"
        cellColorButton.name = "page0_cellColorButton"
        container.addChild(cellColorButton)
        
        fontColorButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        fontColorButton.text = "Font"
        fontColorButton.fontSize = 18
        fontColorButton.fontColor = SKColor.black
        fontColorButton.verticalAlignmentMode = .center
        fontColorButton.position = CGPoint(x: size.width/2 + 140, y: size.height - 160)
        fontColorButton.name = "fontColorButton"
        fontColorButton.name = "page0_fontColorButton"
        container.addChild(fontColorButton)
        
        // Color wheel
        colorWheelBackground = SKSpriteNode(color: SKColor.lightGray.withAlphaComponent(0.2), size: CGSize(width: 100, height: 100))
        colorWheelBackground.position = CGPoint(x: size.width/2 + 90, y: size.height - 280)
        colorWheelBackground.name = "page0_colorWheelBg"
        container.addChild(colorWheelBackground)
        
        if let wheelTexture = createColorWheelTexture() {
            colorWheel = SKSpriteNode(texture: wheelTexture)
            colorWheel.size = CGSize(width: 180, height: 180)
            colorWheel.position = colorWheelBackground.position
            colorWheel.name = "colorWheel"
            colorWheel.name = "page0_colorWheel"
            container.addChild(colorWheel)
            
            // Store the center position for later calculations
            colorWheelCenter = colorWheel.position
        }
        
        // Color preview
        colorPreview = SKShapeNode(rectOf: CGSize(width: 160, height: 160), cornerRadius: 15)
        colorPreview.fillColor = OptionsScene.backgroundColor
        colorPreview.strokeColor = SKColor.black
        colorPreview.lineWidth = 1
        colorPreview.position = CGPoint(x: size.width/2 - 90, y: size.height - 280)
        colorPreview.name = "page0_colorPreview"
        container.addChild(colorPreview)
        
        // Add a cell preview inside the color preview
        let previewCell = SKShapeNode(rectOf: CGSize(width: 120, height: 120), cornerRadius: 15)
        previewCell.fillColor = OptionsScene.cellColor
        previewCell.strokeColor = OptionsScene.cellColor.withAlphaComponent(1.0)
        previewCell.lineWidth = 2
        previewCell.position = CGPoint(x: 0, y: 0) // Center in the preview
        colorPreview.addChild(previewCell)
        
        // Add a number preview inside the cell preview
        let previewNumber = SKLabelNode(fontNamed: "Futura-Bold")
        previewNumber.text = "7" // Random number for preview
        previewNumber.fontSize = 40
        previewNumber.fontColor = OptionsScene.fontColor
        previewNumber.verticalAlignmentMode = .center
        previewNumber.horizontalAlignmentMode = .center
        previewNumber.position = CGPoint(x: 0, y: 0)
        previewCell.addChild(previewNumber)
        
        // Create brightness slider before calling updateColorTypeSelection
        brightnessSlider = SKShapeNode(rectOf: CGSize(width: 170, height: 10), cornerRadius: 5)
        brightnessSlider.fillColor = SKColor.lightGray.withAlphaComponent(0.5)
        brightnessSlider.strokeColor = SKColor.black
        brightnessSlider.lineWidth = 1
        brightnessSlider.position = CGPoint(x: colorWheel.position.x, y: colorWheel.position.y - 120)
        brightnessSlider.name = "brightnessSlider"
        brightnessSlider.name = "page0_brightnessSlider"
        container.addChild(brightnessSlider)
        
        // Create a gradient for the brightness slider
        let gradientNode = SKSpriteNode(color: .white, size: CGSize(width: 170, height: 6))
        gradientNode.position = CGPoint.zero
        
        // Create a gradient texture
        let gradientImage = createBrightnessGradientImage()
        if let gradientTexture = gradientImage {
            gradientNode.texture = SKTexture(image: gradientTexture)
        }
        brightnessSlider.addChild(gradientNode)
        
        // Brightness slider knob
        brightnessSliderKnob = SKShapeNode(circleOfRadius: 12)
        brightnessSliderKnob.fillColor = SKColor.white
        brightnessSliderKnob.strokeColor = SKColor.black
        brightnessSliderKnob.lineWidth = 1
        brightnessSliderKnob.position = CGPoint(x: brightnessSlider.position.x + 90, y: brightnessSlider.position.y)  // Start at full brightness
        brightnessSliderKnob.name = "brightnessSliderKnob"
        brightnessSliderKnob.name = "page0_brightnessSliderKnob"
        container.addChild(brightnessSliderKnob)
        
        // Now call updateColorTypeSelection after all UI elements are initialized
        updateColorTypeSelection()
        
        // Section: Time Limit
        let timeSectionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        timeSectionLabel.text = "Time Limit"
        timeSectionLabel.fontSize = 24
        timeSectionLabel.fontColor = SKColor.black
        timeSectionLabel.position = CGPoint(x: size.width/2, y: size.height - 450)
        timeSectionLabel.name = "page0_timeSection"
        container.addChild(timeSectionLabel)
        
        // Time slider
        timeSlider = SKShapeNode(rectOf: CGSize(width: 280, height: 10), cornerRadius: 5)
        timeSlider.fillColor = SKColor.lightGray.withAlphaComponent(0.5)
        timeSlider.strokeColor = SKColor.black
        timeSlider.lineWidth = 1
        timeSlider.position = CGPoint(x: size.width/2, y: size.height - 470)
        timeSlider.name = "timeSlider"
        timeSlider.name = "page0_timeSlider"
        container.addChild(timeSlider)
        
        // Time slider knob
        timeSliderKnob = SKShapeNode(circleOfRadius: 15)
        timeSliderKnob.fillColor = SKColor.white
        timeSliderKnob.strokeColor = SKColor.black
        timeSliderKnob.lineWidth = 1
        
        // Calculate initial position based on current time limit
        let minTime: TimeInterval = 60.0 // 1 minute
        let maxTime: TimeInterval = 300.0 // 5 minutes
        let sliderWidth = timeSlider.frame.width - 30 // Adjust for knob size
        let normalizedTime = (OptionsScene.timeLimit - minTime) / (maxTime - minTime)
        let initialX = timeSlider.position.x - sliderWidth/2 + CGFloat(normalizedTime) * sliderWidth
        
        timeSliderKnob.position = CGPoint(x: initialX, y: timeSlider.position.y)
        timeSliderKnob.name = "timeSliderKnob"
        timeSliderKnob.name = "page0_timeSliderKnob"
        container.addChild(timeSliderKnob)
        
        // Time label
        timeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        
        // Format time as minutes:seconds
        let minutes = Int(OptionsScene.timeLimit) / 60
        let seconds = Int(OptionsScene.timeLimit) % 60
        timeLabel.text = String(format: "%d:%02d", minutes, seconds)
        
        timeLabel.fontSize = 20
        timeLabel.fontColor = SKColor.black
        timeLabel.position = CGPoint(x: size.width/2, y: size.height - 510)
        timeLabel.name = "timeLabel"
        timeLabel.name = "page0_timeLabel"
        container.addChild(timeLabel)
        
        // Section: Board Size
        let boardSizeSectionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        boardSizeSectionLabel.text = "Board Size"
        boardSizeSectionLabel.fontSize = 24
        boardSizeSectionLabel.fontColor = SKColor.black
        boardSizeSectionLabel.position = CGPoint(x: size.width/2, y: size.height - 560)
        boardSizeSectionLabel.name = "page0_boardSizeSection"
        container.addChild(boardSizeSectionLabel)
        
        // Board size buttons
        let buttonWidth: CGFloat = 280
        let buttonHeight: CGFloat = 40
        let buttonSpacing: CGFloat = 20
        let startY: CGFloat = size.height - 600
        
        for (index, size) in BoardSize.allCases.enumerated() {
            let button = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
            button.fillColor = size == OptionsScene.boardSize ? 
                SKColor.green.withAlphaComponent(0.3) : 
                SKColor.lightGray.withAlphaComponent(0.3)
            button.strokeColor = SKColor.black
            button.lineWidth = 1
            button.position = CGPoint(x: self.size.width/2, y: startY - CGFloat(index) * (buttonHeight + buttonSpacing))
            button.name = "boardSize_\(index)"
            button.name = "page0_boardSize_\(index)"
            
            let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
            label.text = size.rawValue
            label.fontSize = 18
            label.fontColor = SKColor.black
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            button.addChild(label)
            
            container.addChild(button)
            boardSizeButtons.append(button)
        }
    }
    
    // Add this method to the OptionsScene class
    private func updateTimeSlider(at location: CGPoint) {
        // Calculate slider bounds
        let sliderWidth = timeSlider.frame.width - 30 // Adjust for knob size
        let sliderLeft = timeSlider.position.x - sliderWidth/2
        let sliderRight = timeSlider.position.x + sliderWidth/2
        
        // Constrain x position to slider bounds
        let newX = max(sliderLeft, min(sliderRight, location.x))
        timeSliderKnob.position = CGPoint(x: newX, y: timeSlider.position.y)
        
        // Calculate time value based on slider position
        let minTime: TimeInterval = 60.0 // 1 minute
        let maxTime: TimeInterval = 300.0 // 5 minutes
        let normalizedPosition = (newX - sliderLeft) / sliderWidth
        let newTime = minTime + (maxTime - minTime) * TimeInterval(normalizedPosition)
        
        // Update the time limit
        OptionsScene.timeLimit = newTime
        
        // Update the time label
        let minutes = Int(newTime) / 60
        let seconds = Int(newTime) % 60
        timeLabel.text = String(format: "%d:%02d", minutes, seconds)
    }
    
    // Add this method to setup the bonus cat page
    private func setupBonusCatPage() {

        guard pageContainers.count > 2 else { return }
        let container = pageContainers[2]
        
        // Page title - centered at the top
        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.text = "Bonus Cat Settings"
        titleLabel.fontSize = 28
        titleLabel.fontColor = SKColor.black
        titleLabel.position = CGPoint(x: size.width/2, y: size.height - 120)
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.name = "page2_title"
        container.addChild(titleLabel)
        
        // Bonus Cat Count Subsection - centered
        let countLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        countLabel.text = "Number of Bonus Cats"
        countLabel.fontSize = 24
        countLabel.fontColor = SKColor.black
        countLabel.position = CGPoint(x: size.width/2, y: size.height - 200)
        countLabel.horizontalAlignmentMode = .center
        countLabel.name = "page2_countLabel"
        container.addChild(countLabel)
        
        // Bonus Cat Count Slider - centered
        bonusCatCountSlider = SKShapeNode(rectOf: CGSize(width: 280, height: 10), cornerRadius: 5)
        bonusCatCountSlider.fillColor = SKColor.lightGray.withAlphaComponent(0.5)
        bonusCatCountSlider.strokeColor = SKColor.black
        bonusCatCountSlider.lineWidth = 1
        bonusCatCountSlider.position = CGPoint(x: size.width/2, y: size.height - 250)
        bonusCatCountSlider.name = "page2_countSlider"
        container.addChild(bonusCatCountSlider)
        
        // Bonus Cat Count Slider Knob
        bonusCatCountSliderKnob = SKShapeNode(circleOfRadius: 15)
        bonusCatCountSliderKnob.fillColor = SKColor.white
        bonusCatCountSliderKnob.strokeColor = SKColor.black
        bonusCatCountSliderKnob.lineWidth = 1
        
        // Calculate initial position based on current count
        let minCount: CGFloat = 5
        let maxCount: CGFloat = 70
        let countSliderWidth = bonusCatCountSlider.frame.width - 30 // Adjust for knob size
        let normalizedCount = CGFloat(OptionsScene.bonusCatCount - Int(minCount)) / (maxCount - minCount)
        let countInitialX = bonusCatCountSlider.position.x - countSliderWidth/2 + normalizedCount * countSliderWidth
        
        bonusCatCountSliderKnob.position = CGPoint(x: countInitialX, y: bonusCatCountSlider.position.y)
        bonusCatCountSliderKnob.name = "page2_countSliderKnob"
        container.addChild(bonusCatCountSliderKnob)
        
        // Bonus Cat Count Label - centered
        bonusCatCountLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        bonusCatCountLabel.text = "\(OptionsScene.bonusCatCount) cats"
        bonusCatCountLabel.fontSize = 20
        bonusCatCountLabel.fontColor = SKColor.black
        bonusCatCountLabel.position = CGPoint(x: size.width/2, y: size.height - 290)
        bonusCatCountLabel.horizontalAlignmentMode = .center
        bonusCatCountLabel.name = "page2_countValueLabel"
        container.addChild(bonusCatCountLabel)
        
        // Bonus Cat Time Subsection - centered
        let timeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        timeLabel.text = "Time Bonus per Cat"
        timeLabel.fontSize = 24
        timeLabel.fontColor = SKColor.black
        timeLabel.position = CGPoint(x: size.width/2, y: size.height - 350)
        timeLabel.horizontalAlignmentMode = .center
        timeLabel.name = "page2_timeLabel"
        container.addChild(timeLabel)
        
        // Bonus Cat Time Slider - centered
        bonusCatTimeSlider = SKShapeNode(rectOf: CGSize(width: 280, height: 10), cornerRadius: 5)
        bonusCatTimeSlider.fillColor = SKColor.lightGray.withAlphaComponent(0.5)
        bonusCatTimeSlider.strokeColor = SKColor.black
        bonusCatTimeSlider.lineWidth = 1
        bonusCatTimeSlider.position = CGPoint(x: size.width/2, y: size.height - 400)
        bonusCatTimeSlider.name = "page2_timeSlider"
        container.addChild(bonusCatTimeSlider)
        
        // Bonus Cat Time Slider Knob
        bonusCatTimeSliderKnob = SKShapeNode(circleOfRadius: 15)
        bonusCatTimeSliderKnob.fillColor = SKColor.white
        bonusCatTimeSliderKnob.strokeColor = SKColor.black
        bonusCatTimeSliderKnob.lineWidth = 1
        
        // Calculate initial position based on current time bonus
        let minTime: CGFloat = 1
        let maxTime: CGFloat = 60
        let timeSliderWidth = bonusCatTimeSlider.frame.width - 30 // Adjust for knob size
        let normalizedTime = CGFloat(OptionsScene.bonusCatTimeBonus - minTime) / (maxTime - minTime)
        let timeInitialX = bonusCatTimeSlider.position.x - timeSliderWidth/2 + normalizedTime * timeSliderWidth
        
        bonusCatTimeSliderKnob.position = CGPoint(x: timeInitialX, y: bonusCatTimeSlider.position.y)
        bonusCatTimeSliderKnob.name = "page2_timeSliderKnob"
        container.addChild(bonusCatTimeSliderKnob)
        
        // Bonus Cat Time Label - centered
        bonusCatTimeLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        bonusCatTimeLabel.text = "+\(Int(OptionsScene.bonusCatTimeBonus)) seconds"
        bonusCatTimeLabel.fontSize = 20
        bonusCatTimeLabel.fontColor = SKColor.black
        bonusCatTimeLabel.position = CGPoint(x: size.width/2, y: size.height - 440)
        bonusCatTimeLabel.horizontalAlignmentMode = .center
        bonusCatTimeLabel.name = "page2_timeValueLabel"
        container.addChild(bonusCatTimeLabel)
        
        // Add a preview of the bonus cat - centered
        let bonusCatPreview = SKSpriteNode(imageNamed: "bonus_cat")
        bonusCatPreview.size = CGSize(width: 100, height: 100)
        bonusCatPreview.position = CGPoint(x: size.width/2, y: size.height - 550)
        bonusCatPreview.name = "page2_bonusCatPreview"
        container.addChild(bonusCatPreview)
        
        // Add a description - centered with proper width
        let descriptionLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        descriptionLabel.text = "Collect bonus cats to add time to the clock!"
        descriptionLabel.fontSize = 18
        descriptionLabel.fontColor = SKColor.black
        descriptionLabel.position = CGPoint(x: size.width/2, y: size.height - 620)
        descriptionLabel.horizontalAlignmentMode = .center
        descriptionLabel.name = "page2_description"
        container.addChild(descriptionLabel)
    }
    
    // Add these methods to handle the bonus cat sliders
    private func updateBonusCatCountSlider(at location: CGPoint) {
        // Calculate slider bounds
        let sliderWidth = bonusCatCountSlider.frame.width - 30 // Adjust for knob size
        let sliderLeft = bonusCatCountSlider.position.x - sliderWidth/2
        let sliderRight = bonusCatCountSlider.position.x + sliderWidth/2
        
        // Constrain x position to slider bounds
        let newX = max(sliderLeft, min(sliderRight, location.x))
        bonusCatCountSliderKnob.position = CGPoint(x: newX, y: bonusCatCountSlider.position.y)
        
        // Calculate count value based on slider position
        let minCount: Int = 5
        let maxCount: Int = 70
        let normalizedPosition = (newX - sliderLeft) / sliderWidth
        let newCount = minCount + Int(round(CGFloat(maxCount - minCount) * normalizedPosition))
        
        // Update the count
        OptionsScene.bonusCatCount = newCount
        
        // Update the label
        bonusCatCountLabel.text = "\(newCount) cats"
    }
    
    private func updateBonusCatTimeSlider(at location: CGPoint) {
        // Calculate slider bounds
        let sliderWidth = bonusCatTimeSlider.frame.width - 30 // Adjust for knob size
        let sliderLeft = bonusCatTimeSlider.position.x - sliderWidth/2
        let sliderRight = bonusCatTimeSlider.position.x + sliderWidth/2
        
        // Constrain x position to slider bounds
        let newX = max(sliderLeft, min(sliderRight, location.x))
        bonusCatTimeSliderKnob.position = CGPoint(x: newX, y: bonusCatTimeSlider.position.y)
        
        // Calculate time value based on slider position
        let minTime: Int = 1
        let maxTime: Int = 60
        let normalizedPosition = (newX - sliderLeft) / sliderWidth
        let newTime = minTime + Int(round(CGFloat(maxTime - minTime) * normalizedPosition))
        
        // Update the time bonus
        OptionsScene.bonusCatTimeBonus = TimeInterval(newTime)
        
        // Update the label
        bonusCatTimeLabel.text = "+\(newTime) seconds"
    }
}