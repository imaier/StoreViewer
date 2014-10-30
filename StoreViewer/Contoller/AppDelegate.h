//
//  AppDelegate.h
//  StoreViewer
//
//  Created by Admin on 22/10/14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property(nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@end
