//
//  AssetLoader.m
//  Testing
//
//  Created by Daniel Johnston on 2/19/13.
//

#import "AssetLoader.h"
#import <DeferredAPI/Deferred.h>
#import <DeferredAPI/Promise.h>


@interface AssetLoader(Private)
-(void)loadNextAssetWithDeferred:(Deferred *)dfd url:(NSURL *)url;
@end

@interface WebAssetPair : NSObject

@property Deferred  *dfd;
@property NSURL     *url;

+(id)webAssetPairWithDeferred:(Deferred *)dfd url:(NSURL *)url;

@end

@implementation WebAssetPair

+(id)webAssetPairWithDeferred:(Deferred *)dfd url:(NSURL *)url{
    WebAssetPair *pair = [[WebAssetPair alloc] init];
    pair.dfd = dfd;
    pair.url = url;
    return pair;
}

@end

@implementation AssetLoader


-(id)init{
    if (self = [super init])
    {
        self->lockQueue = dispatch_queue_create("com.zombo.assetloaderlock", NULL);
        self->assetLoadingQueue = [NSMutableArray array];
        self->currentConnections = 0;
        self.maxConcurrentConnections = 25;
    }
    return self;
}

-(id)initWithMaxConcurrentConnections:(int)maxConnections{
    if (self = [self init])
    {
        self.maxConcurrentConnections = maxConnections;
    }
    return self;
}

+(id)assetLoaderWithMaxConcurrentConnections:(int)maxConnections{
    AssetLoader *assetLoader = [[AssetLoader alloc] initWithMaxConcurrentConnections:maxConnections];
    return assetLoader;
}

+(id)assetLoader{
    AssetLoader *assetLoader = [[AssetLoader alloc] init];
    return assetLoader;
}

-(Promise *)loadWebAsset:(NSURL *)url{
    
    Deferred *dfd = [DeferredAPI deferred];
    Promise *promise = [dfd promise];
    
    __block AssetLoader *ref = self;
    [promise always:^{
        dispatch_sync(ref->lockQueue, ^{
            ref->currentConnections = ref->currentConnections - 1;
            if([ref->assetLoadingQueue count] > 0){
                WebAssetPair *pair = [ref->assetLoadingQueue lastObject];
                if(pair != nil)
                    [self loadNextAssetWithDeferred:pair.dfd url:pair.url];
                if([ref->assetLoadingQueue count] > 0){
                    [ref->assetLoadingQueue removeLastObject];
                }
            }
        });
    }];
    
    if(self->currentConnections >= self.maxConcurrentConnections){
        //add to queue
        [self->assetLoadingQueue addObject:[WebAssetPair webAssetPairWithDeferred:dfd url:url]];
        return promise;
    }
    
    [self loadNextAssetWithDeferred:dfd url:url];
    return promise;
}

-(void)loadNextAssetWithDeferred:(Deferred *)dfd url:(NSURL *)url{
    self->currentConnections = self->currentConnections + 1;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:5];
    NSOperationQueue *theQueue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:theQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if ([httpResponse statusCode] / 100 != 2 || error != nil){
            [dfd rejectWith:data];
        }else{
            [dfd resolveWith:data];
        }
    }];
}

@end
