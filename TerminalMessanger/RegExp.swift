//
//  MyRegExp.swift
//  TerminalMessenger
//
//  Created by KikuraYuichirou on 2014/06/30.
//  Copyright (c) 2014年 KikuraYuichirou. All rights reserved.
//

import Foundation

class RegExp {
	let internalExpression: NSRegularExpression
	let pattern: String
	
	init(_ pattern: String) {
		self.pattern = pattern
		internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: nil)
	}
	
	func test(input: String) -> Bool {
		return matchCore(input).count > 0
	}
	
	func matchCore(input: String) -> Array<NSTextCheckingResult> {
		return internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0, countElements(input))) as Array<NSTextCheckingResult>
	}
	
	func match(input: String) -> Array<Array<String>> {
		let inputNS = NSString(string: input)
		let matches = matchCore(input)
		var result = Array<Array<String>>()
		
		for match: NSTextCheckingResult in matches {
			var item = Array<String>()
			
			for i: Int in 0..match.numberOfRanges {
				item.append(inputNS.substringWithRange(match.rangeAtIndex(i)) as String)
			}
			
			result.append(item)
		}
		
		return result
	}
}

operator infix =~ {}
func =~ (input: String, pattern: String) -> Bool {
	return RegExp(pattern).test(input)
}