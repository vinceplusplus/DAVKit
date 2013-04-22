//
//  AMkColTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "AMkColTest.h"

@implementation AMkColTest

- (void)testRequest {

    DAVMakeCollectionRequest *req = [self requestOfClass:[DAVMakeCollectionRequest class] withPath:@"davkittest"];
    [self queueAndWaitForRequest:req];
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result {
	STAssertNil(result, @"No result expected for MKCOL");
	
	[self notifyDone];
}

@end
