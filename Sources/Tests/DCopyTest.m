//
//  DCopyTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "DCopyTest.h"

@implementation DCopyTest

- (void)testRequest {
    DAVCopyRequest *req = [self requestOfClass:[DAVCopyRequest class] withPath:@"davkittest/filetest22.txt"];
	req.destinationPath = @"davkittest/filetest23.txt";
	req.overwrite = YES;
    [self queueAndWaitForRequest:req];
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result {
	STAssertNil(result, @"No result expected for COPY");
	
	[self notifyDone];
}

@end
