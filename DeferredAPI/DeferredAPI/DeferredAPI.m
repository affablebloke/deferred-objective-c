//
//  DeferredAPI.m
//  DeferredAPI
//
//  Created by Daniel Johnston on 2/13/13.
//

#import "DeferredAPI.h"
#import "Deferred.h"
#import "Promise.h"

//@interface DeferredAPI (Private)
//    +(DeferredAPI *)sharedInstance;
//@end
@interface DeferredAPI(Private)
+(void)breakCallbackChain:(NSArray*)promises;
+(void)checkCallbackStatus:(Deferred *)dfd withPromises:(NSArray *)promises;
@end

@implementation DeferredAPI

+(Deferred *)deferred{
    return [[Deferred alloc] init];
}


+(Promise *)when:(Promise *)firstPromise, ... NS_REQUIRES_NIL_TERMINATION{
    
    __block NSMutableArray *promises = [NSMutableArray array];
    if (firstPromise)
    {
        if (![firstPromise isMemberOfClass:[Promise class]]){
            [NSException raise:@"Invalid parameter value" format:@"param of %@ is not a Promise Object", firstPromise];
        }
        va_list argumentList;
        // do something with firstObject. Remember, it is not part of the variable argument list
        [promises addObject: firstPromise];
        id obj;
        va_start(argumentList, firstPromise);          // scan for arguments after firstObject.
        while ((obj = va_arg(argumentList, id))) // get rest of the objects until nil is found
        {
            if (![obj isMemberOfClass:[Promise class]]){
                [NSException raise:@"Invalid parameter value" format:@"param of %@ is not a Promise Object", obj];
            }
            [promises addObject:obj];
        }
        va_end(argumentList);
    }
    
    Deferred *dfd = [DeferredAPI deferred];
    
    FailWithDataBlock_t failBlock = ^(id data){
        [DeferredAPI checkCallbackStatus:dfd withPromises:promises];
    };
    
    ResolveWithDataBlock_t resolveBlock = ^(id data){
        [DeferredAPI checkCallbackStatus:dfd withPromises:promises];
    };
    
    for (Promise *promise in promises) {
        [promise doneWithData:resolveBlock];
        [promise failWithData:failBlock];
    }
    
    [DeferredAPI checkCallbackStatus:dfd withPromises:promises];
    
    
    return [dfd promise];
}


+(Promise *)whenArray:(NSArray *)promises{
    for (id promise in promises) {
        if (![promise isMemberOfClass:[Promise class]]){
            [NSException raise:@"Invalid parameter value" format:@"param of %@ is not a Promise Object", promise];
        }
    }
    
    __block NSMutableArray *promisesCopy = [promises mutableCopy];
    
    Deferred *dfd = [DeferredAPI deferred];
    
    FailWithDataBlock_t failBlock = ^(id data){
        [DeferredAPI checkCallbackStatus:dfd withPromises:promisesCopy];
    };
    
    ResolveWithDataBlock_t resolveBlock = ^(id data){
        [DeferredAPI checkCallbackStatus:dfd withPromises:promisesCopy];
    };
    
    for (Promise *promise in promisesCopy) {
        [promise doneWithData:resolveBlock];
        [promise failWithData:failBlock];
    }
    
    [DeferredAPI checkCallbackStatus:dfd withPromises:promisesCopy];
    
    return [dfd promise];
}

+(void)checkCallbackStatus:(Deferred *)dfd withPromises:(NSArray *)promises{
    BOOL resolved = YES;
    for (Promise *promise in promises) {
        if([promise state] == kRejected){
            [DeferredAPI breakCallbackChain:promises];
            [dfd reject];
            resolved = NO;
            break;
        }
        
        if([promise state] == kPending){
            resolved = NO;
            break;
        }
    }
    
    if(resolved){
        [dfd resolve];
    }
}


+(void)breakCallbackChain:(NSArray*)promises{
    for (Promise *promise in promises) {
        [promise detach];
    }
    promises = nil;
}

@end
