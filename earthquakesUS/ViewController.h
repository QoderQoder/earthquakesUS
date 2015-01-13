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

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *earthquakes;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;

@end

