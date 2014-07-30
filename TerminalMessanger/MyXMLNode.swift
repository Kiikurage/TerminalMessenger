//
//  MyXMLNode.swift
//  TerminalMessenger
//
//  Created by KikuraYuichirou on 2014/06/28.
//  Copyright (c) 2014年 KikuraYuichirou. All rights reserved.
//

import Foundation

class MyXMLNode: Printable {
	var name: String
	var attr: Dictionary<String, String> = Dictionary<String, String>()
	var text: String = ""
	var parent: MyXMLNode?
	var children: Array<MyXMLNode> = Array<MyXMLNode>()
	
	init () {
		name = ""
	}

	convenience init (name: String) {
		self.init()
		self.name = name
	}

	convenience init (attr: Dictionary<String, String>) {
		self.init()
		self.attr = attr
	}

	convenience init (name: String, attr: Dictionary<String, String>) {
		self.init()
		self.attr = attr
	}
}

extension MyXMLNode {
	func printBeauty() -> String {
		var result = "<" + name
		
		for (key, value) in attr {
			result += " " + key + "='" + value + "'"
		}
		result += ">"
		
		result += text
		for child in children {
			result += child.printBeauty()
		}
		
		result += "</" + name + ">"
		
		return result
	}
}

extension MyXMLNode {
	func getNodeByName(targetName: String) -> Array<MyXMLNode> {
		var res: Array<MyXMLNode> = []
		
		for child in children {
			res += child.getNodeByName(targetName)
		}

		if self.name == targetName {
			res.append(self)
		}
		
		return res
	}

	func getNodeByAttr(key: String) -> Array<MyXMLNode> {
		var res: Array<MyXMLNode> = []
		
		for child in children {
			res += child.getNodeByAttr(key)
		}
		
		if attr[key] {
			res.append(self)
		}
		
		return res
	}

	func getNodeByAttr(key: String, value: String) -> Array<MyXMLNode> {
		var res: Array<MyXMLNode> = []
		
		for child in children {
			res += child.getNodeByAttr(key, value: value)
		}
		
		if attr[key]? == value {
			res.append(self)
		}
		
		return res
	}
}

extension MyXMLNode {
	var description: String {
	get {
		return printBeauty()
	}
	}
}