//
//  DAVRequests.h
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import "DAVRequest.h"

@interface DAVCopyRequest : DAVRequest {
  @private
	NSString *_destinationPath;
	BOOL _overwrite;
}

@property (copy) NSString *destinationPath;
@property (assign) BOOL overwrite;

@end

@interface DAVDeleteRequest : DAVRequest { }
@end

@interface DAVGetRequest : DAVRequest { }
@end

@interface DAVListingRequest : DAVRequest {
  @private
	NSUInteger _depth;
}

@property (assign) NSUInteger depth; /* default is 1 */

@end

@interface DAVMakeCollectionRequest : DAVRequest { }
@end

@interface DAVMoveRequest : DAVCopyRequest { }
@end


#pragma mark -


@protocol DAVPutRequestDelegate <DAVRequestDelegate>
@optional
- (void)webDAVRequest:(DAVRequest *)request didSendDataOfLength:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
- (NSInputStream *)webDAVRequest:(DAVRequest *)request needNewBodyStream:(NSURLRequest *)request;
@end

@interface DAVPutRequest : DAVRequest {
  @private
    NSMutableURLRequest* _request;
}

+ (NSString*)MIMETypeForExtension:(NSString*)extension;

- (id)initWithPath:(NSString*)path originalRequest:(NSURLRequest*)request session:(DAVSession *)session delegate:(id <DAVRequestDelegate>)delegate;

- (NSUInteger)expectedLength;

@property(nonatomic, assign, readonly) id <DAVPutRequestDelegate> delegate;

@end
