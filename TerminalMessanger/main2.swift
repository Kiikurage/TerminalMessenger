////
////  main2.swift
////  TerminalMessenger
////
////  Created by KikuraYuichirou on 2014/06/28.
////  Copyright (c) 2014年 KikuraYuichirou. All rights reserved.
////
//
//import Foundation
//
//func tmp {
//	let fb: FB = FB()
//	
//	let res = convertJSON(
//		get("https://graph.facebook.com/me/inbox", parameter: [
//			"access_token": fb.accessToken!
//			]
//		)) as NSDictionary
//	
//	let threads: NSArray = res.objectForKey("data") as NSArray
//	
//	var i: Int = 0;
//	
//	for _thread: AnyObject in threads {
//		i++
//		if i > 1 {
//			break
//		}
//		
//		let thread: NSDictionary = _thread as NSDictionary
//		let commentsDict: NSDictionary = thread.objectForKey("comments") as NSDictionary
//		let comments: NSArray = commentsDict.objectForKey("data") as NSArray
//		
//		var lastUser: FBUser? = nil
//		
//		for _comment: AnyObject in comments {
//			let comment: NSDictionary = _comment as NSDictionary
//			let message: FBMessage = FBMessage(dict: comment)
//			
//			if !lastUser || message.sender!.id != lastUser!.id {
//				print("\n" + message.sender!.name!.yellow() + "\n")
//			}
//			
//			if message.time {
//				let time: NSDate = message.time!
//				let formatter: NSDateFormatter = NSDateFormatter()
//				
//				formatter.dateFormat = "HH':'mm'"
//				
//				let timeWithFormat: String = formatter.stringFromDate(time)
//				
//				print(timeWithFormat.blue() + " ")
//			}
//			
//			var messageWithFormat: String = message.text!
//			messageWithFormat.replace("\n", withString: "\n      ")
//			
//			print(messageWithFormat + "\n")
//			
//			lastUser = message.sender
//		}
//	}
//	
//	func drawSendArea() {
//		println("-----------------------------------------")
//		println(" message: ")
//		
//		let tcp: TCP = TCP()
//		tcp.delegate = fb
//		tcp.open()
//		
//		while true {
//			let word: String = inputln()
//			tcp.send(word)
//		}
//	}
//	
//	drawSendArea()
//}