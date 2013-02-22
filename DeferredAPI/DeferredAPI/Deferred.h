//
//  Deferred.h
//  DeferredAPI
//
//  Created by Daniel Johnston on 2/12/13.
//

#import <Foundation/Foundation.h>
#import "DeferredAPI.h"

//@class Promise;

@interface Deferred : NSObject{

}


-(id)init;
-(BOOL)isResolved;
-(BOOL)isRejected;
-(void)resolve;
-(void)resolveWith:(id)data;
-(void)reject;
-(void)rejectWith:(id)data;
-(void)detach;
-(DeferredState)state;
-(Promise *)promise;
-(void)detachPromise:(Promise *)promise;

@end
