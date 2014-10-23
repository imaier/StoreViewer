//
//  StoreFetcher.m
//  StoreViewer
//
//  Created by Ilya Maier on 22.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import "StoreFetcher.h"

@implementation StoreFetcher

+ (NSURL*)URLforStoreDB
{
    return [NSURL URLWithString:@"http://strong-earth-32.heroku.com/stores.aspx"];
}


@end
