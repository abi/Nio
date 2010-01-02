//
//  Client.m
//  Nio - Notify.io client
//
//  Copyright 2009 GliderLab. All rights reserved.
//

#import "Client.h"
#import "CJSONDeserializer.h"


@implementation Client

@synthesize growlData;

- (void)initRemoteHost:(NSString *)urlString
{
	NSLog(@"Connecting to server...");

	NSURL *url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	
	// Set the timeout to 15 min. It will reconnect.
	[urlRequest setTimeoutInterval:900.0];
	
	// Keep this around for reconnects
	notifyReq = urlRequest;
	
	[self makeConnection];
}

- (void)makeConnection
{
	notifyConn = [[NSURLConnection alloc] initWithRequest:notifyReq delegate:self startImmediately:YES];
	NSLog(@"conn: %@", notifyConn);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"received");
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"connection finished");
	[self makeConnection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"did fail with error: %@", error);
	// if hostname not found or net connection offline, try again after delay
	if([error code] == -1003 || [error code] == -1009) {
		[self performSelector:@selector(makeConnection) withObject:nil afterDelay:3.0];
	}
	else if([error code] != -1002) {
		[self makeConnection];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
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
		
		// Call the hook script if it's around
		NSString *hookPath = [NSString stringWithFormat:@"%@/.NioCallback", NSHomeDirectory()];
		NSString *hookScript = [[NSString alloc] initWithContentsOfFile:hookPath encoding:NSASCIIStringEncoding error:&error];
		if ([hookScript length] != 0) {
			NSLog(@"running hook: %@", hookPath);
			NSTask *task = [[NSTask alloc] init];
			NSArray *arguments = [NSArray arrayWithObjects: [growlData objectForKey:@"text"], [growlData objectForKey:@"title"], [growlData objectForKey:@"link"], nil];
			[task setArguments: arguments];
			[task setLaunchPath: hookPath];
			[task launch];
		}
		
		// Get the icon from the json data
		NSString *iconURLStr = [growlData objectForKey:@"icon"];
		if(!iconURLStr)
		{
			
			[GrowlApplicationBridge notifyWithTitle:[growlData objectForKey:@"title"] 
										description:[growlData objectForKey:@"text"] 
								   notificationName:@"Nio" 
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
							   notificationName:@"Nio" 
									   iconData:[image TIFFRepresentation]
									   priority:1 
									   isSticky:[[growlData objectForKey:@"sticky"] isEqualToString:@"true"]
								   clickContext:[growlData objectForKey:@"link"]];
		
		[iconConn release];
		iconConn = nil;
		self.growlData = nil;
	}
}



@end
