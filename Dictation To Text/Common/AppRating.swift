//
//  AppRating.swift
//  Drum Pad Beat Maker - Music Production
//
//  Created by Artem Sherbachuk on 12/22/20.
//

import UIKit
import StoreKit

public enum AppRating {

    // MARK: - Types

    public struct Request {
        let afterAppLaunches: Int
        let customAlertTitle: String
        let customAlertMessage: String
        let customAlertActionCancel: String

        public init(afterAppLaunches: Int,
                    customAlertTitle: String,
                    customAlertMessage: String,
                    customAlertActionCancel: String) {
            self.afterAppLaunches = afterAppLaunches
            self.customAlertTitle = customAlertTitle
            self.customAlertMessage = customAlertMessage
            self.customAlertActionCancel = customAlertActionCancel
        }
    }

    // MARK: - Properties

    private static let iTunesBaseURL = UIDevice.current.userInterfaceIdiom == .tv ?
        "com.apple.TVAppStore://itunes.apple.com/app/id" : "itms-apps://itunes.apple.com/app/id"

    private static let dataURL = "http://itunes.apple.com/lookup?bundleId=\(Bundle.main.bundleIdentifier ?? "-")"
    private static var appID: Int = 1566596774

    private static var isRemoved: Bool {
        get { return UserDefaults.standard.bool(forKey: "SwiftyRateIsRemovedKey") }
        set { UserDefaults.standard.set(newValue, forKey: "SwiftyRateIsRemovedKey") }
    }

    private static var requestCounter: Int {
        get { return UserDefaults.standard.integer(forKey: "SwiftyRateRequestCounterKey") }
        set { UserDefaults.standard.set(newValue, forKey: "SwiftyRateRequestCounterKey") }
    }

    private static var alertsShownThisYear: Int {
        get { return UserDefaults.standard.integer(forKey: "SwiftyRateShownThisYearKey") }
        set { UserDefaults.standard.set(newValue, forKey: "SwiftyRateShownThisYearKey") }
    }

    private static var savedMonth: Int {
        get { return UserDefaults.standard.integer(forKey: "SwiftyRateSavedMonthKey") }
        set { UserDefaults.standard.set(newValue, forKey: "SwiftyRateSavedMonthKey") }
    }

    private static var savedYear: Int {
        get { return UserDefaults.standard.integer(forKey: "SwiftyRateSavedYearKey") }
        set { UserDefaults.standard.set(newValue, forKey: "SwiftyRateSavedYearKey") }
    }

    // MARK: - Request

    /// Request rate app alert
    ///
    /// - parameter request: The request configuration model.
    /// - parameter viewController: The view controller that will present the UIAlertController.
    public static func requestReview(_ request: Request, from viewController: UIViewController) {

        // Make sure app launches is not set to 0 or lower
        var appLaunchesUntilFirstAlert = request.afterAppLaunches

        if appLaunchesUntilFirstAlert <= 0 {
            appLaunchesUntilFirstAlert = 15
        }

        // Show alert
        guard !isRemoved,
              isTimeToShowAlert(forAppLaunches: appLaunchesUntilFirstAlert) else {
            return
        }

        let alertController = UIAlertController(
            title: request.customAlertTitle,
            message: request.customAlertMessage,
            preferredStyle: .alert
        )

        let rateAction = UIAlertAction(title: "Yes!".localized(),
                                       style: .default) { _ in
            isRemoved = true
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                return
            }
        }
        alertController.addAction(rateAction)

        let cancelAction = UIAlertAction(title: request.customAlertActionCancel, style: .default)
        alertController.addAction(cancelAction)

        DispatchQueue.main.async {
            viewController.present(alertController, animated: true)
        }
    }
}

// MARK: - Check If Time To Show Alert
private extension AppRating {

    static func isTimeToShowAlert(forAppLaunches appLaunchesUntilFirstAlert: Int) -> Bool {

        // Get date
        let date = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US") // Set local to US so it always returns an english formatted number
        formatter.dateFormat = "MM.yyyy"
        let dateResult = formatter.string(from: date)

        // Get month string
        guard let monthString = dateResult.components(separatedBy: ".").first else {
            print("SwiftyRate month string error")
            return false
        }

        // Get month int
        guard let month = Int(monthString) else {
            print("SwiftyRate month int error")
            return false
        }

        // Get year string
        guard let yearString = dateResult.components(separatedBy: ".").last else {
            print("SwiftyRate year string error")
            return false
        }

        // Get year int
        guard let year = Int(yearString) else {
            print("SwiftyRate year int error")
            return false
        }

        // Update saved month/year if never set before
        if savedMonth == 0 {
            savedMonth = month
        }

        if savedYear == 0 {
            savedYear = year
        }

        // If year has changed reset everthing
        if year > savedYear {
            savedYear = year
            alertsShownThisYear = 0
            requestCounter = 0
        }

        // Check that max number of 3 alerts shown per year is not reached
        guard alertsShownThisYear < 3 else { return false }

        // Update request counter
        requestCounter += 1

        // Show alert if needed
        if requestCounter == appLaunchesUntilFirstAlert {
            alertsShownThisYear += 1
            savedMonth = month
            return true
        } else if requestCounter > appLaunchesUntilFirstAlert, month >= (savedMonth + 4) {
            alertsShownThisYear += 1
            savedMonth = month
            return true
        }

        // No alert is needed to show
        return false
    }
}
