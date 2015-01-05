//
//  Details.h
//  geoProject
//
//  Created by Spencer on 1/4/15.
//  Copyright (c) 2015 spencer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Details : NSObject
@property (strong, nonatomic) NSString * place;
@property (strong, nonatomic) NSString * detailURL;
@property float latitude;
@property float longitude;
@property float depth;
@property float magnitude;
@property  double timeInterval;
@end
