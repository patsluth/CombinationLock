
#import "TPNumberPad.h"
#import "SWCombinationWheel.h"

@class SBPasscodeNumberPadButton;





@protocol SBNumberPadDelegate <NSObject>

@end





@interface SBNumberPadWithDelegate : TPNumberPad <SWCombinationWheelDataSource, SWCombinationWheelDelegate>
{
}

@property(nonatomic) id<SBNumberPadDelegate> delegate;

- (id)buttonForPoint:(struct CGPoint)arg1 forEvent:(id)arg2;

//new
- (SBPasscodeNumberPadButton *)buttonForStringCharacter:(NSString *)string;

@end




