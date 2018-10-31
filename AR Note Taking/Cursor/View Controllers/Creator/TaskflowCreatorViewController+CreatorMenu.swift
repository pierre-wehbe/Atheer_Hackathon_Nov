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
        default:
            return
        }
    }
    
    
    
    func cancelTaskflowChanges() {
        print("cancelTaskflowChanges")
    }
    
    func createNewStep() {
        print("createNewStep")
    }
    
    func deleteCurrentStep() {
        print("deleteCurrentStep")
    }
    
    func nextStep() {
        print("nextStep")
    }
    
    func previousStep() {
        print("previousStep")
    }
    
    func deleteTaskflow() {
        print("deleteTaskflow")
    }
    
    func saveTaskflow() {
        print("saveTaskflow")
    }
    
    func toggleVoiceCommand() {
        print("toggleVoiceCommand")
    }
    
    func getMainMenuButtons() -> [[MenuButton]]{
        var col1: [MenuButton] = []
        var col2: [MenuButton] = []
        
        col1.append(MenuButton(name: .CANCEL_TASKFLOW_EDIT))
        col1.append(MenuButton(name: .PREV_STEP, image: UIImage(named: "pierre")?.rotated(byDegrees: -90)))
        col1.append(MenuButton(name: .DELETE_STEP))
        col1.append(MenuButton(name: .SAVE_TASKFLOW))
        
        col2.append(MenuButton(name: .VOICE_COMMAND))
        col2.append(MenuButton(name: .NEXT_STEP))
        col2.append(MenuButton(name: .CREATE_STEP))
        col2.append(MenuButton(name: .DELETE_TASKFLOW))
        
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
