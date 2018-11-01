import ARKit
import Foundation
import UIKit

// Collision Delegate
extension TaskflowCreatorViewController: SCNPhysicsContactDelegate {

    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        shouldUpdate = !isOnTarget ? true : false
        isOnTarget = true
        updateCursor(withNode: contact.nodeB)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        shouldUpdate = !isOnTarget ? true : false
        isOnTarget = true
        updateCursor(withNode: contact.nodeB)
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        shouldUpdate = isOnTarget ? true : false
        isOnTarget = false
        updateCursor(withNode: contact.nodeB)
()
    }
    
    func updateCursor(withNode: SCNNode) {
        if shouldUpdate {
            if isOnTarget {
                DispatchQueue.main.async {
                    self.cursorView.removeFromSuperview()
                    self.cursorView = self.cursorViewManager.onTarget
                    self.sceneView.addSubview(self.cursorView)
                    self.currentTarget = getCursorTargetFromNode(node: withNode)
                }
            } else {
                DispatchQueue.main.async {
                    self.cursorView.removeFromSuperview()
                    self.cursorView = self.cursorViewManager.offTarget
                    self.sceneView.addSubview(self.cursorView)
                    self.currentTarget = .none
                }
            }
        }
    }
}

