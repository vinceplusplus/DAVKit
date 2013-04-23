//
//  BPutTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "BPutTest.h"

@implementation BPutTest

- (void)testRequest {
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

@end
