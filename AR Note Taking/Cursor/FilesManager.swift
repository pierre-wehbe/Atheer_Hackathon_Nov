import Foundation
import UIKit

class FilesManager {
    
    static let shared = FilesManager()
    static let localFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    
    private init(){
        print("Files Manager Initialized")
        loadData() ? print ("Load Successfull") : print("Error: Load unsucessfull")
    }
    
    var taskflows: [Taskflow] = []
    
    private var taskflowsPath: String {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Taskflows").path
    }
    
    public func saveTaskflow(taskflow: Taskflow) -> Bool {
        self.taskflows.append(taskflow)
        return NSKeyedArchiver.archiveRootObject(self.taskflows, toFile: taskflowsPath)
    }
    
    private func loadData() -> Bool {
        if let ourData = NSKeyedUnarchiver.unarchiveObject(withFile: taskflowsPath) as? [Taskflow] {
            self.taskflows = ourData
            return true
        }
        return false
    }
    
    public func printTaskflows() {
        for taskflow in taskflows {
            taskflow.printInfo()
        }
    }
    
    func createFile(localPath: String) {
        let filePath = FilesManager.localFileURL.appendingPathComponent(localPath)
        if !FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                NSLog("Couldn't create document directory")
            }
        }
    }
    
    func saveImage(image: UIImage) -> String {
        let url = FilesManager.localFileURL.appendingPathComponent("Files/\(NSUUID().uuidString).png")
        do {
            try image.pngData()?.write(to: url, options: Data.WritingOptions.atomic)
            return url.path
        } catch {
            print("Error")
        }
        return ""
    }
}
