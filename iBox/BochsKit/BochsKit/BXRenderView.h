//
//  BXRenderView.h
//  BochsKit
//
//  Created by Alsey Coleman Miller on 11/8/14.
//  Copyright (c) 2014 Bochs. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface BXRenderView : UIView
{
    CGSize sz;
    int* imageData;
    CGContextRef imageContext;
}

+ (id)sharedInstance;

- (void)addToWindow:(UIWindow*)window;

- (int*)imageData;
- (CGContextRef)imageContext;
- (void)recreateImageContextWithX:(int)x y:(int)y bpp:(int)bpp;

@end