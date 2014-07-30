//
//  FBMessage.swift
//  TerminalMessenger
//
//  Created by KikuraYuichirou on 2014/06/25.
//  Copyright (c) 2014年 KikuraYuichirou. All rights reserved.
//

import Foundation

class FBMessage: FBGraphNode {
	
	init(id: String) {
		super.init(id: id)
	}
	
	convenience init(dict: NSDictionary) {
		
		var id: String = dict.objectForKey("id") as String
		self.init(id: id)
		
		var timestr: String? = dict.objectForKey("created_time") as? String
		
		if timestr {
			let formatter: NSDateFormatter = NSDateFormatter()
			formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"
			time = formatter.dateFromString(timestr!)
		}
		
		text = dict.objectForKey("message") as? String
		if !text {
			text = "---------(検閲にひっかかりました)---------".red()
		}
		
		var userdict: NSDictionary? = dict.objectForKey("from") as? NSDictionary
		if userdict {
			sender = FBUser(dict: userdict!)
		}
		
	}
	
	var time: NSDate?
	var text: String?
	var sender: FBUser?
}
