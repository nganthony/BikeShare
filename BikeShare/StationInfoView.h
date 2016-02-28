//
//  StationInfoView.h
//  BikeShare
//
//  Created by Anthony Ng on 2016-02-22.
//  Copyright © 2016 Anthony Ng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationInfoView : UIView

@property (weak, nonatomic) IBOutlet UILabel *bikes;
@property (weak, nonatomic) IBOutlet UILabel *docks;
@property (weak, nonatomic) IBOutlet UILabel *distance;

@end
