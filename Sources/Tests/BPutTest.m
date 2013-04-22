//
//  BPutTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "BPutTest.h"

@implementation BPutTest

- (void)testRequest {
	const char *bytes = "blah\0";

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url];
    request.HTTPBody = [NSData dataWithBytes:bytes length:strlen(bytes)];
	DAVPutRequest *req = [[DAVPutRequest alloc] initWithPath:@"davkittest/filetest22.txt" originalRequest:request session:self.session delegate:self];
	STAssertNotNil(req, @"Couldn't create the request");

    [self.queue addOperation:req];
	[req release];

	[self waitUntilWeAreDone];
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result {
	STAssertNil(result, @"No result expected for PUT");
	
	[self notifyDone];
}

@end
