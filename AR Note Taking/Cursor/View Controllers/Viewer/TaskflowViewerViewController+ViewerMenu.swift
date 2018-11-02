import ARKit
import Foundation
import SceneKit
import UIKit

extension TaskflowViewerViewController {
    func handleCurrentTargetTapped() {
        switch currentTarget {
        case .none:
            print("Off target")
            return
        case .CANCEL_TASKFLOW_EDIT:
            dismiss(animated: true, completion: nil)
            return
        case .NEXT_STEP:
            nextStep(fromButton: true)
            return
        case .PREV_STEP:
            previousStep(fromButton: true)
            return
        case .VOICE_COMMAND:
            toggleVoiceCommand()
            return
        case .STEP_NODE:
            print("This is a step")
            viewStep()
            return
            
        case .DONE_NOTE:
            exitStepViewer()
            return
        case .PHOTO_NOTE:
            print("This is a photonote")
            return
        case .VIDEO_NOTE:
            print("This is a videonote")
            return
        case .VOICE_NOTE:
            print("This is a voicenote")
            return
        case .ANNOTATION_NOTE:
            print("This is a annotationnote")
            return
            
        default:
            return
        }
    }
    
    func exitStepViewer() {
        if stepMenuNode == nil {
            return
        }
        showAllsteps()
        
        self.stepMenuNode.removeFromParentNode()
        self.stepMenuNode = nil
        
        menuButton.isHidden = false
    }
    
    func viewStep() {
        hideAllsteps()
        menuButton.isHidden = true
        if isMenuVisible {
            toggleMenuHelper()
        }
        showStepMenu()
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
        stepMenuButtons = generateMenu(withButtons: getStepsEditorMenuButtons(hasRecord: step.hasVoice(), hasVideo: step.hasVideo(), hasAnnotation: step.hasAnnotation(), hasPhoto: step.hasPhoto()))
        
        DispatchQueue.main.async {
            for buttonNode in self.stepMenuButtons {
                self.stepMenuNode.addChildNode(buttonNode)
            }
            self.sceneView.scene.rootNode.addChildNode(self.stepMenuNode)
        }
    }
    
    func hideAllsteps() {
        for step in steps {
            step.node.isHidden = true
        }
    }
    
    func showAllsteps() {
        for step in steps {
            step.node.isHidden = false
        }
    }

    func renameSteps() {
        var index = 1
        for step in steps {
            step.name = "Step \(index)"
            if let stepNode = step.node.childNodes.first {
                updateApparence(ofStepNode: stepNode, toColor: ((index - 1) == currentStep) ? getSecondaryColor() : getMainColor(), withText: step.name)
            } else {
                return
            }
            index += 1
        }
    }

    func nextStep(fromButton: Bool = false) {
        print("nextStep")
        
        if steps.isEmpty {
            DispatchQueue.main.async {
                self.currentStepLabel.text = ""
            }
            return
        }
        
        let previousStep = currentStep
        currentStep = currentStep == steps.count - 1 ? currentStep : currentStep + 1
        let nextStep = currentStep
        
        if fromButton {
            if previousStep != nextStep {
                updateApparence(ofStepNode: steps[previousStep].node.childNodes.first!, toColor: getMainColor(), withText: steps[previousStep].name)
                updateApparence(ofStepNode: steps[nextStep].node.childNodes.first!, toColor: getSecondaryColor(), withText: steps[nextStep].name)
            }
        }
        
        DispatchQueue.main.async {
            self.currentStepLabel.text = "Step \(self.currentStep + 1)"
        }
    }
    
    func updateApparence(ofStepNode: SCNNode, toColor: UIColor, withText: String) {
        for child in  ofStepNode.childNodes {
            if child.geometry is SCNText {
                (child.geometry! as! SCNText).string = withText
                let maxX = child.boundingBox.max.x
                let minX = child.boundingBox.min.x
                child.pivot = SCNMatrix4MakeTranslation((maxX - minX) / 2, 0, 0);
            } else if child.geometry is SCNSphere {
                (child.geometry! as! SCNSphere).firstMaterial?.diffuse.contents = toColor
            }
        }
    }
    
    func previousStep(fromButton: Bool = false) {
        print("previousStep")
        if steps.isEmpty {
            DispatchQueue.main.async {
                self.currentStepLabel.text = ""
            }
            return
        }
        
        let previousStep = currentStep
        currentStep = currentStep == 0 ? 0 : currentStep - 1
        let nextStep = currentStep
        
        if fromButton {
            if previousStep != nextStep {
                updateApparence(ofStepNode: steps[previousStep].node.childNodes.first!, toColor: getMainColor(), withText: steps[previousStep].name)
                updateApparence(ofStepNode: steps[nextStep].node.childNodes.first!, toColor: getSecondaryColor(), withText: steps[nextStep].name)
            }
        }
        
        
        DispatchQueue.main.async {
            self.currentStepLabel.text = "Step \(self.currentStep + 1)"
        }
        
    }
    
    //TODO: Need to delete the taskflow itself when in editing mode
    func deleteTaskflow() {
        print("deleteTaskflow")
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveTaskflow() {
        print("saveTaskflow")
        if steps.count == 0 {
            setInstruction(text: "Please create at least one step in this taskflow")
            return
        }
        
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else {
                return self.setInstruction(text: "Error getting current world map")
            }
            self.showAlertView(worldMap: worldMap)
        }
    }

    func showAlertView(worldMap: ARWorldMap) {
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "New Taskflow", message: "Name that taskflow", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Save", style: .default) { (_) in
            //getting the input values from user
            if let name = alertController.textFields?[0].text {
                if FilesManager.shared.saveTaskflow(taskflow: Taskflow(name: name, worldMap: worldMap, image: UIImage(), steps: self.steps)) {
                    DispatchQueue.main.async {
                        self.setInstruction(text: "Taskflow is saved.")
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.setInstruction(text: "Error: Taskflow not saved.")
                    }
                }
            }
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "My first taskflow"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func toggleVoiceCommand() {
        print("toggleVoiceCommand")
    }
    
    func getMainMenuButtons() -> [[MenuButton]]{
        var col1: [MenuButton] = []
        var col2: [MenuButton] = []
        
        col1.append(MenuButton(name: .CANCEL_TASKFLOW_EDIT, image: UIImage(named: "cancel")?.rotated(byDegrees: -90)))
        col1.append(MenuButton(name: .PREV_STEP, image: UIImage(named: "previous")?.rotated(byDegrees: -90)))

        col2.append(MenuButton(name: .VOICE_COMMAND, image: UIImage(named: "voiceCommand")?.rotated(byDegrees: -90)))
        col2.append(MenuButton(name: .NEXT_STEP, image: UIImage(named: "next")?.rotated(byDegrees: -90)))

        return [col1, col2]
    }
}
