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

    var children: [ChildObject] = []

}
