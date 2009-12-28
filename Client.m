//
//  Client.m
//  Nio - notify.io client
//
//  Created by Abimanyu on 11/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Client.h"
#import "CJSONDeserializer.h"

@interface Client ()
// Private methods
- (void)initRemoteHost:(NSString *)path;
@end

@implementation Client

@synthesize growlData;

- (void)initRemoteHost
{
	NSString *filepath = [NSString stringWithFormat:@"%@/.growlURL", NSHomeDirectory()];
	NSError *error;
	NSString *stringFromFileAtPath = [[NSString alloc]
                                      initWithContentsOfFile:filepath
                                      encoding:NSASCIIStringEncoding
                                      error:&error];
	NSLog(@"contents of file: %@", stringFromFileAtPath);
	
	if([stringFromFileAtPath length] == 0)
	{
		NSLog(@"the file at path %@ is empty", filepath);
		return;
	}
	
	NSString *urlString = [stringFromFileAtPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	
	//We connect to a server now
	NSLog(@"Connecting to server...");

	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	
	notifyConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
	NSLog(@"conn: %@", notifyConn);
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
	//NSDictionary *messageDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	if([connection isEqualTo:notifyConn])
	{
		
		NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSLog(@"data: %@", string);
		
		// Keep the data in case we need it to stick around because we won't be posting the growl notif
		// until we get the icon
		
		NSData *jsonData = [string dataUsingEncoding:NSUTF32BigEndianStringEncoding];
		NSError *error = nil;
		NSDictionary *messageDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
		self.growlData = messageDict;
		
		// Get the icon from the json data
		NSString *iconURLStr = [growlData objectForKey:@"icon"];
		if(!iconURLStr)
		{
			
			[GrowlApplicationBridge notifyWithTitle:[growlData objectForKey:@"title"] 
										description:[growlData objectForKey:@"text"] 
								   notificationName:@"name1" 
										   iconData:nil 
										   priority:1 
										   isSticky:[[growlData objectForKey:@"sticky"] isEqualToString:@"true"] 
									   clickContext:[growlData objectForKey:@"link"]];
			
			self.growlData = nil;
		}
		else {
			// Get the icon from the url
			
			NSURL *url = [NSURL URLWithString:iconURLStr];
			
			NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
			
			iconConn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
		}
		
	}
	else if([connection isEqualTo:iconConn])
	{
		// Make an image out of the received data
		NSImage *image = [[NSImage alloc] initWithData:data];
		
		
		[GrowlApplicationBridge notifyWithTitle:[growlData objectForKey:@"title"] 
									description:[growlData objectForKey:@"text"] 
							   notificationName:@"name1" 
									   iconData:[image TIFFRepresentation]
									   priority:1 
									   isSticky:[[growlData objectForKey:@"sticky"] isEqualToString:@"true"]
								   clickContext:[growlData objectForKey:@"link"]];
		
		[iconConn release];
		iconConn = nil;
		self.growlData = nil;
	}
}

#pragma mark GrowlApplicationBridgeDelegate method 

- (NSDictionary *)registrationDictionaryForGrowl;
{
	NSMutableDictionary *regDictionary = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
	
	// An NSArray of all possible names of notifications.
	NSMutableArray *notificationNames = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
	[notificationNames addObject:@"name1"];
	[regDictionary setObject:notificationNames forKey:GROWL_NOTIFICATIONS_ALL];
	
	// An NSArray of notifications enabled by default (either by name, or by index into the GROWL_NOTIFICATIONS_ALL array).
	NSMutableArray *defaultEnabledNotifications = [[NSMutableArray alloc] initWithCapacity:1];
	[defaultEnabledNotifications addObject:@"name1"];
	[regDictionary setObject:defaultEnabledNotifications forKey:GROWL_NOTIFICATIONS_DEFAULT];
	
	return regDictionary;
}

- (void) growlNotificationWasClicked:(id)clickContext;
{
	NSLog(@"growlNotificationWasClicked:%@", clickContext);
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:clickContext]];
}

@end
