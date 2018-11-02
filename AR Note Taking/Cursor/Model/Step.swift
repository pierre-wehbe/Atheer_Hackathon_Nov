import Foundation
import ARKit

class Step: NSObject, NSCoding {
    
    struct Keys {
        static let UUID = "uuid"
        static let NAME = "name"
        static let RESSOURCES = "ressources"
        
        //NOTE
        static let VIDEO_URL = "video"
        static let AUDIO_URL = "audio"
        static let PHOTO_URL = "photo"
        static let ANNO = "annotation"
    }
    
    //MARK: Attributes
    private var _uuid: String = ""
    private var _name: String = ""
    
    private var _node: SCNNode!
    
    //MARK: Note
    private var _videoUrl: String = ""
    private var _photoUrl: String = ""
    private var _voiceUrl: String = ""
    private var _annotationPoints: [(String, SCNVector3)] = []
    
    private var _annotationNodes: [SCNNode] = []

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
        
        if let videoObject = aDecoder.decodeObject(forKey: Keys.VIDEO_URL) as? String {
            _videoUrl = videoObject
        }
        
        if let photoObject = aDecoder.decodeObject(forKey: Keys.PHOTO_URL) as? String {
            _photoUrl = photoObject
        }
        
        if let audioObject = aDecoder.decodeObject(forKey: Keys.AUDIO_URL) as? String {
            _voiceUrl = audioObject
        }
        
        if let annotationObject = aDecoder.decodeObject(forKey: Keys.ANNO) as? [(String, SCNVector3)] {
            _annotationPoints = annotationObject
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_uuid, forKey: Keys.UUID)
        aCoder.encode(_name, forKey: Keys.NAME)
        
        aCoder.encode(_videoUrl, forKey: Keys.VIDEO_URL)
        aCoder.encode(_voiceUrl, forKey: Keys.AUDIO_URL)
        aCoder.encode(_photoUrl, forKey: Keys.PHOTO_URL)
        aCoder.encode(_annotationPoints, forKey: Keys.ANNO)
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
    
    // Notes
    var photoUrl: String {
        get {
            return _photoUrl
        }
        set {
            _photoUrl = newValue
        }
    }
    
    var videoUrl: String {
        get {
            return _videoUrl
        }
        set {
            _videoUrl = newValue
        }
    }
    
    var annotationPoints: [(String, SCNVector3)] {
        get {
            return _annotationPoints
        }
        set {
            _annotationPoints = newValue
        }
    }
    
    var annotationNodes: [SCNNode] {
        get {
            return _annotationNodes
        }
        set {
            _annotationNodes = newValue
        }
    }
    
    var voiceUrl: String {
        get {
            return _voiceUrl
        }
        set {
            _voiceUrl = newValue
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
        return !_annotationPoints.isEmpty
    }

    
    public func printInfo() {
        print("UUID: \(_uuid)")
        print("Name: \(_name)")
    }
}
