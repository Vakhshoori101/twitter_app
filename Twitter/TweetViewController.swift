//
//  TweetViewController.swift
//  Twitter
//
//  Created by Rostam Vakhshoori on 2/3/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var charsleftLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var userArray = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTextView.becomeFirstResponder()
        
        charsleftLabel.text = "140"
        
        self.tweetTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.tweetTextView.layer.borderWidth = 2
        self.tweetTextView.layer.cornerRadius = 5
        self.tweetTextView.layer.borderWidth = 1
        
        let url = "https://api.twitter.com/1.1/statuses/user_timeline.json"

        TwitterAPICaller.client?.getDictionariesRequest(url: url, parameters: [:], success: { (person:[NSDictionary]) in

            let user = person[0]["user"] as! NSDictionary
            let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
            let data = try? Data(contentsOf: imageUrl!)
            
            if let imageData = data{
                self.profileImageView.image = UIImage(data: imageData)
            }

        }, failure: { (Error) in
            print("Count not retrieve tweeets!")
        })
        
        profileImageView.layer.cornerRadius = 30
        
//
        
        
        
        // Do any additional setup after loading the view.
        
    }
    
    func checkRemainingChars(){
        let allowedChars = 140
        let charsInTextView = -tweetTextView.text.count
        let remainingChars = allowedChars + charsInTextView
        
        if remainingChars <= allowedChars{
            charsleftLabel.textColor = UIColor.black
        }
        
        if remainingChars <= 20{
            charsleftLabel.textColor = UIColor.orange
        }
        
        if remainingChars <= 10{
            charsleftLabel.textColor = UIColor.red
        }
        
        charsleftLabel.text = "\(remainingChars)"
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkRemainingChars()
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tweet(_ sender: Any) {
        let allowedChars = 140
        let charsInTextView = -tweetTextView.text.count
        let remainingChars = allowedChars + charsInTextView
        if (remainingChars<0){
            let alert = UIAlertController(title: "Too Many Words in Tweet!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok.", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        else{
            if (!tweetTextView.text.isEmpty){
                TwitterAPICaller.client?.postTweet(tweetString: tweetTextView.text, success: {
                    self.dismiss(animated: true, completion: nil)
                }, failure: { (error) in
                    print("Error posting tweet \(error)")
                    self.dismiss(animated: true, completion: nil)
                })
            } else{
                self.dismiss(animated: true, completion: nil)
            }
       }
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
