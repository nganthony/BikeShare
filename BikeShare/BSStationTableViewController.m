//
//  BSStationTableViewController.m
//  BikeShare
//
//  Created by Anthony Ng on 2016-02-17.
//  Copyright © 2016 Anthony Ng. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "BSStationTableViewController.h"
#import "BSRequestManager.h"
#import "BSStationTableViewCell.h"
#import "BSStation.h"
#import "BSMapViewController.h"
#import "StationInfoView.h"
@import GoogleMaps;

@interface BSStationTableViewController () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, GMSMapViewDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) BSStation *selectedStation;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *pricingView;
@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) BOOL animatedToCurrentPosition;

@end

@implementation BSStationTableViewController {
    StationInfoView *stationInfoView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize table view
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // Initialize Google maps
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.delegate = self;
    
    // Initialize Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BSStation"];
    
    // Add Sort Descriptors
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES]]];
    
    // Initialize Fetched Results Controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    // Configure Fetched Results Controller
    [self.fetchedResultsController setDelegate:self];
    
    // Add refresh button to navigation bar
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];    
    self.navigationItem.rightBarButtonItem = refreshButton;
    
    [self getAllStations];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Register observer for current location
    [self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context: nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove observer for current location
    [self.mapView removeObserver:self forKeyPath:@"myLocation"];
}

// Gets all bike stations from API
- (void)getAllStations {
    self.activityIndicator.hidden = NO;
    
    [[BSRequestManager sharedManager] getAllStations:^(id responseObject) {
        // Display fields in table
        NSError *error = nil;
        [self.fetchedResultsController performFetch:&error];
        
        if (error) {
            NSLog(@"Unable to perform fetch.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        }
        else {
            NSArray *allStations = [_fetchedResultsController fetchedObjects];
            
            // Clear the map of old markers
            [self.mapView clear];
            
            // Add station markers to map
            for(BSStation *station in allStations) {
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake([[station latitude] doubleValue], [[station longitude] doubleValue]);
                marker.title = [station stationName];
                marker.map = self.mapView;
                marker.userData = station;
            }
            
            [self updateStationDistance];

            [self.tableView reloadData];
        }
        
        self.activityIndicator.hidden = YES;
        
    } failure:^(NSError *error) {
        self.activityIndicator.hidden = YES;
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(BSStationTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BSStation *station = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.stationNameLabel.text = [station stationName];
    cell.bikeLabel.text = [[station availableBikes] stringValue];
    cell.dockLabel.text = [[station availableDocks] stringValue];
    cell.distanceLabel.text = [station convertDistanceToString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSStationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BSStationTableViewCell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedStation = [_fetchedResultsController objectAtIndexPath:indexPath];

    // Perform Segue
    [self performSegueWithIdentifier:@"BSMapViewController" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[BSMapViewController class]]) {
        // Configure Book Cover View Controller
        [(BSMapViewController *)segue.destinationViewController setStation:self.selectedStation];
    }
}


#pragma mark - NSFetchedResultsController delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:(BSStationTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - IBAction methods

// Segmented control value change handler
- (IBAction)segmentValueChanged:(id)sender {
    UISegmentedControl *segmentedControl = sender;
    
    switch (segmentedControl.selectedSegmentIndex) {
        // Stations
        case 0:
            self.tableView.hidden = NO;
            self.mapView.hidden = YES;
            self.pricingView.hidden = YES;
            
            if(stationInfoView) {
                [stationInfoView setHidden: YES];
            }
            break;
            
        // Map
        case 1:
            self.tableView.hidden = YES;
            self.mapView.hidden = NO;
            self.pricingView.hidden = YES;
            
            if(stationInfoView) {
                [stationInfoView setHidden: NO];
            }
            break;
            
        // Pricing
        case 2:
            self.tableView.hidden = YES;
            self.mapView.hidden = YES;
            self.pricingView.hidden = NO;
            
            if(stationInfoView) {
                [stationInfoView setHidden: YES];
            }
            break;
        default:
            break;
    }
}

// Handler for refresh button
- (void) refresh:(id)sender
{
    [self getAllStations];
}

#pragma mark - Google maps methods

// Observer for Google maps
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]])
    {
        if(![self animatedToCurrentPosition]) {
            [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:self.mapView.myLocation.coordinate.latitude
                                                                              longitude:self.mapView.myLocation.coordinate.longitude
                                                                                   zoom:15]];
            
            // Only animate to current position once
            self.animatedToCurrentPosition = YES;
        }
        
        [self updateStationDistance];
        [self.tableView reloadData];
    }
}

// Updates the user's distance to all stations
- (void) updateStationDistance {
    NSArray *stations = [_fetchedResultsController fetchedObjects];
    
    for(BSStation *station in stations) {
        // Calculate distance between station location and user's current location
        CLLocation *stationLocation =[[CLLocation alloc] initWithLatitude:[[station latitude] doubleValue] longitude:[[station longitude] doubleValue]];
        CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:self.mapView.myLocation.coordinate.latitude longitude:self.mapView.myLocation.coordinate.longitude];
        station.distance = [NSNumber numberWithDouble:[stationLocation distanceFromLocation:currentLocation]];
    }
}

// Move map camera to current position
- (void) animateToCurrentPosition {
    [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:self.mapView.myLocation.coordinate.latitude
                                                                      longitude:self.mapView.myLocation.coordinate.longitude
                                                                           zoom:15]];
}


// Marker map click delegate method
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    // Remove the existing info view
    if(stationInfoView) {
        [UIView animateWithDuration:0.3
                              delay:0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             stationInfoView.frame = CGRectMake(0, - (self.view.frame.size.height / 8), self.view.frame.size.width, self.view.frame.size.height / 8);
                         }
                         completion:^(BOOL finished){
                             [stationInfoView removeFromSuperview];
                             [self addStationInfoView:marker.userData];
                         }];
    }
    else {
        [self addStationInfoView:marker.userData];
    }
    
    return NO;
}

// Adds station info view to map view when a marker is clicked
- (void) addStationInfoView:(BSStation *)station {
    stationInfoView = [[[NSBundle mainBundle] loadNibNamed:@"StationInfoView"
                                                     owner:self
                                                   options:nil]
                       objectAtIndex:0];
    
    stationInfoView.frame = CGRectMake(0, - (self.view.frame.size.height / 8), self.view.frame.size.width, self.view.frame.size.height / 8);
    
    stationInfoView.bikes.text = [station.availableBikes stringValue];
    stationInfoView.docks.text = [station.availableDocks stringValue];
    stationInfoView.distance.text = [station convertDistanceToString];
    
    // Animate view to drop down from navigation bar
    [UIView animateWithDuration:0.3
                          delay:0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         stationInfoView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 8);
                     }
                     completion:^(BOOL finished){
                     }];
    
    [self.view addSubview:stationInfoView];
}

@end
