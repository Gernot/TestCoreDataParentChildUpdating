import Foundation
import UIKit
import CoreData

class TestViewController: UITableViewController {

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
        guard let context = container?.viewContext else { fatalError() }
        do {
            let url = Bundle.main.url(forResource: fileName, withExtension: "json")!
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.userInfo = [.managedObjectContext: context]
            let children = try decoder.decode([ChildObject].self, from: data)
            parentObject?.children = children
            updateSnapshot()
        } catch {
            print("Error Updating: \(error.localizedDescription)")
        }
    }

}
