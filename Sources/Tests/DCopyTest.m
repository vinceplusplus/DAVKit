//
//  DCopyTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "DCopyTest.h"

@implementation DCopyTest

- (void)testRequest {
	DAVCopyRequest *req = [[DAVCopyRequest alloc] initWithPath:@"davkittest/filetest22.txt" session:self.session delegate:self];
	req.destinationPath = @"davkittest/filetest23.txt";
	req.overwrite = YES;

	STAssertNotNil(req, @"Couldn't create the request");
	
	[self.queue addOperation:req];
	[req release];
	
	[self waitUntilWeAreDone];
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result {
	STAssertNil(result, @"No result expected for COPY");
	
	[self notifyDone];
}

@end
