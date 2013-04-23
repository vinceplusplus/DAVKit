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

    STAssertNil(self.error, @"Unexpected error for COPY %@", self.error);
    STAssertNil(self.result, @"Unexpected result for COPY %@", self.result);
}

@end
