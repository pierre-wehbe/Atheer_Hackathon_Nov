import ARKit
import Foundation
import UIKit

// Cursor Specific

func createCursor() -> SCNNode {
    let cursorNode = SCNNode()
    cursorNode.name = "cursor"
    let cursor = SCNBox(width: 0.001, height: 0.001, length: 5, chamferRadius: 0)
    cursor.firstMaterial?.diffuse.contents = UIColor.clear
    cursorNode.geometry = cursor
    
    // Physics Body for collision
    cursorNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    cursorNode.physicsBody?.isAffectedByGravity = false
    cursorNode.physicsBody?.categoryBitMask = CollisionCategory.cursor.key
    cursorNode.physicsBody?.collisionBitMask = CollisionCategory.virtualNode.key
    return cursorNode
}


extension TaskflowCreatorViewController {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let cameraTrans = frame.camera.transform
        var toModify = SCNMatrix4(cameraTrans)
        let distance: Float = 0
        toModify.m41 -= toModify.m31*distance
        toModify.m42 -= toModify.m32*distance
        toModify.m43 -= toModify.m33*distance
        cursorNode.setWorldTransform(toModify)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let deltaTime = time - lastTimerInterval
        if deltaTime > 0.25 {
        }
    }
}
