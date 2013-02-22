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
    NSMutableArray *promises;
    DeferredState state;
}


- (id)init {
    self = [super init];
    if (self) {
        self->promises = [NSMutableArray array];
        self->state = kPending;
    }
    return self;
}

-(Promise *)promise{
    Promise *promise = [[Promise alloc] initWithDeferred: self];
    [promises addObject:promise];
    return promise;
}

-(DeferredState)state{
    return self->state;
}

-(BOOL)isResolved{
    return self->state == kResolved;
}

-(BOOL)isRejected{
    return self->state == kRejected;
}

-(void)resolve{
    if ([self isResolved]) {
        return;
    }
    self->state = kResolved;
    for (Promise *promise in promises) {
        [promise execDoneBlocks:nil];
        [promise execAlwaysBlocks];
    }
}

-(void)resolveWith:(id)data{
    if ([self isResolved]) {
        return;
    }
    self->state = kResolved;
    for (Promise *promise in promises) {
        [promise execDoneBlocks:data];
        [promise execAlwaysBlocks];
    }
}

-(void)reject{
    if ([self isRejected]) {
        return;
    }
    self->state = kRejected;
    for (Promise *promise in promises) {
        [promise execFailBlocks:nil];
        [promise execAlwaysBlocks];
    }
}

-(void)rejectWith:(id)data{
    if ([self isRejected]) {
        return;
    }
    self->state = kRejected;
    for (Promise *promise in promises) {
        [promise execFailBlocks:data];
        [promise execAlwaysBlocks];
    }
}

-(void)detachPromise:(Promise *)promise{
    [promises removeObject:promise];
}

-(void)detach{
    [promises removeAllObjects];
}


@end
