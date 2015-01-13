//
//  EarthQuakeTableViewCell.h
//  earthquakesUS
//
//  Created by Agnt86 on 1/8/15.
//  Copyright (c) 2015 spencer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EarthQuakeTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *placeLabel;

@property (strong, nonatomic) IBOutlet UILabel *magnitudeLabel;
@end
