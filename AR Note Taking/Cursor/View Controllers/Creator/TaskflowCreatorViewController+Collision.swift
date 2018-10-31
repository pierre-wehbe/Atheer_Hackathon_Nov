import ARKit
import Foundation
import UIKit

// Collision Delegate
extension TaskflowCreatorViewController: SCNPhysicsContactDelegate {
    
    struct CollisionCategory {
        let key: Int
        static let cursor = CollisionCategory.init(key: 1 << 0)
        static let virtualNode = CollisionCategory.init(key: 1 << 1)
    }
    
    func convertNodeToTarget(node: SCNNode) {
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = CollisionCategory.virtualNode.key
        node.physicsBody?.contactTestBitMask = CollisionCategory.cursor.key
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        print("Begin Hit \(counter) between \(nodeA.name) & \(nodeB.name)")
        self.counter += 1
        shouldUpdate = !isOnTarget ? true : false
        isOnTarget = true
        updateCursor()
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        shouldUpdate = !isOnTarget ? true : false
        isOnTarget = true
        updateCursor()
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        print("End contact")
        shouldUpdate = isOnTarget ? true : false
        isOnTarget = false
        updateCursor()
    }
    
    func updateCursor() {
        if shouldUpdate {
            if isOnTarget {
                DispatchQueue.main.async {
                    self.cursorView.removeFromSuperview()
                    self.cursorView = self.cursorViewManager.onTarget
                    self.sceneView.addSubview(self.cursorView)
                    self.currentTarget = .showTaskflows
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

