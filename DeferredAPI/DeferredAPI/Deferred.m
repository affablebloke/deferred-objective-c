//
//  Deferred.m
//  DeferredAPI
//
//  Created by Daniel Johnston on 2/12/13.
//

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "Deferred.h"
#import "Promise.h"


@implementation Deferred{
    NSMutableArray *resolveTaskQueue;
    NSMutableArray *rejectTaskQueue;
    NSMutableArray *alwaysTaskQueue;
    dispatch_queue_t queue;
    DeferredState state;
}


- (id)init {
    self = [super init];
    if (self) {
        resolveTaskQueue = [NSMutableArray array];
        rejectTaskQueue = [NSMutableArray array];
        alwaysTaskQueue = [NSMutableArray array];
        queue = dispatch_queue_create("DeferredQueue", NULL);
        state = kPending;
    }
    return self;
}

-(Promise *)promise{
    return [[Promise alloc] initWithDeferred: self];
}

-(DeferredState)state{
    return state;
}

-(BOOL)isResolved{
    return state == kResolved;
}

-(BOOL)isRejected{
    return state == kRejected;
}

-(void)resolve{
    state = kResolved;
    dispatch_async(queue, ^{
        for (ResolveWithDataBlock_t func in resolveTaskQueue) {
            func(nil);
        }
        for (AlwaysBlock_t func in alwaysTaskQueue) {
            func();
        }
    });
}

-(void)resolveWith:(id)data{
    state = kResolved;
    dispatch_async(queue, ^{
        for (ResolveWithDataBlock_t func in resolveTaskQueue) {
            func(data);
        }
        for (AlwaysBlock_t func in alwaysTaskQueue) {
            func();
        }
    });
}

-(void)reject{
    state = kRejected;
    dispatch_async(queue, ^{
        for (FailWithDataBlock_t func in rejectTaskQueue) {
            func(nil);
        }
        for (AlwaysBlock_t func in alwaysTaskQueue) {
            func();
        }
    });
}

-(void)rejectWith:(id)data{
    state = kRejected;
    dispatch_async(queue, ^{
        for (FailWithDataBlock_t func in rejectTaskQueue) {
            func(data);
        }
        for (AlwaysBlock_t func in alwaysTaskQueue) {
            func();
        }
    });
}

-(void)always:(AlwaysBlock_t)theBlock{
    [alwaysTaskQueue addObject:theBlock];
}

-(void)doneWithData:(ResolveWithDataBlock_t)theBlock{
    [resolveTaskQueue addObject:theBlock];
}

-(void)failWithData:(FailWithDataBlock_t)theBlock{
    [rejectTaskQueue addObject:theBlock];
}

-(void)detachPromise:(Promise *)promise{
    for (id callback in [promise callbacks]) {
        [resolveTaskQueue removeObject:callback];
        [rejectTaskQueue removeObject:callback];
        [alwaysTaskQueue removeObject:callback];
    }
}


@end
