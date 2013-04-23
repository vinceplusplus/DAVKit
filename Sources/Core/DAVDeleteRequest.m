//
//  DAVRequests.m
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "DAVDeleteRequest.h"

#import "DAVRequest+Private.h"

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
