//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Rostam Vakhshoori on 1/30/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    var tweetArray = [NSDictionary]()
    var numberOfTweets : Int!

    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTweets()
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl

    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.loadTweets()
//    }
    
    @objc func loadTweets(){
        numberOfTweets = 20
                
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        
        let myParams = ["count": numberOfTweets]
        
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams, success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
                        
            self.tableView.reloadData()
            
            self.myRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print("Could not retrieve tweets!")
        })
        
    }
    
    
    func loadMoreTweets(){
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        
        numberOfTweets = numberOfTweets + 20
        
        let myParams = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams, success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
                        
        }, failure: { (Error) in
            print("Could not retrieve tweets!")
        })
        
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count{
            loadMoreTweets()
        }
    }

    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey:"userloggedIn")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
                
        cell.userNameLabel.text = user["name"] as? String
        cell.screenNameLabel.text = "@" + (user["screen_name"] as! String)
        cell.tweetsContent.text = tweetArray[indexPath.row]["text"] as? String
        
        let d = tweetArray[indexPath.row]["created_at"] as! String
        cell.timeLabel.text = calclate_time_ago(date: d)
        
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data{
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        
        // cell.retweeted = tweetArray[indexPath.row]["retweeted"] as! Bool
        cell.setRetweet(tweetArray[indexPath.row]["retweeted"] as! Bool)
        
        return cell
    }
    
    func calclate_time_ago(date: String) -> String{
        
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"

        let dateFromString = dateFormatter.date(from: date)

        var secondsSinceNow = (dateFromString!.timeIntervalSinceNow) * -1
//        secondsSinceNow += 28800
        var minutesSinceNow = secondsSinceNow / 60
        var hoursSinceNow = minutesSinceNow / 60
        var daysSinceNow = hoursSinceNow / 24
        var weeksSinceNow = daysSinceNow / 7
        var yearsSinceNow = weeksSinceNow / 52

        secondsSinceNow = floor(secondsSinceNow)
        minutesSinceNow = floor(minutesSinceNow)
        hoursSinceNow = floor(hoursSinceNow)
        daysSinceNow = floor(daysSinceNow)
        weeksSinceNow = floor(weeksSinceNow)
        yearsSinceNow = floor(yearsSinceNow)

        var recentLabel = ""

        if (yearsSinceNow >= 1) {
            if (yearsSinceNow == 1){
                recentLabel = String(format: "%.0f year ago", yearsSinceNow)
            }
            else{
                recentLabel = String(format: "%.0f years ago", yearsSinceNow)
            }
        }
        else if (weeksSinceNow >= 1){
            if (weeksSinceNow == 1){
                recentLabel = String(format: "%.0f week ago", weeksSinceNow)
            }
            else {
               recentLabel = String(format: "%.0f weeks ago", weeksSinceNow)
            }
        }
        else if (daysSinceNow >= 1){
            if (daysSinceNow == 1){
                recentLabel = String(format: "%.0f day ago", daysSinceNow)
            }
            else{
                recentLabel = String(format: "%.0f days ago", daysSinceNow)
            }
        }
        else if (hoursSinceNow >= 1){
            if (hoursSinceNow == 1){
                recentLabel = String(format: "%.0f hour ago", hoursSinceNow)
            }
            else{
                recentLabel = String(format: "%.0f hours ago", hoursSinceNow)
            }
        }
        else if (minutesSinceNow >= 1){
            if (minutesSinceNow == 1){
                recentLabel = String(format: "%.0f minute ago", minutesSinceNow)
            }
            else{
                recentLabel = String(format: "%.0f minutes ago", minutesSinceNow)
            }
        }
        else{
            if (secondsSinceNow == 1){
                recentLabel = String(format: "%.0f second ago", secondsSinceNow)
            }
            else{
                recentLabel = String(format: "%.0f seconds ago", secondsSinceNow)
            }
        }

        return recentLabel
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

 

}

