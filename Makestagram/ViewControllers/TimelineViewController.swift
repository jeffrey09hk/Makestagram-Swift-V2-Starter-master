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
    
    
    @IBOutlet weak var tableView: UITableView!
    var photoTakingHelper: PhotoTakingHelper?
    // var posts: [Post] = []
    let defaultRange = 0...4
    let additionalRangeSize = 5
    var timelineComponent: TimelineComponent <Post, TimelineViewController>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineComponent = TimelineComponent(target: self)
        self.tabBarController?.delegate = self
        // Do any additional setup after loading the view.
    }
    
    //MARK: View Callbacks
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
        
    }
    
    func loadInRange(range: Range<Int>, completionBlock: ([Post]?)->Void){
        ParseHelper.timelineRequestForCurrentUser(range){(result: [PFObject]?, error: NSError?) -> Void in
            
            let posts = result as? [Post] ?? []
            
            if let error = error{
                ErrorHandling.defaultErrorHandler(error)
            }
            
            completionBlock(posts)
            
        }
    } // end of loadInRange
}

//MARK: Tab Bar Delegate
extension TimelineViewController: UITabBarControllerDelegate{
    
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController){
            takePhoto()
            return false
        }else{
            return true
        }
    }
    
}// end of TimelineViewController

extension TimelineViewController: UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineComponent.content.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
    
        let post = timelineComponent.content[indexPath.row]
        post.downloadImage()
        post.fetchLikes()
        cell.post = post
    
        return cell
    }
    
} // end of extension

extension TimelineViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        timelineComponent.targetWillDisplayEntry(indexPath.row)
    }
    
}




