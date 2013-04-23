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

    STAssertNil(self.error, @"Unexpected error for MOVE %@", self.error);
    STAssertNil(self.result, @"Unexpected result for MOVE %@", self.result);
}

@end
