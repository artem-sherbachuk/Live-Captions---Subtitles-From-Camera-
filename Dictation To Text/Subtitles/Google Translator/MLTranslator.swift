//
//  MLTranslator.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 6/14/21.
//

import MLKit
import UIKit

typealias TranslationLanguage = TranslateLanguage

final class MLTranslator {

    static var inputLocale: Locale {
        return Locale(identifier: currentSelectedLocale)
    }

    static var inputLanguage: TranslateLanguage {
        return TranslateLanguage(rawValue: MLTranslator.inputLocale.languageCode ?? "en")
    }

    static var outputLanguage: TranslationLanguage {
        get {
            let value = UserDefaults.standard.value(forKey: "currentTranslateLanguage") as? String ?? "en"
            return TranslationLanguage(rawValue: value)
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: "currentTranslateLanguage")
        }
    }

    private var translator: Translator

    var flipTranslate: Bool = false

    private let modelManager = ModelManager.modelManager()

    var allLanguages: [TranslateLanguage] {
        let inputLocale = MLTranslator.inputLocale
        return TranslateLanguage.allLanguages().sorted {
            return inputLocale.localizedString(forLanguageCode: $0.rawValue)!
                < inputLocale.localizedString(forLanguageCode: $1.rawValue)!
        }
    }

    init() {
        let options = TranslatorOptions(sourceLanguage: MLTranslator.inputLanguage,
                                        targetLanguage: MLTranslator.outputLanguage)
        translator = Translator.translator(options: options)

        NotificationCenter.default.addObserver(
            self, selector: #selector(remoteModelDownloadDidComplete(notification:)),
            name: .mlkitModelDownloadDidSucceed, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(remoteModelDownloadDidComplete(notification:)),
            name: .mlkitModelDownloadDidFail, object: nil)
    }

    static func localizedString(forLanguage language:TranslateLanguage) -> String? {
        return inputLocale.localizedString(forLanguageCode: language.rawValue)
    }

    static func localizedStringForSelectedLanguage() -> String? {
        return inputLocale.localizedString(forLanguageCode: MLTranslator.outputLanguage.rawValue)
    }

    static func model(forLanguage: TranslateLanguage) -> TranslateRemoteModel {
        return TranslateRemoteModel.translateRemoteModel(language: forLanguage)
    }

    static func isLanguageDownloaded(_ language: TranslateLanguage) -> Bool {
        let model = model(forLanguage: language)
        let modelManager = ModelManager.modelManager()
        return modelManager.isModelDownloaded(model)
    }

    func deleteModel(language: TranslateLanguage,
                     completion: @escaping () -> Void) {

        let model = MLTranslator.model(forLanguage: language)

        if language == .english {
            completion()
            return
        }

        if modelManager.isModelDownloaded(model) == false {
            completion()
            return
        }

        modelManager.deleteDownloadedModel(model) { error in
            completion()
        }
    }

    private var downloadCompletion: ((Bool) -> Void)?
    func downloadModel(language: TranslateLanguage,
                     completion: @escaping (Bool) -> Void) {
        downloadCompletion = completion

        let model = MLTranslator.model(forLanguage: language)

        if language == .english {
            downloadCompletion?(true)
            return
        }

        if modelManager.isModelDownloaded(model) {
            downloadCompletion?(true)
            return
        }

        let conditions = ModelDownloadConditions(allowsCellularAccess: true, allowsBackgroundDownloading: true)
        modelManager.download(model, conditions: conditions)
    }

    @objc
    func remoteModelDownloadDidComplete(notification: NSNotification) {
        let userInfo = notification.userInfo
        guard let remoteModel =
                userInfo?[ModelDownloadUserInfoKey.remoteModel.rawValue] as? TranslateRemoteModel else {
            return
        }

        let language = remoteModel.language
        let title = MLTranslator.localizedString(forLanguage: language) ?? language.rawValue

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            if notification.name == .mlkitModelDownloadDidSucceed {
                MLTranslator.outputLanguage = language
                strongSelf.downloadCompletion?(true)
                if let topVC =  UIApplication.shared.topMostViewController() {
                    presentAlert(controller: topVC, title: "Downloaded",
                                 message: "You can now translate offline into \(title)")
                }
            } else {
                strongSelf.downloadCompletion?(false)
            }
        }
    }

    func translate(text: String,
                   completion: @escaping (String) -> Void) {

        let input: TranslateLanguage
        let output: TranslateLanguage

        if flipTranslate {
            input = MLTranslator.outputLanguage
            output = MLTranslator.inputLanguage
        } else {
            input = MLTranslator.inputLanguage
            output = MLTranslator.outputLanguage
        }

        let options = TranslatorOptions(sourceLanguage: input,
                                        targetLanguage: output)
        translator = Translator.translator(options: options)

        translator.downloadModelIfNeeded { [weak self] error in
            guard error == nil else {
                completion("Failed to ensure model downloaded with error \(error!)")
                return
            }

            self?.translator.translate(text) { result, error in
                guard error == nil else {
                    completion("Failed with error \(error!)")
                    return
                }

                completion(result ?? "")
            }
        }
    }
}
