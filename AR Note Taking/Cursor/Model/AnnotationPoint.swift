import Foundation
import ARKit

class AnnotationPoint: NSObject, NSCoding {
    
    struct Keys {
        static let UUID = "uuid"
        static let POSITION = "position"
    }
    
    //MARK: Attributes
    private var _uuid: String = ""
    private var _position: SCNVector3 = SCNVector3(0, 0, 0)
    
    //Constructor
    init(uuid: String, position: SCNVector3) {
        self._uuid = uuid
        self._position = position
    }
    
    //Coder Functions
    required init?(coder aDecoder: NSCoder) {
        if let uuidObject = aDecoder.decodeObject(forKey: Keys.UUID) as? String {
            _uuid = uuidObject
        }
        
        if let positionObject = aDecoder.decodeObject(forKey: Keys.POSITION) as? SCNVector3 {
            _position = positionObject
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_uuid, forKey: Keys.UUID)
        aCoder.encode(_position, forKey: Keys.POSITION)
    }
    
    var uuid: String {
        get {
            return _uuid
        }
    }
    
    var position: SCNVector3 {
        get {
            return _position
        }
    }
}
