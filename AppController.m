//
//  AppController.m
//  Nio - Notify.io client
//
//  Copyright 2009 GliderLab. All rights reserved.
//

#import "AppController.h"
#import "Client.h"
#import "Growl-WithInstaller/GrowlApplicationBridge.h"

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"launched");
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	NSError *error;
	NSString *stringFromFileAtPath = [[NSString alloc]
                                      initWithContentsOfFile:filename
                                      encoding:NSASCIIStringEncoding
                                      error:&error];
	if([stringFromFileAtPath length] == 0)
	{
		NSLog(@"the file at path %@ is empty", stringFromFileAtPath);
		return NO;
	}
	else {
		NSLog(@"loading url: %@", stringFromFileAtPath);
	}

	NSString *nioFilename = [NSString stringWithFormat:@"%@/.Nio", NSHomeDirectory()];
	NSString *nioString = [[NSString alloc]
						   initWithContentsOfFile:nioFilename
						   encoding:NSASCIIStringEncoding
						   error:&error];
	NSRange range = [nioString rangeOfString:stringFromFileAtPath];
	if (range.location == NSNotFound) {
		nioString = [nioString stringByAppendingString:stringFromFileAtPath];
		[nioString writeToFile:nioFilename atomically:YES encoding:NSASCIIStringEncoding error:&error];
	
		NSString *newUrl = [stringFromFileAtPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[[Client alloc] initRemoteHost:newUrl];
	
		[GrowlApplicationBridge notifyWithTitle:@"Installed Listen URL"
								description:@"Now listening to notification stream" 
						   notificationName:@"Nio" 
								   iconData:nil 
								   priority:1
								   isSticky:NO
							   clickContext:nil];
	}
	else {
		[GrowlApplicationBridge notifyWithTitle:@"Skipped Listen URL"
									description:@"This Listen URL was already installed" 
							   notificationName:@"Nio" 
									   iconData:nil 
									   priority:1
									   isSticky:NO
								   clickContext:nil];
	}
	return YES;
}

- (void) awakeFromNib{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	
	NSBundle *bundle = [NSBundle mainBundle];
	
	statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"grin" ofType:@"png"]];
	statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"grin" ofType:@"png"]];
	
	[statusItem setImage:statusImage];
	[statusItem setAlternateImage:statusHighlightImage];
	
	[statusItem setMenu:statusMenu];
	
	[statusItem setToolTip:@"Notify.io"];
	
	[statusItem setHighlightMode:YES];
	
	NSBundle *myBundle = [NSBundle bundleForClass:[AppController class]];
	NSString *growlPath = [[myBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl-WithInstaller.framework"];
	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];

	
	if (growlBundle && [growlBundle load]) {
		[GrowlApplicationBridge setGrowlDelegate:self]; 
	}
	else{
		NSLog(@"Could not load Growl.framework");
	}
	
	
	NSString *filepath = [NSString stringWithFormat:@"%@/.Nio", NSHomeDirectory()];
	NSError *error;
	NSString *nioData = [[NSString alloc]
                                      initWithContentsOfFile:filepath
                                      encoding:NSASCIIStringEncoding
                                      error:&error];
	nioData = [nioData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSLog(@"contents of file: %@", nioData);
	
	if([nioData length] == 0)
	{
		NSLog(@"the file at path %@ is empty. creating empty file.", filepath);
		NSString *emptyString = @"";
		[emptyString writeToFile:filepath atomically:YES encoding:NSASCIIStringEncoding error:&error];
		[GrowlApplicationBridge	notifyWithTitle:@"Nio needs to be configured"
									description:@"Click to finish Getting Started at Notify.io"
							   notificationName:@"Nio"
									   iconData:nil
									   priority:1
									   isSticky:NO
								   clickContext:@"http://www.notify.io/getstarted"]; 
	}
	else {
		NSArray *urls = [nioData componentsSeparatedByString:@"\n"];
		[GrowlApplicationBridge notifyWithTitle:@"Nio started"
									description:[NSString stringWithFormat:@"Listening to %d notification streams", [urls count]] 
							   notificationName:@"Nio" 
									   iconData:nil 
									   priority:1
									   isSticky:NO
								   clickContext:nil];
		for (NSString *url in urls) {
			[[Client alloc] initRemoteHost:url];
		}
	
	}
	
	
}

- (void) dealloc{
	[statusImage release];
	[statusHighlightImage release];
	[super dealloc];
}

- (IBAction)openHistory:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.notify.io/history"]];
}

- (IBAction)openSources:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.notify.io/sources"]];
}

- (IBAction)openSettings:(id)sender{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.notify.io/settings"]];
}

#pragma mark GrowlApplicationBridgeDelegate method 

- (NSDictionary *)registrationDictionaryForGrowl;
{
	NSMutableDictionary *regDictionary = [[[NSMutableDictionary alloc] initWithCapacity:5] autorelease];
	
	// An NSArray of all possible names of notifications.
	NSMutableArray *notificationNames = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
	[notificationNames addObject:@"Nio"];
	[regDictionary setObject:notificationNames forKey:GROWL_NOTIFICATIONS_ALL];
	
	// An NSArray of notifications enabled by default (either by name, or by index into the GROWL_NOTIFICATIONS_ALL array).
	NSMutableArray *defaultEnabledNotifications = [[NSMutableArray alloc] initWithCapacity:1];
	[defaultEnabledNotifications addObject:@"Nio"];
	[regDictionary setObject:defaultEnabledNotifications forKey:GROWL_NOTIFICATIONS_DEFAULT];
	
	return regDictionary;
}

- (void) growlNotificationWasClicked:(id)clickContext;
{
	NSLog(@"growlNotificationWasClicked:%@", clickContext);
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:clickContext]];
}

@end
