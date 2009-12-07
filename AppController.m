//
//  AppController.m
//  Bits
//
//  Created by Abimanyu on 11/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "Client.h"
#import "Growl-WithInstaller/GrowlApplicationBridge.h"

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
	
	NSBundle *myBundle = [NSBundle bundleForClass:[AppController class]];
	NSString *growlPath = [[myBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl-WithInstaller.framework"];
	NSBundle *growlBundle = [NSBundle bundleWithPath:growlPath];
	
	if (growlBundle && [growlBundle load]) {
		NSLog(@"This might work");
		[GrowlApplicationBridge setGrowlDelegate:self]; 
		[GrowlApplicationBridge	notifyWithTitle:@"Tomato Ended"
									description:@"Tomato Ended"
									notificationName:@"Nio"
									   iconData:nil
									   priority:1
									   isSticky:NO
								   clickContext:nil];
	}
	else{
		NSLog(@"This failed");
	}
	
	
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
