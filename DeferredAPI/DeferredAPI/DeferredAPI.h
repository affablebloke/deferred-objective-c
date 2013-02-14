//
//  DeferredAPI.h
//  DeferredAPI
//
//  Created by Daniel Johnston on 2/13/13.
//

#import <Foundation/Foundation.h>

@class Deferred;

typedef void (^FailWithDataBlock_t)(id);
typedef void (^AlwaysBlock_t)(void);
typedef void (^ResolveWithDataBlock_t)(id);

@interface DeferredAPI : NSObject
+(Deferred *)deferred;
@end
