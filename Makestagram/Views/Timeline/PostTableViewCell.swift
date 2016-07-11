//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Jeff Hui on 29/6/2016.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Bond


class PostTableViewCell: UITableViewCell{
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesIconImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    var postDisposable: DisposableType?
    var likeDisposable: DisposableType?
    
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        post?.toggleLikePost(PFUser.currentUser()!)
    }
    
    @IBAction func moreButtonTapped(sender: AnyObject) {
    }
    
    var post: Post? {
        didSet{
            postDisposable?.dispose()
            likeDisposable?.dispose()
            
            //free the memory of image stored with post that is no longer displayed
            if let oldValue = oldValue where oldValue != post {
                oldValue.image.value = nil
            }
            
            if let post = post{
                postDisposable = post.image.bindTo(postImageView.bnd_image)
                likeDisposable = post.likes.observe {(value: [PFUser]?) -> () in
                    
                    if let value = value {
                        self.likesLabel.text = self.stringFromUserList(value)
                        self.likeButton.selected = value.contains(PFUser.currentUser()!)
                        self.likesIconImageView.hidden = (value.count == 0)
                    }
                    else{
                        self.likesLabel.text = ""
                        self.likeButton.selected = false
                        self.likesIconImageView.hidden = true
                    }
                }
            } // end of outer if loop
            
        } // end of didSet
    } // end of Var
    
    func stringFromUserList(userList: [PFUser]) -> String{
        let usernameList = userList.map {user in user.username!}
        let commaSeparatedUserList = usernameList.joinWithSeparator(", ")
        
        return commaSeparatedUserList
    }
    
    
    
}// end of class