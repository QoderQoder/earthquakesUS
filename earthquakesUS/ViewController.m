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
#import "EarthQuakeTableViewCell.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
static NSString *downloadString = @"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson";

@interface ViewController ()<NSURLSessionDataDelegate, MKMapViewDelegate>
{
  UIRefreshControl *refreshControl;
  NSString *title;
  int counter;
  NSString *dataStore;
  NSFileManager *manager;
  NSUserDefaults *userDefaults;
  NSArray *documentsPath;
  NSString *path;
  BOOL isOnline;
  
}



@property (strong, nonatomic) IBOutlet UINavigationItem *earthquakeTitle;
@property (strong, nonatomic) Details *details;
@property (strong, nonatomic) id jsonDetails;

@end

@implementation ViewController
@synthesize earthquakes, details, activityIndicator, listMapSegmentControl, summaryMapView;

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self initModel];
  [self initUI];
  
}

- (void)viewDidAppear:(BOOL)animated{
  self.tableView.userInteractionEnabled = YES;
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
  
  EarthQuakeTableViewCell *cell = (EarthQuakeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
  
  if (cell == nil)
  {
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"EarthQuakeTableViewCell" owner:self options:nil];
    
    cell = [nib objectAtIndex:0];
    
  }
  
  //  NSDate *object = self.objects[indexPath.row];
  Summary *summaryItem = [earthquakes objectAtIndex:indexPath.row];
  cell.backgroundColor = [self getCellColor:summaryItem.magnitude];
  cell.placeLabel.text = summaryItem.place;
  cell.magnitudeLabel.text = [NSString stringWithFormat:@"%f", summaryItem.magnitude];
  
  NSLog(@"Cell's summaryItem.place is %@", summaryItem.place);
  
  if (isOnline)
  {
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  counter++;
  if (isOnline){
    tableView.userInteractionEnabled = NO;
    
    Summary *summaryItem = [earthquakes objectAtIndex:indexPath.row];
    NSLog(@"summaryItem.detailURL is %@",summaryItem.detailURL);
    
    [self getEarthquakeData:summaryItem.detailURL];
    
  }
  else{
    //pop up alert informing detailed data is unavailable in offline mode.
    
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 99;
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
  _tableView.contentInset = UIEdgeInsetsZero;
  self.automaticallyAdjustsScrollViewInsets = NO;
  _tableView.backgroundColor = [UIColor grayColor];
  _earthquakeTitle.title = @"USGS Earthquake Data";
  summaryMapView.mapType = MKMapTypeHybrid;
  summaryMapView.hidden = YES;
  
}

- (void)initModel
{
  CLLocationManager *locationManager = [[CLLocationManager alloc]init];
  locationManager.delegate = self;
  // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
  if(IS_OS_8_OR_LATER)
  {
    // Use one or the other, not both. Depending on what you put in info.plist
    [locationManager requestAlwaysAuthorization];
    
  }
  summaryMapView.delegate = self;
  
  details = [Details new];
  earthquakes = [NSMutableArray new];
  manager = [NSFileManager defaultManager];
  
  
  
  [self getData];
  [self setupRefresh];
  
}

- (void)getEarthquakeData:(NSString*)urlString
{
  
  NSURL *URL = [[NSURL alloc]initWithString:urlString];
  NSURLRequest *requestGEO = [NSURLRequest requestWithURL:URL];
  
  NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
  
  defaultConfiguration.allowsCellularAccess = YES;
  
  NSURLSession *dataSession = [NSURLSession sessionWithConfiguration:defaultConfiguration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
  
  [self.view addSubview:activityIndicator];
  activityIndicator.hidden = NO;
  [activityIndicator startAnimating];
  
  NSLog(@"In getEarthquakeData");
  
  NSURLSessionDataTask *dataTask = [dataSession dataTaskWithRequest:requestGEO completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if(error == nil)
    {
      NSDictionary* JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
      
      
      if ([urlString isEqualToString:downloadString])
      {
        if (JSON)
        {
          NSData *savedJSON = [NSKeyedArchiver archivedDataWithRootObject:JSON];
          [[NSUserDefaults standardUserDefaults]setObject:savedJSON forKey:@"Earthquakes"];
          [[NSUserDefaults standardUserDefaults]synchronize];
          
        }
        
        [self parseSummaryJSON:JSON];
        dispatch_async(dispatch_get_main_queue(), ^{
          [activityIndicator stopAnimating];
          activityIndicator.hidden =YES;
          isOnline = YES;
          
        });
      }
      else
      {
        NSLog(@"Else parseDetails");
        [self parseDetails:JSON];
        
        //Hand off results to mainqueue for UI
        dispatch_async(dispatch_get_main_queue(), ^{
          [activityIndicator stopAnimating];
          activityIndicator.hidden =YES;
          
          
          [self performSegueWithIdentifier:@"ShowDetailID" sender:self];
          
        });
        
      }
    }
    else
    {
#warning need to add better error handling
      [activityIndicator stopAnimating];
      activityIndicator.hidden =YES;
      
      NSLog(@"Error detected!");
      NSLog(@"Response is: %@",response);
      isOnline = NO;
      
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
  
  _earthquakeTitle.title = title;
  
  NSArray* jsonArray = [[NSArray alloc]initWithArray:[jsonDictionary objectForKey:@"features"]];
  
  for (id item in jsonArray)
  {
    Summary *summaryItem = [Summary new];
    
    NSDictionary *properties = [item objectForKey:@"properties"];
    summaryItem.place = [properties objectForKey:@"place"];
    summaryItem.magnitude = [[properties objectForKey:@"mag"]floatValue];
    summaryItem.detailURL = [properties objectForKey:@"detail"];
    NSDictionary *geometry = [item objectForKey:@"geometry"];
    NSArray *coordinates = [[NSArray alloc]initWithArray:[geometry objectForKey:@"coordinates"]];
    summaryItem.longitude = [[coordinates objectAtIndex:0] floatValue];
    summaryItem.latitude  = [[coordinates objectAtIndex:1] floatValue];
    summaryItem.depth = [[coordinates objectAtIndex:2]floatValue];
    [earthquakes addObject:summaryItem];
    NSLog(@"summary: lat %f long %f", summaryItem.latitude, summaryItem.longitude);
    
    [self createMapPinPoint:summaryItem];
    
  }
  
  
  [self.tableView reloadData];
  
}

- (void)parseDetails:(id)json{
  // details = [Details new];
  NSLog(@"parseDetails' json is %@",json);
  NSMutableDictionary *detailsJSON = (NSMutableDictionary*)json;
  details.magnitude = [[[detailsJSON objectForKey:@"properties"]objectForKey:@"mag"] floatValue];
  details.color = [self getCellColor:details.magnitude];
  details.timeInterval = [[[detailsJSON objectForKey:@"properties"]objectForKey:@"time"] floatValue];
  details.place = [[detailsJSON objectForKey:@"properties"]objectForKey:@"place"];
  NSArray *coordinates = [[NSArray alloc]initWithArray:[[detailsJSON objectForKey:@"geometry"]objectForKey:@"coordinates"]];
  
  NSLog(@"coordinates is %@", coordinates);
  details.longitude = [[coordinates objectAtIndex:0]floatValue];
  details.latitude = [[coordinates objectAtIndex:1]floatValue];
  details.depth = [[coordinates objectAtIndex:2]floatValue];
  NSLog(@"coordinates details: %f %f %f", details.latitude, details.longitude, details.depth);
  
  
}


- (UIColor*)getCellColor:(float)magnitude
{
  UIColor *cellColor;
  NSLog(@"magnitude is %f", magnitude);
  
  if (magnitude < 1) {
    cellColor = [UIColor colorWithRed:188/255.0f green:255/255.0f blue:48/255.0f alpha:1.0f];
  }
  else if (magnitude >= 1 && magnitude < 2)
  {
    cellColor = [UIColor colorWithRed:216/255.0f green:251/255.0f blue:61/255.0f alpha:1.0f];
  }
  else if (magnitude >= 2 && magnitude < 3)
  {
    cellColor = [UIColor colorWithRed:231/255.0f green:255/255.0f blue:0/255.0f alpha:1.0f];
  }
  else if (magnitude >= 3 && magnitude < 4)
  {
    cellColor = [UIColor colorWithRed:255/255.0f green:241/255.0f blue:0/255.0f alpha:1.0f];
  }
  else if (magnitude >= 4 && magnitude < 5)
  {
    cellColor = [UIColor colorWithRed:255/255.0f green:212/255.0f blue:0/255.0f alpha:1.0f];
  }
  else if (magnitude >= 5 && magnitude < 6)
  {
    cellColor = [UIColor colorWithRed:255/255.0f green:170/255.0f blue:0/255.0f alpha:1.0f];
  }
  else if (magnitude >= 6 && magnitude < 7)
  {
    cellColor = [UIColor colorWithRed:255/255.0f green:111/255.0f blue:0/255.0f alpha:1.0f];
  }
  else if (magnitude >= 7 && magnitude < 8)
  {
    cellColor = [UIColor colorWithRed:255/255.0f green:98/255.0f blue:0/255.0f alpha:1.0f];
  }
  else if (magnitude >= 8 && magnitude < 9)
  {
    cellColor = [UIColor colorWithRed:255/255.0f green:81/255.0f blue:0/255.0f alpha:1.0f];
  }
  else if (magnitude >= 9 && magnitude < 10)
  {
    cellColor = [UIColor colorWithRed:255/255.0f green:32/255.0f blue:0/255.0f alpha:1.0f];
  }
  
  return cellColor;
}

-(BOOL)networkStatusAvailable
{
  
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


-(void)getData
{
  if ([self networkStatusAvailable]) {
    NSLog(@"Hi. The Network is working");
    
    [self getEarthquakeData:downloadString];
    
  }
  else{
    NSLog(@"There is no network available");
    
    //verify if file exists. if it exists, then fill array; refresh data
    NSData *retrievedSavedData = [[NSUserDefaults standardUserDefaults]objectForKey:@"Earthquakes"];
    id JSON = [NSKeyedUnarchiver unarchiveObjectWithData:retrievedSavedData];
    
    [self parseSummaryJSON:JSON];
    
  }
  
}


-(void)createMapPinPoint:(Summary*)summary
{
  
  CLLocationCoordinate2D coordinate;
  
  coordinate.latitude = summary.latitude;
  coordinate.longitude = summary.longitude;
  
  MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
  point.coordinate = coordinate;
  point.title = summary.place;
  
  
  MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:point reuseIdentifier:@"currentloc"];
  annView.pinColor = MKPinAnnotationColorGreen;
  
  [summaryMapView addAnnotation:point];
  
}


#pragma mark - IBAction Methods
- (IBAction)actionRefresh:(id)sender
{
  earthquakes = [NSMutableArray new];
  [self getData];
  self.tableView.userInteractionEnabled = YES;
  
}


- (IBAction)actionSelectListMap:(id)sender {
  
  if (listMapSegmentControl.selectedSegmentIndex == 0)
  {
    summaryMapView.hidden = YES;
  }
  else if (listMapSegmentControl.selectedSegmentIndex == 1)
  {
    summaryMapView.hidden = NO;
    
    
  }
}
@end
