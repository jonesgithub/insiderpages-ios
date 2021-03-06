//
//  IPIProviderViewHeader.m
//  InsiderPages for iOS
//
//  Created by Truman, Christopher on 8/10/12.
//  Copyright (c) 2012 InsiderPages. All rights reserved.
//
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0] 

#import "IPIProviderMapCarouselView.h"

@implementation IPIProviderMapCarouselView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 4;
        self.clipsToBounds = YES;
        
        self.mapView = [[MKMapView alloc] initWithFrame:frame];
        [self addSubview:self.mapView];
        
        CGRect overlayFrame = frame;
        overlayFrame.size.height = overlayFrame.size.height * .47;
        overlayFrame.origin.x = 0;
        overlayFrame.origin.y = frame.size.height - overlayFrame.size.height;
        self.overlayView = [[UIView alloc] initWithFrame:overlayFrame];
        self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.alpha = 0.6;
        [self addSubview:self.overlayView];
        
        CGRect nameLabelFrame = overlayFrame;
        nameLabelFrame.size.height = nameLabelFrame.size.height * .50;
        nameLabelFrame.origin.x = 10;
        
        self.nameLabel = [[UILabel alloc] initWithFrame:nameLabelFrame];
        self.nameLabel.textColor = [UIColor whiteColor];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.nameLabel];
    }

    return self;
}

-(void)setProvider:(IPKProvider *)provider{
    _provider = provider;
    [self.nameLabel setText:provider.full_name];
    MKPointAnnotation * point = [[MKPointAnnotation alloc] init];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.provider.address.lat doubleValue], [self.provider.address.lng doubleValue]);
    [point setCoordinate:coordinate];
    [self.mapView addAnnotation:point];
    
    MKMapRect mapRect = MKMapRectMake(coordinate.latitude, coordinate.longitude, 100, 100);
    [self.mapView setVisibleMapRect:mapRect animated:YES];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([self.provider.address.lat doubleValue], [self.provider.address.lng doubleValue]) animated:YES];
}

-(void)dealloc{
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
