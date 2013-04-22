//
//  EMoveTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "EMoveTest.h"

@implementation EMoveTest

- (void)testRequest {
	DAVMoveRequest *req = [[DAVMoveRequest alloc] initWithPath:@"davkittest/filetest23.txt" session:self.session delegate:self];
	req.destinationPath = @"davkittest/filetest24.txt";
    [self queueAndWaitForRequest:req];
	[req release];
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result {
	STAssertNil(result, @"No result expected for MOVE");
	
	[self notifyDone];
}

@end
