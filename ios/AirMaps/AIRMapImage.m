//
// Created by Hein Rutjes on 26/08/15.
// Copyright (c) 2016 ATO Gear. All rights reserved.
//

#import "AIRMapImage.h"
#import "UIView+React.h"
#import "RCTUtils.h"
#import "RCTImageLoader.h"

@implementation AIRMapImage {
    RCTImageLoaderCancellationBlock _reloadImageCancellationBlock;
    MKMapRect _mapRect;
}

- (void)setRegion:(MKCoordinateRegion)region {
    
    RCTLogInfo(@"- AIRMapImage setRegion");

    // If location is invalid, abort
    if (!CLLocationCoordinate2DIsValid(region.center)) {
        RCTLogInfo(@"- AIRMapImage setRegion #-1");
        return;
    }
    
    _region = region;
    
    // convert region to MKMapRect
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    _mapRect = MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
    
    RCTLogInfo(@"- AIRMapImage setRegion #2");

    self.renderer = [[AIRMapImageRenderer alloc] initWithOverlay:self region:self.region];
    [self update];
}

- (void)setSource:(NSString *)source
{
    RCTLogInfo(@"- AIRMapImage setSource");
    _source = source;
    
    if (_reloadImageCancellationBlock) {
        _reloadImageCancellationBlock();
        _reloadImageCancellationBlock = nil;
    }
    _reloadImageCancellationBlock = [_bridge.imageLoader loadImageWithURLRequest:[RCTConvert NSURLRequest:_source]
                                                                            size:self.bounds.size
                                                                           scale:RCTScreenScale()
                                                                         clipped:YES
                                                                      resizeMode:UIViewContentModeCenter
                                                                   progressBlock:nil
                                                                 completionBlock:^(NSError *error, UIImage *image) {
                                                                     if (error) {
                                                                         // TODO(lmr): do something with the error?
                                                                         NSLog(@"%@", error);
                                                                     }
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         RCTLogInfo(@"- AIRMapImage image loaded, image: %@", (image == nil) ? @NO : @YES);
                                                                         self.overlayImage = image;
                                                                         [self update];
                                                                     });
                                                                 }];
}

- (void) update
{
    RCTLogInfo(@"- AIRMapImage update...");
    if (!_renderer) return;
    if (!self.overlayImage) return;

    RCTLogInfo(@"- AIRMapImage update #1");
    _renderer.overlayImage = self.overlayImage;
    
    if (_map == nil) return;
    [_map removeOverlay:self];
    [_map addOverlay:self];

    RCTLogInfo(@"- AIRMapImage update #2");
}


#pragma mark MKOverlay implementation

- (CLLocationCoordinate2D) coordinate
{
    return self.region.center;
}

- (MKMapRect) boundingMapRect
{
    return _mapRect;
}

- (BOOL)intersectsMapRect:(MKMapRect)mapRect
{
    return MKMapRectIntersectsRect(_mapRect, mapRect);
}

- (BOOL)canReplaceMapContent
{
    return NO;
}

@end