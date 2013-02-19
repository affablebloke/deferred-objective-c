//
//  DummyDeferred.h
//  DeferredAPI
//
//  Created by Daniel Johnston on 2/18/13.
//
//

#import <Foundation/Foundation.h>
#import "Promise.h"

@interface DummyDeferred : NSObject

+(id)dummy;
-(Promise *)loadWithDone;
-(Promise *)loadWithFail;

@end
