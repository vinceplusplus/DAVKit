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
    NSOperationQueue *_queue;
	BOOL _done;
}

@property (readonly) DAVSession *session;
@property (readonly) NSURL *url;
@property (readonly) NSOperationQueue* queue;

- (void)notifyDone;
- (void)queueAndWaitForRequest:(DAVRequest*)request;
- (void)waitUntilWeAreDone;

@end
