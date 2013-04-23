//
//  BasicTests.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "BasicTests.h"

@implementation BasicTests

- (void)testKMCOL {

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

- (void)testPUT {
	const char *bytes = "blah\0";

    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url];
    request.HTTPBody = [NSData dataWithBytes:bytes length:strlen(bytes)];
    NSString* fullPath = [self fullPathForPath:@"davkittest/filetest22.txt"];
	DAVPutRequest *req = [[DAVPutRequest alloc] initWithPath:fullPath originalRequest:request session:self.session delegate:self];
    [self queueAndWaitForRequest:req];
	[req release];

    STAssertNil(self.error, @"Unexpected error for PUT %@", self.error);
    STAssertNil(self.result, @"Unexpected result for PUT %@", self.result);
}

- (void)testGET {
    DAVGetRequest *req = [self requestOfClass:[DAVGetRequest class] withPath:@"davkittest/filetest22.txt"];
    [self queueAndWaitForRequest:req];

    STAssertNil(self.error, @"Unexpected error for PUT %@", self.error);
	STAssertTrue([self.result isKindOfClass:[NSData class]], @"Expecting a NSData object for GET requests");
	STAssertTrue([self.result length] == 4, @"Invalid length (string should be blah)");
}

- (void)testCOPY {
    DAVCopyRequest *req = [self requestOfClass:[DAVCopyRequest class] withPath:@"davkittest/filetest22.txt"];
	req.destinationPath = @"davkittest/filetest23.txt";
	req.overwrite = YES;
    [self queueAndWaitForRequest:req];

    STAssertNil(self.error, @"Unexpected error for COPY %@", self.error);
    STAssertNil(self.result, @"Unexpected result for COPY %@", self.result);
}

- (void)testMOVE {
    DAVMoveRequest *req = [self requestOfClass:[DAVMoveRequest class] withPath:@"davkittest/filetest23.txt"];
	req.destinationPath = [self fullPathForPath:@"davkittest/filetest24.txt"];
    [self queueAndWaitForRequest:req];

    STAssertNil(self.error, @"Unexpected error for MOVE %@", self.error);
    STAssertNil(self.result, @"Unexpected result for MOVE %@", self.result);
}

- (void)testPROPFIND {
    DAVListingRequest *req = [self requestOfClass:[DAVListingRequest class] withPath:@"davkittest"];
    [self queueAndWaitForRequest:req];

    STAssertNil(self.error, @"Unexpected error for PROPFIND %@", self.error);
	STAssertTrue([self.result isKindOfClass:[NSArray class]], @"Expecting a NSArray object for PROPFIND requests");
	STAssertTrue([self.result count] == 3, @"Array should contain 3 objects");
}

- (void)testDELETE {
    DAVDeleteRequest *req = [self requestOfClass:[DAVDeleteRequest class] withPath:@"davkittest"];
    [self queueAndWaitForRequest:req];
    STAssertNil(self.error, @"Unexpected error for DELETE %@", self.error);
    STAssertNil(self.result, @"Unexpected result for DELETE %@", self.result);
}

@end
