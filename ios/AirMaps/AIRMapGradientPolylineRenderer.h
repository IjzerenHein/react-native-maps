//
//  GradientPolylineRenderer.h
//  mapDemo
//
//  Created by bravo on 13-11-21.
//  Copyright (c) 2013年 bravo. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface AIRMapGradientPolylineRenderer : MKOverlayPathRenderer

-(id)initWithOverlay:(id<MKOverlay>)overlay polyline:(MKPolyline*)polyline;

@property (nonatomic, strong) NSArray<UIColor *> *strokeColors;

@end
