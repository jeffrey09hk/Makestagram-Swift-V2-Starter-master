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
import ConvenienceKit

//1
class Post: PFObject, PFSubclassing{
    var image: Observable<UIImage?> = Observable(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    var likes: Observable<[PFUser]?> = Observable(nil)
    static var imageCache: NSCacheSwift<String, UIImage>!
    
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
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken){
        // inform Parse about this subclass
            self.registerSubclass()
            Post.imageCache = NSCacheSwift<String, UIImage>()
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
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                }
            }
        }
    } // end of uploadPost()

    
    func downloadImage(){
        image.value = Post.imageCache[self.imageFile!.name]
        // get the image if the image is not downloaded yet
        if (image.value == nil){
            imageFile?.getDataInBackgroundWithBlock{(data: NSData?, error: NSError?) -> Void in
                if let data = data{
                    let image = UIImage(data: data, scale:1.0)!
                    self.image.value = image
                    Post.imageCache[self.imageFile!.name] = image
                    
                    if let error = error {
                        ErrorHandling.defaultErrorHandler(error)
                    }
                }
            }
        }
    } // end of downloadImage()
    
    func fetchLikes() {
        if (likes.value != nil){
            return
        }
        
        ParseHelper.likesForPost(self, completionBlock: {(likes: [PFObject]?, error: NSError?) -> Void in
            let validLikes = likes?.filter{like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            self.likes.value = validLikes?.map{like in
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                if let error = error {
                    ErrorHandling.defaultErrorHandler(error)
                }
                
                return fromUser
            }
        })
    }// end of fetchLikes()
    
    func doesUserLikePost(user: PFUser) -> Bool{
        if let likes = likes.value {
            return likes.contains(user)
        } else {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser){
        if (doesUserLikePost(user)){
            // if post is liked, unlike
            likes.value = likes.value?.filter{$0 != user}
            ParseHelper.unlikePost(user, post: self)
        }
        else{
            //if post is not liked, like
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
    
}// end of Post Class