import Foundation

struct CollisionCategory {
    let key: Int
    static let cursor = CollisionCategory.init(key: 1 << 0)
    static let virtualNode = CollisionCategory.init(key: 1 << 1)
}
