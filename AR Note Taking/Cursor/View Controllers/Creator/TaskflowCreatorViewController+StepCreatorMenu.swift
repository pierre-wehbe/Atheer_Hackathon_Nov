import ARKit
import Foundation
import SceneKit
import UIKit

extension TaskflowCreatorViewController {

    func getStepsEditorMenuButtons(hasRecord: Bool, hasVideo: Bool, hasAnnotation: Bool, hasPhoto: Bool) -> [[MenuButton]]{
        var col0: [MenuButton] = []
        var col1: [MenuButton] = []
        var col2: [MenuButton] = []

        col0.append(MenuButton(name: .DONE_NOTE, image: UIImage(named: hasRecord ? "voiceNote" : "voiceNoteAdd")?.rotated(byDegrees: -90)))
        
        col1.append(MenuButton(name: .VOICE_NOTE, image: UIImage(named: hasRecord ? "voiceNote" : "voiceNoteAdd")?.rotated(byDegrees: -90)))
        col1.append(MenuButton(name: .VIDEO_NOTE, image: UIImage(named: hasVideo ? "videoNote" : "videoNoteAdd")?.rotated(byDegrees: -90)))
        
        col2.append(MenuButton(name: .PHOTO_NOTE, image: UIImage(named: hasPhoto ? "photoNote" : "photoNoteAdd")?.rotated(byDegrees: -90)))
        col2.append(MenuButton(name: .ANNOTATION_NOTE, image: UIImage(named: hasAnnotation ? "noteTaking" : "noteTakingAdd")?.rotated(byDegrees: -90)))
        
        return [col1, col2]
    }

}
