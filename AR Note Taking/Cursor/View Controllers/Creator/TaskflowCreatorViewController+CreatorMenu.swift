import ARKit
import Foundation
import SceneKit
import UIKit

extension TaskflowCreatorViewController {
    func handleCurrentTargetTapped() {
        switch currentTarget {
        case .none:
            print("Off target")
            return
        case .CANCEL_TASKFLOW_EDIT:
            cancelTaskflowChanges()
            return
        case .CREATE_STEP:
            createNewStep()
            return
        case .DELETE_STEP:
            deleteCurrentStep()
            return
        case .NEXT_STEP:
            nextStep(fromButton: true)
            return
        case .PREV_STEP:
            previousStep(fromButton: true)
            return
        case .DELETE_TASKFLOW:
            deleteTaskflow()
            return
        case .SAVE_TASKFLOW:
            saveTaskflow()
            return
        case .VOICE_COMMAND:
            toggleVoiceCommand()
            return
        case .STEP_NODE:
            print("This is a step")
            editStepNode()
            return
            
            
        case .DONE_NOTE:
            print("Done Taking Note")
            doneEditingStep()
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
            
        }
    }
    
    func editStepNode() {
        menuButton.isHidden = true
        hideAllSteps()
        if isMenuVisible {
            toggleMenuHelper()
        }
        showStepMenu()
    }

    func doneEditingStep() {
        isStepMenuVisible = false
        showAllSteps()
        DispatchQueue.main.async {
            self.stepMenuNode.removeFromParentNode()
            self.stepMenuNode = nil
        }
        menuButton.isHidden = false
    }
    
    func cancelTaskflowChanges() {
        print("cancelTaskflowChanges")
        self.dismiss(animated: true, completion: nil)
    }
    
    func createNewStep() {
        print("createNewStep")
        toggleMenuHelper() // hide menu
        isCreatingStep = true
        menuButton.titleLabel?.text = "Done" // change title
    }

    func addNewStep(newStep: Step) {
        if currentStep == steps.count - 1 {
            steps.append(newStep)
        } else {
            steps.insert(newStep, at: currentStep)
        }
        nextStep()
    }
    
    func deleteCurrentStep() {
        print("deleteCurrentStep")
        if steps.count == 0 {
            print("No steps to be deleted")
            return
        }
        
        // Remove step anchor
        sceneView.session.remove(anchor: sceneView.anchor(for: steps[currentStep].node)!)
        
        //If deleted last step
        if currentStep == steps.count - 1 {
            steps.remove(at: currentStep)
            previousStep()
        } else {
            steps.remove(at: currentStep)
        }
        
        if steps.isEmpty { // Nothing to rename
            currentStep = 0
            DispatchQueue.main.async {
                self.currentStepLabel.text = ""
            }
            return
        }
        renameSteps()
    }
    
    func renameSteps() {
        var index = 1
        for step in steps {
            step.name = "Step \(index)"
            let stepNode = step.node.childNodes.first!
            updateApparence(ofStepNode: stepNode, toColor: ((index - 1) == currentStep) ? getSecondaryColor() : getMainColor(), withText: step.name)
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
        col1.append(MenuButton(name: .DELETE_STEP, image: UIImage(named: "deleteStep")?.rotated(byDegrees: -90)))
        col1.append(MenuButton(name: .SAVE_TASKFLOW, image: UIImage(named: "save")?.rotated(byDegrees: -90)))
        col2.append(MenuButton(name: .VOICE_COMMAND, image: UIImage(named: "voiceCommand")?.rotated(byDegrees: -90)))
        col2.append(MenuButton(name: .NEXT_STEP, image: UIImage(named: "next")?.rotated(byDegrees: -90)))
        col2.append(MenuButton(name: .CREATE_STEP, image: UIImage(named: "createStep")?.rotated(byDegrees: -90)))
        col2.append(MenuButton(name: .DELETE_TASKFLOW, image: UIImage(named: "delete")?.rotated(byDegrees: -90)))
        
        return [col1, col2]
    }
    
    func generateMenu(withButtons: [[MenuButton]]) -> [SCNNode] {
        // Should be given in columns
        var results: [SCNNode] = []
        
        var colIndex: Double = 0
        var rowIndex: Double = 0
        for col in withButtons {
            rowIndex = 0
            for row in col {
                let buttonGeo = SCNPlane(width: 0.2, height: 0.2)
                buttonGeo.firstMaterial?.locksAmbientWithDiffuse = true
                buttonGeo.firstMaterial?.diffuse.contents = row.image == nil ? getMainColor().cgColor : row.image!
                let buttonNode = SCNNode(geometry: buttonGeo)
                buttonNode.name = row.name.rawValue
                buttonNode.position.x += Float(rowIndex * 0.22)
                buttonNode.position.y += Float(colIndex * 0.22)
                results.append(buttonNode)
                rowIndex += 1
            }
            colIndex += 1
        }
        
        convertNodesToTarget(nodes: results)
//        results.append(createInstructionNode())
    
        return results
    }
    
//    func createInstructionNode() -> SCNNode {
//        let buttonGeo = SCNPlane(width: 0.1, height: 0.42)
//        buttonGeo.firstMaterial?.locksAmbientWithDiffuse = true
//
//
//        let layer = CALayer()
//        layer.frame = CGRect(x: 0, y: 0, width: 14, height: 100)
//        layer.backgroundColor = getMainColor().cgColor
//
//        var textLayer = CATextLayer()
//        textLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(rotationAngle: CGFloat(M_PI_2)));
//        textLayer.frame = layer.bounds
//        textLayer.fontSize = 12
//        textLayer.string = "Step 1"
//        textLayer.alignmentMode = CATextLayerAlignmentMode.center
//        textLayer.foregroundColor = UIColor.white.cgColor
//
//        layer.addSublayer(textLayer)
//
//        buttonGeo.firstMaterial?.diffuse.contents = layer
//
//
//        let buttonNode = SCNNode(geometry: buttonGeo)
//        buttonNode.name = "Instruction"
//        buttonNode.position.x -= Float(0.2)
//        buttonNode.position.y += Float(0.11)
//        return buttonNode
//    }
}
