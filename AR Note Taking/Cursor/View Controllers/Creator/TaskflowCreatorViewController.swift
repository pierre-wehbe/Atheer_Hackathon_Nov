import UIKit
import SceneKit
import ARKit

class TaskflowCreatorViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
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
    
    enum CursorTarget {
        case none
        case showTaskflows
    }
    
    var currentTarget: CursorTarget = .none
    
    
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}


// Adding anchors
extension TaskflowCreatorViewController {
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTapGesture(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didReceiveTapGesture(_ sender: UITapGestureRecognizer) {
        if currentTarget == .showTaskflows {
            showTaskflows()
        }
        //        let location = sender.location(in: sceneView)
        //
        //        guard let hitTestResult = sceneView.hitTest(location, types: [.featurePoint, .estimatedHorizontalPlane]).first
        //            else { return }
        //
        //
        //        let anchor = ARAnchor(transform: hitTestResult.worldTransform)
        //        sceneView.session.add(anchor: anchor)
    }
    
    func showTaskflows() {
        print("Showing Taskflows")
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

