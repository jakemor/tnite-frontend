//
//  *Feed.swift
//  SwiftBook
//
//  Created by Jake Mor on 4/20/15.
//  Copyright (c) 2015 Brian Coleman. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class _Feed: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
	
	var locationManager:CLLocationManager!
	let width:CGFloat = UIScreen.mainScreen().applicationFrame.width
	var refreshControl:UIRefreshControl!
	var loaded = 0
	var items:[[String]] = []
	var lat:String = "0"
	var lon:String = "0"
	
	@IBOutlet weak var tableView: UITableView!
	
	@IBAction func goingOutButton(sender: AnyObject) {
		
		var handler = JMBackend(url: "http://54.200.166.247/imgoingout/index.php?args=")
		
		func received(response:NSData) {
			
			var response = JSON(data: response)
			refresh("")
			if (response["data"] == nil) {
				
			} else {
				
			}
		}
		
		let facebook_id:String = Defaults["user_facebook_id"].string!

		showWaitOverlayWithText("Sending")
		handler.request("isGoingOut/facebook_id=\(facebook_id)/lat=\(lat)/lon=\(lon)", callback: received)
		
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return countElements(items)
		
	}
	
//	func tableView(tableView: UITableView,
//		titleForHeaderInSection section: Int)
//		-> String {
//
//		return "Monday, March 20th"
//			
//	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 75
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
		
		cell.contentView.subviews.map {
				currentSubview in
				(currentSubview as UIView).removeFromSuperview()
		}
		
		
		if (countElements(items) > 0) {
			let fullname = items[indexPath.row][0]
			let facebook_id = items[indexPath.row][1]
			let timeString = items[indexPath.row][2]
			let distanceString = items[indexPath.row][3]
			
			let imageView = YNImageView(frame: CGRectMake(10, 10, 55, 55))
			imageView.backgroundColor = UIColor.clearColor()
			imageView.contentMode = UIViewContentMode.ScaleAspectFit
			imageView.layer.cornerRadius = imageView.frame.size.width / 2
			imageView.clipsToBounds = true
			cell.contentView.addSubview(imageView)
			
			imageView.yn_setImageWithUrl("https://graph.facebook.com/\(facebook_id)/picture?type=large", pattern: false)

			let name = UILabel(frame: CGRectMake(75, 20, width-10, 15))
			name.textAlignment = NSTextAlignment.Left
			name.font = UIFont(name:"HelveticaNeue-Medium", size: 16.0)
			name.text = "\(fullname)"
			cell.contentView.addSubview(name)
			
			let distance = UILabel(frame: CGRectMake(0, 52, width-10, 15))
			distance.textAlignment = NSTextAlignment.Right
			distance.font = UIFont(name: distance.font.fontName, size: 13)
			distance.text = "\(distanceString)"
			distance.alpha = 0.7
			cell.contentView.addSubview(distance)
			
			let time = UILabel(frame: CGRectMake(75, 42, width-10, 15))
			time.textAlignment = NSTextAlignment.Left
			time.font = UIFont(name: distance.font.fontName, size: 13)
			time.text = "\(timeString)"
			time.alpha = 0.7
			cell.contentView.addSubview(time)
		}
		
		return cell
	}
	

	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	
	func refresh(sender:AnyObject) {
		items = []
		tableView.userInteractionEnabled = false
		var handler = JMBackend(url: "http://54.200.166.247/imgoingout/index.php?args=")
		func received(response:NSData) {
			
			var response = JSON(data: response)
			
			
			if (response["data"] == nil) {
				println("no notifications")
				self.refreshControl.endRefreshing()
			} else {
				
				let people: Array<JSON> = response["data"].arrayValue
				
				for (person: JSON) in people {
					let name:String = person["name"].string!
					let facebook_id = person["facebook_id"].string!
					let time = person["time"].string!
					let distance = person["distance"].string!
					
					items.append([name, facebook_id, time, distance])
				}
				tableView.reloadData()
				self.refreshControl.endRefreshing()
				self.hideOverlay()
				tableView.userInteractionEnabled = true
			}
		}

		handler.request("getFeed/lat=\(lat)/lon=\(lon)", callback: received)
		
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		println("at feed!")
		navigationController?.setNavigationBarHidden(false, animated: true)

		let nav = self.navigationController?.navigationBar
		nav?.tintColor = UIColor(red: 75/255, green: 99/255, blue: 153/255, alpha: 1)
		nav?.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 75/255, green: 99/255, blue: 153/255, alpha: 1)]

		self.title = "Tnite's Crowd"
		
		let backItem = UIBarButtonItem(title: "", style: .Bordered, target: nil, action: nil)
		self.navigationItem.backBarButtonItem = backItem
		
		self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		self.refreshControl = UIRefreshControl()
		self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		self.tableView.addSubview(refreshControl)
		

		
		if (!Defaults.hasKey("user_facebook_id")) {
			goToScene("Welcome")
		} else {
			println("location on")
			showWaitOverlayWithText("Locating")
			locationManager = CLLocationManager()
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.requestWhenInUseAuthorization()
			locationManager.startUpdatingLocation()
		}
    }
	
	func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
		

		var location:CLLocation = locations[locations.count-1] as CLLocation
		lat = "\(location.coordinate.latitude)"
		lon = "\(location.coordinate.longitude)"
		
		
		if (loaded == 1) {
			hideOverlay()
			showWaitOverlayWithText("Fetching Feed")
			println("done locating")
			refresh("")
		} else if (loaded == 0) {
			showWaitOverlayWithText("Locating")
		}
		
		loaded++
		
	}
	
	func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
		println("==== error ====")
		println(error)
		var alert = UIAlertController(title: "Can't Locate", message: "We can't seem to find you... make sure you have location services turned on.", preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
		self.presentViewController(alert, animated: true, completion: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		println("func prepareForSegue")
    }


}
