//
//  *AddressBook.swift
//  SwiftBook
//
//  Created by Jake Mor on 4/20/15.
//  Copyright (c) 2015 Brian Coleman. All rights reserved.
//

import UIKit
import AddressBook
import Foundation

class _Friends: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var items:[[String]] = []
	var letters:[String] = []
	var data = Dictionary<String, [[String]]>()
	var selected = Set<String>()
	
	@IBOutlet weak var tableView: UITableView!
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return letters.count
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if (section >= letters.count) {
			return 0
		} else {
			return data[letters[section]]!.count
		}
		
	}
	
	func tableView(tableView: UITableView,
		titleForHeaderInSection section: Int)
		-> String {
			// do not display empty `Section`s
			if (section >= letters.count) {
				return "?"
			} else {
				return letters[section]
			}
			
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
		
		let first = data[letters[indexPath.section]]?[indexPath.row][1]
		let last = data[letters[indexPath.section]]?[indexPath.row][2]
		let phone = data[letters[indexPath.section]]?[indexPath.row][0]
		
		cell.textLabel?.text = "\(first!) \(last!) (\(phone!))"
		
		if (selected.contains("\(indexPath.section)-\(indexPath.row)")) {
		//	cell.accessoryType = .Checkmark
		}
		
		
		return cell
	}
	
	func sectionIndexTitlesForTableView(tableView: UITableView)
		-> [AnyObject] {
			return letters
	}
	
	func tableView(tableView: UITableView,
		sectionForSectionIndexTitle title: String,
		atIndex index: Int)
		-> Int {
			
			return find(letters, title)!
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let phone:String! = data[letters[indexPath.section]]?[indexPath.row][0]
		let facebook_id:String! = Defaults["user_facebook_id"].string!
		var handler = JMBackend(url: "http://54.200.166.247/imgoingout/index.php?args=")
		
		func received(response:NSData) {
			
			var response = JSON(data: response)
			self.hideOverlay()
			
			var view = UIView(frame: CGRect(x: 0, y: 0, width: 500, height: 64))
			
			self.showTextOverlay("Invite Sent!")
			
			let delay = 1 * Double(NSEC_PER_SEC)
			let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
			dispatch_after(time, dispatch_get_main_queue()) {
				self.hideOverlay()
			}
				
			if (response["data"] == nil) {
				
			} else {
				
			}
		}
		
		showWaitOverlayWithText("Sending Invite")
		//tableView.deselectRowAtIndexPath(indexPath, animated: true)
		//let newCell = tableView.cellForRowAtIndexPath(indexPath)
		//newCell?.accessoryType = .Checkmark
		
		let id = "\(indexPath.section)-\(indexPath.row)"
		selected.add(id)
		println(selected)
		
		handler.request("inviteOut/phone_number=\(phone)/facebook_id=\(facebook_id)", callback: received)
		
	}
	
	func refresh() {
		
		var ab = JMAddressBook()
		
		func onSuccess() {
			items = ab.getNumbers()
			
			for contact in items {
				let name = contact[1]
				var letter = ""
				for c in name {
					letter = "\(c)"
					break
				}
				
				letter = letter.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).uppercaseString
				
				if (!letters.isEmpty) {
					if (letters[letters.count - 1] != letter && letter != "") {
						letters.append(letter)
						println(letter)
					}
				} else {
					letters.append(letter)
				}
				
				if (data[letter] == nil) {
					data[letter] = []
				}
				data[letter]?.append(contact)
			}
			
			let facebook_id:String! = Defaults["user_facebook_id"].string!
			var handler = JMBackend(url: "http://54.200.166.247/imgoingout/index.php?args=")
			
			func received(response:NSData) {
				
				var response = JSON(data: response)
				
				
				Defaults["user_uploaded_ab"] = "yes"
				
			}
			
			let ab_data = NSJSONSerialization.dataWithJSONObject(items, options: nil, error: nil)
			let ab_json:String! = NSString(data: ab_data!, encoding: NSUTF8StringEncoding) as String
			
			if (!Defaults.hasKey("user_uploaded_ab")) {
				handler.request("uploadAddressBook/facebook_id=\(facebook_id)", post: ab_json,  callback: received)
			} else {
				println("already uploaded ab")
			}
			
			self.tableView.reloadData()
			self.hideOverlay()
		}
		
		func onFail() {
			self.hideOverlay()
		}
		
		ab.askPermission(onSuccess, onFail)
		
	}
	
	func wait() {
		showWaitOverlayWithText("Reading Addressbook")
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
		
		//self.tableView.contentInset = UIEdgeInsetsMake(64,0,0,0);
		
		dispatch_async(dispatch_get_main_queue()) {
			self.wait()
			self.refresh()
		}
		
		
		
		
	}
	
	override func viewWillDisappear(animated: Bool) {
		
		
		super.viewWillDisappear(animated)
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		
		// Dispose of any resources that can be recreated.
	}
	
	
	
}

