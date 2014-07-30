//
//  TCPConnection.swift
//  TerminalMessenger
//
//  Created by KikuraYuichirou on 2014/06/26.
//  Copyright (c) 2014年 KikuraYuichirou. All rights reserved.
//
//  ref:
//  http://stackoverflow.com/questions/24028995/toll-free-bridging-and-pointer-access-in-swift

import Foundation

@objc protocol TCPConnectionDelegate {
	func tcpConnectionDidOpen(connection: TCPConnection)
	func tcpConnectionDidReceiveMessage(connection: TCPConnection, message: String)
}

class TCPConnection: NSObject, NSStreamDelegate {
	
	var host: CFString?
	var port: UInt32?

	var inputStream: NSInputStream?
	var outputStream: NSOutputStream?

	var isOpen: Bool = false
	
	var delegate: TCPConnectionDelegate?
	
	var lastMessageID: Int = 0
	var syncMessageID: Int = 0

	init (_ host: CFString, port: UInt32) {
		super.init()
		
		self.host = host
		self.port = port
		
		var readStream: Unmanaged<CFReadStream>? = nil;
		var writeStream: Unmanaged<CFWriteStream>? = nil;
		

		CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, host, port, &readStream, &writeStream)
		
		inputStream = readStream!.takeUnretainedValue()
		outputStream = writeStream!.takeUnretainedValue()

		inputStream!.delegate = self
		outputStream!.delegate = self
	}
	
}

extension TCPConnection {
	func open() {

		let thread: NSThread = NSThread(target:self, selector:"openOnSubThread", object:nil)
		thread.start()
	}
	
	func openOnSubThread() {
		inputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode);
		outputStream!.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode);
		
		inputStream!.open()
		outputStream!.open()
		
		isOpen = true
		let that = self

		lastMessageID++
		
		fetch()
	}
	
	func fetch() {
		while true {
			if !isOpen {
				break
			}
			
			NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.1));
			NSThread.sleepForTimeInterval(0.1)
		}
	}
	
	func sync() {
		syncMessageID = lastMessageID
	}
	
	func wait() {
		while true {
			if syncMessageID != lastMessageID {
				break
			}
			
			NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0.1));
			NSThread.sleepForTimeInterval(0.1)
		}
	}
	
	func close() {
		isOpen = false
		
		inputStream!.close()
		outputStream!.close()
		
		inputStream!.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
		outputStream!.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
	}
}

extension TCPConnection {
	func send(str: String) {
		let message: NSString = NSString(string: str)
		let data: NSData = message.dataUsingEncoding(NSUTF8StringEncoding)
		let length: Int = data.length
		var buffer: Array<UInt8> = Array<UInt8>(count: length, repeatedValue: 0)
		memcpy(&buffer, data.bytes, UInt(length))
		
		outputStream!.write(buffer, maxLength: length)
		println(" send ".backBlue())
		println(str)
	}
}

extension TCPConnection {
	func stream(aStream: NSStream!, handleEvent eventCode: NSStreamEvent){
		switch(eventCode) {
			
		case NSStreamEvent.HasBytesAvailable:
			if (aStream == inputStream) {
				read()
			}
			
		default:
			break;
		}
	}
	
	func read() {
		var buffer: Array<UInt8> = Array<UInt8>(count: 1024, repeatedValue: 0)
		let length: Int = inputStream!.read(&buffer, maxLength: 1024)
		let data: NSData = NSData(bytesNoCopy: &buffer, length: length)
		var message: String = NSString(data: data, encoding: NSUTF8StringEncoding)

		println(" receive ".backBlue())
		println(message)

		delegate?.tcpConnectionDidReceiveMessage(self, message: message)

		lastMessageID++
	}
}