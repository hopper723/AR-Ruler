//
//  ViewController.swift
//  AR Ruler
//
//  Created by Hiu Man Yeung on 5/2/19.
//  Copyright © 2019 Hiu Man Yeung. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotsArray = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotsArray.count >= 2 {
            removeDots()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let results = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = results.first {
                addDot(with: hitResult)
            }
        }
    }
    
    func addDot(with result: ARHitTestResult) {
        let dot = SCNSphere(radius: 0.005)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.purple
        
        dot.materials = [material]
        
        let dotNode = SCNNode(geometry: dot)
        
        dotNode.position = SCNVector3(
            x: result.worldTransform.columns.3.x,
            y: result.worldTransform.columns.3.y,
            z: result.worldTransform.columns.3.z
        )
        
        dotsArray.append(dotNode)
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        if dotsArray.count >= 2 {
            calculate()
        }
    }
    
    func calculate() {
        let start = dotsArray[0]
        let end = dotsArray[1]
        
        let dx = start.position.x-end.position.x
        let dy = start.position.y-end.position.y
        let dz = start.position.z-end.position.z
        
        let distance = sqrt(pow(dx, 2)+pow(dy, 2)+pow(dz, 2))
        
        updateText(text: "\(distance)", atPosition: end.position)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(x: position.x, y: position.y+0.01, z: position.z)
        textNode.scale = SCNVector3(x: 0.001, y: 0.001, z: 0.001)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    @IBAction func removeButtonPressed(_ sender: UIBarButtonItem) {
        removeDots()
    }
    
    func removeDots() {
        if !dotsArray.isEmpty {
            for dot in dotsArray {
                dot.removeFromParentNode()
            }
            
            dotsArray.removeAll()
        }
    }
}
