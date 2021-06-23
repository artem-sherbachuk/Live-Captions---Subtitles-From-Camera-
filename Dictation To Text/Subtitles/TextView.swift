//
//  TextView.swift
//  Dictation To Text
//
//  Created by Artem Sherbachuk on 6/20/21.
//

import UIKit

/*
final class TextView: SpringTextView {

    private var fontWeight: Int = SpeechRecognitionSettings.FontWeight.value as! Int
    private var fontSize: Float = SpeechRecognitionSettings.FontSize.value as! Float

    override var text: String! {
        get { return super.text }
        set {
            UIView.transition(with: self, duration: 0.25, options: [.curveEaseInOut, .transitionCrossDissolve], animations: {
                super.text = newValue
                self.scrollToBottom()
            }, completion: nil)
            didSetTextCompletion?(text)
        }
    }

    var didSetTextCompletion: ((String) -> Void)?

    func scrollToBottom() {
        if contentSize.height > bounds.height {
            let point = CGPoint(x: 0.0, y: (contentSize.height - bounds.height))
            setContentOffset(point, animated: true)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateFontSize(fontSize)
        let alignment = NSTextAlignment(rawValue: SpeechRecognitionSettings.TextAlignment.value as! Int) ?? .left
        textAlignment = alignment
        //textColor = Theme.buttonInactiveColor
    }

    func updateFontSize(_ size: Float) {
        fontSize = size
        if fontWeight == 0 {
            font = UIFont.systemFont(ofSize: CGFloat(size), weight: .regular)
        } else if fontWeight == 1 {
            font = UIFont.systemFont(ofSize: CGFloat(size), weight: .medium)
        } else {
            font = UIFont.systemFont(ofSize: CGFloat(size), weight: .bold)
        }
    }

    func updateFontWeight(_ weight: Int) {
        fontWeight = weight
        updateFontSize(fontSize)
    }
}
*/

final class TextView: UIView {

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var textLabel: UITextField!

    private var fontWeight: Int = SpeechRecognitionSettings.FontWeight.value as! Int
    private var fontSize: Float = SpeechRecognitionSettings.FontSize.value as! Float

    var text: String = "" {
        didSet {
            let _text = text
            UIView.transition(with: textLabel, duration: 0.3,
                              options: [.curveEaseInOut, .transitionCrossDissolve],
                              animations: {
                self.textLabel.text = _text
                self.scrollToBottom()
            }, completion: nil)
            didSetTextCompletion?(text)
        }
    }

    var didSetTextCompletion: ((String) -> Void)?

    func scrollToBottom() {
        if scrollView.contentSize.width > scrollView.bounds.width {
            let point = CGPoint(x: (scrollView.contentSize.width - scrollView.bounds.width), y: 0.0)
            scrollView.setContentOffset(point, animated: true)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateFontSize(fontSize)
        //let alignment = NSTextAlignment(rawValue: SpeechRecognitionSettings.TextAlignment.value as! Int) ?? .left
        //textAlignment = alignment
        //textColor = Theme.buttonInactiveColor
    }

    func updateFontSize(_ size: Float) {
        fontSize = size
        if fontWeight == 0 {
            textLabel.font = UIFont.systemFont(ofSize: CGFloat(size), weight: .regular)
        } else if fontWeight == 1 {
            textLabel.font = UIFont.systemFont(ofSize: CGFloat(size), weight: .medium)
        } else {
            textLabel.font = UIFont.systemFont(ofSize: CGFloat(size), weight: .bold)
        }
    }

    func updateFontWeight(_ weight: Int) {
        fontWeight = weight
        updateFontSize(fontSize)
    }
}
