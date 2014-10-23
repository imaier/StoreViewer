//
//  StoreListTableViewController.m
//  StoreViewer
//
//  Created by Ilya Maier on 22.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import "StoreListTableViewController.h"
#import "StoreFetcher.h"
#import "StoreDetailsViewController.h"
#import "StoreTableViewCell.h"

@interface StoreListTableViewController ()

@end

@implementation StoreListTableViewController


-(void)setStores:(NSArray *)stores
{
    _stores = stores;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchStores];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)fetchStores
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Loading"];
    [self.refreshControl beginRefreshing];
    NSURL *url = [StoreFetcher URLforStoreDB];
    dispatch_queue_t fetcher = dispatch_queue_create("Store fetcher", NULL);
    
    dispatch_async(fetcher, ^{
        NSData *jsonData = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyList = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
        dispatch_async(dispatch_get_main_queue(),^{
            self.stores = [propertyList valueForKeyPath:STORE_RESULTS_STORES];
            [self.refreshControl endRefreshing];
            //whait the end of animation
            while (self.refreshControl.isHidden == NO) {
                [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
            self.refreshControl = nil;
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.stores count];
}

- (void)prepareStoreTableViewCell:(StoreTableViewCell*)storeCell toDisplayWithDictionary:(NSDictionary *)store
{
    storeCell.phoneLabel.text = [store valueForKeyPath:STORE_PHONE];
    storeCell.addressLabel.text = [store valueForKeyPath:STORE_ADDRESS];
    
    NSURL* logoURL = [NSURL URLWithString:[store valueForKeyPath:STORE_LOGO_URL]];
    storeCell.logoURL = [logoURL copy];
    storeCell.logoImage.image = nil;
    storeCell.activityIndicator.hidden = NO;
    [storeCell.activityIndicator startAnimating];
    [storeCell.activityIndicator hidesWhenStopped];

    dispatch_queue_t fetcher = dispatch_queue_create("StoreCell logo fetcher", NULL);
    dispatch_async(fetcher, ^{
        NSData *logoData = [NSData dataWithContentsOfURL:logoURL];
        UIImage *logo = [UIImage imageWithData:logoData];
        dispatch_async(dispatch_get_main_queue(),^{
            if ([logoURL isEqual:storeCell.logoURL]) {
                storeCell.logoImage.image = logo;
                [storeCell.activityIndicator stopAnimating];
            }
        });
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Store Cell" forIndexPath:indexPath];

    NSDictionary *store = self.stores[indexPath.row];
    
    if ([cell isKindOfClass:[StoreTableViewCell class]]) {
        [self prepareStoreTableViewCell:(StoreTableViewCell*)cell toDisplayWithDictionary:store];
    }

    return cell;
}

#pragma mark - Navigation

-(void)prepareStoreDetailsViewController:(StoreDetailsViewController*)sdvc toDisplayWithDictionary:(NSDictionary *)store andLogoImage:(UIImage*)logoImage
{
    sdvc.title = [store valueForKeyPath:STORE_NAME];
    sdvc.store = store;
    sdvc.cachedImage = logoImage;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[StoreTableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Store Details"] ) {
                if ([[segue destinationViewController] isKindOfClass:[StoreDetailsViewController class]]) {
                    [self prepareStoreDetailsViewController:[segue destinationViewController] toDisplayWithDictionary:self.stores[indexPath.row] andLogoImage:nil/*((StoreTableViewCell*)sender).logoImage.image*/];
                }
             }
        }
    }
}


@end
