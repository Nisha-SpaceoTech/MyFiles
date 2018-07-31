//
//  APIRequest.swift
//  Utmostu
//
//  Created by SOTSYS138 on 06/04/17.
//  Copyright © 2017 Sohil Memon. All rights reserved.
//

import UIKit
import Alamofire
import Foundation

struct APIRequest {
    
    static func get(_ url: String, success apiSuccess: @escaping (_ dict: Dictionary<String, Any>?) -> Void, failure apiFailure: @escaping (_ error: Error?) -> Void) {

        let headers: HTTPHeaders = ["AuthToken": defaults.string(forKey: Constants.AUTH_TOKEN) ?? "no_auth_key"]
        Alamofire.request(url, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (responseObject) in
            if responseObject.result.isSuccess {
                if let dict = responseObject.result.value as? Dictionary<String, Any> {
                    apiSuccess(dict)
                } else {
                    apiSuccess(nil)
                }
            } else if responseObject.result.isFailure {
                if let error = responseObject.result.error {
                    apiFailure(error)
                }
            }
        }
    }
    
    static func post(_ url: String, _ paramaters: Dictionary<String, Any>, success apiSuccess: @escaping (_ dict: Dictionary<String, Any>?) -> Void, failure apiFailure: @escaping (_ error: Error?) -> Void) {
        let headers: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded","AuthToken": defaults.string(forKey: Constants.AUTH_TOKEN) ?? "no_auth_key"]
        let apiUrl = URL(string: url)
        Alamofire.request(apiUrl!, method: HTTPMethod.post, parameters: paramaters, encoding: URLEncoding.default, headers: headers).responseJSON { (responseObject) in
            if responseObject.result.isSuccess {
                if let dict = responseObject.result.value as? Dictionary<String, Any> {
                    apiSuccess(dict)
                } else {
                    apiSuccess(nil)
                }
         
            } else if responseObject.result.isFailure {
                if let error = responseObject.result.error {
                    apiFailure(error)
                }
            }
        }
    }
    
    static func put(_ url: String, _ paramaters: Dictionary<String, Any>?, success apiSuccess: @escaping (_ dict: Dictionary<String, Any>?) -> Void, failure apiFailure: @escaping (_ error: Error?) -> Void) {
        let headers: HTTPHeaders = ["AuthToken": defaults.string(forKey: Constants.AUTH_TOKEN) ?? "no_auth_key"]
        let apiUrl = URL(string: url)
        Alamofire.request(apiUrl!, method: HTTPMethod.put, parameters: paramaters, encoding: URLEncoding.default, headers: headers).responseJSON { (responseObject) in
            if responseObject.result.isSuccess {
                if let dict = responseObject.result.value as? Dictionary<String, Any> {
                    apiSuccess(dict)
                } else {
                    apiSuccess(nil)
                }
                
            } else if responseObject.result.isFailure {
                if let error = responseObject.result.error {
                    apiFailure(error)
                }
            }
        }
    }

    static func postWebservieImgUploadAPI(strUrl: String?, param: [String: AnyObject]?, imageKeyandPath: [String: String], completionHandler: @escaping (NSDictionary?, NSError?) -> ()) -> (){
        if AppUtility.isInternetAvailable {
            let request = createRequest(type: "POST", apiUrl: strUrl!, param: param!, imagePath: imageKeyandPath)
            let config = URLSessionConfiguration.default
            let headers: HTTPHeaders = ["AuthToken": defaults.string(forKey: Constants.AUTH_TOKEN) ?? "no_auth_key"]
            
            config.httpAdditionalHeaders = headers
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                if error != nil {
                    // handle error here
                    print(error!)
                    return
                }
                
                // if response was JSON, then parse it
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    do{
                        if data != nil{
                            
                            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                            
                            if let parseJSON = json {
                                
                                // Parsed JSON
                                completionHandler(parseJSON, nil)
                            }
                            else {
                                // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                                
                                #if DEBUG
                                    print("Error could not parse JSON: \(String(describing: jsonStr))")
                                #endif
                            }
                        }else{
                            
                            completionHandler(nil, error as NSError?)
                        }
                        
                    }catch let error as NSError{
                        
                        print(error.localizedDescription)
                        completionHandler(nil, error)
                    }
                })
            }
            task.resume()
        }else{
            //            helperInstance.displayInformationAlert(msg: appConstants.kNoInternet)
        }
    }
    
    static func createRequest (type: String, apiUrl: String, param: [String: AnyObject], imagePath: [String: String]) -> NSURLRequest {
        // build your dictionary however appropriate
        let boundary = generateBoundaryString()
        let url = NSURL(string: apiUrl)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = type //"POST"
        request.timeoutInterval = 240
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBodyWithParameters(parameters: param, imgParamaters: imagePath, boundary: boundary) as Data
        return request
    }
    
    static func createBodyWithParameters(parameters: [String: AnyObject]?, imgParamaters : [String : String]?, boundary: String) -> NSData {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        if imgParamaters != nil {
            
            for (key, value) in imgParamaters! {
                
                let url = NSURL(fileURLWithPath: value)
                let filename = url.lastPathComponent
                let data = NSData(contentsOfFile: value)!
                let mimetype = mimeTypeForPath(path: value)
                
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(filename!)\"\r\n")
                body.appendString("Content-Type: \(mimetype)\r\n\r\n")
                body.append(data as Data)
                body.appendString("\r\n")
            }
        }
        
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    
    static func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    static func mimeTypeForPath(path: String) -> String {
        let url = NSURL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension! as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream";
    }
    
}

extension NSMutableData {
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
