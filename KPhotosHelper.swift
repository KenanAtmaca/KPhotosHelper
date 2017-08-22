//
//  KPhotosHelper
//
//  Copyright © 2017 Kenan Atmaca. All rights reserved.
//  kenanatmaca.com
//
//

import UIKit
import Photos

class KPhotosHelper {
    
    private lazy var manager = PHImageManager.default()
    private var requestOptions:PHImageRequestOptions!
    private var fetchOptions:PHFetchOptions!
    private lazy var cacheManager = PHCachingImageManager()

    var imagesAsset:[PHAsset] = [] {
        willSet {
            cacheManager.stopCachingImagesForAllAssets()
        }
        didSet {
            cacheManager.startCachingImages(for: self.imagesAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil)
        }
    }
    
    var images:[UIImage] = []
    
    init() {
        
        PHPhotoLibrary.requestAuthorization { (status) in
            ()
        }
    }
    
    @discardableResult
    func fetchImage(size:CGSize) -> [UIImage]? {
        
        guard requestAuthStatus() else {
            return nil
        }
        
        images = []
        imagesAsset = []
        
        requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let fetchResult:PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) as PHFetchResult! {
  
            if fetchResult.count > 0 {
                
                for i in 0..<fetchResult.count {
                    
                    imagesAsset.append(fetchResult[i])
                    manager.requestImage(for: fetchResult.object(at: i) as PHAsset, targetSize: size, contentMode: .aspectFit, options: requestOptions, resultHandler: { (img, dat) in
                        
                        self.images.append(img!)
                        
                    })
                }
            }
        }
   
        return images
    }
    
    func loadCacheImage(asset:PHAsset,size:CGSize) -> UIImage? {
        
        guard requestAuthStatus() else {
            return nil
        }
        
        var dataImg:UIImage?
        
        cacheManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { (data, nil) in
            
            dataImg = data
        }
        
        return dataImg
    }
   
    @discardableResult
    func fetchImageWithAlbum(size:CGSize,album:String) -> [UIImage]? {
        
        guard requestAuthStatus() else {
            return nil
        }
        
        images = []
        imagesAsset = []
        
        requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        
        fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(format: "title = %@", album)
        
        if let fetchResult:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions) as PHFetchResult! {
            
            if fetchResult.count > 0 {
                
                if let fAlbum = fetchResult.firstObject {
                    
                    let assetColection = PHAsset.fetchAssets(in: fAlbum, options: nil)
                    
                    for i in 0..<assetColection.count {
                        
                        imagesAsset.append(assetColection[i])
                        manager.requestImage(for: assetColection.object(at: i) as PHAsset, targetSize: size, contentMode: .aspectFit, options: requestOptions, resultHandler: { (img, dat) in
                            
                            self.images.append(img!)
                            
                        })
                    }
                }
            }
        }
        
        return images
    }
    
    
    func saveImage(image:UIImage,completion:((_ id :String?) -> ())?) {
        
        guard requestAuthStatus() else {
            return
        }
        
        var imageId: String?
        
        PHPhotoLibrary.shared().performChanges({
            
            let cReq = PHAssetChangeRequest.creationRequestForAsset(from: image)
            
            let placeholder = cReq.placeholderForCreatedAsset
            
            imageId = placeholder?.localIdentifier
            
            completion?(imageId)
            
        }, completionHandler: nil)
    }
    
    func saveVideo(url:URL,completion:((_ id :String?) -> ())?) {
        
        guard requestAuthStatus() else {
            return
        }
        
        var assetId: String?
        
        PHPhotoLibrary.shared().performChanges({
            
            let cReq = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            
            let placeholder = cReq?.placeholderForCreatedAsset
            
            assetId = placeholder?.localIdentifier
            
            completion?(assetId)
            
        }, completionHandler: nil)
    }
    
    func saveImageInAlbum(image:UIImage,album:String,completion:((_ id :String?) -> ())?) {
        
        guard requestAuthStatus() else {
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            
            let cReq = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let placeholder = cReq.placeholderForCreatedAsset
            
            self.fetchOptions = PHFetchOptions()
            self.fetchOptions.predicate = NSPredicate(format: "title = %@", album)
            
            let fetchCollection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: self.fetchOptions).firstObject
            
            if fetchCollection != nil {
                let assetReq = PHAssetCollectionChangeRequest(for: fetchCollection!)
                let enumeration: NSArray = [placeholder!]
                assetReq?.addAssets(enumeration)
            }
            
            completion?(placeholder?.localIdentifier)
            
        }, completionHandler: nil)
    }
    
    @discardableResult
    func createAlbum(album:String) -> Bool {
        
        guard requestAuthStatus() else {
            return false
        }
        
        var result:Bool = false
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: album)
        }) { (succ, error) in
            result = succ
        }
        
        return result
    }
    
    @discardableResult
    func deletePhoto(asset:PHAsset) -> Bool {
        
        guard requestAuthStatus() else {
            return false
        }
        
        var result:Bool = false
        
        PHPhotoLibrary.shared().performChanges({ 
            PHAssetChangeRequest.deleteAssets(PHAsset.fetchAssets(withLocalIdentifiers: [asset.localIdentifier], options: nil))
        }) { (succ, error) in
            result = succ
        }
        
        return result
    }
    
    func requestAuthStatus() -> Bool {
     
        return PHPhotoLibrary.authorizationStatus() == .authorized ? true : false 
    }
    
}//
