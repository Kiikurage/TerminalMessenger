//
//  FBThread.swift
//  TerminalMessenger
//
//  Created by KikuraYuichirou on 2014/06/25.
//  Copyright (c) 2014年 KikuraYuichirou. All rights reserved.
//

import Foundation

class FBThread: FBGraphNode {
	
	init(id: String) {
		super.init(id: id)
	}
	
	var users: Array<FBUser> = []
}
