//
//  GradientPolylineRenderer.m
//  mapDemo
//
//  Created by bravo on 13-11-21.
//  Copyright (c) 2013年 bravo. All rights reserved.
//

#import "AIRMapGradientPolylineRenderer.h"
#import <pthread.h>

/*#define V_MAX 5.0
#define V_MIN 2.0
#define H_MAX 0.3
#define H_MIN 0.03*/

@implementation AIRMapGradientPolylineRenderer {
    //float* hues;
    pthread_rwlock_t rwLock;
    MKPolyline* polyline;
}

@synthesize strokeColors;

-(id)initWithOverlay:(id<MKOverlay>)overlay polyline:(MKPolyline*)polyline1
{
    self = [super initWithOverlay:overlay];
    if (self){
        pthread_rwlock_init(&rwLock,NULL);
        polyline = polyline1;
        //float *velocity = polyline.velocity;
        //int count = (int)polyline.pointCount;
        //[self velocity:velocity ToHue:&hues count:count];
        [self createPath];
    }
    return self;
}

/**
 *  Convert velocity to Hue using specific formular.
 *
 *  H(v) = Hmax, (v > Vmax)
 *       = Hmin + ((v-Vmin)*(Hmax-Hmin))/(Vmax-Vmin), (Vmin <= v <= Vmax)
 *       = Hmin, (v < Vmin)
 *
 *  @param velocity Velocity list.
 *  @param count    count of velocity list.
 *
 *  @return An array of hues mapping each velocity.
 */
/*-(void) velocity:(float*)velocity ToHue:(float**)_hue count:(int)count{
    *_hue = malloc(sizeof(float)*count);
    for (int i=0;i<count;i++){
        float curVelo = velocity[i];
        curVelo = ((curVelo < V_MIN) ? V_MIN : (curVelo  > V_MAX) ? V_MAX : curVelo);
        (*_hue)[i] = H_MIN + ((curVelo-V_MIN)*(H_MAX-H_MIN))/(V_MAX-V_MIN);
    }
}*/

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
}

//-(BOOL)canDrawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale{
//    CGRect pointsRect = CGPathGetBoundingBox(self.path);
//    CGRect mapRectCG = [self rectForMapRect:mapRect];
//    return CGRectIntersectsRect(pointsRect, mapRectCG);
//}


-(void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context
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

}
@end
