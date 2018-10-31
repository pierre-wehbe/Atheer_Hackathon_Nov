import ARKit
import Foundation

extension TaskflowCreatorViewController {
    func generateStepNode() -> SCNNode {
        let result = SCNNode()
        
        let sphere = SCNSphere(radius: 0.05)
        sphere.firstMaterial?.diffuse.contents = getMainColor()
        let stepNode = SCNNode(geometry: sphere)
        stepNode.name = CursorTarget.STEP_NODE.rawValue
        convertNodesToTarget(nodes: [stepNode])
        
        let text = SCNText(string: steps[currentStep].name, extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.flatness = 0.01
        text.firstMaterial?.diffuse.contents = getMainColor()
        let textNode = SCNNode(geometry: text)
        let fontSize = Float(0.04)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        let maxY = sphere.boundingBox.max.y
        let minY = sphere.boundingBox.min.y

        let maxX = textNode.boundingBox.max.x
        let minX = textNode.boundingBox.min.x
        textNode.position.y += (maxY-minY)/2.0
        textNode.pivot = SCNMatrix4MakeTranslation((maxX - minX) / 2, 0, 0);
        
        result.addChildNode(textNode)
        result.addChildNode(stepNode)

        return result
    }
}

extension TaskflowViewerViewController {
    func generateStepNode(withName: String) -> SCNNode {
        let result = SCNNode()
        
        let sphere = SCNSphere(radius: 0.05)
        sphere.firstMaterial?.diffuse.contents = getMainColor()
        let stepNode = SCNNode(geometry: sphere)
        stepNode.name = CursorTarget.STEP_NODE.rawValue
        convertNodesToTarget(nodes: [stepNode])
        
        let text = SCNText(string: withName, extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.flatness = 0.01
        text.firstMaterial?.diffuse.contents = getMainColor()
        let textNode = SCNNode(geometry: text)
        let fontSize = Float(0.04)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        let maxY = sphere.boundingBox.max.y
        let minY = sphere.boundingBox.min.y
        
        let maxX = textNode.boundingBox.max.x
        let minX = textNode.boundingBox.min.x
        textNode.position.y += (maxY-minY)/2.0
        textNode.pivot = SCNMatrix4MakeTranslation((maxX - minX) / 2, 0, 0);
        
        result.addChildNode(textNode)
        result.addChildNode(stepNode)
        
        return result
    }
}

