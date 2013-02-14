//
//  DeferredAPITests.m
//  DeferredAPITests
//
//  Created by Daniel Johnston on 2/12/13.
//

#import "DeferredAPITests.h"
#import "DeferredAPI.h"
#import "Deferred.h"

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





@end
