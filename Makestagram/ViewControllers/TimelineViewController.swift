//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Jeff Hui on 27/6/2016.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse
import ConvenienceKit


class TimelineViewController: UIViewController, TimelineComponentTarget{
    
    var photoTakingHelper: PhotoTakingHelper?
    var posts: [Post] = []
    let defaultRange = 0...4
    let additionalRangeSize = 5
    var timelineComponent: TimelineComponent<Post, TimelineViewController>!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self
    }
    
    func takePhoto(){
        //instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!){
            (image: UIImage?) in
                let post = Post()
            
                post.image.value = image
            post.uploadPost()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        timelineComponent.loadInitialIfRequired()
    } // end of viewDidAppear()
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?) -> Void) {
        // 1
        ParseHelper.timelineRequestForCurrentUser(range) { (result: [PFObject]?, error: NSError?) -> Void in
            // 2
            let posts = result as? [Post] ?? []
            // 3
            completionBlock(posts)
        }
    } // end of loadInRange()
    
} // end of class

extension TimelineViewController: UITableViewDelegate{
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    }
}

public protocol TimeLineComponentTarget: class{
    typealias ContentType
    
    var defaultRange: Range<Int> {get}
    var additionalRangeSize: Int {get}
    var tableView: UITableView! {get}
    func loadInRange(range: Range<Int>, completionBlock: ([ContentType]?) -> Void)
}

// MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool
    {
        if (viewController is PhotoViewController) {
            takePhoto()
            return false
        } else {
            return true
        }
    }// end of tabBarController
}


extension TimelineViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return timelineComponent.content.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        let post = timelineComponent.content[indexPath.row]
        
        post.downloadImage()
        post.fetchLikes()
        
        cell.post = post
        
        return cell
    }
}// end of extension



