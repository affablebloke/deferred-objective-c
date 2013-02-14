//
//  Deferred.h
//  DeferredAPI
//
//  Created by Daniel Johnston on 2/12/13.
//

#import <Foundation/Foundation.h>
#import "DeferredAPI.h"

@class Promise;

@interface Deferred : NSObject{

}

typedef enum {
    kPending,
    kResolved,
    kRejected
} DeferredState;


-(id)init;
-(BOOL)isResolved;
-(BOOL)isRejected;
-(void)resolve;
-(void)resolveWith:(id)data;
-(void)reject;
-(void)rejectWith:(id)data;
-(void)always:(AlwaysBlock_t)always;
-(void)doneWithData:(ResolveWithDataBlock_t)done;
-(void)failWithData:(FailWithDataBlock_t)done;
-(DeferredState)state;
-(Promise *)promise;

@end
