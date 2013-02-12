//
//  DAVRequests.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "DAVRequests.h"

#import "DAVListingParser.h"
#import "DAVRequest+Private.h"

@implementation DAVCopyRequest

@synthesize destinationPath = _destinationPath;
@synthesize overwrite = _overwrite;

- (NSString *)method {
	return @"COPY";
}

- (NSURLRequest *)request {
	NSParameterAssert(_destinationPath != nil);
	
	NSURL *dp = [self concatenatedURLWithPath:_destinationPath];
	
	NSMutableURLRequest *req = [self newRequestWithPath:self.path
												 method:[self method]];
	
	[req setValue:[dp absoluteString] forHTTPHeaderField:@"Destination"];
	
	if (_overwrite)
		[req setValue:@"T" forHTTPHeaderField:@"Overwrite"];
	else
		[req setValue:@"F" forHTTPHeaderField:@"Overwrite"];
	
	return [req autorelease];
}

- (void)dealloc {
	[_destinationPath release];
	[super dealloc];
}

@end


@implementation DAVDeleteRequest

- (id)initWithPath:(NSString *)aPath session:(DAVSession *)session delegate:(id<DAVRequestDelegate>)delegate
{
    if ((self = [super initWithPath:aPath session:session delegate:delegate]) != nil)
    {
        self.expectedStatuses = [NSIndexSet indexSetWithIndex:204];
    }

    return self;
}

- (NSURLRequest *)request {
	return [[self newRequestWithPath:self.path method:@"DELETE"] autorelease];
}

@end


@implementation DAVGetRequest

- (NSURLRequest *)request {
	return [[self newRequestWithPath:self.path method:@"GET"] autorelease];
}

- (id)resultForData:(NSData *)data {
	return data;
}

@end


@implementation DAVListingRequest

@synthesize depth = _depth;

- (id)initWithPath:(NSString *)aPath session:(DAVSession *)session delegate:(id <DAVRequestDelegate>)delegate;
{
	self = [super initWithPath:aPath session:session delegate:delegate];
	if (self) {
		_depth = 1;
	}
	return self;
}

- (NSURLRequest *)request {
	NSMutableURLRequest *req = [self newRequestWithPath:self.path method:@"PROPFIND"];
	
	if (_depth > 1) {
		[req setValue:@"infinity" forHTTPHeaderField:@"Depth"];
	}
	else {
		[req setValue:[NSString stringWithFormat:@"%ld", (unsigned long) _depth] forHTTPHeaderField:@"Depth"];
	}
	
	[req setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
	
	NSString *xml = @"<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n"
					@"<D:propfind xmlns:D=\"DAV:\"><D:allprop/></D:propfind>";
	
	[req setHTTPBody:[xml dataUsingEncoding:NSUTF8StringEncoding]];
	
	return [req autorelease];
}

- (id)resultForData:(NSData *)data {
	DAVListingParser *p = [[DAVListingParser alloc] initWithData:data];
	
	NSError *error = nil;
	NSArray *items = [p parse:&error];
	
	if (error) {
		#ifdef DEBUG
			NSLog(@"XML Parse error: %@", error);
		#endif
	}
	
	[p release];
	
	return items;
}

@end


@implementation DAVMakeCollectionRequest

- (id)initWithPath:(NSString *)aPath session:(DAVSession *)session delegate:(id<DAVRequestDelegate>)delegate
{
    if ((self = [super initWithPath:aPath session:session delegate:delegate]) != nil)
    {
        self.expectedStatuses = [NSIndexSet indexSetWithIndex:204];
    }

    return self;
}

- (NSURLRequest *)request {
	return [[self newRequestWithPath:self.path method:@"MKCOL"] autorelease];
}

@end


@implementation DAVMoveRequest

- (NSString *)method {
	return @"MOVE";
}

@end


@implementation DAVPutRequest

- (id)initWithSession:(DAVSession *)session;
{
    if (self = [super initWithSession:session])
    {
        _MIMEType = @"application/octet-stream";
        NSMutableIndexSet* indexes = [[NSMutableIndexSet alloc] init];
        [indexes addIndex:201]; // The resource was created successfully
        [indexes addIndex:202]; // The resource will be created or deleted, but this has not happened yet
        [indexes addIndex:204]; // The server has fulfilled the request but does not need to return an entity body, and might return updated metadata.
        self.expectedStatuses = indexes;
        [indexes release];
    }
    return self;
}

@dynamic delegate;

@synthesize data = _pdata;
@synthesize dataMIMEType = _MIMEType;
@synthesize stream = _pstream;

- (NSURLRequest *)request {
	NSParameterAssert((_pdata != nil) || (_pstream != nil));
	
	NSMutableURLRequest *req = [self newRequestWithPath:self.path method:@"PUT"];
	[req setValue:[self dataMIMEType] forHTTPHeaderField:@"Content-Type"];

    if (_pdata)
    {
        NSString *len = [NSString stringWithFormat:@"%ld", (unsigned long)[_pdata length]];
        [req setValue:len forHTTPHeaderField:@"Content-Length"];
        [req setHTTPBody:_pdata];
    }
    else if (_pstream)
    {
        [req setHTTPBodyStream:_pstream];
    }

	return [req autorelease];
}

- (void)dealloc
{
	[_pdata release];
    [_MIMEType release];
    [_pstream release];

	[super dealloc];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if ([[self delegate] respondsToSelector:@selector(webDAVRequest:didSendDataOfLength:totalBytesWritten:totalBytesExpectedToWrite:)])
    {
        [[self delegate] webDAVRequest:self didSendDataOfLength:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
{
    NSInputStream* result = nil;

    if ([[self delegate] respondsToSelector:@selector(webDAVRequest:needNewBodyStream:)])
    {
        result = [[self delegate] webDAVRequest:self needNewBodyStream:request];
    }

    return result;
}

@end
