//
//  Helper.swift
//  RIPL
//
//  Created by SOTSYS210 on 05/01/18.
//  Copyright © 2018 SOTSYS210. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias ServiceResponse = (_ responseData: NSDictionary?, _ error: NSError?) -> Void

class Helper: NSObject {

    static func isValidEmail(strEmail:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: strEmail)
    }
    
    static func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    static func saveImageDocumentDirectory(img: UIImage, imageName: String) -> String {
        let fileManager = FileManager.default
        let timeStamp = self.convertDateTimeToTimeStamp(dateString: "")
        var strName = imageName
        if strName == ""{
            strName = timeStamp+".png"
        }
        let paths = (self.getDirectoryPath() as NSString).appendingPathComponent(strName)
        let image = img
        print(paths)
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
        return paths
    }
    
    static func saveImageFromURLDocumentDirectory(imgData: Data, imageName: String){
        let fileManager = FileManager.default
        let timeStamp = self.convertDateTimeToTimeStamp(dateString: "")
        var strName = imageName
        if strName == ""{
            strName = timeStamp+".png"
        }
        let paths = (self.getDirectoryPath() as NSString).appendingPathComponent(strName)
        print(paths)
        fileManager.createFile(atPath: paths as String, contents: imgData, attributes: nil)
    }
    
    static func getImageFromDocumentsDirectory(imageName: String) -> UIImage? {
        var image: UIImage?
        let fileManager = FileManager.default
        let imagePath = (self.getDirectoryPath() as NSString).appendingPathComponent(imageName)
        if fileManager.fileExists(atPath: imagePath){
            image = UIImage(contentsOfFile: imagePath)
            return image!
        }else{
            print("No Image")
            return nil
        }
    }
    
    static func saveVideoDocumentDirectory(videoURL: URL, videoName: String) -> String {
        let fileManager = FileManager.default
        let timeStamp = self.convertDateTimeToTimeStamp(dateString: "")
        var strName = videoName
        if strName == ""{
            strName = timeStamp+".mp4"
        }
        let paths = (self.getDirectoryPath() as NSString).appendingPathComponent(strName)
        
        let videoData = NSData(contentsOf: videoURL)
        print(paths)
        fileManager.createFile(atPath: paths as String, contents: videoData as Data?, attributes: nil)
        return paths
    }
    
    static func convertDateTimeToTimeStamp(dateString: String) -> String{
        var date: NSDate!
        if dateString.count > 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy hh:mm a"
            date = dateFormatter.date(from: dateString) as NSDate!
        }else{
            date = NSDate()
        }
        if date == nil{
            date = NSDate()
        }
        let timeStampDate = date!.timeIntervalSince1970 * 1
        print(timeStampDate)
        return String(timeStampDate)
    }
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
