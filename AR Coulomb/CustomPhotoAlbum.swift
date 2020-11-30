//
//  CustomPhotoAlbum.swift
//  AR Coulomb
//
//  Created by Leonidas Mavrotas on 29/11/20.
//  Copyright © 2020 Leonidas Mavrotas. All rights reserved.
//

import Foundation
import Photos
import UIKit

class CustomPhotoAlbum {

    static let albumName = "Coulomb"
    static let sharedInstance = CustomPhotoAlbum()

    var assetCollection: PHAssetCollection!

    init() {

        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {

            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

            if let _: AnyObject = collection.firstObject {
                return collection.firstObject
            }

            return nil
        }

        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle:CustomPhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }

    func saveImage(image: UIImage) {

        if assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }

        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest?.addAssets([assetPlaceholder] as NSFastEnumeration)
        }, completionHandler: nil)
    }


}
