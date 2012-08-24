//
//  IPIProviderViewController.h
//  InsiderPages for iOS
//
//  Created by Christopher Truman.
//
#import <MapKit/MapKit.h>
#import "IPIBaseNoNavViewController.h"

@class IPKProvider;
@class IPIProviderViewHeader;

@interface IPIProviderViewController : IPIBaseNoNavViewController

@property (nonatomic, strong) IPKProvider *provider;
@property (nonatomic, strong) MKMapView * mapView;
@property (nonatomic, strong) IPIProviderViewHeader * headerView;

@end
