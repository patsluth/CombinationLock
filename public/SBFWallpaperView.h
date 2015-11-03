
@class _UILegibilitySettings;

@interface SBFWallpaperView : UIView
{
    UIImageView *_topGradientView;
    UIImageView *_bottomGradientView;
    UIView *_parallaxView;
    
    int _variant;
    
    UIView *_contentView;
}


@property(nonatomic) float parallaxAxisAdjustmentAngle;
@property(nonatomic) BOOL suppressesGradients;
@property(nonatomic) float parallaxFactor;
@property(nonatomic) BOOL parallaxEnabled;
@property(nonatomic) BOOL wallpaperAnimationEnabled;
@property(nonatomic) BOOL continuousColorSamplingEnabled;
@property(nonatomic) float contrast;
@property(nonatomic) BOOL filtersAverageColor;
@property(nonatomic) int variant;
@property(nonatomic) float zoomFactor;
@property(retain, nonatomic) UIView *contentView;

@property(readonly, nonatomic) UIImage *wallpaperImage;
- (id)_displayedImage;
- (id)_blurredImage;
- (id)_blurReplacementImage;
- (id)blurredImage;







- (id)_averageColorInContentViewRect:(struct CGRect)arg1 smudgeRadius:(float)arg2;
- (id)_computeAverageColor;
- (float)contrastInRect:(struct CGRect)arg1 contrastWithinBoxes:(float *)arg2 contrastBetweenBoxes:(float *)arg3;
- (float)contrastInRect:(struct CGRect)arg1;
- (id)averageColorInRect:(struct CGRect)arg1 withSmudgeRadius:(float)arg2;
- (id)_primaryColorOverride;





- (void)updateLegibilitySettingsForAverageColor:(id)arg1;
- (void)_setLegibilitySettings:(id)arg1 notify:(BOOL)arg2;
@property(retain, nonatomic) _UILegibilitySettings *legibilitySettings;



@end

