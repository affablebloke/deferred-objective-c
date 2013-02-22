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
#import "AssetLoader.h"

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


- (void)testDeferredAPIDoneCallback{
    __block BOOL hasCalledBack = NO;
    
    Promise *promise = [DeferredAPI when:[[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone],
                        [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], nil];
    [promise doneWithData:^(id data) {

    }];
    
    [promise failWithData:^(id data) {
        STFail(@"Failed to load!");

    }];
    
    
    Promise *promise2 = [DeferredAPI whenArray:[NSArray arrayWithObjects:[[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], nil]];
    
    [promise2 doneWithData:^(id data) {
        hasCalledBack = YES;
    }];
    
    [promise2 failWithData:^(id data) {
        hasCalledBack = YES;
        STFail(@"Failed to load!");
    }];
    
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    if (!hasCalledBack)
    {
        STFail(@"Timeout Occurred!!");
    }
    
}


- (void)testDeferredAPIFailCallback{
    __block BOOL hasCalledBack = NO;
    
    Promise *promise = [DeferredAPI when:[[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone],
                        [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithFail], nil];
    [promise doneWithData:^(id data) {
        STFail(@"Done was triggered!!");
        hasCalledBack = YES;

    }];
    
    [promise failWithData:^(id data) {
        hasCalledBack = YES;
    }];
    
    
    Promise *promise2 = [DeferredAPI whenArray:[NSArray arrayWithObjects:[[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithDone], [[DummyDeferred dummy] loadWithFail], nil]];
    
    [promise2 doneWithData:^(id data) {
        STFail(@"Test was supposed to fail!");
        hasCalledBack = YES;
    }];
    
    [promise2 failWithData:^(id data) {
        hasCalledBack = YES;
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    if (!hasCalledBack)
    {
        STFail(@"Timeout Occurred!!");
    }
    
}


-(void)testSomeComplicatedStuff{
   __block BOOL hasCalledBack = NO;
    
    NSMutableArray *promises = [NSMutableArray array];
    for (int i = 0; i < 25; i++) {
        Promise *promise = [[DummyDeferred dummy] loadImage];
        [promise doneWithData:^(id data) {
            
            
        }];
        
        [promises addObject:promise];
    }
    
    Promise *mega = [DeferredAPI whenArray:promises];
    
    [mega doneWithData:^(id data) {
        hasCalledBack = YES;
    }];
    
    [mega failWithData:^(id data) {
        STFail(@"All images did not load!");
    }];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    if (!hasCalledBack)
    {
        STFail(@"Timeout Occurred!!");
    }

}


-(void)testEvenMoreComplicatedStuff{
    
    __block BOOL hasCalledBack = NO;
    
    AssetLoader *assetLoader = [AssetLoader assetLoader];
    NSMutableArray *promises = [NSMutableArray array];
    __block int numLoadedImages = 0;
    for (int i = 0; i < 250; i++) {
        Promise *promise = [assetLoader loadWebAsset:[NSURL URLWithString:@"http://www.digg.com"]];
        [promise doneWithData:^(id data) {
            numLoadedImages = numLoadedImages + 1;
            NSLog(@"Loaded Digg.com!!");
        }];
        
        [promises addObject:promise];
    }
    
    Promise *mega = [DeferredAPI whenArray:promises];
    
    [mega doneWithData:^(id data) {
        hasCalledBack = YES;
    }];
    
    [mega failWithData:^(id data) {
        STFail(@"Test failed or was rejected by Digg.com!");
        hasCalledBack = YES;
    }];
    
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while (hasCalledBack == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    if (!hasCalledBack)
    {
        STFail(@"Timeout Occurred!!");
    }
}




@end
