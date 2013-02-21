//
//  AssetLoader.h
//  Testing
//
//  Created by Daniel Johnston on 2/19/13.
//

#import <Foundation/Foundation.h>
#import <DeferredAPI/Promise.h>

@interface AssetLoader : NSObject{
    __block int currentConnections;
    NSMutableArray *assetLoadingQueue;
    dispatch_queue_t lockQueue;
}

@property __block int maxConcurrentConnections;

+(id)assetLoaderWithMaxConcurrentConnections:(int)maxConnections;
+(id)assetLoader;
-(Promise *)loadWebAsset:(NSURL *)url;

@end
