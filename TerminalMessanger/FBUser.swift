//
//  FBUser.swift
//  TerminalMessenger
//
//  Created by KikuraYuichirou on 2014/06/25.
//  Copyright (c) 2014年 KikuraYuichirou. All rights reserved.
//

import Foundation

var FBUserUserList: Dictionary<String, FBUser> = Dictionary<String, FBUser>()

class FBUser: FBGraphNode {

	init(id: String) {
		super.init(id: id)
		FBUserUserList[self.id] = self
	}

	convenience init(dict: NSDictionary) {
		var id: String = dict.objectForKey("id") as String
		self.init(id: id)
		
		name = dict.objectForKey("name") as? String
	}
	
	class func findById(id: String) -> FBUser? {
		return FBUserUserList[id]
	}
	
	let name: String?
}
