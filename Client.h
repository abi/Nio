//
//  Client.m
//  Nio - notify.io client
//
//  Created by Abimanyu on 11/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Growl-WithInstaller/GrowlApplicationBridge.h"

@interface Client : NSObject <GrowlApplicationBridgeDelegate> {
	NSURLConnection *notifyConn;
	NSURLConnection *iconConn;
	NSDictionary *growlData;
}
@property (nonatomic, retain) NSDictionary *growlData;
@end
