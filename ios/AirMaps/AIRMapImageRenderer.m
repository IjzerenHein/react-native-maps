//
// Created by Hein Rutjes on 26/08/15.
// Copyright (c) 2016 ATO Gear. All rights reserved.
//

#import "AIRMapImageRenderer.h"
#import "RCTLog.h"

@implementation AIRMapImageRenderer {
    MKCoordinateRegion region;
}

@synthesize overlayImage;

-(id)initWithOverlay:(id<MKOverlay>)overlay region:(MKCoordinateRegion)region1
{
    self = [super initWithOverlay:overlay];
    if (self){
        region = region1;
        RCTLogInfo(@"- AIRMapImageRenderer initWithOverlay");
    }
    return self;
}


// TODO
//-(BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale{
//    CGRect pointsRect = CGPathGetBoundingBox(self.path);
//    CGRect mapRectCG = [self rectForMapRect:mapRect];
//    return CGRectIntersectsRect(pointsRect, mapRectCG);
//}


-(void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{
    if (overlayImage == nil) return;

    CGRect theRect = [self rectForMapRect:self.overlay.boundingMapRect];
    
    RCTLogInfo(@"- AIRMapImageRenderer drawMapRect, zoomScale: %lf, theRect: %@", zoomScale, NSStringFromCGRect(theRect));

    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -theRect.size.height);
    CGContextDrawImage(context, theRect, overlayImage.CGImage);
}
@end
