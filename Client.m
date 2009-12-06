//
//  Client.m
//  Bits
//
//  Created by Abimanyu on 11/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Client.h"
#import "CJSONDeserializer.h"

@implementation Client

- (void)initRemoteHost
{
	//We connect to a server now
	NSLog(@"Connecting to server...");
	// TODO: make this URL work
	NSString *urlString = @"http://localhost:8191/v1/listen/f240f3226ca";
	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	
	conn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
	NSLog(@"conn: %@", conn);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"received");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"did fail with error: %@", error);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"connection did receive data");
	if([connection isEqualTo:conn]){
		
		NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		//[jsonString appendString:"\n*\n"];
		//TODO: pick a nice looking character
		//TODO: add a new line after eveverything
		
		NSLog(@"data: %@", jsonString);
		
		NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
		NSError *error = nil;
		NSDictionary *messageDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
		
		NSString *content = [messageDict objectForKey:@"content"];
		NSLog(@"content: %@", content);
		
		NSString *filepath = [NSString stringWithFormat:@"%@/bits.txt", NSHomeDirectory()];
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filepath];
		
		[fileHandle seekToEndOfFile];
		[fileHandle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];
		[fileHandle closeFile];
		
	}
}

@end
