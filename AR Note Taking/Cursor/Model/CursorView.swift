import ARKit
import UIKit

struct CursorView {
    let ON_TARGET_WIDTH = CGFloat(2).toPoint(unit: .mm)
    let OFF_TARGET_WIDTH = CGFloat(1).toPoint(unit: .mm)

    var onTarget: UIView!
    var offTarget: UIView!
    
    var addStepNode: UIView!
    
    init(sceneView: ARSCNView) {
        onTarget = UIView(frame: CGRect(origin: CGPoint(x: sceneView.center.x - ON_TARGET_WIDTH/2.0, y: sceneView.center.y - 1.0*ON_TARGET_WIDTH), size: CGSize(width: ON_TARGET_WIDTH, height: ON_TARGET_WIDTH)))
        onTarget.backgroundColor = .clear
        onTarget.layer.cornerRadius = ON_TARGET_WIDTH/2.0
        onTarget.layer.masksToBounds = true
        onTarget.layer.borderColor = UIColor.red.cgColor
        onTarget.layer.borderWidth = CGFloat(0.5).toPoint(unit: .mm)
        
        offTarget = UIView(frame: CGRect(origin: CGPoint(x: sceneView.center.x - OFF_TARGET_WIDTH/2.0, y: sceneView.center.y - 1.5*OFF_TARGET_WIDTH), size: CGSize(width: OFF_TARGET_WIDTH, height: OFF_TARGET_WIDTH)))
        offTarget.backgroundColor = .red
        offTarget.layer.cornerRadius = ON_TARGET_WIDTH/2.0
        offTarget.layer.masksToBounds = true
        
        addStepNode = UIView(frame: CGRect(origin: CGPoint(x: sceneView.center.x - ON_TARGET_WIDTH/2.0, y: sceneView.center.y - 1.0*ON_TARGET_WIDTH), size: CGSize(width: ON_TARGET_WIDTH, height: ON_TARGET_WIDTH)))
        addStepNode.backgroundColor = .clear
        addStepNode.layer.cornerRadius = ON_TARGET_WIDTH/2.0
        addStepNode.layer.masksToBounds = true
        addStepNode.layer.borderColor = getMainColor().cgColor
        addStepNode.layer.borderWidth = CGFloat(0.5).toPoint(unit: .mm)
    }
    
}
