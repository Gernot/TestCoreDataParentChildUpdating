import Foundation
import CoreData
import UIKit

class SingleRelationshipViewController: UIViewController {
    
    
    var container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    var parentObject: ParentObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let container = container else { fatalError() }
        parentObject = ParentObject.shared(in: container.viewContext)

        updateInterface()
    }
    
    func updateInterface() {
        nameLabel?.text = parentObject?.singleChild?.name ?? "nil"
    }
    
    @IBOutlet var nameLabel: UILabel?
    
    @IBAction func importObject() {
        container?.performBackgroundTask { context in
            do {
                context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                let url = Bundle.main.url(forResource: "Single", withExtension: "json")!
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.userInfo = [.managedObjectContext: context]
                let loadedChildren = try decoder.decode([ChildObject].self, from: data)
                let parent = ParentObject.shared(in: context)
                parent.singleChild = loadedChildren.first
                try context.save()
                DispatchQueue.main.async {
                    self.updateInterface()
                }
            } catch {
                context.reset()
                print("Error Updating: \(error.localizedDescription)")
            }
        }
    }
    
    
}
