//
//  Client.h
//  Bits
//
//  Created by Abimanyu on 11/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Client : NSObject
NSURLConnection *conn;
- (void)initRemoteHost;
@end
