//
//  NavControllerViewController.m
//  earthquakesUS
//
//  Created by Agnt86 on 1/11/15.
//  Copyright (c) 2015 spencer. All rights reserved.
//

#import "NavControllerViewController.h"

@interface NavControllerViewController ()

@end

@implementation NavControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

  
 UIColor *newColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:.0f];  
  self.navigationBar.barTintColor = newColor;
  self.navigationBar.tintColor = [UIColor whiteColor];
  
  
//  [self.navigationBar
//   setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
  NSShadow *shadow = [[NSShadow alloc] init];
  shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
  shadow.shadowOffset = CGSizeMake(0, 1);
  [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                         [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                         shadow, NSShadowAttributeName,
                                                         [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:16.0], NSFontAttributeName, nil]];
  
  self.navigationBar.translucent = YES;
  
  
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

@end
