//
//  PDPseudo3DTouchGestureRecognizer.m
//  Pseudo3DTouch
//
//  Created by Adam Bell on 9/13/15.
//  Copyright © 2015 Adam Bell. All rights reserved.
//

#import "PDPseudo3DTouchGestureRecognizer.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

// This isn't a pan gesture, so this defines the max translation allowed.
static CGFloat const kMaxTouchTranslationAllowed = 50.0;

#if TARGET_IPHONE_SIMULATOR
#else
// 1.0 is basically the same as 1.1; not a lot of force is applied.
static CGFloat const kDepthCalculationFudgeFactor = 0.1;
#endif

#pragma mark - Taptics
extern int AudioServicesPlaySystemSoundWithVibration(int, id obj, NSDictionary *dictionary);

//! @abstract Plays a tiny small vibration alluding to Taptic Feedback.
void PDPseudo3DTouchPlayTap() {
  NSArray *vibrationPattern = @[
                                @YES,  // YES to vibrate
                                @50,   // 50ms
                                 ];
  
  NSDictionary *dictionary = @{
                         @"Intensity" : @1.0,
                         @"VibePattern" : vibrationPattern,
                         };
  
  // 0xFFF magic number for silence or no sound.
  AudioServicesPlaySystemSoundWithVibration(0xFFF, nil, dictionary);
}

@implementation PDPseudo3DTouchGestureRecognizer {
  CGFloat _touchRadius;
  
  CGFloat _initialTouchRadius;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesBegan:touches withEvent:event];
  
  // Only work with one touch. Doesn't make sense with more than one.
  if (touches.count > 1) {
    self.state = UIGestureRecognizerStateFailed;
  } else {
    UITouch *touch = [touches anyObject];
    _touchRadius = touch.majorRadius;
    
    // Grabs the initial touch radius as a starting point.
    _initialTouchRadius = _touchRadius;
    
    [self _beginObservingTouchMajorRadius:touch];
    
    self.state = UIGestureRecognizerStateBegan;
  }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesMoved:touches withEvent:event];
  
  UITouch *touch = [touches anyObject];
  
  CGPoint touchLocation = [touch locationInView:self.view];
  
  // Ignore any sort of movement with the finger... this isn't a pan gesture.
  if ((fabs(touchLocation.x) > kMaxTouchTranslationAllowed) ||
      (fabs(touchLocation.y) > kMaxTouchTranslationAllowed)) {
    self.state = UIGestureRecognizerStateFailed;
    [self _endObservingTouchMajorRadius:touch];
  }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesCancelled:touches withEvent:event];
  
  UITouch *touch = [touches anyObject];
  [self _endObservingTouchMajorRadius:touch];
  
  _touchRadius = _initialTouchRadius;
  
  self.state = UIGestureRecognizerStateCancelled;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
  [super touchesEnded:touches withEvent:event];
  
  UITouch *touch = [touches anyObject];
  [self _endObservingTouchMajorRadius:touch];
  
  _touchRadius = _initialTouchRadius;
  
  self.state = UIGestureRecognizerStateEnded;
}

#pragma mark - 3D Touch Observing
- (void)_beginObservingTouchMajorRadius:(UITouch *)touch {
  // Observe UITouch -majorRadius changes.
  [touch addObserver:self
          forKeyPath:NSStringFromSelector(@selector(majorRadius))
             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
             context:NULL];
}

- (void)_endObservingTouchMajorRadius:(UITouch *)touch {
  // yolo don't care
  @try {
    [touch removeObserver:self
               forKeyPath:NSStringFromSelector(@selector(majorRadius))
                  context:NULL];
  } @catch (NSException *e) { }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
  // Anytime -majorRadius changes, indicate that the gesture's state has changed.
  if ([keyPath isEqualToString:NSStringFromSelector(@selector(majorRadius))]) {
    self.state = UIGestureRecognizerStateChanged;
    _touchRadius = [(UITouch *)object majorRadius];    
  }
}

#pragma mark - Getters / Setters
- (CGFloat)depth
{
  // Hardcodes depth on iPhone Simulator 1.25.
  CGFloat depth = 1.0;
#if TARGET_IPHONE_SIMULATOR
  if (self.state == UIGestureRecognizerStateChanged) {
    depth += 0.25;
  }
#else
  // Converts the delta between the initial touch radius and the current one to a useable depth property.
  depth = MAX(depth, (_touchRadius / _initialTouchRadius));
  if ((depth - 1.0) <= kDepthCalculationFudgeFactor) {
    depth = 1.0;
  }
#endif
  return depth;
}

@end
