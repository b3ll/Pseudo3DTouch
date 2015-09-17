//
//  PDPseudo3DTouchGestureRecognizer.h
//  Pseudo3DTouch
//
//  Created by Adam Bell on 9/13/15.
//  Copyright © 2015 Adam Bell. All rights reserved.
//

#import <UIKit/UIKit.h>

extern void PDPseudo3DTouchPlayTap();

@interface PDPseudo3DTouchGestureRecognizer : UIGestureRecognizer

/**
 @abstract Defines the amount the gesture has depressed into the screen from 1.0 to infinity. Larger means "deeper" into the screen.
 */
@property (nonatomic, readonly) CGFloat depth;

@end
