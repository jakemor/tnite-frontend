//
//  ViewController.swift
//  SwiftBook
//
//  Created by Brian Coleman on 2014-07-07.
//  Copyright (c) 2014 Brian Coleman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, FBLoginViewDelegate {
	
	var firstTime = true
    let width:CGFloat = UIScreen.mainScreen().applicationFrame.width
	
    @IBOutlet var fbLoginView : FBLoginView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		
		self.title = "Menu"
		self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
    }
	
	@IBAction func legalButton(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string: "http://jakemor.com/tnite/legal")!)
	}
	
	// Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
		
		if (!Defaults.hasKey("user_facebook_id")) {
			println("User: \(user)")
			let userEmail = user.objectForKey("email") as String
			let userGender = user.objectForKey("gender") as String
			
			println("=== setting up user defaults ====")
			Defaults["user_facebook_id"] = "\(user.objectID)"
			Defaults["user_name"] = "\(user.name)"
			Defaults["user_first_name"] = "\(user.first_name)"
			Defaults["user_last_name"] = "\(user.last_name)"
			Defaults["user_email"] = "\(userEmail)"
			println(Defaults["user_facebook_id"].string)
			println("=================================")
			
			var handler = JMBackend(url: "http://54.200.166.247/imgoingout/index.php?args=")
			
			func received(response:NSData) {
				
				var response = JSON(data: response)
				
//				var friendsRequest : FBRequest = FBRequest.requestForMyFriends()
//				friendsRequest.startWithCompletionHandler {
//						(connection:FBRequestConnection!,   result:AnyObject!, error:NSError!) -> Void in
//					
//						var resultdict = result as NSDictionary
//						println("Result Dict: \(resultdict)")
//						var data : NSArray = resultdict.objectForKey("data") as NSArray
//						
//						for i in 0 ..< data.count
//						{
//							let valueDict : NSDictionary = data[i] as NSDictionary
//							let id = valueDict.objectForKey("id") as String
//							println("the id value is \(id)")
//						}
//						
//						var friends = resultdict.objectForKey("data") as NSArray
//						println("Found \(friends.count) friends")
//				}
//				
				goToScene("Feed")
			}
		
			showWaitOverlayWithText("Logging In")
			handler.request("createUser/facebook_id=\(user.objectID)/gender=\(userGender)/email=\(userEmail)/first_name=\(user.first_name)/last_name=\(user.last_name)", callback: received)
			navigationController?.setNavigationBarHidden(true, animated: true)
		}
	}
	
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
		navigationController?.setNavigationBarHidden(true, animated: true)
		for key in NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys {
		NSUserDefaults.standardUserDefaults().removeObjectForKey(key.description)
		}
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

