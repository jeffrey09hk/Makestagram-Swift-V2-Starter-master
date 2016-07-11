//
//  PostSectionHeaderView.swift
//  Makestagram
//
//  Created by Jeff Hui on 10/7/2016.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import UIKit

class PostSectionHeaderView: UITableViewCell{

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    
    var post: Post?{
        didSet{
            if let post = post{
                usernameLabel.text = post.user?.username
                postTimeLabel.text = post.createdAt?.shortTimeAgoSinceDate(NSDate()) ?? ""
            }
        }
    }
    
} // end of class