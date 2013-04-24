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
@synthesize host = _host;
@synthesize queue = _queue;
@synthesize error = _error;
@synthesize result = _result;

- (void)setUp {
	_done = NO;

    _queue = [[NSOperationQueue alloc] init];
    _queue.suspended = YES;
    _queue.name = @"DAVTest";
    _queue.maxConcurrentOperationCount = 1;

    // We read the server to use from a defaults setting.
    // If nothing is set, we assert with an error (so that people know they need to set something).
    // If the server is set to "Off" though, we suppress the tests. This lets you at least verify that the tests build.
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* setting = [defaults stringForKey:@"DAVTestURL"];
    if (![setting isEqualToString:@"Off"])
    {
        _url = [[NSURL URLWithString:setting] retain];
        STAssertNotNil(_url, @"You need to set a test server address. Use the defaults command on the command line: defaults write otest DAVTestURL \"server-url-here\". ");

        _host = [[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@", self.url.scheme, self.url.host, self.url.path]] retain];
        NSLog(@"Testing %@ as %@ %@", _host, self.url.user, self.url.password);

        _session = [[DAVSession alloc] initWithRootURL:_host delegate:self];
        STAssertNotNil(_session, @"Couldn't create DAV session");
    }
}

- (BOOL)isEnabled
{
    return self.session != nil;
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

#define USE_FULL_PATH 1

- (NSString*)fullPathForPath:(NSString*)path
{
#if USE_FULL_PATH
    NSString* result = [[self.host path] stringByAppendingPathComponent:path];
#else
    NSString* result = path;
#endif
    
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

    _done = NO;
    self.error = nil;
    self.result = nil;

    [self.queue addOperation:request];
    [self waitUntilWeAreDone];

    
}

- (void)request:(DAVRequest *)aRequest didSucceedWithResult:(id)result
{
    // store the result - the test case will check it
    _result = [result retain];
    [self notifyDone];
}

- (void)request:(DAVRequest *)aRequest didFailWithError:(NSError *)error {
    // store the error - the test case will check it
    _error = [error retain];
	[self notifyDone];
}

- (void)webDAVSession:(DAVSession *)session appendStringToTranscript:(NSString *)string sent:(BOOL)sent
{
    NSLog(@"%@ %@", sent ? @"-->" : @"<--", string);
}

- (void)tearDown {
    [_queue waitUntilAllOperationsAreFinished];
    [_queue release]; _queue = nil;
	[_session release]; _session = nil;
    self.result = nil;
    self.error = nil;
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
