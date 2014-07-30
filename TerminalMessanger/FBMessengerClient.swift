
//
//  FBMessengerClient.swift
//  TerminalMessenger
//
//  Created by KikuraYuichirou on 2014/06/28.
//  Copyright (c) 2014年 KikuraYuichirou. All rights reserved.
//

import Foundation

class FBMessengerClient: TCPConnectionDelegate {
	let host: CFString = "chat.facebook.com"
	let port: UInt32 = 5222 as UInt32

	var connection: TCPConnection?
	var accessToken: String?
	
	
	var parser: MyXMLParser?
	
	
	init () {
	}
}

let XMLStream: String = "<stream:stream xmlns:stream='http://etherx.jabber.org/streams' version='1.0' xmlns='jabber:client' to='chat.facebook.com' xml:lang='en' xmlns:xml='http://www.w3.org/XML/1998/namespace'>"
let XMLAuth: String = "<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='X-FACEBOOK-PLATFORM'></auth>"
let XMLStreamEnd: String = "</stream:stream>"
let XMLResource: String = "<iq type='set' id='3'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><resource>fb_xmpp_script</resource></bind></iq>"
let XMLSession: String = "<iq type='set' id='4' to='chat.facebook.com'><session xmlns='urn:ietf:params:xml:ns:xmpp-session'/></iq>"
let XMLStartTLS: String = "<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>";

/*
 *  AccessToken save/load/update methods
 */
extension FBMessengerClient {
	func loadAccessToken () {
		accessToken = loadSetting(SETTING_KEY_ACCESSTOKEN)
		
		if accessToken {
			println(" OK ".backGreen() + " You have authorized already. Do you continue this session? (y/N:y) >>")
			
			if (inputln() == "N") {
				accessToken = nil
				removeSetting(SETTING_KEY_ACCESSTOKEN)
			}
		}
		
		while !accessToken || accessToken! == "" {
			println(" ERR ".backRed() + " NO_LOGIN_INFO: Please login.")
			self.getAccessToken()
			accessToken = loadSetting(SETTING_KEY_ACCESSTOKEN)
		}
	}

	func getAccessToken() {
		var authURL: String = "https://www.facebook.com/v1.0/dialog/oauth?" +  urlEncode([
			"scope": "xmpp_login",
			"client_id": FB_APP_ID,
			"redirect_uri": FB_REDIRECT_URL,
			"response_type": "token",
			"display": "popup"
			])
		
		exec("/usr/bin/open", args: [authURL])
		
		let spaceSet: NSCharacterSet = NSCharacterSet.whitespaceCharacterSet();
		let token: NSString = inputln().stringByTrimmingCharactersInSet(spaceSet)
		saveSetting(SETTING_KEY_ACCESSTOKEN, token)
	}
}

/*
 *  Core Transmission methods
 */
extension FBMessengerClient {
	func open() {
		connection = TCPConnection(host, port: port)
		connection!.delegate = self
		parser = MyXMLParser(stream: connection!.inputStream!)

		connection!.sync()
		connection!.open()
		connection!.wait()

		connect()
	}
	
	func sendSync(message: String) {
		connection!.sync()
		connection!.send(message)
		connection!.wait()
	}

	func findNode(tag: String) -> MyXMLNode? {
		let res = parser!.rootNode!.getNodeByName(tag)
		return res.count > 0 ? res[0] : nil
	}
	
	func findNode(tag: String, value: String) -> String? {
		let res = parser!.rootNode!.getNodeByName(tag)
		return nil
	}
	
	func findNode(tag: String, text: String) -> MyXMLNode? {
		let nodes = parser!.rootNode!.getNodeByName(tag)
		
		for node in nodes {
			if node.text == text {
				return node
			}
		}
		
		return nil
	}

	func connect() {
		sendSync(XMLStream)

		if !findNode("stream:stream") {
			println(" ERR ".backRed() + " connection closed(CODE = 001).")
			return
		}
		if !findNode("mechanism", text: "X-FACEBOOK-PLATFORM") {
			println(" ERR ".backRed() + " connection closed(CODE = 002).")
			return
		}

		sendSync(XMLStartTLS);
		
		if !findNode("proceed") {
			println(" ERR ".backRed() + " connection closed(CODE = 003).")
			return
		}

		connection!.inputStream!.setProperty(NSStreamSocketSecurityLevelNegotiatedSSL, forKey: NSStreamSocketSecurityLevelKey)

		sendSync(XMLStream)

		if (!findNode("stream:stream")) {
			println(" ERR ".backRed() + " connection closed(CODE = 004).")
			return
		}
		if (!findNode("mechanism", text: "X-FACEBOOK-PLATFORM")) {
			println(" ERR ".backRed() + " connection closed(CODE = 005).")
			return
		}
		
		sendSync(XMLAuth)
		
		var challengeNode: MyXMLNode? = findNode("challenge")
		if !challengeNode {
			println(" ERR ".backRed() + " connection closed(CODE = 006).")
			return
		}
		
		//gets challenge from server and decode it
		let decodedData = NSData(base64EncodedString: challengeNode!.text, options: .IgnoreUnknownCharacters)
		let decodedStr = NSString(data: decodedData, encoding: NSUTF8StringEncoding)
		let decodedDict: Dictionary<String, String> = urlDecode(decodedStr)

		var resArray: Dictionary<String, String> = Dictionary<String, String>()
		resArray["method"] = decodedDict["method"]
		resArray["nonce"] = decodedDict["nonce"]
		resArray["access_token"] = accessToken!
		resArray["api_key"] = FB_APP_ID
		resArray["call_id"] = "0"
		resArray["v"] = "1.0"

		let resQuery = NSString(string: urlEncode(resArray))
		let resData: NSData? = resQuery.dataUsingEncoding(NSUTF8StringEncoding)
		var encodeStr: String = resData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
		encodeStr = join("", encodeStr.componentsSeparatedByString("\r\n"))
		let response: String = "<response xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>" + encodeStr + "</response>"

		sendSync(response)

		if (!findNode("success")) {
			println(" ERR ".backRed() + " connection closed(CODE = 007).")
			return
		}

		sendSync(XMLStream)

		if (!findNode("stream:stream")) {
			println(" ERR ".backRed() + " connection closed(CODE = 008).")
			return
		}
		if (!findNode("stream:features")) {
			println(" ERR ".backRed() + " connection closed(CODE = 009).")
			return
		}

		sendSync(XMLResource)
		
		if (!findNode("jid")) {
			println(" ERR ".backRed() + " connection closed(CODE = 010).")
			return
		}

		sendSync(XMLSession)

		if (!findNode("session")) {
			println(" ERR ".backRed() + " connection closed(CODE = 011).")
			return
		}
		
//		sendSync(XMLStreamEnd)
		
		println(" OK ".backGreen() + " Authentication complete")
		
//<message to='-100001389024434@chat.facebook.com' from='-100003521676178@chat.facebook.com' type='chat'><body>test</body></message>
//<message to='-100001389024434@chat.facebook.com' from='-100001389024434@chat.facebook.com' type='chat'><body>test</body></message>
		return
	}
}

/*
 *  Delegate Methods of TCPConnectionDelegate Protocol
 */
extension FBMessengerClient {
	func tcpConnectionDidOpen(connection: TCPConnection) {
	}
	
	func tcpConnectionDidReceiveMessage(connection: TCPConnection, message: String) {
		parser!.parse(message)
	}
}