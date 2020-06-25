import Foundation
import CoreData

class ParentObject: NSManagedObject {

    static func shared(in context: NSManagedObjectContext) -> ParentObject {
        do {
            let request = NSFetchRequest<ParentObject>(entityName: "ParentObject")
            request.fetchLimit = 1
            let result = try context.fetch(request)
            if let parent = result.first { return parent }
            let entity = NSEntityDescription.entity(forEntityName: "ParentObject", in: context)!
            let parent = ParentObject(entity: entity, insertInto: context)
            try context.save()
            return parent
        } catch {
            fatalError("Error getting parent: \(error.localizedDescription)")
        }
    }

    var children: [ChildObject] {
        get {
            let orderedSet = mutableOrderedSetValue(forKey: "children")
            return orderedSet.array as! [ChildObject]
        } set {
            setValue(NSOrderedSet(array: newValue), forKey: "children")
        }
    }

    func addChildren(_ children: [ChildObject]) {
        let set = mutableOrderedSetValue(forKey: "children")
        set.addObjects(from: children)
    }

    func removeChildren(notIn childrenToKeep: [ChildObject]) {
        let orderedSet = mutableOrderedSetValue(forKey: "children")
        let typedSet = orderedSet.set as! Set<ChildObject>
        let childrenToRemove = typedSet.filter { child in
            childrenToKeep.contains(where: { child.name == $0.name }) == false
        }
        for child in childrenToRemove {
            orderedSet.remove(child)
        }
    }
    
    @NSManaged var singleChild: ChildObject?

}
