//
//  Store+Annotation.m
//  StoreViewer
//
//  Created by Ilya Maier on 30.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import "Store+Annotation.h"

@implementation Store (Annotation)

-(CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coord;
    coord.latitude = [self.latitude doubleValue];
    coord.longitude = [self.longitude doubleValue];
    return coord;
}

-(NSString *)title
{
    return self.name;
}

-(NSString *)subtitle
{
    return self.phone;
}

@end
