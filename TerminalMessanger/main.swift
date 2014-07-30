//
//  main.swift
//  TerminalMessanger
//
//  Created by KikuraYuichirou on 2014/06/19.
//  Copyright (c) 2014年 KikuraYuichirou. All rights reserved.
//

import Foundation

println(exec("/opt/local/bin/tput", args: ["cols"]))
println(exec("/opt/local/bin/tput", args: ["lines"]))

let fb: FBMessengerClient = FBMessengerClient();
fb.loadAccessToken()
fb.open()

do {
	let word: String = inputln()
	fb.sendSync(word)
} while true