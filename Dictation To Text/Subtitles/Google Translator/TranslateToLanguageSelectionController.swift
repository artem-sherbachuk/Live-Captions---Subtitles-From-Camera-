//
//  TranslateToLanguageSelectionController.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 6/14/21.
//
import UIKit

protocol TranslateToLanguageSelectionControllerDelegate: AnyObject {
    func didSelect(language: TranslationLanguage)
}

final class TranslateToLanguageSelectionController: UITableViewController {


    var languages: [TranslationLanguage] = []

    weak var selectionDelegate: TranslateToLanguageSelectionControllerDelegate?

    private let reuseIdentifier = "localeCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Available Languages (\(languages.count))".localized()
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
        return languages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)

            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)

        let language = languages[indexPath.row]
        cell.textLabel?.text = MLTranslator.localizedString(forLanguage: language)

        if MLTranslator.isLanguageDownloaded(language) == true {
            cell.detailTextLabel?.text = "Downloaded"
            cell.accessoryView = nil
            if (language == MLTranslator.outputLanguage) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            cell.detailTextLabel?.text = "Download Translation Model"
            cell.accessoryView = UIImageView(image: UIImage(systemName: "icloud.and.arrow.down"))
            cell.accessoryView?.tintColor = Theme.buttonActiveColor
        }

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let language = languages[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.selectionDelegate?.didSelect(language: language)
        }
    }
}
