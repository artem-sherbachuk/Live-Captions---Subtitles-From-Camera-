//
//  SubscriptionViewController.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 1/21/21.
//
import UIKit

private var discountEndDuration: TimeInterval = 3600

var HoursTimeFormatter: DateComponentsFormatter = {
    let formatter =  DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [ .hour, .minute, .second ]
    formatter.zeroFormattingBehavior = [ .pad ]
    return formatter
}()

final class SubscriptionViewController: BaseViewController,
                                        SubscriptionOptionViewDelegate {

    @IBOutlet weak var benefitsView: SubscriptionBenefitsStackView!

    @IBOutlet weak var subscriptionOptionsView: SubscriptionsOptionsStackView!

    @IBOutlet weak var actionButtonView: SubscriptionButtonView!

    @IBOutlet weak var closeButton: UIButton!

    @IBOutlet weak var hintLabel: UILabel!

    @IBOutlet weak var discountLabel: UILabel!

    @IBOutlet weak var discountLabelBlurView: UIVisualEffectView!

    private var discountTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        closeButton.tintColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
        benefitsView.animateAppearance()
        subscriptionOptionsView.animateAppearance()
        actionButtonView.animateAppearance()
        hintLabel.fadeIn(from: 0, to: 1, delay: 1, duration: 2)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        discountTimer?.invalidate()
        discountTimer = nil
    }

    func setup() {
        discountEndDuration = user.trialEndDate.timeIntervalSinceNow
        subscriptionOptionsView.option1.delegate = self
        subscriptionOptionsView.option2.delegate = self
        subscriptionOptionsView.option3.delegate = self
        fetchSubscriptions()
        setupDiscountTimer()
    }

    func fetchSubscriptions() {
        ActivityIndicatorView.showActivity(topView: view, color: .white)
        RevenueCat.fetchSubscriptionOptions { [weak self] subscriptions in
            ActivityIndicatorView.hideActivity()
            self?.subscriptionOptionsView.option1.borderColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1)
            self?.subscriptionOptionsView.option2.borderColor = #colorLiteral(red: 1, green: 0.8431372549, blue: 0, alpha: 1)
            self?.subscriptionOptionsView.option3.borderColor = #colorLiteral(red: 0.5563425422, green: 0.9793455005, blue: 0, alpha: 1)
            self?.subscriptionOptionsView.option1.shopItem = subscriptions?[safe: 0]
            self?.subscriptionOptionsView.option2.shopItem = subscriptions?[safe: 1]
            self?.subscriptionOptionsView.option3.shopItem = subscriptions?[safe: 2]

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self?.subscriptionOptionsView.option1.isSelected = false
                self?.subscriptionOptionsView.option2.isSelected = true
                self?.subscriptionOptionsView.option3.isSelected = false
                self?.subscriptionOptionsView.validateSelection()
            }
        }
    }

    private func setupDiscountTimer() {
        if discountEndDuration <= 0 {
            discountLabel.isHidden = true
            discountLabelBlurView.alpha = 0
            return
        }


        discountTimer?.invalidate()
        discountTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            discountEndDuration -= 1
            if discountEndDuration <= 0 {
                self?.discountTimer?.invalidate()
                self?.discountTimer = nil
            }

            let time = HoursTimeFormatter.string(from: discountEndDuration) ?? "00:00"
            let discountText = "-50% Ends in: \(time)"
            self?.discountLabel.text = discountText
        })
    }

    @IBAction func subscribeButton(sender: UIButton?) {
        guard let item = subscriptionOptionsView.selectedOption?.shopItem else {
            return
        }

        ActivityIndicatorView.showActivity(topView: view, color: .white)
        actionButtonView.removeShakingAnimation()
        RevenueCat.purchaseSubscription(package: item) { [weak self] state in
            ActivityIndicatorView.hideActivity()
            if state == .subscribed {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.actionButtonView.showIdleAnimation()
            }
        }
    }

    @IBAction func termOfUseAction(sender: UIButton) {
        guard let url = URL(string:  "https://hearing-aid-app.flycricket.io/terms.html") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func privacyPolicityAction(sender: UIButton) {
        guard let url = URL(string: "https://hearing-aid-app.flycricket.io/privacy.html") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @IBAction func closeAction(sender: UIButton) {
        let title = "Are you sure?".localized()
        let description = "Are you sure you want to miss out on this amazing opportunity? This free trial offer is available right here".localized()
        let leftAction = "No, Thanks".localized()
        let rightAction = "Yes!".localized()
        presentAlert(controller: self, title: title, message: description, leftActionTitle: leftAction, rightActionTitle: rightAction, leftActionStyle: .destructive, rightActionStyle: .default)
        { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        } rightActionCompletion: { [weak self] in
            self?.subscribeButton(sender: nil)
        }
    }

    func didSelect(shopItem: ShopItem, fromView view: SubscriptionOptionView) {
        actionButtonView.layer.borderColor = view.borderColor.cgColor

        if let _trial = shopItem.product.introductoryPrice,
           _trial.price == 0,
           let period = _trial.subscriptionPeriod.localizedPeriod() {
            benefitsView.setTrialTile(days: period)
            actionButtonView.setTrialTile(days: period)

            let option = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]
            let text = NSMutableAttributedString(string:"No payment required.\nFree to Try!\nCANCEL ANY TIME!".localized(), attributes:option)
            hintLabel.attributedText = text

        } else {
            benefitsView.setUnlockTile()
            actionButtonView.setUnlockTile()
            hintLabel.attributedText = NSAttributedString(string: "\n\n")
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

final class SubscriptionBenefit: SpringStackView {
    @IBOutlet weak var titleLabel: UILabel!
}

final class SubscriptionBenefitsStackView: UIStackView {

    @IBOutlet weak var titleLabel: SpringLabel!

    @IBOutlet weak var benefit1: SubscriptionBenefit!

    @IBOutlet weak var benefit2: SubscriptionBenefit!

    @IBOutlet weak var benefit3: SubscriptionBenefit!

    @IBOutlet weak var benefit4: SubscriptionBenefit!

    @IBOutlet weak var benefit5: SubscriptionBenefit!

    override func awakeFromNib() {
        super.awakeFromNib()
        setUnlockTile()
        benefit1.titleLabel.text = "Unlimited Hearing Aid Usage".localized()
        benefit2.titleLabel.text = "Unlimited Speech Recognition Usage And Offline Translations".localized()
        benefit3.titleLabel.text = "All Future Premium Updates and Features For Free".localized()
        benefit4.titleLabel.text = "Fast And Friendly Support".localized()
    }

    func animateAppearance() {
        [titleLabel, benefit1, benefit2, benefit3, benefit4].forEach({ $0?.alpha = 0 })
        titleLabel.animate(name:"fadeIn", delay: 0)
        benefit1.animate(name:"fadeIn", delay: 0.2)
        benefit2.animate(name:"fadeIn", delay: 0.35)
        benefit3.animate(name:"fadeIn", delay: 0.5)
        benefit4.animate(name:"fadeIn", delay: 0.65)
    }

    func setTrialTile(days: String) {
        titleLabel.text = "Start your Free\n\(days.uppercased()) Access".localized()
    }

    func setUnlockTile() {
        titleLabel.text = "Unlock Access".localized()
    }
}

final class SubscriptionsOptionsStackView: UIStackView, UIGestureRecognizerDelegate {

    @IBOutlet weak var option1: SubscriptionOptionView!

    @IBOutlet weak var option2: SubscriptionOptionView!

    @IBOutlet weak var option3: SubscriptionOptionView!

    var allOptions: [SubscriptionOptionView] {
        return [option1, option2, option3]
    }

    var selectedOption: SubscriptionOptionView? {
        return allOptions.filter({ $0.isSelected }).first
    }

    func animateAppearance() {
        animateOption1()
        animateOption2()
        animateOption3()
    }

    private func animateOption1() {
        let name = iPhone ? "squeezeRight" : "pop"
        option1.animate(name: name, curve: "liniar", duration: 0.7)
    }

    private func animateOption2() {
        let name = iPhone ? "squeezeLeft" : "pop"
        option2.animate(name: name, curve: "liniar", delay: 0.4,
                              duration: 0.7)
    }

    private func animateOption3() {
        let name = iPhone ? "squeezeRight" : "pop"
        option3.animate(name: name, curve: "liniar", delay: 0.6,
                        duration: 0.7)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(selectionAction(sender:)))
        tap.delegate = self
        addGestureRecognizer(tap)
    }

    @objc private func selectionAction(sender: UITapGestureRecognizer) {
        let point = sender.location(in: self)
        allOptions.forEach({ option in
            option.isSelected = false
            selectIf(point: point, inside: option)
        })
        validateSelection()
    }

    private func selectIf(point: CGPoint, inside option: SubscriptionOptionView) {
        if option.point(inside: convert(point, to: option), with: nil) {
            option.isSelected = true
        }
    }

    func validateSelection() {
        //in case of touch made in the spacing between options. not real case but...
        if selectedOption == nil {
            option1.isSelected = true
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


protocol SubscriptionOptionViewDelegate: AnyObject {
    func didSelect(shopItem: ShopItem, fromView view: SubscriptionOptionView)
}

final class SubscriptionOptionView: SpringStackView {

    var shopItem: ShopItem? {
        didSet {
            setupShopItem()
        }
    }

    @IBOutlet weak var titleLabel: SpringLabel!

    @IBOutlet weak var checkmarkImageView: SpringImageView!

    @IBOutlet weak var oldPriceLabel: SpringLabel!

    @IBOutlet weak var costLabel: SpringLabel!

    @IBOutlet weak var discountLabel: SpringLabel!

    private var blurView: UIVisualEffectView?

    var borderColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.5)

    weak var delegate: SubscriptionOptionViewDelegate?

    var isSelected: Bool = false {
        didSet {
            if isSelected {
                checkmarkImageView.isHidden = false
                animateSelection()

                if let shopItem = shopItem {
                    delegate?.didSelect(shopItem: shopItem, fromView: self)
                }

            } else {
                checkmarkImageView.isHidden = true
                transform = CGAffineTransform(scaleX: 0.87, y: 0.87)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        checkmarkImageView.isHidden = true
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blurView?.layer.masksToBounds = true
        blurView?.layer.cornerRadius = cornerRadius
        blurView?.layer.borderWidth = 2
        blurView?.layer.borderColor = borderColor.cgColor
        insertSubview(blurView!, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let bgFrame = CGRect(x: -4, y: -4,
                             width: bounds.width + 8, height: bounds.height + 8)
        blurView?.frame = bgFrame
    }

    func animateSelection() {
        scale(from: 0.87, to: 1)
        checkmarkImageView.animate(name: "pop")
        titleLabel.animate(name: "pop", delay: 0.3)
        oldPriceLabel.animate(name: "pop", delay: 0.5)
        costLabel.animate(name: "pop", delay: 0.6)
        discountLabel.animate(name: "pop", delay: 0.7)
    }

    private func numberFormatterFor(shopItem: ShopItem) -> NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = shopItem.product.priceLocale
        return currencyFormatter
    }

    private func setupShopItem() {
        guard let shopItem = shopItem else {
            isHidden = true
            return
        }

        blurView?.layer.borderColor = borderColor.cgColor
        titleLabel.textColor = borderColor
        isHidden = false

        let period = shopItem.product.subscriptionPeriod
        let periodTitle = period?.localizedPeriod() ?? "Lifetime"
        costLabel.text = shopItem.localizedPriceString
        titleLabel.text = periodTitle.uppercased()

        let oldPrice = numberFormatterFor(shopItem: shopItem).string(from: NSNumber(value:shopItem.product.price.doubleValue * 2)) ?? ""
        let oldPriceString: NSMutableAttributedString =  NSMutableAttributedString(string: oldPrice)
        oldPriceString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, oldPriceString.length))
        oldPriceLabel.attributedText = oldPriceString

        let price = shopItem.product.price.floatValue
        if shopItem.product.productIdentifier == RevenueCat.monthlyId {
            discountLabel.isHidden = false
            let monthlyStr = numberFormatterFor(shopItem: shopItem).string(from: NSNumber(value:price / 4)) ?? ""
            discountLabel.text = "\(monthlyStr) Week"
        } else if shopItem.product.productIdentifier == RevenueCat.annualId {
            discountLabel.isHidden = false
            let monthlyStr = numberFormatterFor(shopItem: shopItem).string(from: NSNumber(value:price / 12)) ?? ""
            discountLabel.text = "\(monthlyStr) Month"
        }
    }
}

final class SubscriptionButtonView: SpringVisualEffectView {

    @IBOutlet weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.5)
        transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        setUnlockTile()
    }

    func showIdleAnimation() {
        addShakingAnimation(speed: 1.01)
    }

    @IBAction func buttonAction(sender: UIButton) {
        animate(name:"pop")
    }

    func animateAppearance() {
        let name = iPhone ? "squeezeRight" : "pop"
        animate(name: name, curve: "liniar", delay: 0.7, duration: 0.7)
        showIdleAnimation()
    }


    func setTrialTile(days: String) {
        button.setTitle("Start Free \(days.uppercased()) Access".localized(), for: .normal)
    }

    func setUnlockTile() {
        button.setTitle("Unlock Access".localized(), for: .normal)
    }
}

private let cornerRadius: CGFloat = 5
