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
    
    static func timelineRequestForCurrentUser(range: Range<Int>, completionBlock: PFQueryArrayResultBlock){
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseFollowFromUser, equalTo:PFUser.currentUser()!)
        
        let postsFromFollwedUsers = Post.query()
        postsFromFollwedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([postsFromFollwedUsers!, postsFromThisUser!])
        query.includeKey(ParsePostUser)
        query.orderByDescending(ParsePostCreatedAt)
        
        query.skip = range.startIndex
        query.limit = range.endIndex
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    } // end of timelineRequest()
    
    // MARK: Likes
    
    static func likePost(user: PFUser, post:Post){
        let likeObject = PFObject(className: ParseLikeClass)
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        
        likeObject.saveInBackgroundWithBlock(nil)
    }// end of likePost
    
    static func unlikePost(user: PFUser, post: Post){
        let query = PFQuery(className: ParseLikeClass)
        
        query.whereKey(ParseLikeFromUser, equalTo: user)
        query.whereKey(ParseLikeToPost, equalTo: post)
        
        query.findObjectsInBackgroundWithBlock{(results:[PFObject]?, error:NSError?) -> Void in
            
            if let results = results{
                for like in results{
                    like.deleteInBackgroundWithBlock(nil)
                }
            }
        } // end of the call back for findObjectsInBackground
    } // end of unlikePost
    
    static func likesForPost(post: Post, completionBlock: PFQueryArrayResultBlock){
        let query = PFQuery(className: ParseLikeClass)
        
        query.whereKey(ParseLikeToPost, equalTo: post)
        query.includeKey(ParseLikeFromUser)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }// end of likeForPost
    
    
    //MARK: Following
    
    /**
     Fetches all users that the provided user is following.
     
     :param: user The user whose followees you want to retrieve
     :param: completionBlock The completion block that is called when the query completes
     */
    static func getFollowingUsersForUser(user: PFUser, completionBlock: PFQueryArrayResultBlock){
        let query = PFQuery(className:  ParseFollowClass)
        
        query.whereKey(ParseFollowFromUser, equalTo:user)
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    
    /**
     Establishes a follow relationship between two users.
     
     :param: user    The user that is following
     :param: toUser  The user that is being followed
     */
    static func addFollowRelationshipFromUser(user: PFUser, toUser: PFUser){
        let followObject = PFObject(className: ParseFollowClass)
        followObject.setObject(user, forKey: ParseFollowFromUser)
        followObject.setObject(toUser, forKey: ParseFollowFromUser)
        
        followObject.saveInBackgroundWithBlock(nil)
    }
    
    /**
     Deletes a follow relationship between two users.
     
     :param: user    The user that is following
     :param: toUser  The user that is being followed
     */
    static func removeFollowRelationshipFromUser(user: PFUser, toUser: PFUser){
        let query = PFQuery(className: ParseFollowClass)
        query.whereKey(ParseFollowFromUser, equalTo: user)
        query.whereKey(ParseFollowToUser, equalTo: toUser)
        
        query.findObjectsInBackgroundWithBlock{(results: [PFObject]?, error: NSError?) -> Void in
            let results = results ?? []
            
            for follow in results{
                follow.deleteInBackgroundWithBlock(nil)
            }
        }
    }
    
    // MARK: Users
    
    /**
     Fetch all users, except the one that's currently signed in.
     Limits the amount of users returned to 20.
     
     :param: completionBlock The completion block that is called when the query completes
     
     :returns: The generated PFQuery
     */
    static func allUsers(completionBlock: PFQueryArrayResultBlock) -> PFQuery{
        let query = PFUser.query()!
        //exclude the current user
        query.whereKey(ParseHelper.ParseUserUsername, notEqualTo: PFUser.currentUser()!.username!)
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        return query
    }
    
    /**
     Fetch users whose usernames match the provided search term.
     
     :param: searchText The text that should be used to search for users
     :param: completionBlock The completion block that is called when the query completes
     
     :returns: The generated PFQuery
     */
    static func searchUsers(searchText: String, completionBlock: PFQueryArrayResultBlock) -> PFQuery{
        /*
         NOTE: We are using a Regex to allow for a case insensitive compare of usernames.
         Regex can be slow on large datasets. For large amount of data it's better to store
         lowercased username in a separate column and perform a regular string compare.
         */
        let query = PFUser.query()!.whereKey(ParseHelper.ParseUserUsername, matchesRegex: searchText, modifiers: "i")
        
        query.whereKey(ParseHelper.ParseUserUsername, notEqualTo: PFUser.currentUser()!.username!)
        query.orderByAscending(ParseHelper.ParseUserUsername)
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
        return query
    }
    
    
    
    
} // end of ParseHelper class

extension PFObject{
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId{
            return true
        }
        else{
            return super.isEqual(object)
        }
    }
} // end of extension

