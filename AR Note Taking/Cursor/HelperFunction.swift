import ARKit
import Foundation
import UIKit

func conv(_ n: Float) -> String {
    return String(format: "%.02f", n)
}

func getMainColor() -> UIColor {
    return UIColor(red: 38 / 255, green: 135 / 255, blue: 134 / 255, alpha: 1)
}

func convertNodesToTarget(nodes: [SCNNode]) {
    for node in nodes {
        node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = CollisionCategory.virtualNode.key
        node.physicsBody?.contactTestBitMask = CollisionCategory.cursor.key
    }
}

extension UIImage {
    
    func rotated(byDegrees degree: Double) -> UIImage {
        let radians = CGFloat(degree * .pi) / 180.0 as CGFloat
        let rotatedSize = self.size
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, scale)
        let bitmap = UIGraphicsGetCurrentContext()
        bitmap?.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        bitmap?.rotate(by: radians)
        bitmap?.scaleBy(x: 1.0, y: -1.0)
        bitmap?.draw(
            self.cgImage!,
            in: CGRect.init(x: -self.size.width / 2, y: -self.size.height / 2 , width: self.size.width, height: self.size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return newImage!
    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
