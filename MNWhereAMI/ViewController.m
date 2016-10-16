//
//  ViewController.m
//  MNWhereAMI
//
//  Created by Mrunalini on 12/10/16.
//  Copyright © 2016 Mrunalini Nemade. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self startLocating];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    
    longPress.minimumPressDuration = 2;
    
    [self.mapView addGestureRecognizer: longPress];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    
    CLLocationCoordinate2D pressedCoordinate;
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        
        CGPoint pressLoction = [gesture locationInView:gesture.view];
        
        pressedCoordinate = [self.mapView convertPoint:pressLoction toCoordinateFromView:gesture.view];
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
        
        annotation.coordinate = pressedCoordinate;
        
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        
        CLLocation *location = [[CLLocation alloc]initWithLatitude:pressedCoordinate.latitude longitude:pressedCoordinate.longitude];
        
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            if (error) {
                
                NSLog(@"%@",error.localizedDescription);
                
                annotation.title = @"Unknown Place";
                
                [self.mapView addAnnotation:annotation];
            }
            
            else {
                if (placemarks.count >0) {
                    CLPlacemark *placemark = placemarks.lastObject;
                    
                    NSString *title = [placemark.subThoroughfare stringByAppendingString:placemark.thoroughfare];
                    
                    NSString *subTitle = placemark.locality;
                    
                    annotation.title = title;
                    annotation.subtitle = subTitle;
                    [self.mapView addAnnotation:annotation];
                }
                else{
                    annotation.title = @"Unknown Place";
                    [self.mapView addAnnotation:annotation];
                }
            }
        }];
    }
        else if(gesture.state == UIGestureRecognizerStateEnded) {
            
        }
    }
    


-(void)startLocating {
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *currentLocation = [locations lastObject];
    
    _labelLatitude.text = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    _labelLongitude.text = [NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    _labelAltitude.text = [NSString stringWithFormat:@"%f",currentLocation.altitude];
    _labelSpeed.text = [NSString stringWithFormat:@"%f",currentLocation.speed];

    NSLog(@"Latitude : %f",currentLocation.coordinate.latitude);
    
    NSLog(@"Longitude : %f",currentLocation.coordinate.longitude);
    
    MKCoordinateSpan mySpan = MKCoordinateSpanMake(0.001, 0.001);
    
    MKCoordinateRegion myRegion = MKCoordinateRegionMake(currentLocation.coordinate, mySpan);
    
    [self.mapView setRegion:myRegion animated:YES];
    
    if (currentLocation != nil) {
        [locationManager stopUpdatingLocation];
    }
    
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"%@",error.localizedDescription);
}

- (IBAction)actionStartDetectingLocation:(id)sender {
    
    [self startLocating];
}

- (IBAction)changemapType:(id)sender {
    
    UISegmentedControl *segment = sender;
    
    if (segment.selectedSegmentIndex == 0) {
        [self.mapView setMapType:MKMapTypeStandard];
    }
    else if (segment.selectedSegmentIndex ==1){
        [self.mapView setMapType:MKMapTypeSatellite];
    }
    else if (segment.selectedSegmentIndex ==2){
        [self.mapView setMapType:MKMapTypeHybrid];
    }

    
}
@end
