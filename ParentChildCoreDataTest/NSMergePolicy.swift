import Foundation
import CoreData

extension NSMergePolicy {
    
    /**
     A Merge Policy that resorts ordered relationships after merge to match the "before" state.
     
     Background: Merging with Constraints causes relationshp deletion rules to fire. Upon conflict resolution these relationships get re-established but might have the wrong order, since they are re-added in the order of conflict resolution. This Merge policy fixes that by re-ordering ordered relationships.
     */
    static var resortingMergeByPropertyObjectTrump: NSMergePolicy {
        return ResortingMergePolicy.init(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
}

fileprivate class ResortingMergePolicy: NSMergePolicy {
    
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
                    if  let inverseRelationship = relationship.inverseRelationship,
                        inverseRelationship.isToMany,
                        inverseRelationship.isOrdered {
                        
                        //Get all Objects that have inverse ordered relationships to this object
                        var objects: [NSManagedObject] = []
                        if relationship.isToMany && relationship.isOrdered {
                            objects = databaseObject.mutableOrderedSetValue(forKey: relationship.name).array as! [NSManagedObject]
                        } else if relationship.isToMany && !relationship.isOrdered {
                            objects = databaseObject.mutableSetValue(forKey: relationship.name).allObjects as! [NSManagedObject]
                        } else {
                            objects = [databaseObject.value(forKey: relationship.name) as? NSManagedObject].compactMap{$0}
                        }
                        
                        //Create a SortTask for later if one isn't already there
                        for object in objects {
                            if !sortTasks.contains(where: {$0.object == object && $0.relationshipKey == inverseRelationship.name}) {
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
                    
                    // Experiment on re-establishing deleted Relationships. Does not work, here for reference.
                    //                    if let inverseRelationship = relationship.inverseRelationship,
                    //                        inverseRelationship.isToMany == false,
                    //                        conflict.conflictingObjects.count == 1,
                    //                        let newObject = conflict.conflictingObjects.first {
                    //                        let object = databaseObject.value(forKey: relationship.name) as? NSManagedObject
                    //                        object?.setValue(newObject, forKey: inverseRelationship.name)
                    //                    }
                    
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
