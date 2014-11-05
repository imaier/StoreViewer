//
//  StoresForIphoneViewController.m
//  StoreViewer
//
//  Created by Ilya Maier on 30.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import "StoresForIphoneViewController.h"
#import "LocalizedStrings.h"

@implementation StoresForIphoneViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.title = STORES_VIEW_CONTROLLER_MAP_BUTTON_TITLE;;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait + UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
