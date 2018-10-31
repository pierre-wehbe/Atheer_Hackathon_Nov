import Foundation

class FilesManager {
    
    static let shared = FilesManager()
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
}
