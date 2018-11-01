import Foundation
import ARKit

class Step: NSObject, NSCoding {
    
    struct Keys {
        static let UUID = "uuid"
        static let NAME = "name"
        static let RESSOURCES = "ressources"
    }
    
    //MARK: Attributes
    private var _uuid: String = ""
    private var _name: String = ""
    
    private var _node: SCNNode!
    
    //MARK: Note
    private var _videoUrl: String = ""
    private var _photoUrl: String = ""
    private var _voiceUrl: String = ""
    private var _annotationUrl: String = ""

    //Constructor
    init(uuid: String, node: SCNNode) {
        self._uuid = uuid
        self._name = ""
        self._node = node
    }

    //Coder Functions
    required init?(coder aDecoder: NSCoder) {
        if let uuidObject = aDecoder.decodeObject(forKey: Keys.UUID) as? String {
            _uuid = uuidObject
        }
        
        if let nameObject = aDecoder.decodeObject(forKey: Keys.NAME) as? String {
            _name = nameObject
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_uuid, forKey: Keys.UUID)
        aCoder.encode(_name, forKey: Keys.NAME)
    }

    //Getters and Setters
    var uuid: String {
        get {
            return _uuid
        }
    }
    
    var node: SCNNode {
        get {
            return _node
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
    
    func hasVideo() -> Bool {
        return !_videoUrl.isEmpty
    }
    
    func hasVoice() -> Bool {
        return !_voiceUrl.isEmpty
    }

    func hasPhoto() -> Bool {
        return !_photoUrl.isEmpty
    }

    func hasAnnotation() -> Bool {
        return !_annotationUrl.isEmpty
    }

    
    public func printInfo() {
        print("UUID: \(_uuid)")
        print("Name: \(_name)")
    }
}
