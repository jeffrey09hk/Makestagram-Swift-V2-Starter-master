//
//  FriendSearchViewController.swift
//  Makestagram
//
//  Created by Jeff Hui on 27/6/2016.
//  Copyright © 2016 Make School. All rights reserved.
//


import UIKit
import Parse
class FriendSearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    // stores all the users that match the current search query
    var users: [PFUser]?
    
    var followingUsers: [PFUser]? {
        didSet{
            /**
             the list of following users may be fetched after the tableView has displayed
             cells. In this case, we reload the data to reflect "following" status
             */
            tableView.reloadData()
        }
    }
    
    var query: PFQuery? {
        didSet{
            oldValue?.cancel()
        }
    }
    
    enum State{
        case DefaultMode
        case SearchMode
        
    }
    
    var state: State = .DefaultMode{
        didSet{
            switch(state){
            case .DefaultMode:
                query = ParseHelper.allUsers(updateList)
                
            case .SearchMode:
                let searchText = searchBar?.text ?? ""
                query = ParseHelper.searchUsers(searchText, completionBlock: updateList)
            }
        }
    }
    
    
    
    
    
    // MARK: Update userlist
    
    /**
     Is called as the completion block of all queries.
     As soon as a query completes, this method updates the Table View.
     */
    
    func updateList(results:[PFObject]? ,error: NSError?){
        
        if let error = error{
            ErrorHandling.defaultErrorHandler(error)
        }
        self.users = results as? [PFUser] ?? []
        self.tableView.reloadData()
        
        if let error = error {
            ErrorHandling.defaultErrorHandler(error)
        }
        
        if let results = results{
            for like in results{
                like.deleteInBackgroundWithBlock(nil)
            }
        }
    }
    
    // MARK: View Lifecycle
    
    override func viewWillAppear(animated: Bool){
        super.viewWillAppear(animated)
        
        state = .DefaultMode
        
        ParseHelper.getFollowingUsersForUser(PFUser.currentUser()!){ (results: [PFObject]?, error: NSError?) -> Void in
            let relations = results ?? []
            
            if let error = error {
                ErrorHandling.defaultErrorHandler(error)
            }
            self.followingUsers = relations.map{
                $0.objectForKey(ParseHelper.ParseFollowToUser) as! PFUser
                
            }
            
            if let results = results{
                for like in results{
                    like.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
extension FriendSearchViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.users?.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as! FriendSearchTableViewCell
        
        let user = users![indexPath.row]
        cell.user = user
        
        if let followingUsers = followingUsers {
            // check if current user is already following displayed user
            // change button appereance based on result
            cell.canFollow = !followingUsers.contains(user)
        }
        
        cell.delegate = self
        
        return cell
    }
}
extension FriendSearchViewController: UISearchBarDelegate{
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        state = .SearchMode
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        state = .DefaultMode
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        ParseHelper.searchUsers(searchText, completionBlock: updateList)
    }
}
extension FriendSearchViewController: FriendSearchTableViewCellDelegate {
    
    func cell(cell: FriendSearchTableViewCell, didSelectFollowUser user: PFUser) {
        ParseHelper.addFollowRelationshipFromUser(PFUser.currentUser()!, toUser: user)
        // update local cache
        followingUsers?.append(user)
    }
    
    func cell(cell: FriendSearchTableViewCell, didSelectUnfollowUser user: PFUser) {
        if let followingUsers = followingUsers {
            ParseHelper.removeFollowRelationshipFromUser(PFUser.currentUser()!, toUser: user)
            // update local cache
            self.followingUsers = followingUsers.filter({$0 != user})
        }
    }
    
}