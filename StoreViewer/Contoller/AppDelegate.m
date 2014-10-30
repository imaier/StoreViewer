//
//  AppDelegate.m
//  StoreViewer
//
//  Created by Admin on 22/10/14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import "AppDelegate.h"
#import "StoreFetcher.h"
#import "Store+Create.h"
#import "Notifications.h"

@interface AppDelegate ()

@property (nonatomic, strong) UIManagedDocument *storeViewerDatabase;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (!self.storeViewerDatabase) {  // for demo purposes, we'll create a default database if none is set
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default StoreViwer Database"];
        // url is now "<Documents Directory>/Default StoreViwer Database"
        self.storeViewerDatabase = [[UIManagedDocument alloc] initWithFileURL:url]; // setter will create this for us on disk
    }
    
    return YES;
}

- (void)setStoreViewerDatabase:(UIManagedDocument *)storeViewerDatabase
{

    if (_storeViewerDatabase != storeViewerDatabase) {
        _storeViewerDatabase = storeViewerDatabase;
        [self useDocument];
    }

}

- (void)useDocument
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self.storeViewerDatabase.fileURL path]]) {
        // does not exist on disk, so create it
        [self.storeViewerDatabase saveToURL:self.storeViewerDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self broadcastManagedObjectContext];
            [self fetchStoreDataIntoDocument:self.storeViewerDatabase];
            
        }];
    } else if (self.storeViewerDatabase.documentState == UIDocumentStateClosed) {
        // exists on disk, but we need to open it
        [self.storeViewerDatabase openWithCompletionHandler:^(BOOL success) {
            [self broadcastManagedObjectContext];
        }];
    } else if (self.storeViewerDatabase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        [self broadcastManagedObjectContext];
    }
}

- (void)broadcastManagedObjectContext
{
    NSDictionary *userInfo = @{StoreDatabaseAvailabilitiyContext:self.storeViewerDatabase.managedObjectContext};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:StoreDatabaseAvailabilitiyNotification object:self userInfo:userInfo];
}

-(NSManagedObjectContext *)managedObjectContext
{
    return self.storeViewerDatabase.managedObjectContext;
}

- (void)fetchStoreDataIntoDocument:(UIManagedDocument *)document
{
    dispatch_queue_t fetchQ = dispatch_queue_create("Store fetcher", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *stores = [StoreFetcher fetchStores];
        [document.managedObjectContext performBlock:^{ // perform in the NSMOC's safe thread (main thread)
            [Store loadFromStoreInfoArray:stores inManagedObjectContext:document.managedObjectContext];

            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
        }];
    });
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.storeViewerDatabase.documentState == UIDocumentStateNormal) {
        // already open and ready to use
        [self fetchStoreDataIntoDocument:self.storeViewerDatabase];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
