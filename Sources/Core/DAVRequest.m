//
//  DAVRequest.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "DAVRequest.h"

#import "DAVSession.h"

@interface DAVRequest ()

- (void)_didFail:(NSError *)error;
- (void)_didFinish;

@end


@implementation DAVRequest


NSString *const DAVClientErrorDomain = @"com.MattRajca.DAVKit.error";

#define DEFAULT_TIMEOUT 60

- (id)initWithPath:(NSString *)aPath session:(DAVSession *)session delegate:(id <DAVRequestDelegate>)delegate;
{
	NSParameterAssert(aPath != nil);
	
	self = [self initWithSession:session];
	if (self) {
		_path = [aPath copy];
        _delegate = [delegate retain];  // retained till finish running/cancelled
	}
	return self;
}

@synthesize expectedStatuses = _expectedStatuses;
@synthesize path = _path;
@synthesize delegate = _delegate;

- (NSURL *)concatenatedURLWithPath:(NSString *)aPath {
	NSParameterAssert(aPath != nil);
	
    if ([aPath isAbsolutePath])
    {
        CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                      (CFStringRef)aPath,
                                                                      NULL,
                                                                      CFSTR(";?#"), // otherwise e.g. ? character would be misinterpreted as query
                                                                      kCFStringEncodingUTF8);
        
        NSURL *result = [NSURL URLWithString:(NSString *)escaped relativeToURL:self.session.rootURL];
        CFRelease(escaped);
        return result;
    }
    
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_6
	return [self.session.rootURL URLByAppendingPathComponent:aPath];
#else
    CFURLRef result = CFURLCreateCopyAppendingPathComponent(NULL,
                                                             (CFURLRef)[self.session.rootURL absoluteURL],
                                                             (CFStringRef)aPath,
                                                             NO);
    return [NSMakeCollectable(result) autorelease];
#endif
}

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return _executing;
}

- (BOOL)isFinished {
	return _done;
}

- (void)cancel;
{
    [super cancel];
    [_connection cancel];
    [_delegate release]; _delegate = nil;
}

- (void)start {
	if (![NSURLConnection instancesRespondToSelector:@selector(setDelegateQueue:)] &&
        ![NSThread isMainThread])
    {
		[self performSelectorOnMainThread:@selector(start) 
							   withObject:nil waitUntilDone:NO];
		
		return;
	}
	
	[self willChangeValueForKey:@"isExecuting"];
	
	_executing = YES;
	_connection = [[NSURLConnection alloc] initWithRequest:[self request]
                                                  delegate:self
                                          startImmediately:NO];
    
    if ([_connection respondsToSelector:@selector(setDelegateQueue:)])
    {
        static NSOperationQueue *delegateQueue;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            delegateQueue = [[NSOperationQueue alloc] init];
            delegateQueue.maxConcurrentOperationCount = 1;
        });
        
        [_connection setDelegateQueue:delegateQueue];
    }
    else
    {
        [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    [_connection start];
	
	if ([_delegate respondsToSelector:@selector(requestDidBegin:)])
		[_delegate requestDidBegin:self];
	
	[self didChangeValueForKey:@"isExecuting"];
}

- (NSURLRequest *)request {
	@throw [NSException exceptionWithName:NSInternalInconsistencyException
								   reason:@"Subclasses of DAVRequest must override 'request'"
								 userInfo:nil];
	
	return nil;
}

- (id)resultForData:(NSData *)data {
	return nil;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse;
{
    NSString* redirectString;
    if (redirectResponse)
    {
        // NSURLConnection has helpfully stripped out all the useful stuff from the request,
        // so we make a copy of the original one, and replace just the URL with the redirected one
        NSMutableURLRequest* newRequest = [connection.originalRequest mutableCopy];
        newRequest.URL = request.URL;
        redirectString = [NSString stringWithFormat:@" (redirected to %@)", [request URL]];
        request = [newRequest autorelease];
    }
    else
    {
        redirectString = @"";
    }

    [[self session] appendFormatToSentTranscript:@"%@ %@%@", [request HTTPMethod], [[request URL] path], redirectString];     // TODO: Include HTTP version

    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self _didFail:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	if (_data)
	{
		[_data setLength:0];
	}
	else
	{
		_data = [[NSMutableData alloc] init];
	}
	
	NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
	NSInteger code = [resp statusCode];
    NSString *description = [resp.class localizedStringForStatusCode:code];
    
    // Report to transcript
    [self.session appendFormatToReceivedTranscript:@"%i %@", code, description];
	
	if ((code >= 400) || (self.expectedStatuses && ![self.expectedStatuses containsIndex:code])) {
		[_connection cancel];
		
        // TODO: Formalize inclusion of response
		NSError *error = [NSError errorWithDomain:DAVClientErrorDomain
											 code:code
										 userInfo:@{ NSLocalizedFailureReasonErrorKey : description,
                                                     @"response" : response }];
		
		[self _didFail:error];
	}
}

#if defined MAC_OS_X_VERSION_MAX_ALLOWED && MAC_OS_X_VERSION_10_6 >= MAC_OS_X_VERSION_MAX_ALLOWED
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	BOOL result = [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodDefault] ||
	[protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] ||
	[protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest] ||
	[protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
	
	return result;
}
#endif

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // Log the challenge's response object
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)challenge.failureResponse;
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSInteger code = response.statusCode;
        [[self session] appendFormatToReceivedTranscript:@"%i %@", code, [[response class] localizedStringForStatusCode:code]];
    }
	
    
    id <DAVSessionDelegate> delegate = [self.session valueForKey:@"delegate"];
    if ([delegate respondsToSelector:@selector(webDAVSession:didReceiveAuthenticationChallenge:)])
    {
        [delegate webDAVSession:self.session didReceiveAuthenticationChallenge:challenge];
        return;
    }
    
#if defined MAC_OS_X_VERSION_MAX_ALLOWED && MAC_OS_X_VERSION_10_6 >= MAC_OS_X_VERSION_MAX_ALLOWED
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
		if (self.session.allowUntrustedCertificate)
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
				 forAuthenticationChallenge:challenge];
		
		[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
	}
    else
#endif
    {
		if ([challenge previousFailureCount] == 0) {
			[[challenge sender] useCredential:[challenge proposedCredential] forAuthenticationChallenge:challenge];
		} else {
			// Wrong login/password
			[[challenge sender] cancelAuthenticationChallenge:challenge];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    id <DAVSessionDelegate> delegate = [self.session valueForKey:@"delegate"];
    if ([delegate respondsToSelector:@selector(webDAVSession:didCancelAuthenticationChallenge:)])
    {
        [delegate webDAVSession:self.session didCancelAuthenticationChallenge:challenge];
    }
}

- (void)_didFail:(NSError *)error {
	if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[_delegate request:self didFailWithError:[[error retain] autorelease]];
	}
	
	[self _didFinish];
}

- (void)_didFinish {
	[self willChangeValueForKey:@"isExecuting"];
	[self willChangeValueForKey:@"isFinished"];
	
	_done = YES;
	_executing = NO;
	
	[self didChangeValueForKey:@"isExecuting"];
	[self didChangeValueForKey:@"isFinished"];
    
    [_delegate release]; _delegate = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([_delegate respondsToSelector:@selector(request:didSucceedWithResult:)]) {
        id result = [self resultForData:_data];

        [_delegate request:self didSucceedWithResult:[[result retain] autorelease]];
    }
    
    [self _didFinish];
}

- (void)dealloc {
	[_path release];
	[_connection release];
	[_data release];
    [_expectedStatuses release];
	
	[super dealloc];
}

@end


@implementation DAVRequest (Private)

- (NSMutableURLRequest *)newRequestWithPath:(NSString *)path method:(NSString *)method {
	NSURL *url = [self concatenatedURLWithPath:path];
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setHTTPMethod:method];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:DEFAULT_TIMEOUT];
	
	return request;
}

@end
