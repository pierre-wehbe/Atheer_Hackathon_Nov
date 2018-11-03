import ARKit
import Foundation
import SceneKit
import UIKit
import AVKit

extension TaskflowViewerViewController {
    
    func generateMediaPlane(withImage: UIImage) -> [SCNNode] {

        let mediaViewerPlane = SCNPlane(width: 1, height: 1)
        mediaViewerPlane.firstMaterial?.locksAmbientWithDiffuse = true
        mediaViewerPlane.firstMaterial?.diffuse.contents = withImage
        photoNode = SCNNode(geometry: mediaViewerPlane)
        photoNode.name = "MediaNode"

        convertNodesToTarget(nodes: [photoNode])
        
        return [photoNode]
    }
    
    func generateMediaPlane(withVideoUrl: String){
        guard let currentFrame = self.sceneView.session.currentFrame else {
            return
        }
        
        let videoPlayer = AVPlayer(url: URL(fileURLWithPath: withVideoUrl))
        let videoNode = SKVideoNode(avPlayer: videoPlayer)
        videoNode.play()
        
        let skScene = SKScene(size: CGSize(width: 640, height: 480))
        skScene.addChild(videoNode)
        skScene.scaleMode = .aspectFit
        
        videoNode.position = CGPoint(x: skScene.size.width/2, y: skScene.size.height/2)
        videoNode.size = skScene.size
        
        let tvPlane = SCNPlane(width: 1.0, height: 0.75)
        tvPlane.firstMaterial?.diffuse.contents = skScene
        tvPlane.firstMaterial?.isDoubleSided = true
        
        tvPlaneNode = SCNNode(geometry: tvPlane)

        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1.0
        
        tvPlaneNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        tvPlaneNode.eulerAngles = SCNVector3(Double.pi,0,0)
        self.sceneView.scene.rootNode.addChildNode(tvPlaneNode)
    }
}
