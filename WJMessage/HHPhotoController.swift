//
//  HHPhotoController.swift
//  HealthHappy
//
//  Created by apple on 16/4/27.
//  Copyright © 2016年 ekangzhi. All rights reserved.
//

import UIKit

class HHPhotoController: NSObject ,CTAssetsPickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, MWPhotoBrowserDelegate {
    class HHPhotoBrowser : MWPhotoBrowser {
        func toggleControls() {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    static let sharedInstance = HHPhotoController()
    
    var complation: ((image: Array<UIImage>!)->Void)?
    
    var showCount: Int? = 0
    
    var showPhotos: Array<UIImage>?
    
    private override init() {
        super.init()
        
    }
    
    func openCamera(showVc:UIViewController?,count: Int, complation:(image: Array<UIImage>!)->Void) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let picker = UIImagePickerController();
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceType.Camera;
            var vc =  UIApplication.sharedApplication().keyWindow?.rootViewController
            if showVc != nil {
                vc = showVc
            }
            vc?.presentViewController(picker, animated: true, completion: nil)
            self.complation = complation
            self.showCount = count
            return true
        } else {
//            HHAlertController.showAlertTip("提示", message: "你没有授权到此应用")
        }
        return false
    }
    
    func openPhotoLibrary(showVc:UIViewController?,count: Int, complation:(image: Array<UIImage>!)->Void) -> Bool {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            return false
        }
        PHPhotoLibrary.requestAuthorization({ (status) in
            dispatch_async(dispatch_get_main_queue(), {
                let picker = CTAssetsPickerController();
                picker.delegate = self
                picker.defaultAssetCollection = PHAssetCollectionSubtype.AlbumMyPhotoStream

                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
                    picker.modalPresentationStyle = UIModalPresentationStyle.FormSheet
                }
                var vc =  UIApplication.sharedApplication().keyWindow?.rootViewController
                if showVc != nil {
                   vc = showVc
                }
                vc?.presentViewController(picker, animated: true, completion: nil)
                self.complation = complation
                self.showCount = count
            })
        })
        return true
    }
    
//    func show(count: Int, complation: ((image: Array<UIImage>!)->Void)) {
//        show(nil,count:count,complation:complation)
//    }
//    
//    func show(showVc:UIViewController?, count: Int, complation: ((image: Array<UIImage>!)->Void)) {
//        HHAlertController.showActionTip(nil, message: nil, actionTitles: ["拍照","从相册获取"], cancelTitle: "取消", destructTitle: "").subscribeNext { (x) in
//            
//            if  x.isKindOfClass(RACTuple) {
//                let xx = x as! RACTuple
//                let idx = xx.first as! Int
//                if idx == 0 { //拍照
//                    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
//                        let picker = UIImagePickerController();
//                        picker.delegate = self;
//                        picker.sourceType = UIImagePickerControllerSourceType.Camera;
//                        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(picker, animated: true, completion: nil)
//                        self.complation = complation
//                        self.showCount = count
//                    } else {
//                        HHAlertController.showAlertTip("提示", message: "你没有授权到此应用")
//                    }
//                } else {
//                    
//                    PHPhotoLibrary.requestAuthorization({ (status) in
//                        dispatch_async(dispatch_get_main_queue(), { 
//                            
//                            let picker = CTAssetsPickerController();
//                            
//                            // set delegate
//                            picker.delegate = self;
//                            
//                            picker.defaultAssetCollection = PHAssetCollectionSubtype.AlbumMyPhotoStream;
//                            
//                            // Optionally present picker as a form sheet on iPad
//                            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad {
//                                picker.modalPresentationStyle = UIModalPresentationStyle.FormSheet;
//                            }
//                            var vc =  UIApplication.sharedApplication().keyWindow?.rootViewController
//                            if showVc != nil {
//                               vc = showVc
//                            }
//                            vc?.presentViewController(picker, animated: true, completion: nil)
//                            self.complation = complation
//                            self.showCount = count
//                        })
//                    })
//
//                }
//            }
//        }
//    }
    
    func show(images:Array<UIImage>?, index: Int) {
        show(nil, images:images,index:index)
    }
    
    
    func show(showVc:UIViewController?, images:Array<UIImage>?, index: Int) {
        self.showPhotos = images
        
        let browser = HHPhotoBrowser(delegate: self)
        browser.displayActionButton = false;
        browser.displayNavArrows = false;
        browser.displaySelectionButtons = false;
        browser.alwaysShowControls = false;
        browser.zoomPhotosToFill = true;
        browser.enableGrid = false;
        browser.startOnGrid = false;
        browser.enableSwipeToDismiss = false;
        browser.autoPlayOnAppear = false;
        
        if images?.count > index {
            browser.setCurrentPhotoIndex(UInt(index))
        }
        
//        let nav = UINavigationController(rootViewController: browser);
        browser.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve;
        var vc = UIApplication.sharedApplication().keyWindow?.rootViewController
        if  showVc != nil {
            vc = showVc
        }
        vc?.presentViewController(browser, animated: true, completion: nil)
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt((self.showPhotos?.count)!)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        let image: UIImage! = self.showPhotos![Int(index)]
        let photo = MWPhoto(image: image)
        return photo
    }
    
    @objc internal func assetsPickerController(picker: CTAssetsPickerController, didFinishPickingAssets assets: [PHAsset]) {
        let imageManager = PHCachingImageManager();
        
        var arrayM = Array<UIImage>()
        for  asset in assets {
            imageManager.requestImageDataForAsset(asset, options: nil, resultHandler: { (imageData, dataUTI, orientation, info) in
                if imageData != nil {
                    if let image = UIImage(data: imageData!) {
                        arrayM.append(image)
                    }
                }
                
                if arrayM.count == assets.count {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.complation?(image: arrayM)
                        picker.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            })
        }
        
        if  assets.count == 0 {
            self.complation?(image: arrayM)
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func assetsPickerController(picker: CTAssetsPickerController, shouldSelectAsset asset: PHAsset) -> Bool {
        return picker.selectedAssets.count < showCount
    }
    
    @objc internal func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage]
        self.complation?(image:[image as! UIImage])
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}



