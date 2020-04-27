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
        }
        set {

            /* Possible Apple Sample Code, that I did get sent, but don't have the complete source for
            - (void)setObjectsDirectly:(NSOrderedSet *)objects forOrderedRelationshipWithKey:(NSString *)key {
                NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:key]];
                NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tmpOrderedSet count] - 1)];
                [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:key];
                [self setPrimitiveValue:objects forKey:key];
                [self didUpdate];
                [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:key];
            }
             */

            // Translated Apple Sample Code
            let key = "children"
            let existing = mutableOrderedSetValue(forKey: key)
            let temp = NSOrderedSet(orderedSet: existing)
            let indexes = IndexSet(integersIn: 0..<temp.count)
            let newOrderedSet = NSOrderedSet(array: newValue)
            willChange(.replacement, valuesAt: indexes, forKey: key)
            setPrimitiveValue(newOrderedSet, forKey: key)
            //U guess that's what the "didUpdate" method does, that I don't have the source for
            for child in newValue {
                child.setPrimitiveValue(self, forKey: "parent")
            }
            didChange(.replacement, valuesAt: indexes, forKey: key)

            /*
            //Alternative Approach, same results
            let key = "children"
            let existing = mutableOrderedSetValue(forKey: key)
            existing.removeAllObjects()
            existing.addObjects(from: newValue)
             */
        }
    }

}
