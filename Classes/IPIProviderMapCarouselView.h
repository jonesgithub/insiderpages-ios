//
//  IPIProviderMapCarouselView.h
//  InsiderPages for iOS
//
//  Created by Truman, Christopher on 8/10/12.
//  Copyright (c) 2012 InsiderPages. All rights reserved.
//
#import <MapKit/MapKit.h>

@interface IPIProviderMapCarouselView : UIView

@property (nonatomic, strong) MKMapView* mapView;
@property (nonatomic, strong) UIView * overlayView;
@property (nonatomic, strong) UILabel * nameLabel;

@property (nonatomic, strong) IPKProvider * provider;

@end
