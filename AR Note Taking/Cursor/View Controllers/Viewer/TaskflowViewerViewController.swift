import ARKit
import UIKit

class TaskflowViewerViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var currentStepLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!

    var currentTaskflow: Taskflow!
    var steps: [Step]!
    var currentStep = 0
    
    var isMenuVisible = false
    
    // Menu Buttons
    var menuNode: SCNNode!
    var stepMenuNode: SCNNode!
    
    var menuButtonNodes: [SCNNode] = []
    var stepMenuButtons: [SCNNode] = []
    
    //Cursor
    var isOnTarget = false
    var shouldUpdate = true
    
    var cursorNode: SCNNode!
    var cursorViewManager: CursorView!
    var cursorView: UIView!
    var currentTarget: CursorTarget = .none
    
    //Step Viewer
    var isAudioPlaying = false
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        
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
        
        
        // Generate Buttons
        menuButtonNodes = generateMenu(withButtons: getMainMenuButtons())
        
        configureLighting()
    }

    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTrackingConfiguration(with: currentTaskflow.worldMap)
        steps = currentTaskflow.steps
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

    func resetTrackingConfiguration(with worldMap: ARWorldMap? = nil) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        guard let arImages = ARReferenceImage.referenceImages(inGroupNamed: "mediaViewer", bundle: nil) else {return}
        configuration.detectionImages = arImages
        configuration.maximumNumberOfTrackedImages = 1

        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        if let worldMap = worldMap {
            configuration.initialWorldMap = worldMap
            setInstruction(text: "Found saved world map.")
        } else {
            setInstruction(text: "Error: Map Loading Failed")
        }

        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.session.run(configuration, options: options)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
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
    @IBAction func toggleMenu(_ sender: Any) {
        if menuButton.titleLabel?.text == "Done" {
            hideAnnotation()
            return
        }
        toggleMenuHelper()
    }
    
}

extension TaskflowViewerViewController: ARSCNViewDelegate {

    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTapGesture(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didReceiveTapGesture(_ sender: UITapGestureRecognizer) {
        handleCurrentTargetTapped()
    }
    
    func setupVideoOnNode(_ node: SCNNode, fromURL url: URL){
        
        //1. Create An SKVideoNode
        var videoPlayerNode: SKVideoNode!
        
        //2. Create An AVPlayer With Our Video URL
        let videoPlayer = AVPlayer(url: url)
        
        //3. Intialize The Video Node With Our Video Player
        videoPlayerNode = SKVideoNode(avPlayer: videoPlayer)
        videoPlayerNode.yScale = -1
        
        //4. Create A SpriteKitScene & Postion It
        let spriteKitScene = SKScene(size: CGSize(width: 600, height: 300))
        spriteKitScene.scaleMode = .aspectFit
        videoPlayerNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
        videoPlayerNode.size = spriteKitScene.size
        spriteKitScene.addChild(videoPlayerNode)
        
        //6. Set The Nodes Geoemtry Diffuse Contenets To Our SpriteKit Scene
        node.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
        
        //5. Play The Video
        videoPlayerNode.play()
//        videoPlayer.volume = 0
    }
    
    func setUpImageOnNode(_ node: SCNNode, fromURL url: URL) {
        
        let image = UIImage(contentsOfFile: url.path)!
        let texture = SKTexture(image: image)
        let imageNode =  SKSpriteNode(texture: texture)
        imageNode.yScale = -1

        let spriteKitScene = SKScene(size: CGSize(width: 600, height: 300))
        spriteKitScene.scaleMode = .aspectFit
        imageNode.position = CGPoint(x: spriteKitScene.size.width/2, y: spriteKitScene.size.height/2)
        imageNode.size = spriteKitScene.size
        spriteKitScene.addChild(imageNode)

        //6. Set The Nodes Geoemtry Diffuse Contenets To Our SpriteKit Scene
        node.geometry?.firstMaterial?.diffuse.contents = spriteKitScene
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // Also detects when we found our image
        if anchor is ARImageAnchor {
            print("Found an image")
            guard let imageAnchor = anchor as? ARImageAnchor else { return }
            let referenceImage = imageAnchor.referenceImage
            
            //2. Get The Physical Width & Height Of Our Reference Image
            let width = CGFloat(referenceImage.physicalSize.width)
            let height = CGFloat(referenceImage.physicalSize.height)
            
            //3. Create An SCNNode To Hold Our Video Player With The Same Size As The Image Target
            let videoHolder = SCNNode()
            let videoHolderGeometry = SCNPlane(width: width, height: height)
            videoHolder.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
            videoHolder.geometry = videoHolderGeometry
            
            if steps[currentStep].hasVideo() {
                let videoUrl = URL(fileURLWithPath: steps[currentStep].videoUrl)
                setupVideoOnNode(videoHolder, fromURL: videoUrl)
                node.addChildNode(videoHolder)
            } else if steps[currentStep].hasPhoto() {
                let photoUrl = URL(fileURLWithPath: steps[currentStep].photoUrl)
                setUpImageOnNode(videoHolder, fromURL: photoUrl)
                node.addChildNode(videoHolder)
            }
            return
        }
        
        guard !(anchor is ARPlaneAnchor) else { return }
        for step in steps { // Does nothing...
            for pointID in step.annotationPoints {
                if pointID.uuid == anchor.identifier.uuidString {
                    print("This is an annotation, should hide it")
                    //TODO: need to add it to steps nodes list
                    return // do not add it for now
                }
            }
        }
        let stepNode = generateStepNode(withName: getStepName(fromAnchorUUID: anchor.identifier.uuidString, withNode: node))
        stepNode.constraints = [SCNBillboardConstraint()]
        DispatchQueue.main.async {
            node.addChildNode(stepNode)
            self.renameSteps()
        }
    }

    func getStepName(fromAnchorUUID: String, withNode: SCNNode) -> String {
        for step in steps {
            if step.uuid == fromAnchorUUID {
                step.node = withNode
                return step.name
            }
        }
        //Means it is a drawing node
        return "test"
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let cameraTrans = frame.camera.transform
        var toModify = SCNMatrix4(cameraTrans)
        let distance: Float = 0
        toModify.m41 -= toModify.m31*distance
        toModify.m42 -= toModify.m32*distance
        toModify.m43 -= toModify.m33*distance
        cursorNode.setWorldTransform(toModify)
    }
}
