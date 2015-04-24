//
//  JMBackend.swift
//  contacts
//
//  Created by Jake Mor on 3/29/15.
//  Copyright (c) 2015 Jake Mor. All rights reserved.
//

import Foundation

class JMBackend {
    var url:String = ""
    
    init (url:String) {
        self.url = url
    }
    
    init () {
        
    }

    func request(endpoint: String, post: String = "", callback: (NSDictionary)->()) {
        
        func requested(response:NSData!) -> () {
            dispatch_async(dispatch_get_main_queue()) {
                println("____DONE____")
                println()
                
                var error:NSError?
                var response = NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary!
                
                if (response != nil) {
                    callback(response)
                } else {
                    callback(["error":true])
                }
                
                
            }
        }
        
        // get request
        if (post == "") {
            println("____GET____\n")
            
            http_get(self.url + "\(endpoint)", callback:requested)
            
            // post request
        } else {
            println("____POST____\n")
            
            http_post(self.url + "\(endpoint)", post:post, callback:requested)
        }
        
    }
    

    func request(endpoint: String, post: String = "", callback: (NSData)->()) {
            
        func requested(response:NSData!) -> () {
            dispatch_async(dispatch_get_main_queue()) {
                println("____DONE____")
                println()
                callback(response)
            }
        }
        
        // get request
        if (post == "") {
            println("____GET____\n")
            
            http_get(self.url + "\(endpoint)", callback:requested)
        
        // post request
        } else {
            println("____POST____\n")
            
            http_post(self.url + "\(endpoint)", post:post, callback:requested)
        }
        
    }
    
    func http_get(url:String, callback:(NSData)->()){
        
        println("====URL====")
        println(url)
        println()
        
        var nsURL = NSURL(string: url)!
        let task = NSURLSession.sharedSession().dataTaskWithURL(nsURL) {
            (data,response,error) in

            println("====RAW RESPONSE====")
            var raw:String! = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(raw)
            println()
            
            callback(data)
            
        }
        task.resume()
    }
    
    
    func http_post(url:String, post:String, callback:(NSData)->()){
       
        println("====URL====")
        println(url)
        println()
        
        println("====POST DATA====")
        println(post)
        println()
        
        var nsURL: NSURL = NSURL(string: url)!
        var request = NSMutableURLRequest(URL: nsURL, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 500)
        var bodyData = post
        request.HTTPMethod = "POST"
        var data:NSData! = (bodyData as NSString).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true);
        request.HTTPBody = data
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
            (response, data, error) in

            println("====RAW RESPONSE====")
            var raw:String! = NSString(data: data, encoding: NSUTF8StringEncoding)
            println(raw)
            println()
            
            callback(data)

        }
    }
}
