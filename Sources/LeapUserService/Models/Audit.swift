
import Foundation
import Vapor

public protocol Audited {
    var created: NSDate? { get set }
    var updated: NSDate? { get set }
}

extension Audited {
    mutating func willCreate() throws {
        self.created = NSDate()
    }

    mutating func willUpdate() throws {
        self.updated = NSDate()
    }
}
