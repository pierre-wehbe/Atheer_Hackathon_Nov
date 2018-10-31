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
        default:
            break
        }
    }
    return CursorTarget.none
}
