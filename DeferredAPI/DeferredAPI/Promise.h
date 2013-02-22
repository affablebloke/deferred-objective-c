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
    NSMutableArray *alwaysBlocks;
    NSMutableArray *doneBlocks;
    NSMutableArray *failBlocks;
}




-(id)initWithDeferred:(Deferred *)theDeferred;
-(void)always:(AlwaysBlock_t)always;
-(void)doneWithData:(ResolveWithDataBlock_t)done;
-(void)failWithData:(RejectWithDataBlock_t)done;
-(DeferredState)state;
-(void)detach;
-(void)execDoneBlocks:(id)data;
-(void)execFailBlocks:(id)data;
-(void)execAlwaysBlocks;

@end
