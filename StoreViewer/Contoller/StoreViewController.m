//
//  StoreViewController.m
//  StoreViewer
//
//  Created by Ilya Maier on 30.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import "StoreViewController.h"
#import "ImageCache.h"
#import "MapViewController.h"
#import "LocalizedStrings.h"

@interface StoreViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *zipcodeLabel;
@end

@implementation StoreViewController

- (void)fillData
{
    self.nameLabel.text     = self.store.name;
    self.phoneLabel.text    = self.store.phone;
    self.addressLabel.text  = self.store.address;
    self.cityLabel.text     = self.store.city;
    self.stateLabel.text    = self.store.state;
    self.zipcodeLabel.text  = self.store.zipcode;
    
    self.logoImage.image = nil;
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    [self.activityIndicator hidesWhenStopped];
    
    [[ImageCache sharedInstance] loadImageAsyncWithImageURL:self.store.storeLogoURL andCompletionBlock:^(UIImage *image, NSString *imageURL) {
        dispatch_async(dispatch_get_main_queue(),^{
            if ([imageURL isEqual:self.store.storeLogoURL]) {
                self.logoImage.image = image;
                [self.activityIndicator stopAnimating];
                self.activityIndicator.hidden = YES;
            }
        });
    }];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.title = STORE_VIEW_CONTROLLER_SHOW_BUTTON_TITLE;

}

-(void)viewWillAppear:(BOOL)animated
{
    [self fillData];
}

-(void)setStore:(Store *)store
{
    _store = store;
    if (self.isViewLoaded && self.view.window) {
        //view is visible
        [self fillData];
    }
}

-(void)prepareStoresOnMapViewController:(MapViewController*)mvc toDisplayStroe:(Store*)store
{
    mvc.selectedStore = store;
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"Show Store on map"]) {
        if ([[segue destinationViewController] isKindOfClass:[MapViewController class]]) {
            [self prepareStoresOnMapViewController:segue.destinationViewController toDisplayStroe:self.store];
        }
    }
    
}

@end
