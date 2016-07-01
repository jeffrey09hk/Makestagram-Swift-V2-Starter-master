//
//  Post.swift
//  Makestagram
//
//  Created by Jeff Hui on 28/6/2016.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond

//1
class Post: PFObject, PFSubclassing{
    var image: Observable<UIImage?> = Observable(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    //2
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    //MARK: PFSubclassing Protocol
    
    //3
    static func parseClassName() -> String{
        return "Post"
    }
    
    //4
    override init () {
        super.init()
    }
        
    override class func initialize(){
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken){
        // inform Parse about this subclass
            self.registerSubclass()
        }
    }// end of parseClassName()
    
    func uploadPost(){
        
        if let image = image.value{
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data:imageData) else{return}
            
            user = PFUser.currentUser() // relating the post that uploaded to the user that is currently logged in
            self.imageFile = imageFile
            
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler{ () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            saveInBackgroundWithBlock() {(success: Bool, error: NSError?) in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    } // end of uploadPost()

    
    func downloadImage(){
        // get the image if the image is not downloaded yet
        if (image.value == nil){
            imageFile?.getDataInBackgroundWithBlock{(data: NSData?, error: NSError?) -> Void in
                if let data = data{
                    let image = UIImage(data: data, scale:1.0)!
                    self.image.value = image
                }
            }
        }
    } // end of downloadImage()
    
    
    
    
    
}// end of Post Class