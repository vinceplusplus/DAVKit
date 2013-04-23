//
//  AMkColTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "AMkColTest.h"

@implementation AMkColTest

- (void)testRequest {

    // delete the directory if it exists - we don't really care if this fails - it's just to attempt to clean up
    DAVMakeCollectionRequest *deleteRequest = [self requestOfClass:[DAVDeleteRequest class] withPath:@"davkittest"];
    [self queueAndWaitForRequest:deleteRequest];

    // try to make the directory
    DAVMakeCollectionRequest *createRequest = [self requestOfClass:[DAVMakeCollectionRequest class] withPath:@"davkittest"];
    [self queueAndWaitForRequest:createRequest];

    // did we get an error?
    STAssertNil(self.error, @"unexpected error for MKCOL %@", self.error);
    STAssertNil(self.result, @"unexpected result for MKCOL %@", self.result);

    // try to make the directory again - we should get back a 405, which we ignore
    DAVMakeCollectionRequest *createRequest2 = [self requestOfClass:[DAVMakeCollectionRequest class] withPath:@"davkittest"];
    [self queueAndWaitForRequest:createRequest2];

    STAssertTrue(self.error.code == 405, @"unexpected error for MKCOL %@", self.error);
    STAssertNil(self.result, @"unexpected result for MKCOL %@", self.result);
}

@end
