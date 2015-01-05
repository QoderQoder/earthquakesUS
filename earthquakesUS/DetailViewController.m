//
//  DetailViewController.m
//  earthquakesUS
//
//  Created by Spencer on 1/5/15.
//  Copyright (c) 2015 spencer. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (strong, nonatomic) IBOutlet UILabel *magnitudeLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateTimeLabel;

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@end

@implementation DetailViewController
@synthesize mapView, details, magnitudeLabel, dateTimeLabel, locationLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)initModel
{
  magnitudeLabel.text = [NSString stringWithFormat:@"%1.3f",details.magnitude];
  
  NSDate *date = [NSDate dateWithTimeIntervalSince1970:details.timeInterval];
  NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
  [formatter setDateFormat:@"dd.MM.yyyy"];
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
