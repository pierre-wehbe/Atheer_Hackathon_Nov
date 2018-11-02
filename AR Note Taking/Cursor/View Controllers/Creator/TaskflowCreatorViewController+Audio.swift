import UIKit
import SceneKit
import ARKit
import AVKit

extension TaskflowCreatorViewController: AVAudioRecorderDelegate {
    
    func voiceModeOn() {
        stepMenuNode.isHidden = true
        noteTaking = .voice
        voiceMenuNode = SCNNode()
        let frame = sceneView.session.currentFrame!
        var toModify = SCNMatrix4(frame.camera.transform)
        let distance: Float = 1
        toModify.m41 -= toModify.m31*distance
        toModify.m42 -= toModify.m32*distance
        toModify.m43 -= toModify.m33*distance
        voiceMenuNode.setWorldTransform(toModify)
        DispatchQueue.main.async {
            for buttonNode in self.voiceRecordingMenuButtons {
                self.voiceMenuNode.addChildNode(buttonNode)
            }
            self.sceneView.scene.rootNode.addChildNode(self.voiceMenuNode)
        }
    }
    
    func getVoiceRecorderMenuButtons(recording: Bool) -> [[MenuButton]]{
        setupAudio()
        var col0: [MenuButton] = []
        var col1: [MenuButton] = []

        col0.append(MenuButton(name: .VOICE_DONE_RECORDING, image: UIImage(named: "cancel")?.rotated(byDegrees: -90)))
        
        col1.append(MenuButton(name: .VOICE_RECORDING, image: UIImage(named: !recording ? "voiceNote" : "stopRecording")?.rotated(byDegrees: -90)))

        return [col0, col1]
    }
    
    
    //Permission
    public func setupAudio() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //load ui if we want to add a UI in the future
                    } else {
                        // failed to record! we can display a fail error message or something
                    }
                }
            }
        } catch {
            print("Error with Audio permissions")
        }
    }
    
    func startVoiceRecoding() {
        let audioFilename = FilesManager.localFileURL.appendingPathComponent("Files/\(NSUUID().uuidString).pcm")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            for menuButton in voiceRecordingMenuButtons {
                if menuButton.name == CursorTarget.VOICE_RECORDING.rawValue {
                    menuButton.geometry!.firstMaterial?.diffuse.contents = UIImage(named: "stopRecording")?.rotated(byDegrees: -90)
                    menuButton.name = CursorTarget.VOICE_DONE_RECORDING.rawValue
                }
            }
        } catch {
            print("Unwanted Behavior")
        }
    }
    
    func finishVoiceRecording() {
        if audioRecorder != nil  {
            audioRecorder.stop()
            for menuButton in voiceRecordingMenuButtons {
                if menuButton.name == CursorTarget.VOICE_DONE_RECORDING.rawValue {
                    menuButton.geometry!.firstMaterial?.diffuse.contents = UIImage(named: "voiceNote")?.rotated(byDegrees: -90)
                    menuButton.name = CursorTarget.VOICE_RECORDING.rawValue
                }
            }
        }
        audioRecorder = nil
        if voiceMenuNode != nil {
            self.voiceMenuNode.removeFromParentNode()
            self.voiceMenuNode = nil
        }
        noteTaking = .none
    }
    
    //Delegate Function
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        steps[currentStep].voiceUrl = recorder.url.path
        showStepMenu()
        print(recorder.url.path)
    }
}
