//
//  Extensions.swift
//  Utmostu
//
//  Created by SOTSYS138 on 18/03/17.
//  Copyright © 2017 Sohil Memon. All rights reserved.
//

import UIKit

//MARK: String

extension String{
    
    var checkIsEmpty: Bool {
        get {
            if self.isEmpty || self.trimSpaceCount() == 0 {
                return true
            }
            return false
        }
    }
    
    func trimSpaceCount() -> Int{
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count
    }
    
    func convertStringToDictionary() -> Dictionary<String, AnyObject>? {
        if let data = self.data(using: String.Encoding.utf8) {
            print(self)
            do {
                return try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? Dictionary<String, AnyObject>
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    func stripSpecialCharacters() -> String {
        let chars: Set<Character> =
            Set("1234567890".characters)
        return String(self.characters.filter {chars.contains($0)})
    }
    
}

//MARK: UIViewController

//Generate UIViewController Instance from Storyboard Identifier

protocol StoryboardIdentifiable {
    static var storyboardIdentifier: String { get }
}

extension StoryboardIdentifiable where Self: UIViewController {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
}

extension UIStoryboard {
    
    public class func instantiateViewController <T: UIViewController>(type: T.Type, storyboardIdentifier: String = "Main") -> T {
        let storyboard = UIStoryboard(name: storyboardIdentifier, bundle: nil)
        return storyboard.instantiateViewController(type: type)
    }
    
    public func instantiateViewController <T: UIViewController>(type: T.Type) -> T {
        return instantiateViewController(withIdentifier: String(describing: type)) as! T
    }
    
}

extension UIViewController {
    
    public class func instantiateFromStoryboard(storyboardName: String = "Main") -> Self {
        return UIStoryboard.instantiateViewController(type: self, storyboardIdentifier: storyboardName)
    }
}
