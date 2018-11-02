import UIKit
import SceneKit
import ARKit
import AVKit
import ARVideoKit

extension TaskflowCreatorViewController: RenderARDelegate, RecordARDelegate {
    
    func getVideoRecorderMenuButtons(recording: Bool) -> [[MenuButton]]{
        setupAudio()
        var col0: [MenuButton] = []
        var col1: [MenuButton] = []
        
        col0.append(MenuButton(name: .VIDEO_DONE_RECORDING, image: UIImage(named: "cancel")?.rotated(byDegrees: -90)))
        
        col1.append(MenuButton(name: .VIDEO_RECORDING, image: UIImage(named: !recording ? "videoNote" : "stopRecording")?.rotated(byDegrees: -90)))
        
        return [col0, col1]
    }

    
    func startVideoRecoding() {
        let videoFilename = FilesManager.localFileURL.appendingPathComponent("Files/\(NSUUID().uuidString).mp4")
        
        if !isRecordingVideo {
            if videoRecorder?.status == .readyToRecord {
                recordingQueue.async {
                    self.videoRecorder?.record()
                    self.isRecordingVideo = true
                }
            }
        }
        
        for menuButton in videoRecordingMenuButtons {
            if menuButton.name == CursorTarget.VIDEO_RECORDING.rawValue {
                menuButton.geometry!.firstMaterial?.diffuse.contents = UIImage(named: "stopRecording")?.rotated(byDegrees: -90)
                menuButton.name = CursorTarget.VIDEO_DONE_RECORDING.rawValue
            }
        }
    }
    
    func finishVideoRecording() {
        if isRecordingVideo {
            if videoRecorder?.status == .recording {
                videoRecorder?.stop() { path in
                    self.videoRecorder?.export(video: path) { saved, status in
                        DispatchQueue.main.sync {
                            print("Done Recording")
                            print(path.path)
                        }
                    }
                }
            }
            
            for menuButton in videoRecordingMenuButtons {
                if menuButton.name == CursorTarget.VIDEO_DONE_RECORDING.rawValue {
                    menuButton.geometry!.firstMaterial?.diffuse.contents = UIImage(named: "videoNote")?.rotated(byDegrees: -90)
                    menuButton.name = CursorTarget.VIDEO_RECORDING.rawValue
                }
            }
            isRecordingVideo = false
        }
    
        if videoMenuNode != nil {
            self.videoMenuNode.removeFromParentNode()
            self.videoMenuNode = nil
        }
        noteTaking = .none
    }

    
    // Delegate Function
    func frame(didRender buffer: CVPixelBuffer, with time: CMTime, using rawBuffer: CVPixelBuffer) {
        // Do some image/video processing.
    }
    
    func recorder(didEndRecording path: URL, with noError: Bool) {
        if noError {
            // Do something with the video path.
            steps[currentStep].videoUrl = path.path
            showStepMenu()
            print(path.path)
        } else {
            print("Error Recording")
        }
    }

    func recorder(didFailRecording error: Error?, and status: String) {
        // Inform user an error occurred while recording.
    }
    
    func recorder(willEnterBackground status: RecordARStatus) {
        // Use this method to pause or stop video recording. Check [applicationWillResignActive(_:)](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622950-applicationwillresignactive) for more information.
        if status == .recording {
            videoRecorder?.stopAndExport()
        }
    }
    
    
    
//    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//        steps[currentStep].voiceUrl = recorder.url.path
//        showStepMenu()
//        print(recorder.url.path)
//    }
}
