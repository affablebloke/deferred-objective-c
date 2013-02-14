//
//  Promise.h
//  DeferredAPI
//
//  Created by Daniel Johnston on 2/13/13.
//

#import <Foundation/Foundation.h>
#import "DeferredAPI.h"

@class Deferred;

@interface Promise : NSObject{
    
}

-(id)initWithDeferred:(Deferred *)theDeferred;
-(void)always:(AlwaysBlock_t)always;
-(void)doneWithData:(ResolveWithDataBlock_t)done;
-(void)failWithData:(FailWithDataBlock_t)done;
-(void)detach;

@end
