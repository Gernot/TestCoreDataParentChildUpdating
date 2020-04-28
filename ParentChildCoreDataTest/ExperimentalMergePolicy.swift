import Foundation
import CoreData

class ExperimentalMergePolicy: NSMergePolicy {

    override func resolve(mergeConflicts list: [Any]) throws {
        for conflict in list {
            print("Merge Conflict: \(conflict)")
        }
        try super.resolve(mergeConflicts: list)
    }

    override func resolve(constraintConflicts list: [NSConstraintConflict]) throws {
        for conflict in list {
            print("Constraint Conflict: \(conflict)")
        }
        try super.resolve(constraintConflicts: list)
    }

    override func resolve(optimisticLockingConflicts list: [NSMergeConflict]) throws {
        for conflict in list {
            print("Locking Conflict: \(conflict)")
        }
        try super.resolve(optimisticLockingConflicts: list)
    }

}
