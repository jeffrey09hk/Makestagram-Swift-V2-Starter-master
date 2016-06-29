//
//  PhotoTakingHelper.swift
//  Makestagram
//
//  Created by Jeff Hui on 28/6/2016.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

typealias PhotoTakingHelperCallback = UIImage -> Void

class PhotoTakingHelper: NSObject {

    weak var viewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
    init(viewController: UIViewController, callback: PhotoTakingHelperCallback){
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        showPhotoSourceSelection()
    }// end of init
    
    func showPhotoSourceSelection(){
        //Allow user to choose between photo library and camera
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .Default){
            (action) in self.showImagePickerController(.PhotoLibrary)
        } // end of photoLibraryAction
        
        alertController.addAction(photoLibraryAction)
        
        //only show camera option if rear camera is available
        if (UIImagePickerController.isCameraDeviceAvailable(.Rear)){
            let cameraAction = UIAlertAction(title: "Photo from Camera", style: . Default){
                (action) in self.showImagePickerController(.Camera)
            }// end of cameraAction
            alertController.addAction(cameraAction)
        }
        
        
    viewController.presentViewController(alertController, animated: true, completion: nil)
    
    }// end of showPhotoSourcesSelection
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType){
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        
        self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil)
    }
    
}// end of class

extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject: AnyObject]!){
        
        viewController.dismissViewControllerAnimated(false, completion: nil)
        callback(image)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
