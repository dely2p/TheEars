//
//  ViewController.swift
//  TheEars
//
//  Created by dely on 16/07/2019.
//  Copyright © 2019 dely. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var animations = [String:CAAnimation]()
    var idle: Bool = true
    
    var baseUrl: String = "art.scnassets/human/"
    var isLeftEarMoving: Bool = false
    var isRightEarMoving: Bool = false

    enum Motion: String {
        case idleFixed, sambaFixed
    }
    enum Direction: Int {
        case left = 1, right
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureLighting()
        loadModel(vector3: SCNVector3(-0.2, 0, -0.2))
        loadModel(vector3: SCNVector3(0, 0, -0.2))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView?.session.pause()
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func loadModel(vector3: SCNVector3) {
        let idleScene = SCNScene(named: baseUrl+Motion.idleFixed.rawValue+".dae")!
        let node = SCNNode()
        
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        
        node.position = vector3
        node.scale = SCNVector3(0.05, 0.05, 0.05)
        sceneView.scene.rootNode.addChildNode(node)
        
        loadAnimation(withKey: "dancing", sceneName: baseUrl+Motion.sambaFixed.rawValue, animationIdentifier: "sambaFixed-1")
    }
    
    // button
    @IBAction func leftEarButton(_ sender: Any) {
        if isLeftEarMoving {
            stopAnimation(key: "dancing", indexOfNode: 1)
            isLeftEarMoving = false
        }else {
            playAnimation(key: "dancing", indexOfNode: 1)
            isLeftEarMoving = true
        }
    }
    
    @IBAction func rightEarButton(_ sender: Any) {
        if isRightEarMoving {
            stopAnimation(key: "dancing", indexOfNode: 2)
            isRightEarMoving = false
        }else {
            playAnimation(key: "dancing", indexOfNode: 2)
            isRightEarMoving = true
        }
    }
    
}

// AR animation
extension ViewController {
    func loadAnimation(withKey: String, sceneName: String, animationIdentifier: String) {
        guard let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae") else { return }
        let sceneSource = SCNSceneSource(url: sceneURL, options: nil)

        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
            animationObject.repeatCount = 1
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(0.5)
            animations[withKey] = animationObject
        }
    }
    
    func playAnimation(key: String, indexOfNode: Int) {
        if let node = sceneView?.scene.rootNode.childNodes[indexOfNode] {
            node.addAnimation(animations[key]!, forKey: key)
        }
        
    }
    
    func stopAnimation(key: String, indexOfNode: Int) {
        guard let node = sceneView?.scene.rootNode.childNodes[indexOfNode] else { return }
        node.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }

}

