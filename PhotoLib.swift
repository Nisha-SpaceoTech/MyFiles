//
//  PhotoLib.swift
//  RIPL
//
//  Created by SOTSYS210 on 21/03/18.
//  Copyright © 2018 SOTSYS210. All rights reserved.
//

import UIKit
import Photos

struct PhotoLib {
    
    //MARK: Variables
    static let phImgManager = PHImageManager.default()
    
    //MARK: Request Photo Library Permission
    
    static func requestPermissionToAccessPhotoLibrary(completion: @escaping(_ errorMessage: String?, _ isPermissionGranted: Bool) -> ()) {
        //Get the current authorizatin state
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == .authorized){
            //Access has been granted
            completion(nil, true)
        }else if (status == .denied) {
            // Access has been denied.
            completion("Photos permission denied.", false)
        }else if (status == .notDetermined) {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == .authorized) {
                    //Access has been granted
                    completion(nil, true)
                }else if (status == .denied) {
                    // Access has been denied.
                    completion("Photos permission denied.", false)
                }else if (status == .restricted) {
                    // Restricted access - normally won't happen.
                    completion("Photos permission restricted.", false)
                }
            })
        }else if (status == .restricted){
            // Restricted access - normally won't happen.
            completion("Photos permission restricted.", false)
        }
    }
    
    //MARK: - Fetch All PHAsset
    static func fetchAllAssets(withOptions options: PHFetchOptions) -> [PHAsset]{
        options.includeAssetSourceTypes = .typeUserLibrary
        var assets = [PHAsset]()
        let fetchResult = PHAsset.fetchAssets(with: options)
        fetchResult.enumerateObjects { (asset : PHAsset, index: Int, umPointer: UnsafeMutablePointer<ObjCBool>) in
            assets.append(asset)
        }
        return assets
    }
    
    static func fetchAllPhotos() -> [PHAsset] {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        //fetchOptions.fetchLimit = 100
        fetchOptions.includeAssetSourceTypes = .typeUserLibrary
        var assets = [PHAsset]()
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        fetchResult.enumerateObjects({ (asset: PHAsset, index: Int, umPointer: UnsafeMutablePointer<ObjCBool>) in
            if asset.mediaSubtypes.rawValue != 4{
                assets.append(asset)
            }
        })
        return assets
    }
    
    static func fetchAllVideos() -> [PHAsset]{
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d",
                                             PHAssetMediaType.video.rawValue)
        //fetchOptions.fetchLimit = 100
        fetchOptions.includeAssetSourceTypes = .typeUserLibrary
        var assets = [PHAsset]()
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        fetchResult.enumerateObjects({ (asset: PHAsset, index: Int, umPointer: UnsafeMutablePointer<ObjCBool>) in
            if asset.mediaSubtypes.rawValue != 4{
                assets.append(asset)
            }
        })
        return assets
    }
    
    //MARK: Fetch PHAsset of specific type
    static func fetchAssets(ofType type: PHAssetMediaType, withOptions options: PHFetchOptions?) -> [PHAsset] {
        options?.includeAssetSourceTypes = .typeUserLibrary
        var assets = [PHAsset]()
        let fetchResult = PHAsset.fetchAssets(with: type, options: options)
        fetchResult.enumerateObjects({ (asset: PHAsset, index: Int, umPointer: UnsafeMutablePointer<ObjCBool>) in
            assets.append(asset)
        })
        return assets
    }
    
    //MARK: Get the Thumbnail from the PHAsset
    static func loadThumbnail(fromAsset asset: PHAsset, ofSize size: CGSize? = CGSize(width: 150, height: 150), completion: @escaping (UIImage?) -> ()) {
        phImgManager.requestImage(for: asset, targetSize: size!, contentMode: PHImageContentMode.default, options: PHImageRequestOptions()) { (image, info) in
            completion(image)
        }
    }
    
    //MARK: Get the Original Image from the PHAsset *SYNC*
    static func loadOriginalImage(fromAsset asset: PHAsset, ofSize size: CGSize? = PHImageManagerMaximumSize, completion: @escaping (UIImage?) -> ()) {
        let imageRequestOptions: PHImageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isSynchronous = true
        imageRequestOptions.isNetworkAccessAllowed = true
        phImgManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: PHImageContentMode.default, options: imageRequestOptions) { (image, info) in
            completion(image)
        }
    }
    
    //MARK: Request AVAsset for PHAsset
    static func requestVideoUrl(forPHAsset phAsset: PHAsset, completion: @escaping (_ videoAsset: AVAsset?) -> ()) {
        let videoRequestOptions: PHVideoRequestOptions = PHVideoRequestOptions()
        videoRequestOptions.deliveryMode = .automatic
        videoRequestOptions.isNetworkAccessAllowed = true
        videoRequestOptions.version = .original
        videoRequestOptions.progressHandler = { (progress, error, stop, info) in
            
        }
        phImgManager.requestAVAsset(forVideo: phAsset, options: videoRequestOptions) { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) in
            if asset != nil{
                completion(asset)
            }
        }
    }
    
    //MARK: Get the Original AVAsset from the PHAsset *SYNC*
    static func requestVideoUrlInSync(forPHAsset phAsset: PHAsset, completion: @escaping (_ videoAsset: AVAsset?) -> ()) {
        //let semaphore = DispatchSemaphore(value: 0)
        
        let videoRequestOptions: PHVideoRequestOptions = PHVideoRequestOptions()
        videoRequestOptions.deliveryMode = .automatic
        videoRequestOptions.isNetworkAccessAllowed = true
        videoRequestOptions.version = .original
        phImgManager.requestAVAsset(forVideo: phAsset, options: videoRequestOptions) { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) in
            completion(asset)
            //    semaphore.signal()
        }
        
        // _ = semaphore.wait(timeout: DispatchTime.distantFuture)
    }
    
    static func checkVideoSize(phAsset: PHAsset) -> Float{
        let resources = PHAssetResource.assetResources(for: phAsset) // your PHAsset
        var sizeOnDisk: Int64? = 0
        if let resource = resources.first {
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong
            sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64!))
            let formatter:ByteCountFormatter = ByteCountFormatter()
            formatter.countStyle = .binary
            let strVideoSize = formatter.string(fromByteCount: sizeOnDisk!)
            let trimmedString = strVideoSize.replacingOccurrences(of: " MB", with: "")
            if let size = Float(trimmedString) {
                return size
            }
        }
        return 0.0
    }
    
    static func fetchAlbum() -> [PHAssetCollection]{
        // *** 2 ***
        // Get all user albums (with additional sort for example to only show albums with at least one photo)
        var arrAlbumCollection = [PHAssetCollection]()
        
        let userAlbumsOptions = PHFetchOptions()
        userAlbumsOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        
        let userAlbums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: userAlbumsOptions)
//        print("album count: \(userAlbums.count)")
        
        userAlbums.enumerateObjects({ (collection: PHAssetCollection, index: Int, umPointer: UnsafeMutablePointer<ObjCBool>) in
            if let collection = collection.self as? PHAssetCollection {
                arrAlbumCollection.append(collection)
            }
        })
        
        return arrAlbumCollection
        
    }
    
    static func getAssetFromAlbum(_ collection : PHAssetCollection) -> [PHAsset]{
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d || mediaType == %d",
                                             PHAssetMediaType.image.rawValue,
                                             PHAssetMediaType.video.rawValue)
        fetchOptions.includeAssetSourceTypes = .typeUserLibrary
        let fetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        
        var assets = [PHAsset]()
        fetchResult.enumerateObjects({ (asset: PHAsset, index: Int, umPointer: UnsafeMutablePointer<ObjCBool>) in
            if asset.mediaType.rawValue == 1{
                if asset.mediaSubtypes.rawValue != 4{
                    assets.append(asset)
                }
            }else if  asset.mediaType.rawValue == 2{
                if asset.mediaSubtypes.rawValue != 4{
                    assets.append(asset)
                }
            }
        })
        return assets
    }
    
    static func fetchSmartAlbum(){
        // *** 3 ***
        // Get smart albums
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil) // Here you can specify Photostream, etc. as PHAssetCollectionSubtype.xxx
        smartAlbums.enumerateObjects({ (collection: PHAssetCollection, index: Int, umPointer: UnsafeMutablePointer<ObjCBool>) in
            if let assetCollection = collection.self as? PHAssetCollection{
//                print("album title: \(String(describing: assetCollection.localizedTitle))")
                // One thing to note with Smart Albums is that collection.estimatedAssetCount can return NSNotFound if estimatedAssetCount cannot be determined. As title suggest this is estimated. If you want to be sure of number of assets you have to perform fetch and get the count like:
                
                let assetsFetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
                let numberOfAssets = assetsFetchResult.count
                let estimatedCount =  (assetCollection.estimatedAssetCount == NSNotFound) ? -1 : assetCollection.estimatedAssetCount
                print("Assets count: \(numberOfAssets), estimate: \(estimatedCount)")
            }
        })
    }
    
    static func getMediaDuration(assetDuration: TimeInterval) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: Date(timeIntervalSince1970: assetDuration))
    }

}
