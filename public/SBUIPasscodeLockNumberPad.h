
#import <UIKit/UIKit.h>





@protocol SBUIPasscodeLockNumberPadDelegate <NSObject>

@optional
//- (void)passcodeLockNumberPadEmergencyCallButtonHit:(SBUIPasscodeLockNumberPad *)arg1;
//- (void)passcodeLockNumberPadBackspaceButtonHit:(SBUIPasscodeLockNumberPad *)arg1;
//- (void)passcodeLockNumberPadCancelButtonHit:(SBUIPasscodeLockNumberPad *)arg1;
//- (void)passcodeLockNumberPad:(SBUIPasscodeLockNumberPad *)arg1 keyCancelled:(UIControl<SBUIPasscodeNumberPadButton> *)arg2;
//- (void)passcodeLockNumberPad:(SBUIPasscodeLockNumberPad *)arg1 keyUp:(UIControl<SBUIPasscodeNumberPadButton> *)arg2;
//- (void)passcodeLockNumberPad:(SBUIPasscodeLockNumberPad *)arg1 keyDown:(UIControl<SBUIPasscodeNumberPadButton> *)arg2;

- (void)passcodeLockNumberPadBackspaceButtonHit:(id)arg1;
- (void)passcodeLockNumberPad:(id)arg1 keyUp:(id)arg2;
- (void)passcodeLockNumberPad:(id)arg1 keyDown:(id)arg2;

@end





@interface SBUIPasscodeLockNumberPad : UIView// <SBNumberPadDelegate>
{
}

@property(nonatomic) id<SBUIPasscodeLockNumberPadDelegate> delegate; //SBUIPasscodeLockViewSimple4DigitKeypad : SBUIPasscodeLockViewWithKeypad : SBUIPasscodeLockViewBase
@property(readonly, nonatomic) NSArray *buttons;

- (id)initWithDefaultSizeAndLightStyle:(BOOL)arg1;

- (void)setDownButton:(id)arg1;

@end




