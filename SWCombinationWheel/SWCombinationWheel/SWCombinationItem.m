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
    self = [super initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]]];
    
    if (self){
        
        self.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}

- (void)didGetSelected
{
    CGAffineTransform originalTransform = self.transform;
    
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveLinear | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.transform = CGAffineTransformScale(self.transform, 2.5, 2.5);
                     }completion:^(BOOL finished){
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveLinear
                                          animations:^{
                                              self.transform = CGAffineTransformScale(originalTransform, 1.0, 1.0);
                                          }completion:^(BOOL finished){
                                              self.transform = CGAffineTransformScale(originalTransform, 1.0, 1.0);
                                          }];
                     }];
}

- (UILabel *)label
{
    if (!_label){
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        
        _label.font = [UIFont boldSystemFontOfSize:27];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        _label.textColor = [UIColor whiteColor];
        
        [self.contentView addSubview:_label];
        
    }
    
    return _label;
}

@end




