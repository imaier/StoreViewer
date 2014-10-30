//
//  StoresCDTVC.m
//  StoreViewer
//
//  Created by Ilya Maier on 29.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import "StoresCDTVC.h"
#include "Store.h"
#import "StoreTableViewCell.h"
#import "Notifications.h"
#import "ImageCache.h"
#import "StoreViewController.h"
#import "MapViewController.h"


@implementation StoresCDTVC

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:StoreDatabaseAvailabilitiyNotification
                                                      object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
        self.managedObjectContext = [note.userInfo valueForKey:StoreDatabaseAvailabilitiyContext];
    }];
}


-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Store"];
    request.predicate = nil;
    request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Store Cell" forIndexPath:indexPath];
    
    Store *store =  [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[StoreTableViewCell class]]) {
        [self prepareStoreTableViewCell:(StoreTableViewCell*)cell toDisplayWithStore:store];
    }
    
    return cell;
}


- (void)prepareStoreTableViewCell:(StoreTableViewCell*)storeCell toDisplayWithStore:(Store *)store
{
    storeCell.phoneLabel.text = store.phone;
    storeCell.addressLabel.text = store.address;
    
    NSURL* logoURL = [NSURL URLWithString:store.storeLogoURL];
    
    storeCell.logoURL = [logoURL copy];
    storeCell.logoImage.image = nil;
    storeCell.activityIndicator.hidden = NO;
    [storeCell.activityIndicator startAnimating];
    [storeCell.activityIndicator hidesWhenStopped];
    
    [[ImageCache sharedInstance] loadImageAsyncWithImageURL:store.storeLogoURL andCompletionBlock:^(UIImage *image, NSString *imageURL) {
        dispatch_async(dispatch_get_main_queue(),^{
            if ([logoURL isEqual:storeCell.logoURL]) {
                storeCell.logoImage.image = image;
                [storeCell.activityIndicator stopAnimating];
            }
        });
    }];
}


-(void)prepareStoreDetailsViewController:(StoreViewController*)sdvc toDisplayWithStore:(Store *)store
{
    sdvc.title = store.name;
    sdvc.store = store;
}

-(void)prepareToDisplayStoresOnMapViewController:(MapViewController*)mvc
{
    mvc.selectedStore = nil;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[StoreTableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Store Details"] ) {
                if ([[segue destinationViewController] isKindOfClass:[StoreViewController class]]) {
                    Store *store =  [self.fetchedResultsController objectAtIndexPath:indexPath];
                    [self prepareStoreDetailsViewController:[segue destinationViewController] toDisplayWithStore:store];
                }
            }
        }
    } else if ([segue.identifier isEqualToString:@"Stores on Map"]) {
        if ([[segue destinationViewController] isKindOfClass:[MapViewController class]]) {
            [self prepareToDisplayStoresOnMapViewController:segue.destinationViewController];
        }
    }
}

@end
