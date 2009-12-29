//
//  AppController.h
//  Nio - Notify.io client
//
//  Copyright 2009 GliderLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
	IBOutlet NSMenu *statusMenu;
	NSStatusItem *statusItem;
	NSImage *statusImage;
	NSImage *statusHighlightImage;
}

-(IBAction)openHistory:(id)sender;
-(IBAction)openSources:(id)sender;
-(IBAction)openSettings:(id)sender;

@end
