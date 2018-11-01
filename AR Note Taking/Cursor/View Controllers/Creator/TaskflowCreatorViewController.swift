import UIKit
import SceneKit
import ARKit

class TaskflowCreatorViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var currentStepLabel: UILabel!
    
    
    var isOnTarget = false
    var shouldUpdate = true

    var cursorNode: SCNNode!
    var cursorViewManager: CursorView!
    var cursorView: UIView!
    var lastTimerInterval = TimeInterval()
    
    var menuNode: SCNNode!
    var stepMenuNode: SCNNode!
    
    var isMenuVisible = false
    var isStepMenuVisible = false

    var currentTarget: CursorTarget = .none

    var isCreatingStep = false
    
    // Initial Steps
    var steps: [Step] = []
    var currentStep: Int = 0
    
    // Menu Buttons
    var menuButtonNodes: [SCNNode] = []
    var stepMenuButtons: [SCNNode] = []

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
        sceneView.scene.physicsWorld.timeStep = 1/300
        
        // Cursor View
        cursorViewManager = CursorView(sceneView: sceneView)
        
        configureLighting()
        
        // Generate Buttons
        menuButtonNodes = generateMenu(withButtons: getMainMenuButtons())
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    @IBAction func toggleMenu(_ sender: Any) {
        if menuButton.titleLabel?.text == "Done" {
            menuButton.titleLabel?.text = "Menu"
            isMenuVisible = false
            isCreatingStep = false
            return
        }

       toggleMenuHelper()
    }
    
    func toggleMenuHelper() {
        if isMenuVisible {
            cursorView = cursorViewManager.offTarget
            DispatchQueue.main.async {
                self.menuNode.removeFromParentNode()
                self.menuNode = nil
            }
            isMenuVisible = !isMenuVisible
            return
        }
        
        let frame = sceneView.session.currentFrame!
        var toModify = SCNMatrix4(frame.camera.transform)
        let distance: Float = 1
        toModify.m41 -= toModify.m31*distance
        toModify.m42 -= toModify.m32*distance
        toModify.m43 -= toModify.m33*distance
        
        menuNode = SCNNode()
        menuNode.setWorldTransform(toModify)
        
        DispatchQueue.main.async {
            for buttonNode in self.menuButtonNodes {
                self.menuNode.addChildNode(buttonNode)
            }
            self.sceneView.scene.rootNode.addChildNode(self.menuNode)
        }
        isMenuVisible = !isMenuVisible
    }
    
    func showStepMenu() {
        let frame = sceneView.session.currentFrame!
        var toModify = SCNMatrix4(frame.camera.transform)
        let distance: Float = 1
        toModify.m41 -= toModify.m31*distance
        toModify.m42 -= toModify.m32*distance
        toModify.m43 -= toModify.m33*distance
        
        stepMenuNode = SCNNode()
        stepMenuNode.setWorldTransform(toModify)
        
        let step = steps[currentStep]
        stepMenuButtons = generateMenu(withButtons: self.getStepsEditorMenuButtons(hasRecord: step.hasVoice(), hasVideo: step.hasVideo(), hasAnnotation: step.hasAnnotation(), hasPhoto: step.hasPhoto()))

        DispatchQueue.main.async {
            for buttonNode in self.stepMenuButtons {
                self.stepMenuNode.addChildNode(buttonNode)
            }
            self.sceneView.scene.rootNode.addChildNode(self.stepMenuNode)
        }
        isStepMenuVisible = true
    }
    
    func hideAllSteps() {
        for step in steps {
            step.node.isHidden = true
        }
    }
    
    func showAllSteps() {
        for step in steps {
            step.node.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTrackingConfiguration()
    }

    func resetTrackingConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        setInstruction(text: "Move camera around to map your surrounding space.")
        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.session.run(configuration, options: options)
    }
    
    func setInstruction(text: String) {
        UIView.animate(withDuration: 1, animations: {
            self.instructionLabel.text = text
        }) { (true) in
            //Wait 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                UIView.animate(withDuration: 1) {
                    self.instructionLabel.text = ""
                }
            })
        }
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
        if isCreatingStep {
            let location = sender.location(in: sceneView)
    
            guard let hitTestResult = sceneView.hitTest(location, types: [.featurePoint, .estimatedHorizontalPlane]).first
                else { return }
            let stepAnchor = ARAnchor(transform: hitTestResult.worldTransform)
            sceneView.session.add(anchor: stepAnchor)
        } else {
            handleCurrentTargetTapped()
        }
    }

    // ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        addNewStep(newStep: Step(uuid: anchor.identifier.uuidString, node: node))
        let stepNode = generateStepNode()
        stepNode.constraints = [SCNBillboardConstraint()] // So that the node always faces the user

        DispatchQueue.main.async {
            node.addChildNode(stepNode)
            self.renameSteps()
        }
    }
}
