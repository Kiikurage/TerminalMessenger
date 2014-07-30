//
//  MyXMLParser.swift
//  TerminalMessenger
//
//  Created by KikuraYuichirou on 2014/06/28.
//  Copyright (c) 2014年 KikuraYuichirou. All rights reserved.
//

import Foundation

class MyXMLParser {
	
	var stream: NSInputStream?
	var currentNode: MyXMLNode?
	var rootNode: MyXMLNode?
	
	init (stream: NSInputStream) {
		self.stream = stream
	}
	
	func parse(message: String) {
		let regTag: RegExp = RegExp("<([^\\?>'\"\\s]+)((?:[^>'\"]+|'[^']*')*)>([^<]*)")
		let regAttr: RegExp = RegExp("([^='\"\\s]+)='([^']*)'")
		let matches = regTag.match(message)
		
		for match in matches {
			let tag = match[0]
			let tagName = match[1]
			let tagAttr = match[2]
			let tagText = match[3]

			if (tag =~ "^</") {
				currentNode = currentNode!.parent!
			} else {
				var node = MyXMLNode(name: tagName)
				
				let attrMatches = regAttr.match(tagAttr)
				for attrMatch in attrMatches {
					let key = attrMatch[1]
					let value = attrMatch[2]
					
					node.attr[key] = value
				}

				if !currentNode {
					rootNode = node
				} else {
					node.text = tagText
					node.parent = currentNode
					currentNode!.children.append(node)
				}
				currentNode = node
				
				if (tag =~ "/>$") {
					currentNode = currentNode!.parent!
				}
			}
		}
	}
	
}