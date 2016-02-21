//
//  BSStationTableViewCell.h
//  BikeShare
//
//  Created by Anthony Ng on 2016-02-18.
//  Copyright © 2016 Anthony Ng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSStationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dockLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end
