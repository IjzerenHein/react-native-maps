/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AIRMapImageManager.h"

#import "RCTBridge.h"
#import "RCTConvert.h"
#import "RCTConvert+CoreLocation.h"
#import "RCTConvert+MoreMapKit.h"
#import "RCTEventDispatcher.h"
#import "UIView+React.h"
#import "AIRMapMarker.h"
#import "RCTViewManager.h"
#import "AIRMapImage.h"

@interface AIRMapImageManager()

@end

@implementation AIRMapImageManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    AIRMapImage *image = [AIRMapImage new];
    image.bridge = self.bridge;
    return image;
}

RCT_EXPORT_VIEW_PROPERTY(region, MKCoordinateRegion)
RCT_EXPORT_VIEW_PROPERTY(source, NSString)

// NOTE(lmr):
// for now, onPress events for overlays will be left unimplemented. Seems it is possible with some work, but
// it is difficult to achieve in both ios and android so I decided to leave it out.
//RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)

@end
