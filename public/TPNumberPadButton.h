
@interface TPNumberPadButton : UIControl// <TPNumberPadButtonProtocol>
{
}

@property(retain) UIColor *color;
@property unsigned int character;

- (void)touchUp;
- (void)touchDown;

- (void)setHighlightedGlyphLayer:(id)arg1;
- (void)setGlyphLayer:(id)arg1;

@end




