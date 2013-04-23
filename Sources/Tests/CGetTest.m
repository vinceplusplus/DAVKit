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

    STAssertNil(self.error, @"Unexpected error for PUT %@", self.error);
	STAssertTrue([self.result isKindOfClass:[NSData class]], @"Expecting a NSData object for GET requests");
	STAssertTrue([self.result length] == 4, @"Invalid length (string should be blah)");
}

@end
