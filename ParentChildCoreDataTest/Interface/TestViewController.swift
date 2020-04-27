import Foundation
import UIKit
import CoreData

class TestViewController: UITableViewController {

    var datasource: UITableViewDiffableDataSource<Int, Child>?

    var parentObject: Parent?

    override func viewDidLoad() {
        super.viewDidLoad()

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
        var snapshot = NSDiffableDataSourceSnapshot<Int, Child>()
        snapshot.appendSections([0])
        snapshot.appendItems(parentObject?.children ?? [])
        datasource?.apply(snapshot)
    }

    @IBAction func loadSample1() {

    }

    @IBAction func loadSample2() {

    }

}
