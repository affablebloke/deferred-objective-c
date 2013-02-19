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
        //TODO initialization
    }
    return self;
}


-(id)initWithDeferred:(Deferred *)theDeferred{
    self = [self init];
    deferred = theDeferred;
    return self;
}

-(void)always:(AlwaysBlock_t)theBlock{
    [deferred always:theBlock];
    [self.callbacks addObject:theBlock];
}

-(void)doneWithData:(ResolveWithDataBlock_t)theBlock{
    [deferred doneWithData:theBlock];
    [self.callbacks addObject:theBlock];
}

-(void)failWithData:(FailWithDataBlock_t)theBlock{
    [deferred failWithData:theBlock];
    [self.callbacks addObject:theBlock];
}

-(DeferredState)state{
    return [deferred state];
}

-(void)detach{
    [deferred detachPromise:self];
    [self.callbacks removeAllObjects];
}



@end
