import Foundation
import CoreData

class ChildObject: NSManagedObject, Decodable {

    enum CodingKeys: String, CodingKey {
        case name
    }

    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    //MARK: Decodable

    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.managedObjectContext] as? NSManagedObjectContext,
            let entityDescription = NSEntityDescription.entity(forEntityName: "ChildObject", in: context)
            else { fatalError() }
        self.init(entity: entityDescription, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decode(String.self, forKey: .name)
    }

    @NSManaged var name: String

}
