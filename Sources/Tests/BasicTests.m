//
//  BasicTests.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "BasicTests.h"

@implementation BasicTests

#pragma mark - Support

- (void)makeTestDirectory
{
    DAVMakeCollectionRequest *createRequest = [self requestOfClass:[DAVMakeCollectionRequest class] withPath:@"davkittest"];
    [self queueAndWaitForRequest:createRequest];
}

- (void)removeTestDirectory
{
    DAVMakeCollectionRequest *deleteRequest = [self requestOfClass:[DAVDeleteRequest class] withPath:@"davkittest"];
    [self queueAndWaitForRequest:deleteRequest];
}

- (void)makeTestFile
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url];
    request.HTTPBody = [@"blah" dataUsingEncoding:NSUTF8StringEncoding];
    NSString* fullPath = [self fullPathForPath:@"davkittest/filetest22.txt"];
	DAVPutRequest *req = [[DAVPutRequest alloc] initWithPath:fullPath originalRequest:request session:self.session delegate:self];
    [self queueAndWaitForRequest:req];
	[req release];
}

#pragma mark - Tests

- (void)testKMCOL {

    // delete the directory if it exists - we don't really care if this fails - it's just to attempt to clean up
    [self removeTestDirectory];

    // try to make the directory
    [self makeTestDirectory];

    // did we get an error?
    STAssertNil(self.error, @"unexpected error for MKCOL %@", self.error);
    STAssertNil(self.result, @"unexpected result for MKCOL %@", self.result);

    // try to make the directory again - we should get back a 405, which we ignore
    [self makeTestDirectory];

    STAssertTrue(self.error.code == 405, @"unexpected error for MKCOL %@", self.error);
    STAssertNil(self.result, @"unexpected result for MKCOL %@", self.result);

    [self removeTestDirectory];
}

- (void)testPUT {
    // make test dir - ignore errors, as they aren't part of this test
    [self makeTestDirectory];

    [self makeTestFile];

    STAssertNil(self.error, @"Unexpected error for PUT %@", self.error);
    STAssertNil(self.result, @"Unexpected result for PUT %@", self.result);

    [self removeTestDirectory];
}

- (void)testGET {
    [self makeTestDirectory];
    [self makeTestFile];

    DAVGetRequest *req = [self requestOfClass:[DAVGetRequest class] withPath:@"davkittest/filetest22.txt"];
    [self queueAndWaitForRequest:req];

    STAssertNil(self.error, @"Unexpected error for GET %@", self.error);
	STAssertTrue([self.result isKindOfClass:[NSData class]], @"Expecting a NSData object for GET requests");
	STAssertTrue([self.result length] == 4, @"Invalid length (string should be blah)");

    [self removeTestDirectory];
}

- (void)testCOPY {
    [self makeTestDirectory];
    [self makeTestFile];
    
    DAVCopyRequest *req = [self requestOfClass:[DAVCopyRequest class] withPath:@"davkittest/filetest22.txt"];
	req.destinationPath = @"davkittest/filetest23.txt";
	req.overwrite = YES;
    [self queueAndWaitForRequest:req];

    STAssertNil(self.error, @"Unexpected error for COPY %@", self.error);
    STAssertNil(self.result, @"Unexpected result for COPY %@", self.result);

    [self removeTestDirectory];
}

- (void)testMOVE {
    [self makeTestDirectory];
    [self makeTestFile];

    DAVMoveRequest *req = [self requestOfClass:[DAVMoveRequest class] withPath:@"davkittest/filetest22.txt"];
	req.destinationPath = [self fullPathForPath:@"davkittest/filetest24.txt"];
    [self queueAndWaitForRequest:req];

    STAssertNil(self.error, @"Unexpected error for MOVE %@", self.error);
    STAssertNil(self.result, @"Unexpected result for MOVE %@", self.result);

    [self removeTestDirectory];
}

- (void)testPROPFIND {
    [self makeTestDirectory];
    [self makeTestFile];

    DAVListingRequest *req = [self requestOfClass:[DAVListingRequest class] withPath:@"davkittest"];
    [self queueAndWaitForRequest:req];

    STAssertNil(self.error, @"Unexpected error for PROPFIND %@", self.error);
	STAssertTrue([self.result isKindOfClass:[NSArray class]], @"Expecting a NSArray object for PROPFIND requests");
	STAssertEquals([self.result count], 1UL, @"Unexpected result count %lu %@", [self.result count], self.result);

    [self removeTestDirectory];
}

- (void)testDELETE {
    [self makeTestDirectory];

    [self removeTestDirectory];
    STAssertNil(self.error, @"Unexpected error for DELETE %@", self.error);
    STAssertNil(self.result, @"Unexpected result for DELETE %@", self.result);
}

@end
