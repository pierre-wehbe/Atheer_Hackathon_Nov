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
    case VOICE_NOTE = "Voice Note"
    case VIDEO_NOTE = "Video Note"
    case PHOTO_NOTE = "Photo Note"
    case ANNOTATION_NOTE = "Annotation Note"
    case DONE_NOTE = "Done Note"
    
    // Audio Note
    case VOICE_RECORDING = "Record Voice"
    case VOICE_DONE_RECORDING = "Stop Record Voice"
    
    // Video Note
    case VIDEO_RECORDING = "Record Video"
    case VIDEO_DONE_RECORDING = "Stop Record Video"
    
    // Note Taking
    case ANNOTATION_NODE = "Annotation Node"
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
            
        case CursorTarget.VOICE_RECORDING.rawValue:
            return CursorTarget.VOICE_RECORDING
        case CursorTarget.VOICE_DONE_RECORDING.rawValue:
            return CursorTarget.VOICE_DONE_RECORDING
            
        case CursorTarget.VIDEO_RECORDING.rawValue:
            return CursorTarget.VIDEO_RECORDING
        case CursorTarget.VIDEO_DONE_RECORDING.rawValue:
            return CursorTarget.VIDEO_DONE_RECORDING
            
        case CursorTarget.ANNOTATION_NODE.rawValue:
            return CursorTarget.ANNOTATION_NODE

        default:
            CursorTarget.none
        }
    }
    return CursorTarget.none
}
