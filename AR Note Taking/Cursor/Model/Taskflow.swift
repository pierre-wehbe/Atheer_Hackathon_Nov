import Foundation
import ARKit

class Taskflow: NSObject, NSCoding {
    
    struct Keys {
        static let UUID = "uuid"
        static let NAME = "name"
        static let WORLD_MAP = "world_map"
        static let IMAGE = "image"
        static let STEPS = "steps"
    }
    
    //MARK: Attributes
    private var _uuid: String = ""
    private var _name: String = ""
    private var _worldMap: ARWorldMap? = nil
    private var _thumbnailImage: UIImage? = nil
    private var _steps: [Step] = []
    
    //Constructor
    init(name: String, worldMap: ARWorldMap, image: UIImage, steps: [Step]) {
        self._uuid = NSUUID().uuidString
        self._name = name
        self._worldMap = worldMap
        self._thumbnailImage = image
        self._steps = steps
    }
    
    //Coder Functions
    required init?(coder aDecoder: NSCoder) {
        if let uuidObject = aDecoder.decodeObject(forKey: Keys.UUID) as? String {
            _uuid = uuidObject
        }
        
        if let nameObject = aDecoder.decodeObject(forKey: Keys.NAME) as? String {
            _name = nameObject
        }
        
        if let worldMapObject = aDecoder.decodeObject(forKey: Keys.WORLD_MAP) as? ARWorldMap {
            _worldMap = worldMapObject
        }
        
        if let imageObject = aDecoder.decodeObject(forKey: Keys.IMAGE) as? UIImage {
            _thumbnailImage = imageObject
        }
        
        if let stepsObject = aDecoder.decodeObject(forKey: Keys.STEPS) as? [Step] {
            _steps = stepsObject
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_uuid, forKey: Keys.UUID)
        aCoder.encode(_name, forKey: Keys.NAME)
        aCoder.encode(_thumbnailImage, forKey: Keys.IMAGE)
        aCoder.encode(_worldMap, forKey: Keys.WORLD_MAP)
        aCoder.encode(_steps, forKey: Keys.STEPS)
    }
    
    //Getters and Setters
    var uuid: String {
        get {
            return _uuid
        }
    }
    
    var steps: [Step] {
        get {
            return _steps
        }
        set {
            _steps = newValue
        }
    }
    
    var name: String {
        get {
            return _name
        }
        set {
            _name = newValue
        }
    }
    
    var worldMap: ARWorldMap {
        get {
            return _worldMap!
        }
        set {
            _worldMap = newValue
        }
    }
    
    var image: UIImage {
        get {
            return _thumbnailImage!
        }
        set {
            _thumbnailImage = newValue
        }
    }
    
    public func printInfo() {
        print("UUID: \(_uuid)")
        print("Name: \(_name)")
        print("Steps: \n")
        for step in _steps {
            step.printInfo()
        }
    }
    
}
