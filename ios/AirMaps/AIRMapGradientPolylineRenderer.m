//
//  GradientPolylineRenderer.m
//  mapDemo
//
//  Created by bravo on 13-11-21.
//  Copyright (c) 2013年 bravo. All rights reserved.
//

#import "AIRMapGradientPolylineRenderer.h"
#import <pthread.h>


@interface AIRMapGradientPolylineRendererSegment : NSObject
@property UIColor *color;
@property CGPathRef path;
@end
@implementation AIRMapGradientPolylineRendererSegment
@synthesize color;
@synthesize path;
@end


@implementation AIRMapGradientPolylineRenderer {
    NSMutableArray* segments;
    MKPolyline* polyline;
    NSArray<UIColor *> *_strokeColors;
}

@synthesize strokeColors;

-(id)initWithOverlay:(id<MKOverlay>)overlay polyline:(MKPolyline*)polyline1
{
    self = [super initWithOverlay:overlay];
    if (self){
        polyline = polyline1;
        [self createPath];
        [self createSegments];
    }
    return self;
}

-(void) createPath{
    CGMutablePathRef path = CGPathCreateMutable();
    BOOL first = YES;
    for (NSUInteger i = 0, n = polyline.pointCount; i < n; i++){
        CGPoint point = [self pointForMapPoint:polyline.points[i]];
        if (first) {
            CGPathMoveToPoint(path, nil, point.x, point.y);
            first = NO;
        } else {
            CGPathAddLineToPoint(path, nil, point.x, point.y);
        }
    }
    self.path = path;
}

-(void) createSegments {
    segments = [NSMutableArray new];
    if (_strokeColors == nil) return;
    AIRMapGradientPolylineRendererSegment* segment = nil;
    for (NSUInteger i = 0, n = polyline.pointCount; i < n; i++){
        CGPoint point = [self pointForMapPoint:polyline.points[i]];
        UIColor* color = _strokeColors[i];
        if ((segment == nil) || ![segment.color isEqual:color]) {
            if (segment != nil) {
                CGPathAddLineToPoint(segment.path, nil, point.x, point.y);
            }
            segment = [AIRMapGradientPolylineRendererSegment new];
            segment.path = CGPathCreateMutable();
            segment.color = color;
            [segments addObject:segment];
            CGPathMoveToPoint(segment.path, nil, point.x, point.y);
        } else {
            CGPathAddLineToPoint(segment.path, nil, point.x, point.y);
        }
    }
}

- (void)setStrokeColors:(NSArray<UIColor *> *)strokeColors {
    _strokeColors = strokeColors;
    [self createSegments];
}

-(void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{    
    CGRect pointsRect = CGPathGetBoundingBox(self.path);
    CGRect mapRectCG = [self rectForMapRect:mapRect];
    if (!CGRectIntersectsRect(pointsRect, mapRectCG))return;

    CGContextSetLineWidth(context, self.lineWidth / zoomScale);
    CGContextSetLineCap(context, self.lineCap);
    CGContextSetLineJoin(context, self.lineJoin);
    CGContextSetMiterLimit(context, self.miterLimit);
    CGFloat dashes[self.lineDashPattern.count];
    for (NSUInteger i = 0; i < self.lineDashPattern.count; i++) {
        dashes[i] = self.lineDashPattern[i].floatValue;
    }
    CGContextSetLineDash(context, self.lineDashPhase, dashes, self.lineDashPattern.count);

    for (NSUInteger i = 0, n = segments.count; i < n; i++) {
        AIRMapGradientPolylineRendererSegment* segment = segments[i];
        CGContextSaveGState(context);
        CGContextAddPath(context, segment.path);
        CGContextSetStrokeColorWithColor(context, segment.color.CGColor);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
}

/*
-(void) createPath{
    CGMutablePathRef path = CGPathCreateMutable();
    BOOL pathIsEmpty = YES;
    for (NSUInteger i = 0, n = polyline.pointCount;i < n; i++){
        CGPoint point = [self pointForMapPoint:polyline.points[i]];
        if (pathIsEmpty){
            CGPathMoveToPoint(path, nil, point.x, point.y);
            pathIsEmpty = NO;
        } else {
            CGPathAddLineToPoint(path, nil, point.x, point.y);
        }
    }
    
    pthread_rwlock_wrlock(&rwLock);
    self.path = path; //<—— don't forget this line.
    pthread_rwlock_unlock(&rwLock);
}*/

//-(BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale{
//    CGRect pointsRect = CGPathGetBoundingBox(self.path);
//    CGRect mapRectCG = [self rectForMapRect:mapRect];
//    return CGRectIntersectsRect(pointsRect, mapRectCG);
//}


/*-(void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
{    
    CGRect pointsRect = CGPathGetBoundingBox(self.path);
    CGRect mapRectCG = [self rectForMapRect:mapRect];
    if (!CGRectIntersectsRect(pointsRect, mapRectCG))return;

    UIColor* pcolor,*ccolor;
    for (NSUInteger i = 0, n = polyline.pointCount; i < n; i++){
        CGPoint point = [self pointForMapPoint:polyline.points[i]];
        CGMutablePathRef path = CGPathCreateMutable();
        ccolor = strokeColors[i];
        if (i == 0){
            CGPathMoveToPoint(path, nil, point.x, point.y);
        } else {
            CGPoint prevPoint = [self pointForMapPoint:polyline.points[i - 1]];
            CGPathMoveToPoint(path, nil, prevPoint.x, prevPoint.y);
            CGPathAddLineToPoint(path, nil, point.x, point.y);
            
            CGFloat pc_r,pc_g,pc_b,pc_a,
                    cc_r,cc_g,cc_b,cc_a;
            
            [pcolor getRed:&pc_r green:&pc_g blue:&pc_b alpha:&pc_a];
            [ccolor getRed:&cc_r green:&cc_g blue:&cc_b alpha:&cc_a];
            
            CGFloat gradientColors[8] = {pc_r,pc_g,pc_b,pc_a,
                                        cc_r,cc_g,cc_b,cc_a};
            
            CGFloat gradientLocation[2] = {0,1};
            CGContextSaveGState(context);
            //CGFloat lineWidth = CGContextConvertSizeToUserSpace(context, (CGSize){self.lineWidth,self.lineWidth}).width;
            CGFloat lineWidth = self.lineWidth / zoomScale;
            CGPathRef pathToFill = CGPathCreateCopyByStrokingPath(path, NULL, lineWidth, self.lineCap, self.lineJoin, self.miterLimit);
            CGContextAddPath(context, pathToFill);
            CGContextClip(context);
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradientColors, gradientLocation, 2);
            CGColorSpaceRelease(colorSpace);
            CGPoint gradientStart = prevPoint;
            CGPoint gradientEnd = point;
            CGContextDrawLinearGradient(context, gradient, gradientStart, gradientEnd, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            CGContextRestoreGState(context);
        }
        pcolor = [UIColor colorWithCGColor:ccolor.CGColor];
    }
}*/


@end
