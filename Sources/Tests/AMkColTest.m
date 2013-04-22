//
//  AMkColTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "AMkColTest.h"

@implementation AMkColTest

- (void)testRequest {

    DAVMakeCollectionRequest *req = [[DAVMakeCollectionRequest alloc] initWithPath:@"davkittest" session:self.session delegate:self];
    [self queueAndWaitForRequest:req];
	[req release];
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result {
	STAssertNil(result, @"No result expected for MKCOL");
	
	[self notifyDone];
}

@end
