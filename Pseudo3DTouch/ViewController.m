//
//  ViewController.m
//  Pseudo3DTouch
//
//  Created by Adam Bell on 9/13/15.
//  Copyright © 2015 Adam Bell. All rights reserved.
//

#import "ViewController.h"

#import <pop/POP.h>

#import "PDPseudo3DTouchGestureRecognizer.h"

static const CGFloat kCircleDiameter = 220.0;

static const CGFloat kCircleScaleDampener = 0.6;
static const CGFloat kCircleScaleDampenerDelta = 0.2;

static NSString *const kDepthSpringAnimationKey = @"kDepthSpringAnimationKey";

@interface ViewController ()

@end

@implementation ViewController {
  PDPseudo3DTouchGestureRecognizer *_3DTouchGestureRecognizer;
  
  UIView *_circleView;
  
  POPSpringAnimation *_depthSpringAnimation;
  
  BOOL _playedTaptics;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Create our demo circle to force-touch.
  _circleView = [[UIView alloc] initWithFrame:CGRectZero];
  _circleView.backgroundColor = [UIColor purpleColor];
  [self.view addSubview:_circleView];
  
  // Create our 3D touch gesture recognizer and attach it to the circle view.
  _3DTouchGestureRecognizer = [[PDPseudo3DTouchGestureRecognizer alloc] initWithTarget:self action:@selector(_handle3DTouchGestureRecognizer:)];
  [_circleView addGestureRecognizer:_3DTouchGestureRecognizer];
  
  // Setup a simple spring animation to make the circle look as if it's bouncing.
  _depthSpringAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
  _depthSpringAnimation.removedOnCompletion = NO;
  _depthSpringAnimation.fromValue = [NSValue valueWithCGPoint:POPLayerGetScaleXY(_circleView.layer)];
  [_circleView.layer pop_addAnimation:_depthSpringAnimation forKey:kDepthSpringAnimationKey];
}

#pragma mark - Layout
- (void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  
  CGRect bounds = self.view.bounds;
  
  _circleView.bounds = CGRectMake(0.0,
                                  0.0,
                                  kCircleDiameter,
                                  kCircleDiameter);
  _circleView.layer.position = CGPointMake(floor(CGRectGetMidX(bounds)), floor(CGRectGetMidY(bounds)));
  _circleView.layer.cornerRadius = floor(kCircleDiameter / 2.0);
}

#pragma mark - Gesture Recognizer Handling
- (void)_handle3DTouchGestureRecognizer:(PDPseudo3DTouchGestureRecognizer *)gestureRecognizer
{
  // Grab our depth, and scale it down to a sensible scale for the circle's transform.
  // Scales down by 40%.
  // Mostly magic numbers, but just creates a nicer scaling effect for the string.
  CGFloat depth = gestureRecognizer.depth;
  CGFloat scaleDelta = (1.0 - (fabs(1.0 - depth) * kCircleScaleDampenerDelta) - kCircleScaleDampenerDelta);
  
  CGPoint scale = CGPointMake(scaleDelta, scaleDelta);
    
  switch (gestureRecognizer.state) {
    case UIGestureRecognizerStateBegan: {
      _depthSpringAnimation.toValue = [NSValue valueWithCGPoint:scale];
      _playedTaptics = NO;
      break;
    }
    case UIGestureRecognizerStateChanged: {
      _depthSpringAnimation.toValue = [NSValue valueWithCGPoint:scale];
      
      // Only play taptics once.
      if (depth >= 1.2 && !_playedTaptics) {
        PDPseudo3DTouchPlayTap();
        _playedTaptics = YES;
      }
      break;
    }
    case UIGestureRecognizerStateEnded:
    case UIGestureRecognizerStateCancelled: {
      _depthSpringAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
      _playedTaptics = NO;
      break;
    }
      
    default:
      break;
  }
}

@end
