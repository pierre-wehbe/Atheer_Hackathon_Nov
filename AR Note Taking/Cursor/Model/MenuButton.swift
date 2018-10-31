import Foundation
import UIKit

class MenuButton {
    
    var image: UIImage? = nil
    var name: CursorTarget = .none

    init(name: CursorTarget, image: UIImage? = nil) {
        self.name = name
        self.image = image
    }
}
