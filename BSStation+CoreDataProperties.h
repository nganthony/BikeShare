//
//  BSStation+CoreDataProperties.h
//  BikeShare
//
//  Created by Anthony Ng on 2016-02-20.
//  Copyright © 2016 Anthony Ng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BSStation.h"

NS_ASSUME_NONNULL_BEGIN

@interface BSStation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *availableBikes;
@property (nullable, nonatomic, retain) NSNumber *availableDocks;
@property (nullable, nonatomic, retain) NSNumber *latitude;
@property (nullable, nonatomic, retain) NSNumber *longitude;
@property (nullable, nonatomic, retain) NSNumber *remoteID;
@property (nullable, nonatomic, retain) NSString *stationName;
@property (nullable, nonatomic, retain) NSNumber *distance;

@end

NS_ASSUME_NONNULL_END
