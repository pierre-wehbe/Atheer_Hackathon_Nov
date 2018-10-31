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
            nextStep()
            return
        case .PREV_STEP:
            previousStep()
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
            return
        }
    }
    
    func cancelTaskflowChanges() {
        print("cancelTaskflowChanges")
        self.dismiss(animated: true, completion: nil)
    }
    
    func createNewStep() {
        print("createNewStep")
        isCreatingStep = true
        toggleMenu(self)
        menuButton.titleLabel?.text = "Done"
        cursorView = cursorViewManager.addStepNode
    }

    func addNewStep(newStep: Step) {
        if currentStep == steps.count - 1 {
            steps.append(newStep)
            currentStep += 1
        } else {
            steps.insert(Step(), at: currentStep)
        }
        renameSteps()
    }
    
    func deleteCurrentStep() {
        print("deleteCurrentStep")
        if steps.count == 0 {
            print("No steps to be deleted")
            return
        }
        
        //If deleted last step
        if currentStep == steps.count - 1 {
            steps.remove(at: currentStep)
            currentStep -= 1
        } else {
            steps.remove(at: currentStep)
        }
        
        if steps.isEmpty {
            currentStep = 0
            return
        }
        renameSteps()
    }
    
    func renameSteps() {
        var index = 1
        for step in steps {
            step.name = "Step \(index)"
            index += 1
        }
    }

    func nextStep() {
        print("nextStep")
        currentStep = currentStep == steps.count - 1 ? currentStep : currentStep + 1
    }
    
    func previousStep() {
        print("previousStep")
        currentStep = currentStep == 0 ? 0 : currentStep - 1
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
        
        //        let button11 = SCNPlane(width: 0.2, height: 0.2)
        //        button11.firstMaterial?.locksAmbientWithDiffuse = true
        //        button11.firstMaterial?.diffuse.contents = UIImage(named: "pierre")?.rotated(byDegrees: -90)
        //        let button11Node = SCNNode(geometry: button11)
        //        button11Node.name = "Button 11"
        
        convertNodesToTarget(nodes: results)
        return results
        
    }
}
