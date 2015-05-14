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

#pragma mark Init

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
        
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}

#pragma mark Public

- (void)didGetSelected
{
    for (UIView *v in self.subviews){
        
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationCurveLinear
                         animations:^{
                             v.transform = CGAffineTransformMakeScale(2.2, 2.2);
                         }completion:^(BOOL finished){
                             [UIView animateWithDuration:0.15
                                                   delay:0.0
                                                 options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationCurveLinear
                                              animations:^{
                                                  v.transform = CGAffineTransformIdentity;
                                              }completion:^(BOOL finished){
                                                  v.transform = CGAffineTransformIdentity;
                                              }];
                         }];
        
    }
}

#pragma mark Internal

- (NSString *)identifier
{
    if (!_identifier){
        if (self.label){
            return self.label.text;
        }
    }
    
    return _identifier;
}

- (UILabel *)label
{
    if (!_label){
        
        _label = [[UILabel alloc] init];
        
        _label.userInteractionEnabled = NO;
        
        [_label addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
        [_label addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:nil];
        
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor whiteColor];
        _label.alpha = 0.8;
        
        //[self.contentView addSubview:_label];
        [self addSubview:_label];
        
    }
    
    return _label;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.label){
        //keep our label centered
        [self.label sizeToFit];
        self.label.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
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

- (void)dealloc
{
    [_label removeObserver:self forKeyPath:@"text"];
    [_label removeObserver:self forKeyPath:@"font"];
}

@end




