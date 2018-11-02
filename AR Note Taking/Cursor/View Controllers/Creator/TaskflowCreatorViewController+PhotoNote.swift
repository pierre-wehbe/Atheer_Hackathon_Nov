import UIKit
import SceneKit
import ARKit
import Vision

extension TaskflowCreatorViewController {
    
    func photoModeOn() {
        stepMenuNode.isHidden = true
        noteTaking = .photo
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        seconds -= 1     //This will decrement(count down)the seconds.
        if seconds < 0 {
            noteTaking = .none
            timer.invalidate()
            DispatchQueue.main.async {
                self.timerLabel.text = ""
                self.timerLabel.isHidden = true
            }
            print("Take Picture")
            let imageNote = self.sceneView.snapshot()
            steps[currentStep].photoUrl = FilesManager.shared.saveImage(image: imageNote)
            showStepMenu()
            return
        }
        DispatchQueue.main.async {
            self.timerLabel.text = "\(self.seconds)"
        }
    }

    func resetTimer() {
        timer.invalidate()
        seconds = 3
        DispatchQueue.main.async {
            self.timerLabel.text = "\(self.seconds)"
            self.timerLabel.isHidden = false
        }
        runTimer()
    }
}
