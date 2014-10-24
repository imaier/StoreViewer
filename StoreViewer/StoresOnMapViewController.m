//
//  StoresOnMapViewController.m
//  StoreViewer
//
//  Created by Ilya Maier on 24.10.14.
//  Copyright (c) 2014 Mera. All rights reserved.
//

#import "StoresOnMapViewController.h"
#import <MapKit/MapKit.h>
#import "StoreAnnotation.h"
#import "StoreFetcher.h"

@interface StoresOnMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation StoresOnMapViewController

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

-(void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    _mapView.delegate = self;
    [self updateMapViewAnnotation];
}

-(void)setStores:(NSArray *)stores
{
    _stores = stores;
    [self updateMapViewAnnotation];
}


-(void)selectStore
{
    for (StoreAnnotation *storeAnnotation in self.mapView.annotations) {
        if ([storeAnnotation.store isEqual:self.selectedStore]) {
            [self.mapView selectAnnotation:storeAnnotation animated:YES];
        }
    }
}

-(void)setSelectedStore:(NSDictionary *)selectedStore
{
    _selectedStore = selectedStore;
    [self selectStore];
}

- (void)updateMapViewAnnotation
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:[StoreAnnotation annotationsWithStoreArray:self.stores]];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    
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
        if ([annotationView.annotation isKindOfClass:[StoreAnnotation class]]) {
            StoreAnnotation *storeAnnotation = (StoreAnnotation*)annotationView.annotation;
            NSDictionary *store = storeAnnotation.store;

            NSURL* logoURL = [NSURL URLWithString:[store valueForKeyPath:STORE_LOGO_URL]];
            
            
            dispatch_queue_t fetcher = dispatch_queue_create("Store logo fetcher", NULL);
            dispatch_async(fetcher, ^{
                NSData *logoData = [NSData dataWithContentsOfURL:logoURL];
                UIImage *logo = [UIImage imageWithData:logoData];
                dispatch_async(dispatch_get_main_queue(),^{
                    if ([storeAnnotation isEqual:annotationView.annotation]) {
                        imageView.image = logo;
                    }
                });
            });
        }
    }
}

@end
