import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var counter = 0
    var isOnTarget = false
    var shouldUpdate = true

    var cursorNode: SCNNode!
    var cursorViewManager: CursorView!
    var cursorView: UIView!
    var lastTimerInterval = TimeInterval()

    var menuNode: SCNNode!
    var isMenuVisible = false

    struct CursorView {
        let ON_TARGET_WIDTH = CGFloat(2).toPoint(unit: .mm)
        let OFF_TARGET_WIDTH = CGFloat(1).toPoint(unit: .mm)

        var onTarget: UIView!
        var offTarget: UIView!

        init(sceneView: ARSCNView) {
            onTarget = UIView(frame: CGRect(origin: CGPoint(x: sceneView.center.x - ON_TARGET_WIDTH/2.0, y: sceneView.center.y - 1.0*ON_TARGET_WIDTH), size: CGSize(width: ON_TARGET_WIDTH, height: ON_TARGET_WIDTH)))
            onTarget.backgroundColor = .clear
            onTarget.layer.cornerRadius = ON_TARGET_WIDTH/2.0
            onTarget.layer.masksToBounds = true
            onTarget.layer.borderColor = UIColor.red.cgColor
            onTarget.layer.borderWidth = CGFloat(0.5).toPoint(unit: .mm)
            
            offTarget = UIView(frame: CGRect(origin: CGPoint(x: sceneView.center.x - OFF_TARGET_WIDTH/2.0, y: sceneView.center.y - 1.5*OFF_TARGET_WIDTH), size: CGSize(width: OFF_TARGET_WIDTH, height: OFF_TARGET_WIDTH)))
            offTarget.backgroundColor = .red
            offTarget.layer.cornerRadius = ON_TARGET_WIDTH/2.0
            offTarget.layer.masksToBounds = true
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        cursorNode = createCursor()
        scene.rootNode.addChildNode(cursorNode)

        // Set the scene to the view
        sceneView.scene = scene
        sceneView.session.delegate = self
        
        // Add Tap Gesture
        addTapGestureToSceneView()
        
        // Collision Delegate
        sceneView.scene.physicsWorld.contactDelegate = self
        print(sceneView.scene.physicsWorld.timeStep)
        sceneView.scene.physicsWorld.timeStep = 1/300
        
        // Cursor View
        cursorViewManager = CursorView(sceneView: sceneView)
        
    }

    
    @IBAction func toggleMenu(_ sender: Any) {
        if isMenuVisible {
            DispatchQueue.main.async {
                self.menuNode.removeFromParentNode()
                self.menuNode = nil
            }
            isMenuVisible = !isMenuVisible
            cursorView = cursorViewManager.offTarget
            return
        }
        
        let frame = sceneView.session.currentFrame!
        var toModify = SCNMatrix4(frame.camera.transform)
        let distance: Float = 1
        toModify.m41 -= toModify.m31*distance
        toModify.m42 -= toModify.m32*distance
        toModify.m43 -= toModify.m33*distance
        
        let menuButtonNodes = generateMenuButtonNodes()
        menuNode = SCNNode()
        
        menuNode.setWorldTransform(toModify)
        DispatchQueue.main.async {
            for buttonNode in menuButtonNodes {
                self.menuNode.addChildNode(buttonNode)
            }
            self.sceneView.scene.rootNode.addChildNode(self.menuNode)
        }
        isMenuVisible = !isMenuVisible
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Cursor
        if let view = cursorView {
            view.removeFromSuperview()
        }
        cursorView = cursorViewManager.offTarget
        sceneView.addSubview(cursorView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

// Collision Delegate
extension ViewController: SCNPhysicsContactDelegate {

    struct CollisionCategory {
        let key: Int
        static let cursor = CollisionCategory.init(key: 1 << 0)
        static let virtualNode = CollisionCategory.init(key: 1 << 1)
    }

    func convertNodeToTarget(node: SCNNode) {
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = CollisionCategory.virtualNode.key
        node.physicsBody?.contactTestBitMask = CollisionCategory.cursor.key
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        print("Begin Hit \(counter) between \(nodeA.name) & \(nodeB.name)")
        self.counter += 1
        
        shouldUpdate = !isOnTarget ? true : false
        isOnTarget = true
        updateCursor()
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        print("On going contact")
        shouldUpdate = !isOnTarget ? true : false
        isOnTarget = true
        updateCursor()
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        print("End contact")
        shouldUpdate = isOnTarget ? true : false
        isOnTarget = false
        updateCursor()
    }
    
    func updateCursor() {
        if shouldUpdate {
            if isOnTarget {
                DispatchQueue.main.async {
                    self.cursorView.removeFromSuperview()
                    self.cursorView = self.cursorViewManager.onTarget
                    self.sceneView.addSubview(self.cursorView)
                }
            } else {
                DispatchQueue.main.async {
                    self.cursorView.removeFromSuperview()
                    self.cursorView = self.cursorViewManager.offTarget
                    self.sceneView.addSubview(self.cursorView)
                }
            }
        }
    }
}

// Adding anchors
extension ViewController {
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTapGesture(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didReceiveTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        guard let hitTestResult = sceneView.hitTest(location, types: [.featurePoint, .estimatedHorizontalPlane]).first
            else { return }
        
        
        let anchor = ARAnchor(transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
    }
    
    func generateMenuButtonNodes() -> [SCNNode] {
        let button11 = SCNPlane(width: 0.2, height: 0.2)
        
        
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        layer.backgroundColor = UIColor.orange.cgColor
        
        var textLayer = CATextLayer()
        textLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat(M_PI_2)));
        textLayer.frame = layer.bounds
        textLayer.fontSize = layer.bounds.size.height
        textLayer.string = "Test"
        textLayer.alignmentMode = CATextLayerAlignmentMode.left
        textLayer.foregroundColor = UIColor.green.cgColor
        textLayer.display()
        
        var imageLayer = CALayer()
        imageLayer.contents = UIImage(named: "pierre")?.cgImage
        imageLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat(M_PI_2)));
        imageLayer.contentsGravity = .resizeAspect
        layer.addSublayer(imageLayer)
        
        button11.firstMaterial?.locksAmbientWithDiffuse = true
        button11.firstMaterial?.diffuse.contents = UIImage(named: "pierre")?.rotated(byDegrees: -90)
        let button11Node = SCNNode(geometry: button11)
        button11Node.name = "Button 11"

        
        let button12 = SCNPlane(width: 0.2, height: 0.2)
        button12.firstMaterial?.diffuse.contents = UIColor.yellow
        let button12Node = SCNNode(geometry: button12)
        button12Node.name = "Button 12"
        button12Node.position.x += 0.22

        let button13 = SCNPlane(width: 0.2, height: 0.2)
        button13.firstMaterial?.diffuse.contents = UIColor.purple
        let button13Node = SCNNode(geometry: button13)
        button13Node.name = "Button 13"
        button13Node.position.x += 0.22*2
        
        
        let button21 = SCNPlane(width: 0.2, height: 0.2)
        button21.firstMaterial?.diffuse.contents = UIColor.blue
        let button21Node = SCNNode(geometry: button21)
        button21Node.name = "Button 21"
        button21Node.position.y += 0.22
        
        let button22 = SCNPlane(width: 0.2, height: 0.2)
        button22.firstMaterial?.diffuse.contents = UIColor.white
        let button22Node = SCNNode(geometry: button22)
        button22Node.name = "Button 22"
        button22Node.position.x += 0.22
        button22Node.position.y += 0.22
        
        let button23 = SCNPlane(width: 0.2, height: 0.2)
        button23.firstMaterial?.diffuse.contents = UIColor.orange
        let button23Node = SCNNode(geometry: button23)
        button23Node.name = "Button 23"
        button23Node.position.x += 0.22*2
        button23Node.position.y += 0.22
        
        convertNodeToTarget(node: button11Node)
        convertNodeToTarget(node: button12Node)
        convertNodeToTarget(node: button13Node)
        convertNodeToTarget(node: button21Node)
        convertNodeToTarget(node: button22Node)
        convertNodeToTarget(node: button23Node)
        
        return [button11Node, button12Node, button13Node, button21Node, button22Node, button23Node]
        
    }

    // ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
//        let menuButtonNodes = generateMenuButtonNodes()
//        DispatchQueue.main.async {
//            for buttonNode in menuButtonNodes {
//                node.addChildNode(buttonNode)
//            }
//        }
    }
}

// Cursor Specific
extension ViewController {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let cameraTrans = frame.camera.transform
        var toModify = SCNMatrix4(cameraTrans)
        let distance: Float = 0
        toModify.m41 -= toModify.m31*distance
        toModify.m42 -= toModify.m32*distance
        toModify.m43 -= toModify.m33*distance
        cursorNode.setWorldTransform(toModify)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let deltaTime = time - lastTimerInterval
        if deltaTime > 0.25 {
        }
    }
    
    func createCursor() -> SCNNode {
        let cursorNode = SCNNode()
        cursorNode.name = "cursor"
        let cursor = SCNBox(width: 0.001, height: 0.001, length: 5, chamferRadius: 0)
        cursor.firstMaterial?.diffuse.contents = UIColor.clear
        cursorNode.geometry = cursor
        
        // Physics Body for collision
        cursorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        cursorNode.physicsBody?.isAffectedByGravity = false
        cursorNode.physicsBody?.categoryBitMask = CollisionCategory.cursor.key
        cursorNode.physicsBody?.collisionBitMask = CollisionCategory.virtualNode.key
        return cursorNode
    }
}
