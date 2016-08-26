//
// Created by Hein Rutjes on 26/08/15.
// Copyright (c) 2016 ATO Gear. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

#import "RCTConvert+MapKit.h"
#import "RCTComponent.h"
#import "AIRMapCoordinate.h"
#import "AIRMap.h"
#import "RCTView.h"
#import "RCTBridge.h"
#import "AIRMapImageRenderer.h"

@interface AIRMapImage: MKAnnotationView <MKOverlay>

@property (nonatomic, weak) AIRMap *map;
@property (nonatomic, weak) RCTBridge *bridge;

@property (nonatomic, strong) AIRMapImageRenderer *renderer;
@property (nonatomic, strong) UIImage *overlayImage;

@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, copy) NSString *source;

#pragma mark MKOverlay protocol

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, readonly) MKMapRect boundingMapRect;
- (BOOL)intersectsMapRect:(MKMapRect)mapRect;
- (BOOL)canReplaceMapContent;

@end