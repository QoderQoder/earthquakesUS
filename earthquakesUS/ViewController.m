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

@interface ViewController ()<NSURLSessionDataDelegate>
{
  UIRefreshControl *refreshControl;
  Details *details;
  NSString *title;
}
@property (strong, nonatomic) IBOutlet UINavigationItem *earthquakeTitle;


@end

@implementation ViewController
@synthesize earthquakes;

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
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
  [self performSegueWithIdentifier:@"ShowDetailID" sender:self];
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"ShowDetailID"]) {
    
    //  DetailViewController *dvc = (DetailViewController *) segue.destinationViewController;
    
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
  earthquakes = [NSMutableArray new];
  [self getEarthquakeData];
  [self setupRefresh];
  
}

- (void)getEarthquakeData
{
  NSString *downloadString = @"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson";
  NSURL *URL = [[NSURL alloc]initWithString:downloadString];
  NSURLRequest *requestGEO = [NSURLRequest requestWithURL:URL];
  
  NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
  
  defaultConfiguration.allowsCellularAccess = YES;
  
  NSURLSession *dataSession = [NSURLSession sessionWithConfiguration:defaultConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
  
  NSURLSessionDataTask *dataTask = [dataSession dataTaskWithRequest:requestGEO completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if(error == nil)
    {
      id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
      [self parseSummaryJSON:JSON];
      NSLog(@"%@", JSON);
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
  
  [self getEarthquakeData];
  
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
    summaryItem.latitude = [[coordinates objectAtIndex:0] floatValue];
    summaryItem.longitude  = [[coordinates objectAtIndex:1] floatValue];
    summaryItem.depth = [[coordinates objectAtIndex:2]floatValue];
    [earthquakes addObject:summaryItem];
    
  }
  
  
  [self.tableView reloadData];
  
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
