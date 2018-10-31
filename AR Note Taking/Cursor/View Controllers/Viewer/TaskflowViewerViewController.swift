import ARKit
import UIKit

class TaskflowViewerViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var instructionLabel: UILabel!

    var currentTaskflow: Taskflow!
    var steps: [Step]!
    var currentStep = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
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
    
    func resetTrackingConfiguration(with worldMap: ARWorldMap? = nil) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
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
    
}

extension TaskflowViewerViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        let stepNode = generateStepNode(withName: getStepName(fromAnchorUUID: anchor.identifier.uuidString))
        stepNode.constraints = [SCNBillboardConstraint()]
        DispatchQueue.main.async {
            node.addChildNode(stepNode)
        }
    }
    
    func getStepName(fromAnchorUUID: String) -> String {
        for step in steps {
            if step.uuid == fromAnchorUUID {
                return step.name
            }
        }
        return "test"
    }
}
