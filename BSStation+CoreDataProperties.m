//
//  BSStation+CoreDataProperties.m
//  BikeShare
//
//  Created by Anthony Ng on 2016-02-20.
//  Copyright © 2016 Anthony Ng. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BSStation+CoreDataProperties.h"

@implementation BSStation (CoreDataProperties)

@dynamic availableBikes;
@dynamic availableDocks;
@dynamic latitude;
@dynamic longitude;
@dynamic remoteID;
@dynamic stationName;
@dynamic distance;

@end
