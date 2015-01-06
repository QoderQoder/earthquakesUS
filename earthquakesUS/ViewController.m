//
//  ViewController.m
//  earthquakesUS
//
//  Created by Spencer on 1/5/15.
//  Copyright (c) 2015 spencer. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
#import "Summary.h"
#import "DetailViewController.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
static NSString *downloadString = @"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson";

@interface ViewController ()<NSURLSessionDataDelegate>
{
  UIRefreshControl *refreshControl;
  NSString *title;
  int counter;
}



@property (strong, nonatomic) IBOutlet UINavigationItem *earthquakeTitle;
@property (strong, nonatomic) Details *details;
@property (strong, nonatomic) id jsonDetails;

@end

@implementation ViewController
@synthesize earthquakes,details;

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self initModel];
}


#pragma mark - Table View Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
  return [earthquakes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"Inside cellForRowAtIndexPath");
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
  }

//  NSDate *object = self.objects[indexPath.row];
  Summary *summaryItem = [earthquakes objectAtIndex:indexPath.row];
  
 cell.textLabel.text = summaryItem.place;
  NSLog(@"Cell's summaryItem.place is %@", summaryItem.place);
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  counter++;

  Summary *summaryItem = [earthquakes objectAtIndex:indexPath.row];
  NSLog(@"summaryItem.detailURL is %@",summaryItem.detailURL);
  
  [self getEarthquakeData:summaryItem.detailURL];
  
  
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"ShowDetailID"]) {
    
    NSLog(@"In prepareForSegue Alpha");
    
     DetailViewController *dvc = (DetailViewController *) segue.destinationViewController;
    dvc.details = details;
      NSLog(@"In prepareForSegue: details: %f %f %f", details.latitude, details.longitude, details.longitude);
    NSLog(@"In prepareForSegue: dvc.details: %f %f %f", dvc.details.latitude, dvc.details.longitude, dvc.details.longitude);

    //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
//    NSDate *object = self.objects[indexPath.row];
//    [[segue destinationViewController] setDetailItem:object];
  }
}


#pragma mark - Private Methods

- (void)initUI
{
  
}

- (void)initModel
{
  CLLocationManager *locationManager = [[CLLocationManager alloc]init];
  locationManager.delegate = self;
  // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
  if(IS_OS_8_OR_LATER) {
    // Use one or the other, not both. Depending on what you put in info.plist
    
    [locationManager requestAlwaysAuthorization];
  }
  
  details = [Details new];
  earthquakes = [NSMutableArray new];
  [self getEarthquakeData:downloadString];
  [self setupRefresh];
  
}

- (void)getEarthquakeData:(NSString*)urlString
{

  NSURL *URL = [[NSURL alloc]initWithString:urlString];
  NSURLRequest *requestGEO = [NSURLRequest requestWithURL:URL];
  
  NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
  
  defaultConfiguration.allowsCellularAccess = YES;
  
  NSURLSession *dataSession = [NSURLSession sessionWithConfiguration:defaultConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
  
  NSURLSessionDataTask *dataTask = [dataSession dataTaskWithRequest:requestGEO completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if(error == nil)
    {
      id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
      if ([urlString isEqualToString:downloadString]){
        [self parseSummaryJSON:JSON];
      }
      else
      {
        NSLog(@"Else parseDetails");
        [self parseDetails:JSON];
        [self performSegueWithIdentifier:@"ShowDetailID" sender:self];
      }
    }
    else
    {
      
      NSLog(@"Error detected!");
    }
  }];
  
  [dataTask resume];
  
  NSLog(@"getEarthquakeData");
  [self.tableView reloadData];
}

- (void)setupRefresh{
  
  // Initialize Refresh Control
  refreshControl = [[UIRefreshControl alloc] init];
  
  // Configure Refresh Control
  [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
  
  // Configure View Controller
  //[self setRefreshControl:refreshControl];
  
}

- (void)refresh:(id)sender
{
  NSLog(@"Refreshing");
  
  [self getEarthquakeData:downloadString];
  
  //End Refreshing
  [(UIRefreshControl *)sender endRefreshing];
}

- (void)refreshData{
  
}

-(void)parseSummaryJSON:(id)json
{
  NSLog(@"parseSummary: %@",json);
  
  NSDictionary *jsonDictionary = (NSDictionary*)json;
  NSMutableDictionary *jsonDictionary2  = [jsonDictionary objectForKey:@"metadata"];
  
  NSLog(@"jsonDictionary2 is %@", jsonDictionary2);
  
  title = [jsonDictionary2 objectForKey:@"title"];
  NSArray* jsonArray = [[NSArray alloc]initWithArray:[jsonDictionary objectForKey:@"features"]];
  
  for (id item in jsonArray) {
    Summary *summaryItem = [Summary new];
    
    NSDictionary *properties = [item objectForKey:@"properties"];
    summaryItem.place = [properties objectForKey:@"place"];
    summaryItem.detailURL = [properties objectForKey:@"detail"];
    NSDictionary *geometry = [item objectForKey:@"geometry"];
    NSArray *coordinates = [[NSArray alloc]initWithArray:[geometry objectForKey:@"coordinates"]];
    summaryItem.longitude = [[coordinates objectAtIndex:0] floatValue];
    summaryItem.latitude  = [[coordinates objectAtIndex:1] floatValue];
    summaryItem.depth = [[coordinates objectAtIndex:2]floatValue];
    [earthquakes addObject:summaryItem];
    NSLog(@"summary: lat %f long %f", summaryItem.latitude, summaryItem.longitude);
    
  }
  
  
  [self.tableView reloadData];
  
}

- (void)parseDetails:(id)json{
  // details = [Details new];
  NSLog(@"parseDetails' json is %@",json);
  NSMutableDictionary *detailsJSON = (NSMutableDictionary*)json;
  details.magnitude = [[[detailsJSON objectForKey:@"properties"]objectForKey:@"mag"] floatValue];
  details.timeInterval = [[[detailsJSON objectForKey:@"properties"]objectForKey:@"time"] floatValue];
  details.place = [[detailsJSON objectForKey:@"properties"]objectForKey:@"place"];
  NSArray *coordinates = [[NSArray alloc]initWithArray:[[detailsJSON objectForKey:@"geometry"]objectForKey:@"coordinates"]];
  
  NSLog(@"coordinates is %@", coordinates);
  details.longitude = [[coordinates objectAtIndex:0]floatValue];
  details.latitude = [[coordinates objectAtIndex:1]floatValue];
  details.depth = [[coordinates objectAtIndex:2]floatValue];
  NSLog(@"coordinates details: %f %f %f", details.latitude, details.longitude, details.depth);
  

}


+(BOOL)networkStatusAvailable{
  
  Reachability *internetReach =  [Reachability reachabilityForInternetConnection];
  [internetReach startNotifier];
  
  Reachability *wifiReach = [Reachability reachabilityForLocalWiFi] ;
  [wifiReach startNotifier];
  
  NetworkStatus netStatusInternetConnection = [internetReach currentReachabilityStatus];
  NetworkStatus netStatusLocalWiFi = [wifiReach currentReachabilityStatus];
  
  if(netStatusInternetConnection == NotReachable && netStatusLocalWiFi == NotReachable)
  {
    return netStatusInternetConnection;
  }
  else
  {
    return netStatusInternetConnection;
  }
  
}

@end
