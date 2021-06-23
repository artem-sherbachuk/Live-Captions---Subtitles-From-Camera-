import UIKit

/// Function that performs fade in/out animation.
public typealias FadeInAnimation = (UIView) -> Void

/// Function that performs fade out animation.
///
/// - Note: Must call the second parameter on the animation completion.
public typealias FadeOutAnimation = (UIView, @escaping () -> Void) -> Void

public final class ActivityIndicatorView: UIView {

    /// Default color of activity indicator. Default value is UIColor.white.
    public static var DEFAULT_COLOR = UIColor.white

    /// Default color of text. Default value is UIColor.white.
    public static var DEFAULT_TEXT_COLOR = UIColor.white

    /// Default padding. Default value is 0.
    public static var DEFAULT_PADDING: CGFloat = 0

    /// Default size of activity indicator view in UI blocker. Default value is 60x60.
    public static var DEFAULT_BLOCKER_SIZE = CGSize(width: 60, height: 60)

    /// Default display time threshold to actually display UI blocker. Default value is 0 ms.
    ///
    /// - note:
    /// Default time that has to be elapsed (between calls of `startAnimating()` and `stopAnimating()`) in order to actually display UI blocker. It should be set thinking about what the minimum duration of an activity is to be worth showing it to the user. If the activity ends before this time threshold, then it will not be displayed at all.
    public static var DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD = 0

    /// Default minimum display time of UI blocker. Default value is 0 ms.
    ///
    /// - note:
    /// Default minimum display time of UI blocker. Its main purpose is to avoid flashes showing and hiding it so fast. For instance, setting it to 200ms will force UI blocker to be shown for at least this time (regardless of calling `stopAnimating()` ealier).
    public static var DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME = 0

    /// Default message displayed in UI blocker. Default value is nil.
    public static var DEFAULT_BLOCKER_MESSAGE: String?

    /// Default message spacing to activity indicator view in UI blocker. Default value is 8.
    public static var DEFAULT_BLOCKER_MESSAGE_SPACING = CGFloat(8.0)

    /// Default font of message displayed in UI blocker. Default value is bold system font, size 20.
    public static var DEFAULT_BLOCKER_MESSAGE_FONT = UIFont.boldSystemFont(ofSize: 20)

    /// Default background color of UI blocker. Default value is UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    public static var DEFAULT_BLOCKER_BACKGROUND_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

    /// Default fade in animation.
    public static var DEFAULT_FADE_IN_ANIMATION: FadeInAnimation = { view in
        view.alpha = 0
        UIView.animate(withDuration: 0.25) {
            view.alpha = 1
        }
    }

    /// Default fade out animation.
    public static var DEFAULT_FADE_OUT_ANIMATION: FadeOutAnimation = { (view, complete) in
        UIView.animate(withDuration: 0.25,
                       animations: {
                        view.alpha = 0
                       },
                       completion: { completed in
                        if completed {
                            complete()
                        }
                       })
    }

    /// Color of activity indicator view.
    @IBInspectable public var color: UIColor = ActivityIndicatorView.DEFAULT_COLOR

    /// Padding of activity indicator view.
    @IBInspectable public var padding: CGFloat = ActivityIndicatorView.DEFAULT_PADDING

    /// Current status of animation, read-only.
    @available(*, deprecated)
    public var animating: Bool { return isAnimating }

    /// Current status of animation, read-only.
    private(set) public var isAnimating: Bool = false

    /**
     Returns an object initialized from data in a given unarchiver.
     self, initialized using the data in decoder.

     - parameter decoder: an unarchiver object.

     - returns: self, initialized using the data in decoder.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        isHidden = true
    }

    /**
     Create a activity indicator view.

     Appropriate ActivityIndicatorView.DEFAULT_* values are used for omitted params.

     - parameter frame:   view's frame.
     - parameter type:    animation type.
     - parameter color:   color of activity indicator view.
     - parameter padding: padding of activity indicator view.

     - returns: The activity indicator view.
     */
    public init(frame: CGRect,  color: UIColor? = nil, padding: CGFloat? = nil) {
        self.color = color ?? ActivityIndicatorView.DEFAULT_COLOR
        self.padding = padding ?? ActivityIndicatorView.DEFAULT_PADDING
        super.init(frame: frame)
        isHidden = true
    }

    // Fix issue #62
    // Intrinsic content size is used in autolayout
    // that causes mislayout when using with MBProgressHUD.
    /**
     Returns the natural size for the receiving view, considering only properties of the view itself.

     A size indicating the natural size for the receiving view based on its intrinsic properties.

     - returns: A size indicating the natural size for the receiving view based on its intrinsic properties.
     */
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: bounds.height)
    }

    public override var bounds: CGRect {
        didSet {
            // setup the animation again for the new bounds
            if oldValue != bounds && isAnimating {
                setUpAnimation()
            }
        }
    }

    /**
     Start animating.
     */
    public final func startAnimating() {
        guard !isAnimating else {
            return
        }
        isHidden = false
        isAnimating = true
        layer.speed = 1
        setUpAnimation()
    }

    //alias
    public final func show() {
        startAnimating()
    }

    public final func hide() {
        stopAnimating()
    }

    /**
     Stop animating.
     */
    public final func stopAnimating() {
        guard isAnimating else {
            return
        }
        isHidden = true
        isAnimating = false
        layer.sublayers?.removeAll()
    }

    // MARK: Privates

    private final func setUpAnimation() {
        var animationRect = frame.inset(by: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        let minEdge = min(animationRect.width, animationRect.height)

        layer.sublayers = nil
        animationRect.size = CGSize(width: minEdge, height: minEdge)
        IndicatorShape.setUpAnimation(in: layer, size: animationRect.size, color: color)
    }

    static var indicator: ActivityIndicatorView?
    private(set) var stateLabel: UILabel?

    static func showActivity(topView: UIView,
                             color: UIColor = Theme.buttonActiveColor,
                             text: String = "Loading...".localized()) {
        hideActivity()

        let rect = CGRect(x: topView.bounds.midX, y: topView.bounds.midY,
                          width: 100, height: 100)

        let view = ActivityIndicatorView(frame: rect, color: color)
        topView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        view.centerXAnchor.constraint(equalTo: topView.centerXAnchor).isActive = true
        view.startAnimating()


        let loadingLabel = UILabel()
        loadingLabel.text = text
        loadingLabel.font = UIFont.boldSystemFont(ofSize: 20)
        loadingLabel.textColor = color
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingLabel)
        loadingLabel.topAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.stateLabel = loadingLabel
        ActivityIndicatorView.indicator = view
    }

    static func hideActivity() {
        ActivityIndicatorView.indicator?.removeFromSuperview()
        ActivityIndicatorView.indicator = nil
    }
}
