//
//  BSRequestManager.m
//  BikeShare
//
//  Created by Anthony Ng on 2016-02-17.
//  Copyright © 2016 Anthony Ng. All rights reserved.
//

#import "BSRequestManager.h"
#import "AFNetworking.h"
#import "BSStation.h"
#import "AppDelegate.h"

@interface BSRequestManager ()

@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;

@end

@implementation BSRequestManager

static NSString *const BaseUrl = @"http://www.bikesharetoronto.com";

+ (BSRequestManager *)sharedManager {
    static BSRequestManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}


- (id)init {
    if (self = [super init]) {
        _httpSessionManager = [AFHTTPSessionManager manager];
        _httpSessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    }
    return self;
}

// Gets all bike stations in Toronto
- (void)getAllStations:(SuccessBlock)success failure:(FailureBlock)failure {
    NSString *url = [NSString stringWithFormat:@"%@/%s", BaseUrl, "stations/json"];
    
    [self.httpSessionManager GET:url
                      parameters:nil
                        progress:nil
                         success:^(NSURLSessionDataTask * task, NSDictionary *responseObject) {
                             NSArray *stations = responseObject[@"stationBeanList"];
                             
                             AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                             
                             __weak NSManagedObjectContext *context = app.managedObjectContext;
                             
                             [context performBlockAndWait:^{
                                 for(NSDictionary *station in stations) {
                                     NSFetchRequest *fetchRequest=[NSFetchRequest fetchRequestWithEntityName:@"BSStation"];
                                     NSPredicate *predicate=[NSPredicate predicateWithFormat:@"remoteID==%@",station[@"id"]];
                                     fetchRequest.predicate=predicate;
                                     
                                     // Check if core data object already exists
                                     BSStation *existingStationEntity = [[context executeFetchRequest:fetchRequest error:nil] lastObject];
                                     
                                     if(existingStationEntity) {
                                         // Update object
                                         [existingStationEntity unpackDictionary:station];
                                     }
                                     else {
                                         // Insert new object
                                         BSStation *stationEntity = [NSEntityDescription insertNewObjectForEntityForName:@"BSStation" inManagedObjectContext:context];
                                         
                                         [stationEntity unpackDictionary:station];
                                     }
                                 }
                                 
                                 [context save:nil];
                             }];
                             
                             success(responseObject);
                         }
                         failure:^(NSURLSessionDataTask *task, NSError *error) {
                             failure(error);
                         }
     ];
}

@end
