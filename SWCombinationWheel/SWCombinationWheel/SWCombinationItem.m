//
//  SWCombinationItem.m
//  SWCombinationWheel
//
//  Created by Pat Sluth on 2015-04-04.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWCombinationItem.h"





@interface SWCombinationItem()
{
}

@end





@implementation SWCombinationItem

- (id)init
{
    self = [self initWithEffect:nil];
    return self;
}

- (id)initWithEffect:(UIVisualEffect *)effect
{
    //self = [super initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]]];
    self = [super init];
    
    if (self){
        
        self.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}

- (void)didGetSelected
{
    UIControl *x;
    [x sendActionsForControlEvents:UIControlEventTouchDown];
    [x sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    
    CGAffineTransform originalTransform = CGAffineTransformIdentity;
    CGFloat angle = atan2f(self.transform.b, self.transform.a);
    originalTransform = CGAffineTransformRotate(originalTransform, angle);
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.transform = CGAffineTransformScale(originalTransform, 2.2, 2.2);
                     }completion:^(BOOL finished){
                         [UIView animateWithDuration:0.2
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveLinear
                                          animations:^{
                                              self.transform = originalTransform;
                                          }completion:^(BOOL finished){
                                              self.transform = originalTransform;
                                          }];
                     }];
}

- (UILabel *)label
{
    if (!_label){
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor whiteColor];
        _label.alpha = 0.8;
        
        //[self.contentView addSubview:_label];
        [self addSubview:_label];
        
    }
    
    return _label;
}

- (UIImageView *)image
{
    if (!_image){
        
        _image = [[UIImageView alloc] init];
        
        _image.contentMode = UIViewContentModeScaleAspectFit;
        _image.clipsToBounds = YES;
        _image.userInteractionEnabled = NO;
        _image.translatesAutoresizingMaskIntoConstraints = NO;
        _image.backgroundColor = [UIColor clearColor];
        
         [self addSubview:_image];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_image
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_image
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_image
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_image
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0.0]];
        
        [self layoutIfNeeded];
        
    }
    
    return _image;
}

@end




