//
//  AppController.m
//  Bits
//
//  Created by Abimanyu on 11/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "Client.h"
#import "Growl/GrowlApplicationBridge.h"

@implementation AppController

- (void) awakeFromNib{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	
	NSBundle *bundle = [NSBundle mainBundle];
	
	statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"grin" ofType:@"png"]];
	statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"grin" ofType:@"png"]];
	
	[statusItem setImage:statusImage];
	[statusItem setAlternateImage:statusHighlightImage];
	
	[statusItem setMenu:statusMenu];
	
	[statusItem setToolTip:@"Bits"];
	
	[statusItem setHighlightMode:YES];
	
	[GrowlApplicationBridge setGrowlDelegate:self]; 
	
	[GrowlApplicationBridge	notifyWithTitle:@"Tomato Ended"
								description:@"Tomato Ended"
						   notificationName:@"Bits"
								   iconData:nil
								   priority:1
								   isSticky:NO
							   clickContext:nil];
	NSLog(@"This worked");
	
	[[Client alloc] initRemoteHost];
}

- (void) dealloc{
	[statusImage release];
	[statusHighlightImage release];
	[super dealloc];
}

- (IBAction)helloWorld:(id)sender{
	NSLog(@"Hello Andrew Jones");
}

@end
