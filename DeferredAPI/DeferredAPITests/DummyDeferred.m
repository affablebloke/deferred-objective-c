//
//  DummyDeferred.m
//  DeferredAPI
//
//  Created by Daniel Johnston on 2/18/13.
//
//

#import "DummyDeferred.h"
#import "Promise.h"
#import "Deferred.h"

@implementation DummyDeferred

+(id)dummy{
    return [[DummyDeferred alloc] init];
}

-(Promise *)loadWithDone{
    Deferred *dfd = [DeferredAPI deferred];
    NSURL *url = [NSURL URLWithString:@"https://www.google.com/search?q=clang"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSOperationQueue *theQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:theQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [dfd resolve];
    }];
    return [dfd promise];
}

-(Promise *)loadWithFail{
    Deferred *dfd = [DeferredAPI deferred];
    NSURL *url = [NSURL URLWithString:@"https://www.google.com/search?q=clang"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSOperationQueue *theQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:theQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [dfd reject];
    }];
    return [dfd promise];
}

@end
