//
//  AppUtility.swift
//  Utmostu
//
//  Created by SOTSYS138 on 17/03/17.
//  Copyright © 2017 Sohil Memon. All rights reserved.
//

import UIKit
import Alamofire

//Global Instances
//var sideMenuController: SideMenuController?
let appDel = UIApplication.shared.delegate as! AppDelegate
let defaults = UserDefaults.standard

struct AppUtility {
    
    //MARK: Available Fonts in Project
    
    static func printMyFonts() {
        print("--------- Available Font names ----------")
        for name in UIFont.familyNames {
            print(name)
            print(UIFont.fontNames(forFamilyName: name))
        }
    }
    
    //MARK: Alerts
    
    static func showSimpleAlert(withMessage message: String, yesCompletionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: Constants.APP_NAME, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: yesCompletionHandler))
        appDel.window!.rootViewController!.present(alertController, animated: true, completion: nil)
    }
    
    static func showSimpleAlert(withTitle title: String, andMessage message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        appDel.window!.rootViewController!.present(alertController, animated: true, completion: nil)
    }
    
    static func showYesNoAlert(withMessage message: String, yesCompletionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: Constants.APP_NAME, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: yesCompletionHandler))
        alertController.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        appDel.window!.rootViewController!.present(alertController, animated: true, completion: nil)
    }
    
    static func showSimpleAlertOn(currentVC vc: UIViewController, withMessage message: String, yesCompletionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: Constants.APP_NAME, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: yesCompletionHandler))
        vc.present(alertController, animated: true, completion: nil)
    }
    
    static func showYesNoAlertOn(currentVC vc: UIViewController, withMessage message: String, yesCompletionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: Constants.APP_NAME, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: yesCompletionHandler))
        vc.present(alertController, animated: true, completion: nil)
    }
    
    //Static Alerts
    static func showNoNetworkAlert() {
        let alertController = UIAlertController(title: Constants.APP_NAME, message: KeyMessages.ALERT_NO_NETWORK, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        appDel.window!.rootViewController!.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Dispatch Queue
    static func mainQueue(withCompletion completion:@escaping () -> Void) {
        DispatchQueue.main.async(execute: completion)
    }
    
    static func createQueue(withDelay seconds: Double, _ completion:@escaping () -> Void){
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
    }
    
    static func dispatchMainAfter(time : DispatchTime , execute :@escaping (() -> Void)) {
        DispatchQueue.main.asyncAfter(deadline: time, execute: execute)
    }
    
    //MARK: Print Debug Functions
    static func printValues(_ vc: UIViewController, _ values: Any?) {
        print(String(describing: vc.self) + " : " + values.debugDescription)
    }
    
    //MARK: Loaders
    static func showLoader(withTitle title: String? = "Loading...") {
        DispatchQueue.main.async {
            SwiftLoader.show(title: title, animated: true)
        }
    }
    
    static func hideLoader() {
        SwiftLoader.hide()
    }
    
    //MARK: Check Internet Connection
    static var isInternetAvailable: Bool {
        get {
            return NetworkReachabilityManager()!.isReachable
        }
    }
    
    //MARK: Logout From the app
    static func logoutFromApp() {
        let deviceToken = defaults.string(forKey: Constants.DEVICE_TOKEN)
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        defaults.setPersistentDomain(["":""], forName: Bundle.main.bundleIdentifier!)
        defaults.set(deviceToken, forKey: Constants.DEVICE_TOKEN)
    }
}
