//
//  BDeleteTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "GDeleteTest.h"

@implementation GDeleteTest

- (void)testRequest {
	DAVDeleteRequest *req = [[DAVDeleteRequest alloc] initWithPath:@"davkittest" session:self.session delegate:self];

	STAssertNotNil(req, @"Couldn't create the request");
	
	[self.queue addOperation:req];
	[req release];
	
	[self waitUntilWeAreDone];
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result {
	STAssertNil(result, @"No result expected for DELETE");
	
	[self notifyDone];
}

@end
