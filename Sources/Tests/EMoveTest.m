//
//  EMoveTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "EMoveTest.h"

@implementation EMoveTest

- (void)testRequest {
    DAVMoveRequest *req = [self requestOfClass:[DAVMoveRequest class] withPath:@"davkittest/filetest23.txt"];
	req.destinationPath = [self fullPathForPath:@"davkittest/filetest24.txt"];
    [self queueAndWaitForRequest:req];
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result {
	STAssertNil(result, @"No result expected for MOVE");
	
	[self notifyDone];
}

@end
