//
//  Promise.m
//  DeferredAPI
//
//  Created by Daniel Johnston on 2/13/13.
//

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "Promise.h"
#import "Deferred.h"

@implementation Promise{
    Deferred *deferred;
}


- (id)init {
    self = [super init];
    if (self) {
        self->alwaysBlocks = [NSMutableArray array];
        self->doneBlocks = [NSMutableArray array];
        self->failBlocks = [NSMutableArray array];
    }
    return self;
}


-(id)initWithDeferred:(Deferred *)theDeferred{
    self = [self init];
    deferred = theDeferred;
    return self;
}

-(void)always:(AlwaysBlock_t)theBlock{
    [self->alwaysBlocks addObject:[theBlock copy]];
}

-(void)doneWithData:(ResolveWithDataBlock_t)theBlock{
    [self->doneBlocks addObject:[theBlock copy]];
}

-(void)failWithData:(RejectWithDataBlock_t)theBlock{
    [self->failBlocks addObject:[theBlock copy]];
}

-(DeferredState)state{
    return [deferred state];
}

-(void)detach{
    [deferred detachPromise:self];
}

-(void)execDoneBlocks:(id)data{
    for (ResolveWithDataBlock_t block in doneBlocks) {
        block(data);
    }
}

-(void)execFailBlocks:(id)data{
    for (RejectWithDataBlock_t block in failBlocks) {
        block(data);
    }
}

-(void)execAlwaysBlocks{
    for (AlwaysBlock_t block in alwaysBlocks) {
        block();
    }
}



@end
