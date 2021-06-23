import UIKit

protocol CameraFilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: FilterType)
}

var currentFilter: FilterType?

class CameraFilterViewController: UITableViewController {

    let filters = FilterType.allCases
    private let reuseIdentifier = "cameraFilterSelection"
    weak var selectionDelegate: CameraFilterViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(format: "Available %i Filters".localized(), filters.count)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        tableView.flashScrollIndicators()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        let filter = filters[indexPath.row]
        cell.textLabel?.text = filter.rawValue

        if (filter == currentFilter) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let filter = filters[indexPath.row]
        currentFilter = filter
        selectionDelegate?.didSelectFilter(filter)
        dismiss(animated: true, completion: nil)
    }
}
