//
// Created by Hein Rutjes on 26/08/15.
// Copyright (c) 2016 ATO Gear. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface AIRMapImageRenderer : MKOverlayPathRenderer

-(id)initWithOverlay:(id<MKOverlay>)overlay region:(MKCoordinateRegion)region;

@property (nonatomic, strong) UIImage *overlayImage;

@end
