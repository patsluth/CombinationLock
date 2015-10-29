
@class SBFWallpaperView;

@interface SBWallpaperController : NSObject
{
    SBFWallpaperView *_lockscreenWallpaperView;
    SBFWallpaperView *_homescreenWallpaperView;
    SBFWallpaperView *_sharedWallpaperView;
}

+ (id)sharedInstance;

@end




