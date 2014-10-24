//
//  StoreAnnotation.h
//  StoreViewer
//
//  Created by Ilya Maier on 24.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface StoreAnnotation : NSObject <MKAnnotation>

@property (nonatomic,strong) NSDictionary *store;

- (instancetype)initWithStore:(NSDictionary *)store;

+ (NSArray*)annotationsWithStoreArray:(NSArray*)stores;
@end
