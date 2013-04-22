//
//  BDeleteTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "GDeleteTest.h"

@implementation GDeleteTest

- (void)testRequest {
    DAVDeleteRequest *req = [self requestOfClass:[DAVDeleteRequest class] withPath:@"davkittest"];
    [self queueAndWaitForRequest:req];
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result {
	STAssertNil(result, @"No result expected for DELETE");
	
	[self notifyDone];
}

@end
