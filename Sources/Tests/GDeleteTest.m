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
    STAssertNil(self.error, @"Unexpected error for DELETE %@", self.error);
    STAssertNil(self.result, @"Unexpected result for DELETE %@", self.result);
}

@end
