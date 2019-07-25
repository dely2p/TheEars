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
import Vision
import AVKit

class ViewController: UIViewController, ARSCNViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var animations = [String:CAAnimation]()
    var idle: Bool = true
    
    private var scanTimer: Timer?
    private var scannedFaceViews = [UIView]()
    
    private var imageOrientation: CGImagePropertyOrientation {
        switch UIDevice.current.orientation {
            case .portrait: return .right
            case .landscapeRight: return .down
            case .portraitUpsideDown: return .left
            case .unknown: fallthrough
            case .faceUp: fallthrough
            case .faceDown: fallthrough
            case .landscapeLeft: return .up
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true

        let scene = SCNScene()
        sceneView.scene = scene
        
        loadAnimations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        scanTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkFaceDetected), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scanTimer?.invalidate()
        sceneView.session.pause()
    }
}

// AR animation
extension ViewController {
    func loadAnimations () {
//        let idleScene = SCNScene(named: "art.scnassets/human/idleFixed.dae")!
        let idleScene = SCNScene(named: "art.scnassets/ears/UpRightEar.DAE")!
//        UpRightEar.scn
        let node = SCNNode()
        
        for child in idleScene.rootNode.childNodes {
            node.addChildNode(child)
        }
        node.position = SCNVector3(0, 0, -0.1)
//        node.scale = SCNVector3(0.02, 0.02, 0.02)
        node.scale = SCNVector3(0.005, 0.005, 0.005)
        
        sceneView.scene.rootNode.addChildNode(node)
        
        loadAnimation(withKey: "dancing", sceneName: "art.scnassets/human/sambaFixed", animationIdentifier: "sambaFixed-1")
    }
    
    func loadAnimation(withKey: String, sceneName:String, animationIdentifier:String) {
        let sceneURL = Bundle.main.url(forResource: sceneName, withExtension: "dae")
        let sceneSource = SCNSceneSource(url: sceneURL!, options: nil)
        
        if let animationObject = sceneSource?.entryWithIdentifier(animationIdentifier, withClass: CAAnimation.self) {
            animationObject.repeatCount = 1
            animationObject.fadeInDuration = CGFloat(1)
            animationObject.fadeOutDuration = CGFloat(0.5)
            animations[withKey] = animationObject
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: sceneView)
        
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        
        let hitResults: [SCNHitTestResult]  = sceneView.hitTest(location, options: hitTestOptions)
        
        if hitResults.first != nil {
            if(idle) {
                playAnimation(key: "dancing")
            } else {
                stopAnimation(key: "dancing")
            }
            idle = !idle
            return
        }
    }
    
    func playAnimation(key: String) {
        sceneView.scene.rootNode.addAnimation(animations[key]!, forKey: key)
    }
    
    func stopAnimation(key: String) {
        sceneView.scene.rootNode.removeAnimation(forKey: key, blendOutDuration: CGFloat(0.5))
    }
}

// tracking face
extension ViewController {
    @objc func checkFaceDetected() {
        _ = scannedFaceViews.map { $0.removeFromSuperview() }
        scannedFaceViews.removeAll()
        
        guard let capturedImage = sceneView.session.currentFrame?.capturedImage else { return }
        
        let image = CIImage.init(cvPixelBuffer: capturedImage)
        
        let detectFaceRequest = VNDetectFaceRectanglesRequest { (request, error) in
            
            DispatchQueue.main.async {
                if let faces = request.results as? [VNFaceObservation] {
                    _ = faces.map({
                        print("\($0.boundingBox.origin.x), \($0.boundingBox.origin.y)")
                    })
//                    for face in faces {
//                        let faceView = UIView(frame: self.faceFrame(from: face.boundingBox))
//
//                        // draw red box
////                        faceView.backgroundColor = .red
////                        self.sceneView.addSubview(faceView)
////                        self.scannedFaceViews.append(faceView)
//                    }
                }
            }
        }
        
        DispatchQueue.global().async {
            try? VNImageRequestHandler(ciImage: image, orientation: self.imageOrientation).perform([detectFaceRequest])
        }
    }
    
    private func faceFrame(from boundingBox: CGRect) -> CGRect {
        let origin = CGPoint(x: boundingBox.minX * sceneView.bounds.width, y: (1 - boundingBox.maxY) * sceneView.bounds.height)
        let size = CGSize(width: boundingBox.width * sceneView.bounds.width, height: boundingBox.height * sceneView.bounds.height)
        
        return CGRect(origin: origin, size: size)
    }
}
