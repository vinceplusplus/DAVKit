//
//  CGetTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "CGetTest.h"

@implementation CGetTest

- (void)testRequest {
    DAVGetRequest *req = [self requestOfClass:[DAVGetRequest class] withPath:@"davkittest/filetest22.txt"];
    [self queueAndWaitForRequest:req];
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result {
	STAssertTrue([result isKindOfClass:[NSData class]], @"Expecting a NSData object for GET requests");
	STAssertTrue([result length] == 4, @"Invalid length (string should be blah)");
	
	[self notifyDone];
}

@end
