//
//  DAVTest.h
//  DAVKit
//
//  Copyright Matt Rajca 2010. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <DAVKit/DAVKit.h>

@interface DAVTest : SenTestCase < DAVRequestDelegate, DAVSessionDelegate > {
  @private
	DAVSession *_session;
    NSURL *_url;
    NSURL *_host;
    NSOperationQueue *_queue;
    NSError *_error;
	BOOL _done;
    id _result;
}

@property (readonly) DAVSession *session;
@property (readonly) NSURL *url;
@property (readonly) NSURL *host;
@property (readonly) NSOperationQueue *queue;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) id result;

- (void)notifyDone;
- (void)queueAndWaitForRequest:(DAVRequest*)request;
- (void)waitUntilWeAreDone;
- (id)requestOfClass:(Class)class withPath:(NSString *)path;
- (NSString*)fullPathForPath:(NSString*)path;
@end
