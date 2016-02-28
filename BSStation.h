//
//  BSStation.h
//  BikeShare
//
//  Created by Anthony Ng on 2016-02-20.
//  Copyright © 2016 Anthony Ng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface BSStation : NSManagedObject

- (void)unpackDictionary:(NSDictionary *)dictionary;
- (NSString *)convertDistanceToString;

@end

NS_ASSUME_NONNULL_END

#import "BSStation+CoreDataProperties.h"
