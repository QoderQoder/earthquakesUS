//
//  ViewController.h
//  earthquakesUS
//
//  Created by Spencer on 1/5/15.
//  Copyright (c) 2015 spencer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "ZSPinAnnotation.h"
#import "AppDelegate.h"

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *summaryMapView;

@property (nonatomic, strong) NSMutableArray *earthquakes;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;
@property (strong, nonatomic) IBOutlet UISegmentedControl *listMapSegmentControl;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
- (IBAction)actionRefresh:(id)sender;

- (IBAction)actionSelectListMap:(id)sender;

@end

