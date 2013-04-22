//
//  DAVTest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "DAVTest.h"

@interface DAVTest()

@end

@implementation DAVTest

@synthesize session = _session;
@synthesize url = _url;
@synthesize queue = _queue;

- (void)setUp {
	_done = NO;

    _queue = [[NSOperationQueue alloc] init];
    _queue.suspended = YES;
    _queue.name = @"DAVTest";
    _queue.maxConcurrentOperationCount = 1;

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    _url = [[NSURL URLWithString:[defaults stringForKey:@"DAVTestURL"]] retain];
    STAssertNotNil(_url, @"You need to set a test server address. Use the defaults command on the command line: defaults write otest DAVTestURL \"server-url-here\". ");

	_session = [[DAVSession alloc] initWithRootURL:self.url delegate:self];
	STAssertNotNil(_session, @"Couldn't create DAV session");
}

- (void)notifyDone {
	_done = YES;
}

- (void)waitUntilWeAreDone {
	while (!_done) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result
{

}

- (void)request:(DAVRequest *)aRequest didFailWithError:(NSError *)error {
	STFail(@"We have an error: %@", error);
	
	[self notifyDone];
}

- (void)tearDown {
	[_session release];
	_session = nil;
}

- (void)webDAVSession:(DAVSession *)session didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	NSURLCredential *credentials = [NSURLCredential credentialWithUser:self.url.user
                                                              password:self.url.password
                                                           persistence:NSURLCredentialPersistenceNone];
    STAssertNotNil(credentials, @"Couldn't create credentials");
	STAssertTrue([self.url.user isEqualToString:credentials.user], @"Couldn't set username");
	STAssertTrue([self.url.password isEqualToString:credentials.password], @"Couldn't set password");


    [[challenge sender] useCredential:credentials forAuthenticationChallenge:challenge];
}

@end
