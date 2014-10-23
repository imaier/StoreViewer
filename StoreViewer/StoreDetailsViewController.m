//
//  StoreDetailsViewController.m
//  StoreViewer
//
//  Created by Ilya Maier on 22.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import "StoreDetailsViewController.h"
#import "StoreFetcher.h"

@interface StoreDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *zipcodeLabel;

@property (strong, nonatomic) NSURL* logoURL;

@end

@implementation StoreDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)fillData
{
    self.nameLabel.text     = [self.store valueForKeyPath:STORE_NAME];
    self.phoneLabel.text    = [self.store valueForKeyPath:STORE_PHONE];
    self.addressLabel.text  = [self.store valueForKeyPath:STORE_ADDRESS];
    self.cityLabel.text     = [self.store valueForKeyPath:STORE_CITY];
    self.stateLabel.text    = [self.store valueForKeyPath:STORE_STATE];
    self.zipcodeLabel.text  = [self.store valueForKeyPath:STORE_ZIPCODE];
    
    if (self.cachedImage) {
        self.logoImage.image = self.cachedImage;
        self.logoURL = nil;
        self.activityIndicator.hidden = YES;
    } else {
        NSURL* logoURL = [NSURL URLWithString:[self.store valueForKeyPath:STORE_LOGO_URL]];
        self.logoURL = [logoURL copy];
        self.logoImage.image = nil;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
        [self.activityIndicator hidesWhenStopped];
        
        dispatch_queue_t fetcher = dispatch_queue_create("StoreDetails logo fetcher", NULL);
        dispatch_async(fetcher, ^{
            NSData *logoData = [NSData dataWithContentsOfURL:logoURL];
            UIImage *logo = [UIImage imageWithData:logoData];
            dispatch_async(dispatch_get_main_queue(),^{
                if ([logoURL isEqual:self.logoURL]) {
                    self.logoImage.image = logo;
                    [self.activityIndicator stopAnimating];
                    self.activityIndicator.hidden = YES;
                }
            });
        });
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self fillData];
}

-(void)setStore:(NSDictionary *)store
{
    _store = store;
    if (self.isViewLoaded && self.view.window) {
        //view is visible
        [self fillData];
    }
}

@end
