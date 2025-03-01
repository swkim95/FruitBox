//
//  GameViewController.swift
//  FruitBox
//
//  Created by 김성원 on 3/1/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func loadView() {
        // Create an SKView and set it as the view
        self.view = SKView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sure settings are loaded before creating the start scene
        OptionsScene.loadSavedSettings()
        
        if let view = self.view as! SKView? {
            // Create the start scene
            let scene = StartScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
} 