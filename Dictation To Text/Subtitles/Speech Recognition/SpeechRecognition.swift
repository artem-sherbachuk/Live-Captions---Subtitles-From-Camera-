//
//  SpeechRecognition.swift
//  Hearing Aid App
//
//  Created by Artem Sherbachuk on 5/13/21.
//

import UIKit
import Speech

public class SpeechRecognition: NSObject, SFSpeechRecognizerDelegate {
    private static let AUDIO_BUFFER_SIZE: UInt32 = 1024
    private var recognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var speechTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    var availabilityDidChangeCompletion: ((Bool) -> Void)? = nil

    override init() {
        super.init()

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord,
                                         mode: .measurement,
                                         options: .duckOthers)
            try audioSession.setAllowHapticsAndSystemSoundsDuringRecording(true)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch let error {
            presentError(error: error)
        }

        let locale = Locale(identifier: currentSelectedLocale)
        setLocale(locale)
    }

    public func setLocale(_ locale: Locale) {
        stopRecognition()
        self.recognizer = SFSpeechRecognizer(locale: locale)
        self.recognizer?.delegate = self
        self.recognizer?.defaultTaskHint = .unspecified
    }

    /// Helper to get a list of supported locales
    public static func supportedLocales() -> [Locale] {
        return Array(SFSpeechRecognizer.supportedLocales()).sorted(by: { $0.identifier < $1.identifier})
    }

    public static func localizedSelectedLanguage() -> String {
        guard let locale = supportedLocales().filter({ $0.identifier == currentSelectedLocale }).first else {
            return "Language"
        }
        return locale.localizedString(forIdentifier: locale.identifier) ?? "Language"
    }

    public static func requestAuthorization(_ statusHandler: ((Bool) -> Void)? = nil ) {

        if SFSpeechRecognizer.authorizationStatus() == .authorized {
            statusHandler?(true)
            return
        }

        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    statusHandler?(true)
                case .denied:
                    statusHandler?(false)
                    presentError(customDescription: "User denied access to speech recognition")
                case .restricted:
                    statusHandler?(false)
                    presentError(customDescription:"Speech recognition restricted on this device")
                case .notDetermined:
                    statusHandler?(false)
                    presentError(customDescription:"Speech recognition not yet authorized")
                @unknown default:
                    statusHandler?(false)
                }
            }
        }
    }


    func startRecognition(_ sessionUpdate: @escaping (TranscriptionSession) -> Void, errorHandler: ((Error?) -> Void)? = nil) {
        SpeechRecognition.requestAuthorization { [weak self] (authStatus) in
            guard let controller = self else { return }
            if authStatus {
                controller.recognize(sessionUpdate: sessionUpdate,
                                     errorHandler: errorHandler)
            } else {
                let errorMsg = "Speech recognizer needs to be authorized first"
                errorHandler?(NSError(domain:"speechcontroller", code:1, userInfo:[NSLocalizedDescriptionKey: errorMsg]))
            }
        }
    }


    //Transcription
    private(set) var speechSession = TranscriptionSession()

    private func recognize(sessionUpdate: @escaping (TranscriptionSession) -> Void, errorHandler: ((Error?) -> Void)? = nil) {
        audioEngine.prepare()
        try? audioEngine.start()

        let node = audioEngine.inputNode

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest!.requiresOnDeviceRecognition = false
        recognitionRequest!.shouldReportPartialResults = true

        node.installTap(onBus: 0,
                        bufferSize: SpeechRecognition.AUDIO_BUFFER_SIZE,
                        format: nil) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        speechTask = recognizer?.recognitionTask(with: recognitionRequest!) { [weak self] (result, error) in
            guard let `self` = self else { return }

            if let r = result {
                let isFinal = r.isFinal

                if isFinal {
                    self.stopRecognition()
                    self.startRecognition(sessionUpdate, errorHandler: errorHandler)
                }

                self.speechSession.update(transcription: r.bestTranscription, isFinal: isFinal)

                sessionUpdate(self.speechSession)

                self.performFeedbackGenerator()
            } else {
                self.stopRecognition()
                errorHandler?(error)
            }
        }
    }

    private func performFeedbackGenerator() {
        TapticEngine.selection.feedback()
    }

    /// Method which will stop the recording
    public func stopRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        speechTask?.cancel()
        speechTask = nil
        recognitionRequest = nil
    }

    func deleteSessionData() {
        speechSession.reset()
    }

    deinit {
        stopRecognition()
    }

    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        availabilityDidChangeCompletion?(available)
    }
}

final class TranscriptionSession {

    var formattedString: String = ""

    private var dictationString: Set<String> = Set()

    private(set) var segments: [SubtitleTranscription] = []

    func update(transcription: SFTranscription, isFinal: Bool) {
        var string = ""

        if isFinal {
            string = transcription.formattedString
            self.dictationString.insert(string)
        } else {
            string = self.dictationString.joined() + " " + transcription.formattedString
        }

        self.segments = transcription.segments.compactMap({ SubtitleTranscription(segment: $0)})
        formattedString = string
    }

    func reset() {
        dictationString.removeAll()
        segments = []
    }
}

final class SubtitleTranscription: Hashable {

    static func == (lhs: SubtitleTranscription,
                    rhs: SubtitleTranscription) -> Bool {
        return lhs.timestamp == rhs.timestamp
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(timestamp)
    }


    init(segment: SFTranscriptionSegment) {
        substring = segment.substring
        timestamp = segment.timestamp
        duration = segment.duration
        alternativeSubstrings = segment.alternativeSubstrings
    }

    var substring: String

    let timestamp: TimeInterval

    let duration: TimeInterval

    let alternativeSubstrings: [String]
}

