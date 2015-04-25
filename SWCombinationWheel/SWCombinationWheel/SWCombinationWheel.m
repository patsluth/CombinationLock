//
//  SWCombinationWheel.m
//  SWCombinationWheel
//
//  Created by Pat Sluth on 2015-04-04.12
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "SWCombinationWheel.h"
#import "SWCombinationItem.h"

#import "SWMLine.h"
#import "SWMCircle.h"
#import "SWMQuadratic.h"





@interface SWCombinationWheel()
{
}

@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

@property (readwrite, strong, nonatomic) UIView *wheel;
@property (readwrite, strong, nonatomic) UIView *backgroundView;

//NSArray of current SWCombinationItem items
@property (strong, nonatomic) NSArray *wheelCombinationItems;

//**************************************************
//Variables to keep track of rotation between frames
//**************************************************

@property (readwrite, nonatomic) CGFloat angleChangeSinceLastCombinationSelection;

@property (readwrite, nonatomic) CGFloat panStartAngleFromOrigin;

//these are updated at the end of every frame, so we can
//compare the differences the next frame

@property (readwrite, nonatomic) CGFloat panPreviousAngle;
@property (readwrite, nonatomic) NSDate *panPreviousAngleDate;
@property (readwrite, nonatomic) CGFloat wheelVelocity;

@property (strong, nonatomic) UIBezierPath *wheelMaskCachedIdentity;
@property (strong, nonatomic) UIBezierPath *wheelMaskCachedScaled;
@property (strong, nonatomic) UIBezierPath *wheelCutoutMaskCachedIdentity;
@property (strong, nonatomic) UIBezierPath *wheelCutoutMaskCachedScaled;

@end





@implementation SWCombinationWheel

#pragma mark -
#pragma mark Init

- (id)init
{
    self = [super init];
    
    if (self){
        
        self.clipsToBounds = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.wheel
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:0.0];
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.wheel
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:0.0];
        
        [self addConstraint:self.widthConstraint];
        [self addConstraint:self.heightConstraint];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        pan.delegate = self;
        [self addGestureRecognizer:pan];
        
        self.backgroundColor = [UIColor clearColor];
        
        if (self.wheel){}
        
        [self reset];
        
        self.needleAngle = M_PI_2;
        self.panPreviousAngle = self.needleAngle;
    }
    
    return self;
}

- (void)reset
{
    for (UIView *v in self.wheel.subviews){
        if ([v isKindOfClass:[SWCombinationItem class]]){
            [v removeFromSuperview];
        }
    }
    
    self.wheelCombinationItems = nil;
    [self.wheelCombinationSelection removeAllObjects];
    
    self.layer.mask = [CAShapeLayer layer];
    
    if (self.wheelCutoutView){
        self.wheelCutoutView.layer.mask = [CAShapeLayer layer];
    }
}

- (void)reloadData
{
    [self reset];
    
    if (self.backgroundView){
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if (self.dataSource){
        
        if (self.backgroundView){}
        
        CGSize needleSize = [self.dataSource sizeForCombinationNeedleView:self];
        
        //combination item setup
        NSUInteger numberOfItems = [self.dataSource numberOfCombinationItemsInCircumferenceWheel:self];
        NSMutableArray *tempItems = [NSMutableArray arrayWithCapacity:numberOfItems];
        
        for (NSUInteger i = 0; i < numberOfItems; i++){
            
            SWCombinationItem *item = [self.dataSource swCombinationWheel:self combinationItemForIndex:i];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
            [item addGestureRecognizer:tap];
            
            tempItems[i] = item;
            [self.wheel addSubview:item];
            
            CGFloat radius = CGRectGetMidX(self.bounds);
            CGPoint center = CGPointMake(radius, radius);
            
            CGFloat slice = [self angleSliceForItems:numberOfItems];
            CGFloat angle = -slice * i; //stupid ios does radians backwards :O
            
            //since we are setting the center of the view
            //this will align the top of the label to the outside of the circle
            //basically making a smaller circle, with a difference in radius of half the view height
            radius -= CGRectGetMidY(item.bounds) + needleSize.height;
            
            CGFloat x = center.x + radius * cos(angle);
            CGFloat y = center.y + radius * sin(angle);
            
            item.center = CGPointMake(x, y);
            
            item.transform = CGAffineTransformMakeRotation(angle + M_PI_2);
            
        }
        
        self.wheelCombinationItems = [tempItems copy];
        
        [self snapCombinationItemToNeedle:[self.wheelCombinationItems firstObject] animated:NO];
        
    }
    
    self.needleAngle = self.needleAngle;
}

#pragma mark -
#pragma mark Rotation

//allow interaction with views behind us
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (![self pointIsInTouchableArea:point]){ //outside the wheel view
        return nil;
    }
    
    return [super hitTest:point withEvent:event];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:gestureRecognizer.view];
    return [self pointIsInTouchableArea:location];
}

- (BOOL)pointIsInTouchableArea:(CGPoint)point
{
    if (self.wheelMaskCachedIdentity && ![self.wheelMaskCachedIdentity containsPoint:point]){
        return NO;
    }
    
    return YES;
}

- (void)pan:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateBegan){
        
        CGPoint panLocation = [pan locationInView:pan.view];
        
        //the angle of our first touch, + the current rotation of the wheel
        self.panStartAngleFromOrigin = [self angleFromCenter:panLocation] + atan2f(self.wheel.transform.b, self.wheel.transform.a);
        self.panPreviousAngle = [self angleFromCenter:panLocation];
        self.wheelVelocity = 0.0;
        self.angleChangeSinceLastCombinationSelection = 0.0;
        self.panPreviousAngleDate = [NSDate date];
        
    } else if (pan.state == UIGestureRecognizerStateEnded){
        
        [self wheelRotationDidChangeDirection];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(swCombinationWheel:didEnterCombination:)]){
            [self.delegate swCombinationWheel:self didEnterCombination:[self.wheelCombinationSelection copy]];
        }
        
        [self snapCombinationItemToNeedle:[self combinationItemClosestToAngle:self.needleAngle] animated:YES];
        
        [self.wheelCombinationSelection removeAllObjects];
        
        
    } else if (pan.state == UIGestureRecognizerStateChanged){
        
        CGPoint panLocation = [pan locationInView:pan.view];
        
        //if (![self pointIsInTouchableArea:panLocation]){
        //}
        
        CGFloat newAngle = [self angleFromCenter:panLocation];
        
        NSDate *now = [NSDate date];
        
        CGFloat deltaAngle = newAngle - self.panPreviousAngle;
        
        BOOL didCrossThreshhold = NO;
        
        if (fabs(deltaAngle) > (M_PI_2)){ //crossing the 0-2PI threshold can give us a big deltaAngle which messes up the deceleration
            deltaAngle = copysign(0.01, -deltaAngle); //preserve derection
            didCrossThreshhold = YES;
        }
        
        //angular velocity = change in angle / change in time
        CGFloat newWheelVelocity = deltaAngle / [now timeIntervalSinceDate:self.panPreviousAngleDate];
        
        if (!didCrossThreshhold){
            //our direction changed! fire event
            //wheel velocity at this point, will still be equal to the wheel velocity last frame
            //so we can compare the difference
            if (self.wheelVelocity != 0.0 &&
                ((self.wheelVelocity >= 0 && newWheelVelocity < 0) ||
                 (self.wheelVelocity < 0 && newWheelVelocity >= 0))){
                    [self wheelRotationDidChangeDirection];
                }
        }
        
        self.wheelVelocity = newWheelVelocity;
        
        self.panPreviousAngle = newAngle;
        self.panPreviousAngleDate = now;
        
        self.wheel.transform = CGAffineTransformMakeRotation(self.panStartAngleFromOrigin - newAngle);
        self.angleChangeSinceLastCombinationSelection += fabs(deltaAngle);
        
        SWCombinationItem *closest = [self combinationItemClosestToAngle:self.needleAngle];
        
        if ([self shouldSelectItem:closest]){
            [self growNeedleView:YES];
        } else {
            [self shrinkNeedleView:YES];
        }
    }
}

- (void)wheelRotationDidChangeDirection
{
    SWCombinationItem *closest = [self combinationItemClosestToAngle:self.needleAngle];
    
    if ([self shouldSelectItem:closest]){
        [self selectItem:closest];
    }
    
    self.angleChangeSinceLastCombinationSelection = 0.0;
}

#pragma mark -
#pragma mark SWCombinationItem

- (void)onTap:(UITapGestureRecognizer *)tap
{
    if ([tap.view isKindOfClass:[SWCombinationItem class]]){
        [self selectItem:(SWCombinationItem *)tap.view];
    }
}

- (BOOL)shouldSelectItem:(SWCombinationItem *)item
{
    //ensure we rotate at least N% of one item distance
    if (self.angleChangeSinceLastCombinationSelection >= 0.0 &&
        self.angleChangeSinceLastCombinationSelection < [self angleSliceForItems:self.wheelCombinationItems.count] * 0.6){
        return NO;
    }
    
    return [self combinationItemIsWithinSelectionThreshold:item];
}

- (void)selectItem:(SWCombinationItem *)item
{
    [self.wheelCombinationSelection addObject:item];
    
    [item didGetSelected];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(swCombinationWheel:didSelectCombinationItem:)]){
        [self.delegate swCombinationWheel:self didSelectCombinationItem:item];
        [self shrinkNeedleView:YES];
    }
}

- (BOOL)combinationItemIsWithinSelectionThreshold:(SWCombinationItem *)item
{
    CGFloat angle = [self angleFromCenter:[self convertPoint:item.center fromView:self.wheel]];
    CGFloat difference = fabs(angle - self.needleAngle);
    
    //we will make fake points with respect to the main view based on the combination item size
    //so it would be centered horizontally, and aligned to the top vertically
    //this will allow us to measure the angle of the top left and right corner from the center
    //so we can get the allowable angle difference we should use
    CGPoint topLeft = CGPointMake(CGRectGetMidX(self.bounds) - CGRectGetMidX(item.bounds), 0.0);
    CGPoint topRight = CGPointMake(CGRectGetMidX(self.bounds) + CGRectGetMidX(item.bounds), 0.0);
    
    CGFloat angleTopLeft = [self angleFromCenter:topLeft];
    CGFloat angleTopRight = [self angleFromCenter:topRight];
    
    CGFloat angleDifference = fabs(angleTopLeft - angleTopRight);
    //divide by two, because we are measuring the item angle difference from the center of the item
    CGFloat allowableDifference = angleDifference / 2.0;
    
    return (difference < allowableDifference);
}

- (CGFloat)angleFromCenter:(CGPoint)point
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    CGFloat angle = [self angleFromPoint:point toPoint:center];
    
    if (angle < 0){
        //TODO: check effect
        //angle += (2 * M_PI);
    }
    
    return angle;
}

- (CGFloat)angleFromPoint:(CGPoint)pointA toPoint:(CGPoint)pointB
{
    CGFloat run = pointA.x - pointB.x;
    CGFloat rise = pointB.y - pointA.y;
    
    CGFloat angle = atan2f(rise, run);
    
    return angle;
}

//angle must be between 0 and 2PI
- (SWCombinationItem *)combinationItemClosestToAngle:(CGFloat)angle
{
    SWCombinationItem *nearestCombinationItem = [self.wheelCombinationItems firstObject];
    
    CGFloat closestAngleDifference = CGFLOAT_MAX;
    
    for (SWCombinationItem *item in self.wheelCombinationItems){
        
        CGFloat itemAngle = [self angleFromCenter:[self convertPoint:item.center fromView:self.wheel]];
        
        if (fabs(angle - itemAngle) < closestAngleDifference){
            
            closestAngleDifference = fabs(angle - itemAngle);
            nearestCombinationItem = item;
            
        }
        
        //special conditions for objects that are crossing the 0 - 2pi threshhold
        if (angle <= 0.0 || angle >= (2 * M_PI)){
            if (fabs(angle - ((2 * M_PI) - itemAngle)) < closestAngleDifference){
                
                closestAngleDifference = fabs(angle - ((2 * M_PI) - itemAngle));
                nearestCombinationItem = item;
                
            }
        }
        
    }
    
#ifdef DEBUG
    //NSLog(@"Combination Item # closest to angle %f", [self.wheelCombinationItems indexOfObject:nearestCombinationItem], angle);
#endif
    
    return nearestCombinationItem;
}

#pragma mark -
#pragma mark Needle

- (void)snapCombinationItemToNeedle:(SWCombinationItem *)item animated:(BOOL)animated
{
    if (!item){
        return;
    }
    
    //if we set wheel rotation to this angle, then the item would be at 0 or 2PI
    CGFloat itemAngle = [self.wheelCombinationItems indexOfObject:item] * [self angleSliceForItems:self.wheelCombinationItems.count];
    //so to set it to the needle angle, we just need to subtract the needle angle from this variable
    
    CGFloat targetWheelAngle = itemAngle - self.needleAngle;
    
    if (animated){
        
        [UIView animateWithDuration:1.0
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:20
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.wheel.transform = CGAffineTransformMakeRotation(targetWheelAngle);
                         }
                         completion:nil];
        
    } else {
        self.wheel.transform = CGAffineTransformMakeRotation(targetWheelAngle);
    }
}

- (void)setNeedleAngle:(CGFloat)needleAngle
{
    if (needleAngle < 0.0 || needleAngle > (2 * M_PI)){
        needleAngle = 0.0;
    }
    
    _needleAngle = needleAngle;
   
    [self shrinkNeedleView:NO];
}

- (void)growNeedleView:(BOOL)animated
{
    NSArray *masks = [self maskPathsForAngle:_needleAngle andScale:CGPointMake(1.4, 1.25)];
    [self setMaskToPath:masks animated:animated animationKey:@"growNeedle"];
}

- (void)shrinkNeedleView:(BOOL)animated
{
    NSArray *masks = [self maskPathsForAngle:_needleAngle andScale:CGPointMake(1.0, 1.0)];
    [self setMaskToPath:masks animated:animated animationKey:@"shrinkNeedle"];
}

/**
 *  Updates self.layer.mask to the supplied values. Code for shinking/growing was basically the same, so moved it to one method.
 *
 *  @param targetPath   CGPathRef
 *  @param currentPath  CGPathRef
 *  @param animated     BOOL
 *  @param animationKey NSString
 */
- (void)setMaskToPath:(NSArray *)targetPaths
             animated:(BOOL)animated
         animationKey:(NSString *)animationKey
{
    if (!targetPaths || targetPaths.count < 1){
        return;
    }
    
    if (!animated){
        
        [self.layer.mask removeAllAnimations];
        if (self.wheelCutoutView){
            [self.wheelCutoutView.layer.mask removeAllAnimations];
        }
        
        [self.layer.mask setValue:[targetPaths objectAtIndex:0] forKey:@"path"];
        if (self.wheelCutoutView){
            [self.wheelCutoutView.layer.mask setValue:[targetPaths objectAtIndex:1] forKey:@"path"];
        }
        
        return;
    }
    
    //check if we are already animating
    if ([self.layer.mask animationForKey:animationKey]){
        return;
    }
    
    CABasicAnimation *maskAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    
    maskAnimation.duration = 0.2;
    
    maskAnimation.fromValue = [self.layer.mask.presentationLayer valueForKey:@"path"];
    maskAnimation.toValue = [targetPaths objectAtIndex:0];
    maskAnimation.fillMode = kCAFillModeForwards;
    maskAnimation.removedOnCompletion = NO;
    
    [self.layer.mask removeAllAnimations];
    
    [self.layer.mask addAnimation:maskAnimation forKey:animationKey];
    if (self.wheelCutoutView){
        
        CABasicAnimation *maskAnimationInverted = [maskAnimation copy];
        maskAnimationInverted.fromValue = [self.wheelCutoutView.layer.mask.presentationLayer valueForKey:@"path"];
        maskAnimationInverted.toValue = [targetPaths objectAtIndex:1];
        
        [self.wheelCutoutView.layer.mask removeAllAnimations];
        
        [self.wheelCutoutView.layer.mask addAnimation:maskAnimationInverted forKey:animationKey];
    }
}

/**
 *  Returns Array of 2 UIBezierpaths, the exact inverses of each other
 *
 *  @param angle CGFloat
 *  @param scale CGPoint
 *
 *  @return NSArray
 */
- (NSArray *)maskPathsForAngle:(CGFloat)angle andScale:(CGPoint)scale
{
    if (!self.dataSource){
        return nil;
    }
    
    BOOL isIdentityScale = (scale.x == 1.0 && scale.y == 1.0);
    
    if (isIdentityScale){
        if (self.wheelMaskCachedIdentity && self.wheelCutoutMaskCachedIdentity){
            return @[(id)self.wheelMaskCachedIdentity.CGPath, (id)self.wheelCutoutMaskCachedIdentity.CGPath];
        }
    } else {
        if (self.wheelMaskCachedScaled && self.wheelCutoutMaskCachedScaled){
            return @[(id)self.wheelMaskCachedScaled.CGPath, (id)self.wheelCutoutMaskCachedScaled.CGPath];
        }
    }
    
    CGSize needleSize = [self.dataSource sizeForCombinationNeedleView:self];
    needleSize.width *= scale.x;
    needleSize.height *= scale.y;
    
    CGFloat outerRadius = [self.dataSource diamaterForCombinationWheel:self] / 2.0;
    CGFloat innerRadius = [self.dataSource diamaterForCombinationWheelInnerMask:self] / 2.0;
    CGPoint center = CGPointMake(outerRadius, outerRadius);
    
    
    //See Fig A
    CGPoint needlePoint_A = CGPointMake((center.x + outerRadius), center.y + (needleSize.width / 2));
    CGPoint needlePoint_B = CGPointMake((center.x + outerRadius) - needleSize.height, center.y);
    
    //Calculate roots (so we can find the point where our line intersects the circle)
    SWMLine *needleEquation = [SWMLine lineForPoint:needlePoint_A and:needlePoint_B];
    SWMCircle *wheelEquation = [SWMCircle circleWithCenter:center andRadius:outerRadius];
    SWMQuadratic *needleAndWheelQuadratic = [SWMCircle quadraticWithCircle:wheelEquation andLine:needleEquation];
    CGPoint nwRoots = [needleAndWheelQuadratic solveRoots];
    
    
    //the y values where the needle intersects the circle at newRoots.x
    CGPoint wheelNeedleIntersectionPoints = [wheelEquation solveInTermsOfX:nwRoots.x];
    //x and y are inverted because origin is at upper left corner in ios
    CGPoint needlePoint_D = CGPointMake(nwRoots.x, wheelNeedleIntersectionPoints.y);
    CGPoint needlePoint_F = CGPointMake(nwRoots.x, wheelNeedleIntersectionPoints.x);
    
    
    
    
    
    UIBezierPath *wheelCutout = [UIBezierPath bezierPath];
    
    [wheelCutout moveToPoint:needlePoint_B];
    [wheelCutout addLineToPoint:needlePoint_F];
    [wheelCutout addArcWithCenter:center radius:outerRadius //angles are reversed because ios quadrants are different
                     startAngle:-[self angleFromCenter:needlePoint_F]
                       endAngle:-[self angleFromCenter:needlePoint_D] clockwise:YES];
    [wheelCutout addLineToPoint:needlePoint_D];
    [wheelCutout addLineToPoint:needlePoint_B];
    
    [wheelCutout closePath];
    
    //inner circle
    [wheelCutout appendPath:[UIBezierPath bezierPathWithArcCenter:center radius:innerRadius startAngle:0.0 endAngle:(2 * M_PI) clockwise:NO]];
    
    
    UIBezierPath *wheelCutoutPath = [UIBezierPath bezierPath];
    
    [wheelCutoutPath moveToPoint:needlePoint_B];
    [wheelCutoutPath addLineToPoint:needlePoint_D];
    [wheelCutoutPath addArcWithCenter:center radius:outerRadius
                           startAngle:-[self angleFromCenter:needlePoint_D] //angles are reversed because ios quadrants are different
                             endAngle:-[self angleFromCenter:needlePoint_F] clockwise:NO];
    [wheelCutoutPath addLineToPoint:needlePoint_B];
    
    [wheelCutoutPath closePath];
    
    //inner circle
    [wheelCutoutPath appendPath:[UIBezierPath bezierPathWithArcCenter:center radius:innerRadius startAngle:0.0 endAngle:(2 * M_PI) clockwise:NO]];
    
    
    
    
    
    //rotate the wheel paths around their center to match supplied angle
    CGPoint wheelPathCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGAffineTransform wheelPathRotation = CGAffineTransformIdentity;
    wheelPathRotation = CGAffineTransformTranslate(wheelPathRotation, wheelPathCenter.x, wheelPathCenter.y);
    wheelPathRotation = CGAffineTransformRotate(wheelPathRotation, -angle);
    wheelPathRotation = CGAffineTransformTranslate(wheelPathRotation, -wheelPathCenter.x, -wheelPathCenter.y);
    
    [wheelCutout applyTransform:wheelPathRotation];
    [wheelCutoutPath applyTransform:wheelPathRotation];
    
    
    //move the wheel cutout path down to match our origin
    CGAffineTransform wheelCutoutTranslation = CGAffineTransformIdentity;
    CGPoint convertedOrigin = [self.superview convertPoint:self.frame.origin toView:self.wheelCutoutView];
    wheelCutoutTranslation = CGAffineTransformTranslate(wheelCutoutTranslation, convertedOrigin.x, convertedOrigin.y);
    [wheelCutoutPath applyTransform:wheelCutoutTranslation];
    
    
    
    
    
    //append the bounds path after, because we only want to rotate the wheel
    [wheelCutoutPath appendPath:[UIBezierPath bezierPathWithRect:self.wheelCutoutView.bounds]];
    
    
    
    if (isIdentityScale){
        self.wheelMaskCachedIdentity = wheelCutout;
        self.wheelCutoutMaskCachedIdentity = wheelCutoutPath;
    } else {
        self.wheelMaskCachedScaled = wheelCutout;
        self.wheelCutoutMaskCachedScaled = wheelCutoutPath;
    }
    
    return @[(id)wheelCutout.CGPath, (id)wheelCutoutPath.CGPath];
}

#pragma mark -
#pragma mark Internal

//get the "slice" angle for specified number of items, (angle for each item to be equally spaced along circle)
- (CGFloat)angleSliceForItems:(NSUInteger)numberOfItems
{
    if (numberOfItems == 0){
        return 0.0;
    }
    
    return (2 * M_PI) / numberOfItems;
}

- (UIView *)wheel
{
    if (!_wheel){
        
        _wheel = [[UIView alloc] init];
        
        _wheel.clipsToBounds = YES;
        _wheel.translatesAutoresizingMaskIntoConstraints = NO;
        
        _wheel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:_wheel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_wheel
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_wheel
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_wheel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_wheel
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0
                                                          constant:0.0]];
        
        [self layoutIfNeeded];
        
    }
    
    return _wheel;
}

- (UIView *)backgroundView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(backgroundViewForCombinationWheel:)]){
        
        if (!_backgroundView){
            
            _backgroundView = [self.dataSource backgroundViewForCombinationWheel:self];
            
            _backgroundView.clipsToBounds = YES;
            _backgroundView.userInteractionEnabled = NO;
            _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
            
            [self insertSubview:_backgroundView belowSubview:self.wheel];
            
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundView
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:_backgroundView
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1.0
                                                              constant:0.0]];
            
            [self layoutIfNeeded];
            
        }
    }
    
    return _backgroundView;
}

- (void)layoutIfNeeded
{
    if (self.dataSource){
        self.widthConstraint.constant = [self.dataSource diamaterForCombinationWheel:self];
        self.heightConstraint.constant = self.widthConstraint.constant;
    }
    
    self.wheelMaskCachedIdentity = nil;
    self.wheelMaskCachedScaled = nil;
    self.wheelCutoutMaskCachedIdentity = nil;
    self.wheelCutoutMaskCachedScaled = nil;
    
    [super layoutIfNeeded];
}

- (NSArray *)wheelCombinationItems
{
    if (!_wheelCombinationItems){
        _wheelCombinationItems = [NSArray array];
    }
    
    return _wheelCombinationItems;
}

- (NSMutableArray *)wheelCombinationSelection
{
    if (!_wheelCombinationSelection){
        _wheelCombinationSelection = [NSMutableArray array];
    }
    
    return _wheelCombinationSelection;
}

- (void)setDataSource:(id<SWCombinationWheelDataSource>)dataSource
{
    _dataSource = dataSource;
    
    [self reloadData];
}

@end




