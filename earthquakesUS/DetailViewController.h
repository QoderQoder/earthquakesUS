//
//  DetailViewController.h
//  earthquakesUS
//
//  Created by Spencer on 1/5/15.
//  Copyright (c) 2015 spencer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "AppDelegate.h"
#import "ZSPinAnnotation.h"

#import "Details.h"

@interface DetailViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *detailsView;

@property (strong, nonatomic) Details *details;

@end
