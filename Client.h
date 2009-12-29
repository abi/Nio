//
//  Client.m
//  Nio - Notify.io client
//
//  Copyright 2009 GliderLab. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Growl-WithInstaller/GrowlApplicationBridge.h"

@interface Client : NSObject <GrowlApplicationBridgeDelegate> {
	NSURLConnection *notifyConn;
	NSURLRequest *notifyReq;
	NSURLConnection *iconConn;
	NSDictionary *growlData;
}
@property (nonatomic, retain) NSDictionary *growlData;
@end
