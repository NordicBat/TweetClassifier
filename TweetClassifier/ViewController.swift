//
//  ViewController.swift
//  TweetClassifier
//
//  Created by Gabriel de Freitas Meira on 01/04/2019.
//  Copyright © 2019 gfmeira. All rights reserved.
//

import UIKit
import SwifteriOS
import SwiftyJSON
import CoreML

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emojiLabel: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    let swifter = Swifter(consumerKey: "", consumerSecret: "")

    let tweetCounter = 100
    
    let sentimentClassifier = TweetClassifier()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self

    }

    @IBAction func searchButton(_ sender: Any) {
        
        fetchTweets()
        
    }
    
    func fetchTweets(){
        
        if let text = textField.text {
            
            swifter.searchTweet(using: text, lang: "en", count: tweetCounter, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetClassifierInput]()
                
                for i in 0..<self.tweetCounter {
                    if let tweet = results[i]["full_text"].string {
                        let tweetToInspect = TweetClassifierInput(text: tweet)
                        tweets.append(tweetToInspect)
                    }
                }
                self.returnSentiment(with: tweets)
                
            }) { (error) in
                print("Error in \(error)")
            }
            
        }
        
    }
    
    func returnSentiment(with tweets: [TweetClassifierInput]){
        
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for p in predictions {
                let sentiment = p.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            
            updateUI(sentimentScore)
        } catch {
            print("Error returning sentiment")
        }
    }
    
    func updateUI(_ score: Int){
        
       
        if score > 20 {
            emojiLabel.text = "😍"
        } else if score > 10 {
            emojiLabel.text = "😁"
        } else if score > 10 {
            emojiLabel.text = "🙂"
        } else if score > 0 {
            emojiLabel.text = "😐"
        } else if score < -10 {
            emojiLabel.text = "😖"
        } else if score < -20 {
            emojiLabel.text = "🤬"
        } else {
            emojiLabel.text = "🤮"
        }
    
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

