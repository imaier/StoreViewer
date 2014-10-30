//
//  MapViewController.m
//  StoreViewer
//
//  Created by Ilya Maier on 30.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "Store+Annotation.h"
#import "ImageCache.h"
#import "Notifications.h"
#import "AppDelegate.h"

@interface MapViewController () <MKMapViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation MapViewController

-(void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    _mapView.delegate = self;
    [self updateMapViewAnnotation];
}


-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:StoreDatabaseAvailabilitiyNotification
                                                      object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           self.managedObjectContext = [note.userInfo valueForKey:StoreDatabaseAvailabilitiyContext];
                                                       }];
    
    
    if (!self.managedObjectContext) {
        if ([[UIApplication sharedApplication].delegate isKindOfClass:[AppDelegate class]]) {
            AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
            if (app.managedObjectContext) {
                self.managedObjectContext = app.managedObjectContext;
            }

        }
    }
}


-(void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    if (_managedObjectContext) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Store"];
        request.predicate = nil;
        request.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
}


-(void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != fetchedResultsController) {
        _fetchedResultsController = fetchedResultsController;
        NSError *error;
        [fetchedResultsController performFetch:&error];
        [self updateMapViewAnnotation];
    }
}

-(void)selectStore
{
    for (Store *storeAnnotation in self.mapView.annotations) {
        if ([storeAnnotation.storeID isEqual:self.selectedStore.storeID]) {
            [self.mapView selectAnnotation:storeAnnotation animated:YES];
            [self.mapView showAnnotations:@[storeAnnotation] animated:YES];
        }
    }
}

-(void)setSelectedStore:(Store *)selectedStore
{
    _selectedStore = selectedStore;
    [self selectStore];
}

- (void)updateMapViewAnnotation
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView addAnnotations:self.fetchedResultsController.fetchedObjects];
    
    [self showAllStores];
    
    [self selectStore];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *reuseId = @"StoresOnMapViewController";
    
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        view.leftCalloutAccessoryView = imageView;
    }
    
    view.annotation = annotation;
    
    return view;
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [self updateleftCalloutAccessoryViewInAnnotationView:view];
}

- (void)updateleftCalloutAccessoryViewInAnnotationView:(MKAnnotationView *)annotationView
{
    UIImageView *imageView = nil;
    if ([annotationView.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        imageView = (UIImageView*)annotationView.leftCalloutAccessoryView;
    }
    if (imageView) {
        if ([annotationView.annotation isKindOfClass:[Store class]]) {
            Store *store = (Store*)annotationView.annotation;

            [[ImageCache sharedInstance] loadImageAsyncWithImageURL:store.storeLogoURL andCompletionBlock:^(UIImage *image, NSString *imageURL) {
                dispatch_async(dispatch_get_main_queue(),^{
                    if ([store isEqual:annotationView.annotation]) {
                        imageView.image = image;
                    }
                });
            }];
        }
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self updateMapViewAnnotation];
}

-(void)showAllStores;
{
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}

@end
