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

    NSURL* host = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@", self.url.scheme, self.url.host, self.url.path]];
    NSLog(@"Testing %@ as %@ %@", host, self.url.user, self.url.password);

	_session = [[DAVSession alloc] initWithRootURL:host delegate:self];
	STAssertNotNil(_session, @"Couldn't create DAV session");
}

- (void)notifyDone {
	_done = YES;
}

- (void)waitUntilWeAreDone {
    self.queue.suspended = NO;
	while (!_done) {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	}
}

- (NSString*)fullPathForPath:(NSString*)path
{
    NSString* result = [self.url.path stringByAppendingPathComponent:path];

    return result;
}

- (id)requestOfClass:(Class)class withPath:(NSString *)path
{
    NSString* fullPath = [self fullPathForPath:path];
    id request = [[class alloc] initWithPath:fullPath session:self.session delegate:self];

    return [request autorelease];
}

- (void)queueAndWaitForRequest:(DAVRequest*)request
{
	STAssertNotNil(request, @"Couldn't create the request");

    [self.queue addOperation:request];
    [self waitUntilWeAreDone];

    
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result
{
    [self notifyDone]; // test class should override this, but just in case...
}

- (void)request:(DAVRequest *)aRequest didFailWithError:(NSError *)error {
	STFail(@"We have an error: %@", error);
	
	[self notifyDone];
}

- (void)tearDown {
    [_queue waitUntilAllOperationsAreFinished];
    [_queue release];
	[_session release];
	_session = nil;
}

- (void)webDAVSession:(DAVSession *)session didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] > 0)
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
    else
    {
        NSURLCredential *credentials = [NSURLCredential credentialWithUser:self.url.user
                                                                  password:self.url.password
                                                               persistence:NSURLCredentialPersistenceNone];
        STAssertNotNil(credentials, @"Couldn't create credentials");
        STAssertTrue([self.url.user isEqualToString:credentials.user], @"Couldn't set username");
        STAssertTrue([self.url.password isEqualToString:credentials.password], @"Couldn't set password");
        
        [[challenge sender] useCredential:credentials forAuthenticationChallenge:challenge];
    }
}

@end
