//
//  DeferredAPITests.m
//  DeferredAPITests
//
//  Created by Daniel Johnston on 2/12/13.
//

#import "DeferredAPITests.h"
#import "DeferredAPI.h"
#import "Deferred.h"
#import "DummyDeferred.h"

@implementation DeferredAPITests{
    NSConditionLock *asyncLock;
}

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testCreation
{
    Deferred *dfd = [DeferredAPI deferred];
    STAssertNotNil(dfd, @"Could not create an instance of Deferred!");
    STAssertNotNil([dfd promise], @"Could not create an instance of Promise!");
}

- (void)testReject
{
    Deferred *dfd = [DeferredAPI deferred];
    [dfd reject];
    STAssertTrue([dfd state] == kRejected, @"Deferred is not in kRejected state!");
    
    dfd = [DeferredAPI deferred];
    [dfd rejectWith:@"Just a dumb string"];
    STAssertTrue([dfd state] == kRejected, @"Deferred is not in kRejected state!");
}

- (void)testResolve
{
    Deferred *dfd = [DeferredAPI deferred];
    [dfd resolve];
    STAssertTrue([dfd state] == kResolved, @"Deferred is not in kRejected state!");
    
    dfd = [DeferredAPI deferred];
    [dfd resolveWith:@"Just a dumb string"];
    STAssertTrue([dfd state] == kResolved, @"Deferred is not in kRejected state!");
}


- (void)testResolveInOrder
{
    Deferred *dfd = [DeferredAPI deferred];
    
    // create the semaphore and lock it once before we start
    // the async operation
    NSConditionLock *tl = [NSConditionLock new];
    asyncLock = tl;
    
    __block int state = 0;
    // start the async operation
    [dfd doneWithData:^(id data) {
        state ++;
    }];
    
    [dfd doneWithData:^(id data) {
        state ++;
    }];
    
    [dfd doneWithData:^(id data) {
        STAssertTrue(state == 2, @"Callbacks were not executed in order!!");
        [asyncLock unlockWithCondition:1];
    }];
    
    [dfd resolve];
    [asyncLock lockWhenCondition:1];
}

- (void)testRejectInOrder
{
    Deferred *dfd = [DeferredAPI deferred];
    
    // create the semaphore and lock it once before we start
    // the async operation
    NSConditionLock *tl = [NSConditionLock new];
    asyncLock = tl;
    
    __block int state = 0;
    // start the async operation
    [dfd failWithData:^(id data) {
        state ++;
    }];
    
    [dfd failWithData:^(id data) {
        state ++;
    }];
    
    [dfd failWithData:^(id data) {
        STAssertTrue(state == 2, @"Callbacks were not executed in order!!");
        [asyncLock unlockWithCondition:1];
    }];
    
    [dfd reject];
    [asyncLock lockWhenCondition:1];
}


- (void)testDeferredAPIDoneCallback
{
    // create the semaphore and lock it once before we start
    // the async operation
    NSConditionLock *tl = [NSConditionLock new];
    asyncLock = tl;
    
    Promise *promise = [DeferredAPI when:[[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone],
                        [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], nil];
    [promise doneWithData:^(id data) {
        
        [asyncLock unlockWithCondition:1];
    }];
    
    [promise failWithData:^(id data) {
        STFail(@"Fail was triggered!!");
        [asyncLock unlockWithCondition:1];
    }];
    
    
    
    Promise *promise2 = [DeferredAPI whenArray:[NSArray arrayWithObjects:[[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], nil]];
    
    [promise2 doneWithData:^(id data) {
        
        [asyncLock unlockWithCondition:1];
    }];
    
    [promise2 failWithData:^(id data) {
        STFail(@"Fail was triggered!!");
        [asyncLock unlockWithCondition:1];
    }];
    
    
    [asyncLock lockWhenCondition:1];
    
}


- (void)testDeferredAPIFailCallback
{
    // create the semaphore and lock it once before we start
    // the async operation
    NSConditionLock *tl = [NSConditionLock new];
    asyncLock = tl;
    
    Promise *promise = [DeferredAPI when:[[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone],
                        [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithFail], nil];
    [promise doneWithData:^(id data) {
        STFail(@"Done was triggered!!");
        [asyncLock unlockWithCondition:1];
    }];
    
    [promise failWithData:^(id data) {
        [asyncLock unlockWithCondition:1];
    }];
    
    
    Promise *promise2 = [DeferredAPI whenArray:[NSArray arrayWithObjects:[[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithFail], nil]];
    
    [promise2 doneWithData:^(id data) {
        STFail(@"Done was triggered!!");
        [asyncLock unlockWithCondition:1];
    }];
    
    [promise2 failWithData:^(id data) {
        [asyncLock unlockWithCondition:1];
    }];
    
    
    [asyncLock lockWhenCondition:1];
    
}





@end
