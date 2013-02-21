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
    NSURL *url = [NSURL URLWithString:@"http://cdn.uproxx.com/wp-content/uploads/2010/04/alf.jpg"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSOperationQueue *theQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:theQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [dfd resolve];
    }];
    return [dfd promise];
}

-(Promise *)loadWithFail{
    Deferred *dfd = [DeferredAPI deferred];
    NSURL *url = [NSURL URLWithString:@"http://cdn.uproxx.com/wp-content/uploads/2010/04/alf.jpg"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSOperationQueue *theQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:theQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        [dfd reject];
    }];
    return [dfd promise];
}

-(Promise *)loadImage{
    Deferred *dfd = [DeferredAPI deferred];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://cdn.uproxx.com/wp-content/uploads/2010/04/alf.jpg"]];
    NSOperationQueue *theQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:theQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([httpResponse statusCode] / 100 != 2 || error != nil){
            [dfd rejectWith:data];
        }else{
            [dfd resolveWith:data];
        }
    }];
    
    return [dfd promise];
}

@end
