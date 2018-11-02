import UIKit
import SceneKit
import ARKit

extension TaskflowCreatorViewController {
    
    func annotationModeOn() {
        menuButton.isHidden = false
        stepMenuNode.isHidden = true
        noteTaking = .annotation
        menuButton.setTitle("Fire", for: .normal)
    }
    
    func doneAnnotating() {
        // Save Annotation and Hide it
        hideAnnotation()
        menuButton.setTitle("Menu", for: .normal)
        menuButton.isHidden = true
        noteTaking = .none
        showStepMenu()
    }
    
    func hideAnnotation() {
        print("Number of noes")
        print(steps[currentStep].annotationNodes.count)
        DispatchQueue.main.async {
            for node in self.steps[self.currentStep].annotationNodes {
                node.isHidden = true
            }
        }
    }
    
    func showAnnotation() {
        for node in steps[currentStep].annotationNodes {
            node.isHidden = false
        }
    }
}
