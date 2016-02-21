//
//  BSMapViewController.m
//  BikeShare
//
//  Created by Anthony Ng on 2016-02-20.
//  Copyright © 2016 Anthony Ng. All rights reserved.
//

#import "BSMapViewController.h"
@import GoogleMaps;

@interface BSMapViewController ()

@end

@implementation BSMapViewController {
    GMSMapView *mapView_;
}

@synthesize station;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[station latitude] doubleValue]
                                                            longitude:[[station longitude] doubleValue]
                                                                 zoom:15];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;

    self.view = mapView_;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([[station latitude] doubleValue], [[station longitude] doubleValue]);
    marker.title = [station stationName];
    marker.map = mapView_;
}

@end
