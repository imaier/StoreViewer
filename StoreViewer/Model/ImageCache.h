//
//  ImageCache.h
//  StoreViewer
//
//  Created by Ilya Maier on 29.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ICCompletionBlock)(UIImage * image, NSString *imageURL);

@interface ImageCache : NSObject

+(ImageCache *) sharedInstance;

-(BOOL)isLoadedImageWithURL:(NSString *)imageURL;

-(UIImage *)imageWithImageURL:(NSString *)imageURL;

-(void)loadImageAsyncWithImageURL:(NSString *)imageURL andCompletionBlock:(ICCompletionBlock)handler;

@end
