//
//  BSStation.m
//  BikeShare
//
//  Created by Anthony Ng on 2016-02-20.
//  Copyright © 2016 Anthony Ng. All rights reserved.
//

#import "BSStation.h"

@implementation BSStation

- (void)unpackDictionary:(NSDictionary *)dictionary {
    
    if(dictionary[@"availableBikes"]) {
        self.availableBikes = dictionary[@"availableBikes"];
    }
    
    if(dictionary[@"availableDocks"]) {
        self.availableDocks = dictionary[@"availableDocks"];
    }
    
    if(dictionary[@"latitude"]) {
        self.latitude = dictionary[@"latitude"];
    }
    
    if(dictionary[@"longitude"]) {
        self.longitude = dictionary[@"longitude"];
    }
    
    if(dictionary[@"id"]) {
        self.remoteID = dictionary[@"id"];
    }
    
    if(dictionary[@"stationName"]) {
        self.stationName = dictionary[@"stationName"];
    }
}

- (NSString *)convertDistanceToString {
    int kilometers = [self.distance doubleValue] / 1000;
    
    if(kilometers == 0) {
        return [NSString stringWithFormat:@"%d m", (int)[self.distance doubleValue]];
    }
    else {
        return [NSString stringWithFormat:@"%d km", kilometers];
    }
}

@end
