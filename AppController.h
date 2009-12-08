//
//  AppController.h
//  Bits
//
//  Created by Abimanyu on 11/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
	IBOutlet NSMenu *statusMenu;
	NSStatusItem *statusItem;
	NSImage *statusImage;
	NSImage *statusHighlightImage;
}

-(IBAction)helloWorld:(id)sender;
-(IBAction)openHistory:(id)sender;
-(IBAction)openNotificationSources:(id)sender;

@end
