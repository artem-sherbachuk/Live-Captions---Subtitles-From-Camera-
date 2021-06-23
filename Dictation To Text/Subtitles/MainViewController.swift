//
//  SpeechRecognitionViewController.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/12/21.
//

import UIKit

final class SpeechRecognitionViewController: BaseViewController {

    @IBOutlet weak var menuView: MainMenuView!

    private let keyboardNotification = KeyboardNotification()


    @IBOutlet weak var textView: TextView!

    @IBOutlet weak var topMenuStackView: SpeechRecognitionTopMenuView!

    private let speech = SpeechRecognition()

    //translate mode
    @IBOutlet weak var hideTextViewButton: ButtonView!

    @IBOutlet weak var translateToButton: ButtonView!

    @IBOutlet weak var flipTranslationButton: ButtonView!

    @IBOutlet weak var translationControlsView: UIStackView!

    @IBOutlet weak var translationTextView: TextView!

    private lazy var translator = MLTranslator()


    private var fullScreenViewController: TextViewFullScreenViewController?

    private var isLandscape: Bool = false

    private var isTranslateMode: Bool = false {
        didSet {
            translationTextView.isHidden = !isTranslateMode
            translationControlsView.isHidden = !isTranslateMode

            if isTranslateMode {
                translateText()
            }

            translateToButton.isSelected = true
            hideTextViewButton.isSelected = true
            flipTranslationButton.isSelected = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isTranslateMode = SpeechRecognitionSettings.TranslateMode.value as? Bool ?? false

        setupTextView()

        setupSpeech()

        keyboardNotification.keyboardWillShow = { [weak self] _ in
            self?.topMenuStackView.alpha = 0
            self?.topMenuStackView.isHidden = true
        }

        keyboardNotification.keyboardWillHide = { [weak self] _ in
            self?.topMenuStackView.alpha = 1
            self?.topMenuStackView.isHidden = false
        }
    }

    private func setupTextView() {
        //textView.delegate = self
        textView.didSetTextCompletion = { [weak self] text in
            if self?.isTranslateMode == true {
                self?.translateText()
            }
        }

        resetTextView()
    }

    private func setupSpeech() {
        speech.availabilityDidChangeCompletion = { [weak self] available in
            if available {
                self?.resetTextView()
            } else {
                self?.textView.text = "Recognition Not Available :(".localized()
            }
        }

    }

    private func resetTextView() {
        textView.text = "Tap the mic to get started ;)".localized()
        fullText = nil
        deletedText = nil
    }

    @IBAction func settingsAction(sender: UIButton) {
        let vc: SpeechRecognitionSettingsViewController = SpeechRecognitionSettingsViewController.instantiate()
        vc.delegate = self
        presentAsPopover(vc: vc, sourceView: sender, height: 350)
    }

    @IBAction func shareAction(sender: UIButton) {
        let callToActionText = textView.text ?? "Try this app!🙂"
        let appStore = URL(string: "https://apps.apple.com/us/app/hearing-aid-app/id1566596774")!
        let objectsToShare: [Any] = [callToActionText, appStore]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [.print,.copyToPasteboard,.assignToContact,
                                            .addToReadingList,.openInIBooks,.markupAsPDF]
        activityVC.popoverPresentationController?.sourceView = sender

        self.present(activityVC, animated: true, completion: nil)
    }

    @IBAction func changeLanguageAction(sender: UIButton) {
        let localeSelection = SpeechRecognitionLocaleSelectionViewController()
        localeSelection.selectionDelegate = self
        presentAsPopover(vc: localeSelection, sourceView: sender)
    }

    @IBAction func hideLeftTextViewAction(sender: UIButton) {
        textView.isHidden = !textView.isHidden
        hideTextViewButton.isSelected = !textView.isHidden
    }

    @IBAction func translateToLanguageAction(sender: UIButton) {
        let localeSelection = TranslateToLanguageSelectionController()
        localeSelection.languages = translator.allLanguages
        localeSelection.selectionDelegate = self
        presentAsPopover(vc: localeSelection, sourceView: sender)
    }

    @IBAction func filtersAction(sender: UIButton) {

    }

    private var deletedText: String?
    private var fullText: String?
    @IBAction func clearTextAction(sender: UIButton?) {
        deletedText = fullText
        textView.text = ""
        fullScreenViewController?.text = ""
        TapticEngine.notification.feedback(.success)
    }

    @IBAction func rotate(sender: UIButton) {
        isLandscape = !isLandscape

        if isLandscape {
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        } else {
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }

    @IBAction func speechRecognitionAction(sender: UIButton) {
        if !user.isPremium {
            presentSubscriptionViewController()
            return
        }

        speech.stopRecognition()
        fullText = nil
        deletedText = nil

        let readyText = "Go ahead, I'm listening :)".localized()
        if textView.text == readyText {
            resetTextView()
        }
        
        if !menuView.isRecognitionButtonSelected {
            UIApplication.shared.isIdleTimerDisabled = true
            textView.text = readyText
            speech.startRecognition(textHandler: {[weak self] text, _, _ in
                self?.fullText = text

                if let deletedText = self?.deletedText {
                    let filteredText = text.replacingOccurrences(of: deletedText, with: "")
                    self?.fullScreenViewController?.text = filteredText
                    self?.textView.text = filteredText
                } else {
                    self?.fullScreenViewController?.text = text
                    self?.textView.text = text
                }

            }, errorHandler: {[weak self] error in
                self?.menuView.isRecognitionButtonSelected = false
            })
        } else {
            UIApplication.shared.isIdleTimerDisabled = false
            speech.stopRecognition()
        }

        menuView.isRecognitionButtonSelected = !menuView.isRecognitionButtonSelected
    }

    @IBAction func fullScreenAction(sender:UIButton) {
        let vc: TextViewFullScreenViewController = TextViewFullScreenViewController.instantiate()
        vc.delegate = self
        vc.text = textView.text
        vc.transform = textView.transform
        vc.modalPresentationCapturesStatusBarAppearance = true
        fullScreenViewController = vc
        present(vc, animated: true, completion: nil)
    }

    @IBAction func flipAction(sender: UIButton) {
        UIView.animate(withDuration: 0.35) {
            let flipTransform = CGAffineTransform(scaleX: -1, y: -1)
            if self.textView.transform == flipTransform {
                self.textView.transform = .identity
                return
            }
            self.textView.transform = flipTransform
        }
    }

    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        let isShakeToClearEnabled = SpeechRecognitionSettings.ShakeToClearText.value as? Bool ?? false
        if motion == .motionShake && isShakeToClearEnabled {
            clearTextAction(sender: nil)
        }
    }
}

//extension MainViewController: UITextViewDelegate {
//
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        speech.stopRecognition()
//    }
//}

extension SpeechRecognitionViewController: SpeechRecognitionLocaleSelectionDelegate, SpeechRecognitionSettingsDelegate, TranslateToLanguageSelectionControllerDelegate {

    func didChangeTextAlignment(_ alignment: NSTextAlignment) {
//        textView.textAlignment = alignment
//        translationTextView.textAlignment = alignment
    }

    func didChangeFontSize(_ size: Float) {
        textView.updateFontSize(size)
        translationTextView.updateFontSize(size)
    }

    func didChangeFontWeight(_ weight: Int) {
        textView.updateFontWeight(weight)
        translationTextView.updateFontWeight(weight)
    }

    func didToggleSetting(_ setting: SpeechRecognitionSettings,
                          _ value: Bool) {
        if setting == .TranslateMode {
            isTranslateMode = value
        }
    }

    func didSelectLocale(_ locale: Locale) {
        speech.setLocale(locale)
        topMenuStackView.updateLanguageButtonTitle()
    }

    func didSelect(language: TranslationLanguage) {
        if MLTranslator.isLanguageDownloaded(language) == true {
            MLTranslator.outputLanguage = language
            translateText()
        } else {
            presentAlert(controller: self, title: "Download?", message: "This language model is not downloaded. Would you like to download it?", leftActionTitle: "No", rightActionTitle: "Yes", leftActionStyle: .cancel, rightActionStyle: .default) {
            } rightActionCompletion: { [weak self] in
                self?.download(language)
            }
        }
    }

    private func download(_ language: TranslationLanguage) {
        ActivityIndicatorView.showActivity(topView: translationTextView, text: "")
        let loca = MLTranslator.localizedString(forLanguage: language) ?? language.rawValue
        translationTextView.text = "Downloading \(loca) ..."
        translator.downloadModel(language: language,
                                  completion: { [weak self] _ in
                                    ActivityIndicatorView.hideActivity()
                                    self?.translateText()
                                  })
    }

    private func translateText() {
        translateToButton.title?.text = MLTranslator.localizedStringForSelectedLanguage()

        translator.translate(text: textView.text) { [weak self] translation in
            self?.translationTextView.text = translation
        }
    }
}

extension SpeechRecognitionViewController: TextViewFullScreenViewControllerDelegate {

    func didExitFullScreen() {
        fullScreenViewController = nil
    }
}

final class MainMenuView: UIStackView {
    @IBOutlet weak var clearButton: ButtonView!
    @IBOutlet weak var rotateButton: ButtonView!
    @IBOutlet weak var recognitionButton: ButtonView!
    @IBOutlet weak var fullScreenButton: ButtonView!
    @IBOutlet weak var flipButton: ButtonView!


    override func awakeFromNib() {
        super.awakeFromNib()
        clearButton.isSelected = true
        rotateButton.isSelected = true
        fullScreenButton.isSelected = true
        flipButton.isSelected = true
        recognitionButton.isSelected = true
        isRecognitionButtonSelected = false
        //recognitionButton.button.impactStyle = .
    }

    var isRecognitionButtonSelected: Bool = false {
        didSet {
            recognitionButton.isSelected = isRecognitionButtonSelected
            if isRecognitionButtonSelected {
                recognitionButton.animate(name:"flash", repeatCount:.infinity)
            } else {
                recognitionButton.layer.removeAllAnimations()
            }
        }
    }
}

final class SpeechRecognitionTopMenuView: UIStackView {

    @IBOutlet weak var shareButton: ButtonView!
    @IBOutlet weak var languageButton: ButtonView!
    @IBOutlet weak var settingsButton: ButtonView!

    override func awakeFromNib() {
        super.awakeFromNib()
        shareButton.isSelected = true
        languageButton.isSelected = true
        settingsButton.isSelected = true
        languageButton.isSelected = true
        updateLanguageButtonTitle()
    }

    func updateLanguageButtonTitle() {
        let language = SpeechRecognition.localizedSelectedLanguage()
        languageButton.title?.text = language
    }
}
