
#import "SBUIPasscodeLockNumberPad.h"
#import "SBNumberPadWithDelegate.h"
#import "SBPasscodeNumberPadButton.h"
#import "TPRevealingRingView.h"
#import "SBUIPasscodeLockViewBase.h"
#import "SBUIPasscodeEntryField.h"

#import "SWCombinationWheel.h"
#import "SWCombinationItem.h"

#import "libSluthware.h"





%hook SBNumberPadWithDelegate

- (id)initWithButtons:(id)arg1
{
    self = %orig(arg1);
    
    
    
    
    

    //move all buttons into a temproary view, so we can mask them without affecting the wheel
    UIView *temp = [[UIView alloc] initWithFrame:self.bounds];
    temp.backgroundColor = [UIColor clearColor];
    
    for (UIView *v in self.subviews){
        [temp addSubview:v];
    }
    
    [self addSubview:temp];
    
    
    
    
    
    
    
    SWCombinationWheel *wheel = [[SWCombinationWheel alloc] init];
    wheel.wheelCutoutView = temp;
    
    [self addSubview:wheel];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:wheel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:wheel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self layoutIfNeeded];
    [self bringSubviewToFront:wheel];
    
    wheel.delegate = self;
    wheel.dataSource = self; //triggers reload data
    
    return self;
}

//buttons dont respond to touch normally, so setting userInteractionEndabled to NO doesnt work
- (id)buttonForPoint:(struct CGPoint)arg1 forEvent:(id)arg2
{
    //return %orig(arg1, arg2);
    return nil;
}

#pragma mark SWCombinationWheelDataSource

%new
- (CGFloat)diamaterForCombinationWheel:(SWCombinationWheel *)swCombinationWheel
{
    return fmin(self.bounds.size.width, self.bounds.size.height);
}

%new
- (CGFloat)diamaterForCombinationWheelInnerMask:(SWCombinationWheel *)swCombinationWheel
{
    return fmin(self.bounds.size.width, self.bounds.size.height) * 0.5; //50%
}

%new
- (CGSize)sizeForCombinationNeedleView:(SWCombinationWheel *)swCombinationWheel
{
    CGFloat centerOfRing = [self diamaterForCombinationWheel:nil] - [self diamaterForCombinationWheelInnerMask:nil];
    centerOfRing /= 6;
    
    return CGSizeMake(40, centerOfRing);
}

%new
- (NSUInteger)numberOfCombinationItemsInCircumferenceWheel:(SWCombinationWheel *)swCombinationWheel
{
    return 10;
}

%new
- (SWCombinationItem *)swCombinationWheel:(SWCombinationWheel *)swCombinationWheel combinationItemForIndex:(NSUInteger)index
{
    SWCombinationItem *item = [[SWCombinationItem alloc] init];
    
    item.frame = CGRectMake(0, 0, 70, 50);
    
    item.label.text =  [NSString stringWithFormat:@"%lu", (unsigned long)index];
    item.identifier = item.label.text;
    
    return item;
}

#pragma mark SWCombinationWheelDelegate

%new
- (void)swCombinationWheel:(SWCombinationWheel *)swCombinationWheel didSelectCombinationItem:(SWCombinationItem *)item
{
    SBPasscodeNumberPadButton *dopelganger = [self buttonForStringCharacter:item.identifier];
    
    if (dopelganger){
        
        if ([self.delegate isKindOfClass:[%c(SBUIPasscodeLockNumberPad) class]]){
            
            SBUIPasscodeLockNumberPad *numberPad = (SBUIPasscodeLockNumberPad *)self.delegate;
                
            if ([numberPad.delegate respondsToSelector:@selector(passcodeLockNumberPad:keyDown:)]){
                [numberPad.delegate passcodeLockNumberPad:self keyDown:dopelganger];
            }
            
            if ([numberPad.delegate respondsToSelector:@selector(passcodeLockNumberPad:keyUp:)]){
                [numberPad.delegate passcodeLockNumberPad:self keyUp:dopelganger];
            }
        }
    }
}

%new
- (void)swCombinationWheel:(SWCombinationWheel *)swCombinationWheel didEnterCombination:(NSArray *)combination
{
    if ([self.delegate isKindOfClass:[%c(SBUIPasscodeLockNumberPad) class]]){
        
        SBUIPasscodeLockNumberPad *numberPad = (SBUIPasscodeLockNumberPad *)self.delegate;
        
        if ([numberPad.delegate isKindOfClass:%c(SBUIPasscodeLockViewBase)]){
            
            SBUIPasscodeLockViewBase *lockViewBase = (SBUIPasscodeLockViewBase *)numberPad.delegate;
            
            //passcode view is full, so if we reset it, it wont unlock even if the passcode is correct
            if (lockViewBase._entryField.stringValue.length != 4){
                
                //reset passcode
                if ([numberPad.delegate respondsToSelector:@selector(passcodeLockNumberPadBackspaceButtonHit:)]){
                    for (NSUInteger x = 0; x < 5; x++){
                        [numberPad.delegate passcodeLockNumberPadBackspaceButtonHit:self];
                    }
                }
                
            }
        }
    }
}

#pragma mark -
#pragma mark Helper

%new
- (SBPasscodeNumberPadButton *)buttonForStringCharacter:(NSString *)string
{
    for (id button in self.buttons){
        if ([button isKindOfClass:[%c(SBPasscodeNumberPadButton) class]]){
            
            SBPasscodeNumberPadButton *passcodeButton = (SBPasscodeNumberPadButton *)button;
            if ([[passcodeButton stringCharacter] isEqualToString:string]){
                return passcodeButton;
            }
            
        }
    }
    
    return nil;
}

%end





#pragma mark -
#pragma mark SBPasscodeNumberPadButton

%hook SBPasscodeNumberPadButton

//get rid of the button highlighted text
- (void)setHighlightedGlyphLayer:(CALayer *)arg1
{
    %orig(arg1);
    arg1.hidden = YES;
}

//get rid of the button text
- (void)setGlyphLayer:(CALayer *)arg1
{
    %orig(arg1);
    arg1.hidden = YES;
}

%end





#pragma mark -
#pragma mark TPRevealingRingView

%hook TPRevealingRingView

- (id)_bezierPathForRect:(CGRect)arg1 cornerRadius:(double)arg2
{
    //get rid of the ring around the button
    if ([self.superview isKindOfClass:[%c(SBPasscodeNumberPadButton) class]]){
        return %orig(CGRectZero, 0.0);
    }
    
    return %orig(arg1, arg2);
}

%end





%ctor
{
}