//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Jeff Hui on 29/6/2016.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse

class ParseHelper{
    
    static let ParseFollowClass     = "Follow"
    static let ParseFollowFromUser  = "fromUser"
    static let ParseFollowToUser    = "toUser"
    
    static let ParseLikeClass       = "Like"
    static let ParseLikeToPost      = "toPost"
    static let ParseLikeFromUser    = "fromUser"
    
    static let ParsePostUser        = "user"
    static let ParsePostCreatedAt   = "createdAt"
    
    static let ParseFlaggedContentClass     = "FlaggedContent"
    static let ParseFlaggedContentFromUser  = "fromUser"
    static let ParseFlaggedContentToUser    = "toPost"
    
    static let  ParseUserUsername   = "username"
    
    
    
    static func timelineRequestForCurrentUser(completionBlock: PFQueryArrayResultBlock){
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseFollowFromUser, equalTo:PFUser.currentUser()!)
        
        let postsFromFollwedUsers = Post.query()
        postsFromFollwedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([postsFromFollwedUsers!, postsFromThisUser!])
        query.includeKey(ParsePostUser)
        query.orderByDescending(ParsePostCreatedAt)
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    } // end of timelineRequest()
    
    static func likePost(user: PFUser, post:Post){
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackgroundWithBlock(nil)

    }
    
    
} // end of ParseHelper class


