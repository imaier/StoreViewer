//
//  StoreAnnotation.m
//  StoreViewer
//
//  Created by Ilya Maier on 24.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import "StoreAnnotation.h"
#import "StoreFetcher.h"

@implementation StoreAnnotation

- (instancetype)initWithStore:(NSDictionary *)store;
{
    self = [super init];
    if (self) {
        self.store = store;
    }
    return self;
}

-(CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coord;
    coord.latitude = [(NSString*)[self.store valueForKeyPath:STORE_LATITUDE] doubleValue];
    coord.longitude = [(NSString*)[self.store valueForKeyPath:STORE_LONGITUDE] doubleValue];
    return coord;
}

-(NSString *)title
{
    return [self.store valueForKeyPath:STORE_NAME];

}

-(NSString *)subtitle
{
    return [self.store valueForKeyPath:STORE_PHONE];
}

+ (NSArray*)annotationsWithStoreArray:(NSArray*)stores
{
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    
    for (NSDictionary *store in stores) {
        [annotations addObject: [[StoreAnnotation alloc] initWithStore:store]];
    }
    
    return [NSArray arrayWithArray:annotations];
}


@end
