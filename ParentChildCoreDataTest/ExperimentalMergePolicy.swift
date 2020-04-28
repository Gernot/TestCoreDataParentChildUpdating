import Foundation
import CoreData

class ExperimentalMergePolicy: NSMergePolicy {

    private struct SortTask {
        let object: NSManagedObject
        let relationshipKey: String
        let objectIDs: [NSManagedObjectID]
    }

    override func resolve(constraintConflicts list: [NSConstraintConflict]) throws {
        assert(mergeType == .mergeByPropertyObjectTrumpMergePolicyType)

        //Build an mapping from new ObjectIDs to Database ObjectIDs
        let newOldObjectIDMapping = list.reduce(into: [NSManagedObjectID: NSManagedObjectID]()) { mapping, conflict in
            if let databaseObject = conflict.databaseObject {
                for conflictingObject in conflict.conflictingObjects {
                    mapping[conflictingObject.objectID] = databaseObject.objectID
                }
            }
        }

        //Build Sort tasks for sorted inverse relationships
        var sortTasks = [SortTask]()
        for conflict in list {
            if let databaseObject = conflict.databaseObject {
                databaseObject.entity.relationshipsByName.forEach { name, relationship in
                    if  relationship.isToMany == false, //We don't support sortend m:n relationships yet
                        let inverseRelationship = relationship.inverseRelationship,
                        inverseRelationship.isToMany,
                        inverseRelationship.isOrdered {
                        if let object = databaseObject.value(forKey: relationship.name) as? NSManagedObject,
                            !sortTasks.contains(where: {$0.object == object && $0.relationshipKey == inverseRelationship.name}) {
                            let sortedObjects = object
                                .value(forKey: inverseRelationship.name) as! NSOrderedSet
                            let sortedObjectIDs = sortedObjects.array.map{($0 as! NSManagedObject).objectID}
                            let mappedSortedObjectIDs = sortedObjectIDs.map { newOldObjectIDMapping[$0] ?? $0 }
                            sortTasks.append(SortTask(object: object,
                                                      relationshipKey: inverseRelationship.name,
                                                      objectIDs: mappedSortedObjectIDs))
                        }
                    }
                }
            }
        }

        //Let the solver do its thing
        try super.resolve(constraintConflicts: list)

        //Now we have the resolved object, but the relationship sorting is wrong. We sort it again based on the indexes of the original sort, taking the *last* mapped Identifiers (assuming the new content got appended!)
        for sortTask in sortTasks {
            let orderedSet = sortTask.object.mutableOrderedSetValue(forKey: sortTask.relationshipKey)
            orderedSet.sort { lhs, rhs -> ComparisonResult in
                guard let leftIndex = sortTask.objectIDs.lastIndex(of: (lhs as! NSManagedObject).objectID),
                let rightIndex = sortTask.objectIDs.lastIndex(of: (rhs as! NSManagedObject).objectID)
                    else { return .orderedSame }
                if leftIndex == rightIndex { return .orderedSame }
                return (leftIndex < rightIndex) ? .orderedAscending : .orderedDescending
            }
        }
    }

}
