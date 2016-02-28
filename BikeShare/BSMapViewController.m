//
//  BSMapViewController.m
//  BikeShare
//
//  Created by Anthony Ng on 2016-02-20.
//  Copyright © 2016 Anthony Ng. All rights reserved.
//

#import "BSMapViewController.h"
#import "StationInfoView.h"
@import GoogleMaps;

@interface BSMapViewController ()
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation BSMapViewController {
    StationInfoView *stationInfoView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Initialize map view
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[[self station] latitude] doubleValue]
                                                            longitude:[[[self station] longitude] doubleValue]
                                                                 zoom:15];
    
    [self mapView].camera = camera;
    [self mapView].myLocationEnabled = YES;
    [self mapView].settings.compassButton = YES;
    [self mapView].settings.myLocationButton = YES;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([[[self station] latitude] doubleValue], [[[self station] longitude] doubleValue]);
    marker.title = [[self station] stationName];
    marker.map = [self mapView];
    
    // Select the marker
    [self mapView].selectedMarker = marker;
    
    // Place info view as sub view
    stationInfoView = [[[NSBundle mainBundle] loadNibNamed:@"StationInfoView"
                                                                      owner:self
                                                                    options:nil]
                                        objectAtIndex:0];
    
    // Initialize view
    stationInfoView.bikes.text = [[self station].availableBikes stringValue];
    stationInfoView.docks.text = [[self station].availableDocks stringValue];
    stationInfoView.distance.text = [[self station] convertDistanceToString];
    
    [self.view addSubview:stationInfoView];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // Update station info view frame layout based on auto constraint sizes
    stationInfoView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 8);
}

@end
