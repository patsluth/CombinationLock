
@interface _UILegibilitySettings : NSObject
{
}

+ (id)sharedInstanceForStyle:(int)arg1;

@property(retain, nonatomic) UIColor *shadowColor;;
@property(retain, nonatomic) UIColor *secondaryColor;
@property(retain, nonatomic) UIColor *primaryColor;
@property(retain, nonatomic) UIColor *contentColor;
@property(nonatomic) int style;

- (id)initWithStyle:(int)arg1 primaryColor:(id)arg2 secondaryColor:(id)arg3 shadowColor:(id)arg4;
- (id)initWithStyle:(int)arg1 contentColor:(id)arg2;
- (id)initWithContentColor:(id)arg1 contrast:(float)arg2;
- (id)initWithContentColor:(id)arg1;
- (id)initWithStyle:(int)arg1;

@end


