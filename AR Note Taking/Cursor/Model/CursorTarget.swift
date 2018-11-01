import Foundation
import SceneKit

enum CursorTarget: String {
    case none = "none"
    
    // Taskflow Creator
    case CANCEL_TASKFLOW_EDIT = "Cancel Changes"
    case VOICE_COMMAND = "Voice Command"
    case PREV_STEP = "Previous Step"
    case NEXT_STEP = "Next Step"
    case DELETE_STEP = "Delete Step"
    case CREATE_STEP = "Create New Step"
    case SAVE_TASKFLOW = "Save changes"
    case DELETE_TASKFLOW = "Delete Taskfloww"
    case STEP_NODE = "Step Node"
    
    // Step Creator
    case VOICE_NOTE = "Voice Node"
    case VIDEO_NOTE = "Video Node"
    case PHOTO_NOTE = "Photo Node"
    case ANNOTATION_NOTE = "Annotation Node"
    case DONE_NOTE = "Done Note"
    
}

func getCursorTargetFromNode(node: SCNNode) -> CursorTarget {
    if let name = node.name {
        switch name {
        case CursorTarget.none.rawValue:
            return CursorTarget.none
        case CursorTarget.CANCEL_TASKFLOW_EDIT.rawValue:
            return CursorTarget.CANCEL_TASKFLOW_EDIT
        case CursorTarget.VOICE_COMMAND.rawValue:
            return CursorTarget.VOICE_COMMAND
        case CursorTarget.PREV_STEP.rawValue:
            return CursorTarget.PREV_STEP
        case CursorTarget.NEXT_STEP.rawValue:
            return CursorTarget.NEXT_STEP
        case CursorTarget.DELETE_STEP.rawValue:
            return CursorTarget.DELETE_STEP
        case CursorTarget.CREATE_STEP.rawValue:
            return CursorTarget.CREATE_STEP
        case CursorTarget.SAVE_TASKFLOW.rawValue:
            return CursorTarget.SAVE_TASKFLOW
        case CursorTarget.DELETE_TASKFLOW.rawValue:
            return CursorTarget.DELETE_TASKFLOW
            
        case CursorTarget.STEP_NODE.rawValue:
            return CursorTarget.STEP_NODE
            
        case CursorTarget.VIDEO_NOTE.rawValue:
            return CursorTarget.VIDEO_NOTE
        case CursorTarget.VOICE_NOTE.rawValue:
            return CursorTarget.VOICE_NOTE
        case CursorTarget.ANNOTATION_NOTE.rawValue:
            return CursorTarget.ANNOTATION_NOTE
        case CursorTarget.PHOTO_NOTE.rawValue:
            return CursorTarget.PHOTO_NOTE
        case CursorTarget.DONE_NOTE.rawValue:
            return CursorTarget.DONE_NOTE

        default:
            CursorTarget.none
        }
    }
    return CursorTarget.none
}
