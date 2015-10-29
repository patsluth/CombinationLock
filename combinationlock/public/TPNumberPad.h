
@interface TPNumberPad : UIControl
{
    NSMutableArray *_buttons;
    BOOL _numberButtonsEnabled;
}

- (id)initWithButtons:(id)arg1;

- (void)buttonLongPressed:(id)arg1;
- (void)buttonCancelled:(id)arg1;
- (void)buttonDown:(id)arg1;
- (void)buttonUp:(id)arg1;
- (void)buttonTapped:(id)arg1;
- (void)buttonLongPressedViaGesture:(id)arg1;
- (void)_addButton:(id)arg1;
- (void)_layoutGrid;
- (void)_setBackgroundAlphaOnButton:(id)arg1 alpha:(float)arg2;
- (float)_backgroundAlphaOfButton:(id)arg1;
- (void)replaceButton:(id)arg1 atIndex:(unsigned int)arg2;
- (struct CGSize)intrinsicContentSize;

@property(nonatomic) float buttonBackgroundAlpha;
@property(retain) NSArray *buttons;
@property(nonatomic) BOOL numberButtonsEnabled;

@end




