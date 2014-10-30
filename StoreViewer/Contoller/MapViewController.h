//
//  MapViewController.h
//  StoreViewer
//
//  Created by Ilya Maier on 30.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Store.h"

@interface MapViewController : UIViewController

@property (nonatomic, strong) Store *selectedStore;

-(void)showAllStores;
@end
