//
//  DetailViewController.m
//  earthquakesUS
//
//  Created by Spencer on 1/5/15.
//  Copyright (c) 2015 spencer. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
#define METERS_PER_MILE 1609.344

@property (strong, nonatomic) IBOutlet UILabel *magnitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateTimeLabel;

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@end

@implementation DetailViewController
@synthesize mapView, details, magnitudeLabel, dateTimeLabel, locationLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  mapView.showsUserLocation = YES;

  [self initModel];
}

-(void)viewWillAppear:(BOOL)animated
{

}


-(void)initModel
{
    
  CLLocationCoordinate2D zoomLocation;
  zoomLocation.latitude = details.latitude;
  zoomLocation.longitude = details.longitude;
  NSLog(@"zoomLocation: %f %f", details.latitude, details.longitude);
  
  NSLog(@"latitude: %f longitude: %f", details.latitude, details.longitude);
  MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, .5 * METERS_PER_MILE, .5 * METERS_PER_MILE);
  [mapView setRegion:viewRegion animated:YES];
  [mapView setMapType:MKMapTypeSatellite];
  [mapView setZoomEnabled:YES];
  [mapView setScrollEnabled:YES];
  
  magnitudeLabel.text = [NSString stringWithFormat:@"%1.3f",details.magnitude];
  NSLog(@"timeInterval is [%f]", details.timeInterval);
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:details.timeInterval];
  NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
  [formatter setDateFormat:@"MMM dd, yyyy h:mm"];
  [formatter setTimeZone: [NSTimeZone timeZoneForSecondsFromGMT:0]];
  dateTimeLabel.text = [formatter stringFromDate:date];
  locationLabel.text = details.place;

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
