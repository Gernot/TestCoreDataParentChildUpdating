import Foundation
import UIKit
import CoreData

class OrderedSetMergeViewController: UITableViewController {

    var datasource: UITableViewDiffableDataSource<Int, ChildObject>?

    var container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer

    var parentObject: ParentObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let container = container else { fatalError() }
        parentObject = ParentObject.shared(in: container.viewContext)

        datasource = UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, child in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Child", for: indexPath)
            cell.textLabel?.text = child.name
            return cell
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateSnapshot()
    }

    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, ChildObject>()
        snapshot.appendSections([0])
        snapshot.appendItems(parentObject?.children ?? [])
        datasource?.apply(snapshot)
    }

    @IBAction func loadSample1() {
        update(fromFileName: "Sample1")
    }

    @IBAction func loadSample2() {
        update(fromFileName: "Sample2")
    }
    
    private func update(fromFileName fileName: String) {
        container?.performBackgroundTask { context in
            do {
                
                /** See the default merge policy messing with the order in an OrderedSet. Replace that by the `resortingMergeByPropertyObjectTrump` merge policy to see how this issue is fixed during the merge. */
                context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                //context.mergePolicy = NSMergePolicy.resortingMergeByPropertyObjectTrump
                
                let url = Bundle.main.url(forResource: fileName, withExtension: "json")!
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.userInfo = [.managedObjectContext: context]
                let children = try decoder.decode([ChildObject].self, from: data)
                let parent = ParentObject.shared(in: context)
                
                /** Here the new Children are added to the existing ones, afterwards the objects in the OrderedSet are removed that are *not* shaing the "name" constraint. This way, before the merge, the new objects *and their duplicates* are present, the duplicates will be removed by the merge. If they are removed before, e.g. by setting them directly, the deletion rules are fired, leading to deletion of the resolved objects, too.*/
                parent.addChildren(children)
                parent.removeChildren(notIn: children)
                
                /** Use this instead of the add/remove above to see the deletion issue */
                //parent.children = children

                try context.save()
                DispatchQueue.main.async {
                    self.updateSnapshot()
                }
            } catch {
                context.reset()
                print("Error Updating: \(error.localizedDescription)")
            }
        }
    }

}
