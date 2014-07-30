//
//  util.swift
//  TerminalMessanger
//
//  Created by KikuraYuichirou on 2014/06/19.
//  Copyright (c) 2014年 KikuraYuichirou. All rights reserved.
//

import Foundation



/*
 * print color escape sequence
 */

let escNormal: String = "\u{1B}[m"
let escTextRed: String    = "\u{1B}[31m"
let escTextGreen: String  = "\u{1B}[32m"
let escTextYellow: String = "\u{1B}[33m"
let escTextBlue: String   = "\u{1B}[34m"
let escTextBold: String = "\u{1B}[1m"
let escBackRed: String    = "\u{1B}[41m"
let escBackGreen: String  = "\u{1B}[42m"
let escBackYellow: String = "\u{1B}[43m"
let escBackBlue: String   = "\u{1B}[44m"

extension String {
	func backRed() -> String {
		return escBackRed + self + escNormal
	}
	
	func backBlue() -> String {
		return escBackBlue + self + escNormal
	}
	
	func backGreen() -> String {
		return escBackGreen + self + escNormal
	}
	
	func backYellow() -> String {
		return escBackYellow + self + escNormal
	}
	
	func red() -> String {
		return escTextRed + self + escNormal
	}

	func blue() -> String {
		return escTextBlue + self + escNormal
	}

	func green() -> String {
		return escTextGreen + self + escNormal
	}

	func yellow() -> String {
		return escTextYellow + self + escNormal
	}

	func bold() -> String {
		return escTextBold + self + escNormal
	}
}

/*
 * http request method
 */
func get(url: String, parameter: Dictionary<String, String>? = nil) -> String {
	var urlWithParam = url
	
	if parameter {
		urlWithParam += "?" + urlEncode(parameter!)
	}
	var request = NSURLRequest(URL: NSURL(string: urlWithParam))

	return httpRequestSend(request)
}
func post(url: String, parameter: Dictionary<String, String>? = nil) -> String {
	var body: String = ""
	
	if parameter {
		body = urlEncode(parameter!)
	}
	var request = NSMutableURLRequest(URL: NSURL(string: url))
	
	request.HTTPMethod = "POST"
	request.HTTPBody = NSString(string: body).dataUsingEncoding(NSUTF8StringEncoding)
	
	return httpRequestSend(request)
}
func httpRequestSend(request: NSURLRequest) -> String {
	
	var e: NSError?
	var responseData: NSData = NSURLConnection.sendSynchronousRequest(
		request,
		returningResponse: nil,
		error: &e
	)
	if e {
		println("Error: \(e!.localizedDescription)");
	}
	
	var encArray: [UInt] = [
		NSUTF8StringEncoding,           // UTF-8
		NSShiftJISStringEncoding,       // Shift-JIS
		NSJapaneseEUCStringEncoding,    // EUC-JP
		NSISO2022JPStringEncoding,      // JIS
		NSUnicodeStringEncoding,        // Unicode
		NSASCIIStringEncoding           // ASCII
	]
	
	var string: NSString?
	for encoding: UInt in encArray {
		string = NSString(data: responseData, encoding: encoding)
		if string != nil {
			break;
		}
	}
	
	return string!
}
func urlEncode(parameter: Dictionary<String, String>) -> String {
	var queries: Array<String> = []
	
	for (key, val) in parameter {
		queries.append(key + "=" + val)
	}
	
	return join("&", queries)
}
func urlDecode(parameter: String) -> Dictionary<String, String> {
	
	var res = Dictionary<String, String>()
	let arr = parameter.componentsSeparatedByString("&")
	
	for token in arr {
		let arr2 = token.componentsSeparatedByString("=")
		if arr2.count != 2 {
			continue
		}
		
		res[arr2[0]] = arr2[1]
	}
	
	return res
}


/*
 * execute terminal command method
 */
func exec(launchPath: String, args: [String] = [String]()) -> String{
	var task = NSTask()
	task.launchPath = launchPath
	task.arguments = args
	
	let pipe = NSPipe()
	task.standardOutput = pipe
	
	task.launch()
	task.waitUntilExit()
	
	let data = pipe.fileHandleForReading.availableData
	let str = NSString(data: data, encoding: NSUTF8StringEncoding)
	
	return str
}


/*
 * read input method
 */
func inputln() -> String {
	var stdinHandle: NSFileHandle = NSFileHandle.fileHandleWithStandardInput()
	var data: NSData = stdinHandle.availableData
	
	return NSString(data: data, encoding:NSUTF8StringEncoding)
		.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
}


/*
 * convert JSON to Dictionary
 */
func convertJSON(string: String) -> AnyObject {
	let data: NSData = string.dataUsingEncoding(NSUTF8StringEncoding)!
	return NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
}


/*
 * save setting
 */
func saveSetting(key: String, value: String) {
	var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults();
	defaults.setObject(value, forKey: key)
	defaults.synchronize()
}


/*
 * load setting
 */
func loadSetting(key: String) -> String? {
	var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults();
	return defaults.stringForKey(key)
}


/*
 * remove setting
 */
func removeSetting(key: String) {
	var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults();
	defaults.removeObjectForKey(key)
	defaults.synchronize()
}

extension String {
	
	mutating func replace(target: String, withString: String) -> String  {
		self = NSString(string: self).stringByReplacingOccurrencesOfString(target, withString: withString)
		return self
	}
	
}