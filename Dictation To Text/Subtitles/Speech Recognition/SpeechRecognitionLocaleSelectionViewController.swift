//
//  SpeechRecognitionLocaleSelectionViewController.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/13/21.
//

import UIKit

protocol SpeechRecognitionLocaleSelectionDelegate: AnyObject {
    func didSelectLocale(_ locale: Locale)
}

var currentSelectedLocale: String {
    get {
        return UserDefaults.standard.value(forKey: "currentSelectedLocale") as? String ?? "en-US"
    }
    set {
        UserDefaults.standard.setValue(newValue, forKey: "currentSelectedLocale")
    }
}

class SpeechRecognitionLocaleSelectionViewController: UITableViewController {

    var locales: [Locale] = SpeechRecognition.supportedLocales()
    private let reuseIdentifier = "localeCell"
    weak var selectionDelegate: SpeechRecognitionLocaleSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Available Languages (\(locales.count))".localized()
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
        return locales.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
        let locale = locales[indexPath.row]
        let id = locale.identifier
        cell.textLabel?.text = locale.localizedString(forIdentifier: id)
        cell.detailTextLabel?.text = id

        if (id == currentSelectedLocale) {
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
        let locale = locales[indexPath.row]
        currentSelectedLocale = locale.identifier
        selectionDelegate?.didSelectLocale(locales[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
}
