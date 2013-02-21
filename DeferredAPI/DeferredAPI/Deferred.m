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
    dispatch_queue_t lockqueue;
    DeferredState state;
}


- (id)init {
    self = [super init];
    if (self) {
        self->resolveTaskQueue = [NSMutableArray array];
        self->rejectTaskQueue = [NSMutableArray array];
        self->alwaysTaskQueue = [NSMutableArray array];
        self->queue = dispatch_queue_create("com.zombocom.deferred", NULL);
        self->lockqueue = dispatch_queue_create("com.zombocom.deferredlock", NULL);
        self->state = kPending;
    }
    return self;
}

-(Promise *)promise{
    return [[Promise alloc] initWithDeferred: self];
}

-(DeferredState)state{
    __block DeferredState result;
    dispatch_sync(lockqueue, ^{
        result = self->state;
    });
    return result;
}

-(BOOL)isResolved{
    __block BOOL result;
    dispatch_sync(self->lockqueue, ^{
        result = self->state == kResolved;
    });
    return result;
}

-(BOOL)isRejected{
    __block BOOL result;
    dispatch_sync(self->lockqueue, ^{
        result = self->state == kRejected;
    });
    return result;
}

-(void)resolve{
    if ([self isResolved]) {
        return;
    }
    self->state = kResolved;
    for (ResolveWithDataBlock_t func in self->resolveTaskQueue) {
        func(nil);
    }
    for (AlwaysBlock_t func in self->alwaysTaskQueue) {
        func();
    }
}

-(void)resolveWith:(id)data{
    if ([self isResolved]) {
        return;
    }
    self->state = kResolved;
    for (ResolveWithDataBlock_t func in self->resolveTaskQueue) {
        func(data);
    }
    for (AlwaysBlock_t func in self->alwaysTaskQueue) {
        func();
    }
}

-(void)reject{
    if ([self isRejected]) {
        return;
    }
    self->state = kRejected;
    for (FailWithDataBlock_t func in self->rejectTaskQueue) {
        func(nil);
    }
    for (AlwaysBlock_t func in self->alwaysTaskQueue) {
        func();
    }
}

-(void)rejectWith:(id)data{
    if ([self isRejected]) {
        return;
    }
    self->state = kRejected;
    for (FailWithDataBlock_t func in self->rejectTaskQueue) {
        func(data);
    }
    for (AlwaysBlock_t func in self->alwaysTaskQueue) {
        func();
    }
}

-(void)always:(AlwaysBlock_t)theBlock{
    [self->alwaysTaskQueue addObject:theBlock];
}

-(void)doneWithData:(ResolveWithDataBlock_t)theBlock{
    [self->resolveTaskQueue addObject:theBlock];
}

-(void)failWithData:(FailWithDataBlock_t)theBlock{
    [rejectTaskQueue addObject:theBlock];
}

-(void)detachPromise:(Promise *)promise{
    for (id callback in [promise callbacks]) {
        [self->resolveTaskQueue removeObject:callback];
        [self->rejectTaskQueue removeObject:callback];
        [self->alwaysTaskQueue removeObject:callback];
    }
}


@end
