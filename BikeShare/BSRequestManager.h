//
//  BSRequestManager.h
//  BikeShare
//
//  Created by Anthony Ng on 2016-02-17.
//  Copyright © 2016 Anthony Ng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSRequestManager : NSObject

typedef void (^SuccessBlock)(id responseObject);
typedef void (^FailureBlock)(NSError *error);

+ (BSRequestManager*)sharedManager;

- (void)getAllStations:(SuccessBlock)success failure:(FailureBlock)failure;

@end
