//
//  StoresForIpadViewController.m
//  StoreViewer
//
//  Created by Ilya Maier on 30.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import "StoresForIpadViewController.h"
#import "Store.h"
#import "MapViewController.h"

@implementation StoresForIpadViewController

-(void)awakeFromNib
{
    [super awakeFromNib];
    if (self.splitViewController) {
        self.splitViewController.delegate = self;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.splitViewController) {
        if ([self.splitViewController.viewControllers[1] isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController*)self.splitViewController.viewControllers[1];
            if ([[navigationController.viewControllers firstObject] isKindOfClass:[MapViewController class]]) {
                MapViewController *mapVC = (MapViewController *)[navigationController.viewControllers firstObject];
                Store *store =  [self.fetchedResultsController objectAtIndexPath:indexPath];
                
                mapVC.selectedStore = store;
            }
        }
    }
}

-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.splitViewController) {
        if ([self.splitViewController.viewControllers[1] isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = (UINavigationController*)self.splitViewController.viewControllers[1];
            if ([[navigationController.viewControllers firstObject] isKindOfClass:[MapViewController class]]) {
                MapViewController *mapVC = (MapViewController *)[navigationController.viewControllers firstObject];

                [mapVC showAllStores];
            }
        }
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}
@end
