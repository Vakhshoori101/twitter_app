//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Rostam Vakhshoori on 2/12/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    
    var userArray = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        
        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: [:], success: { (person:[NSDictionary]) in

            let user = person[0]["user"] as! NSDictionary
            
            print(user)
            
            self.nameLabel.text = user["name"] as? String
            self.userName.text = "@" + (user["screen_name"] as! String)
            self.followingLabel.text = "\(user["friends_count"]!) Following"
            self.followersLabel.text = "\(user["followers_count"]!) Follower"
                        
            let imageUrl1 = user["profile_image_url_https"] as? String
            let imageUrl = URL(string: (imageUrl1!.replacingOccurrences(of: "_normal", with: "", options: .literal, range: nil)))

            
            let backgroundimageUrl = (user["profile_background_image_url_https"] as? String)
            if let d = backgroundimageUrl{
                let b_url = URL(string: d)
                let data1 = try? Data(contentsOf: b_url!)
                if let imageData1 = data1{
                    self.backgroundImageView.image = UIImage(data: imageData1)
                }
            }

            let data = try? Data(contentsOf: imageUrl!)
            
            if let imageData = data{
                self.profileImageView.image = UIImage(data: imageData)
            }

        }, failure: { (Error) in
            print("Count not retrieve tweeets!")
        })
        
        profileImageView.layer.cornerRadius = 80
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
