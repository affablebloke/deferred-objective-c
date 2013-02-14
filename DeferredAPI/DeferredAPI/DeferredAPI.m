//
//  DeferredAPI.m
//  DeferredAPI
//
//  Created by Daniel Johnston on 2/13/13.
//

#import "DeferredAPI.h"
#import "Deferred.h"

@implementation DeferredAPI
+(Deferred *)deferred{
    return [[Deferred alloc] init];
}
@end
