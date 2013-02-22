//
//  DeferredAPI.h
//  DeferredAPI
//
//  Created by Daniel Johnston on 2/13/13.
//

#import <Foundation/Foundation.h>

@class Deferred;
@class Promise;


typedef enum {
    kPending,
    kResolved,
    kRejected
} DeferredState;

typedef void (^RejectWithDataBlock_t)(id);
typedef void (^AlwaysBlock_t)(void);
typedef void (^ResolveWithDataBlock_t)(id);

@interface DeferredAPI : NSObject

+(Deferred *)deferred;
+(Promise *)when:(Promise *)firstPromise, ... NS_REQUIRES_NIL_TERMINATION;
+(Promise *)whenArray:(NSArray *)promises;


@end
