//
//  SWCombinationWheel.h
//  SWCombinationWheel
//
//  Created by Pat Sluth on 2015-04-04.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWCombinationWheel;
@class SWCombinationItem;





@protocol SWCombinationWheelDataSource <NSObject>

@required

/**
 *  Desired size for the combination wheel view (forced square). To change the size, call setNeedsLayout on the SWCombinationWheel, and it will update to the delegate method return value
 *
 *  @param swCombinationWheel SWCombinationWheel
 *
 *  @return Diamater of the circle
 */
- (CGFloat)diamaterForCombinationWheel:(SWCombinationWheel *)swCombinationWheel;
/**
 *  Desired size for the 'donut' cutout inside the circle. Defaults to radius / 2
 *
 *  @param swCombinationWheel SWCombinationWheel
 *
 *  @return Diamater of the circle cutout
 */
- (CGFloat)diamaterForCombinationWheelInnerMask:(SWCombinationWheel *)swCombinationWheel;
- (CGSize)sizeForCombinationNeedleView:(SWCombinationWheel *)swCombinationWheel;

- (NSUInteger)numberOfCombinationItemsInCircumferenceWheel:(SWCombinationWheel *)swCombinationWheel;
/* example of how indexes are spaced
   * 2 *
  *     *
 3       1
  *     *
   * 4 *
*/
- (SWCombinationItem *)swCombinationWheel:(SWCombinationWheel *)swCombinationWheel
                  combinationItemForIndex:(NSUInteger)index;

@optional

/**
 *  Return custom background view
 *
 *  @param swCombinationWheel SWCombinationWheel
 *  @param backgroundView     NSUInteger
 *
 *  @return UIView
 */
- (UIView *)backgroundViewForCombinationWheel:(SWCombinationWheel *)swCombinationWheel;

@optional

@end





@protocol SWCombinationWheelDelegate <NSObject>

@optional

/**
 *  Called each time an item is 'selected'. Ex when you rotate the wheel onto a SWCombinationItem, and then rotate the opposite direction
 *
 *  @param swCombinationWheel SWCombinationWheel
 *  @param item               SWCombinationItem
 */
- (void)swCombinationWheel:(SWCombinationWheel *)swCombinationWheel didSelectCombinationItem:(SWCombinationItem *)item;

/**
 *  Called when the user is finished selecting a combination by rotating the wheel. Will be called when the wheel is released
 *
 *  @param swCombinationWheel SWCombinationWheel
 *  @param combination        NSArray
 */
- (void)swCombinationWheel:(SWCombinationWheel *)swCombinationWheel didEnterCombination:(NSArray *)combination;

/**
 *  Called when the lock is rotated three times (Like a real life combination lock, you rotate 3 times to reset)
 *
 *  @param swCombinationWheel SWCombinationWheel
 */
- (void)didClearCombinationForSWCombinationWheel:(SWCombinationWheel *)swCombinationWheel;

@end





@interface SWCombinationWheel : UIView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<SWCombinationWheelDataSource> dataSource;
@property (weak, nonatomic) id<SWCombinationWheelDelegate> delegate;

/**
 *  This is the view that rotates
 */
@property (readonly, strong, nonatomic) UIView *wheel;

/**
 *  This will be cutout to the same view as the wheel, but it wont rotate. Use datasource (backgroundViewForCombinationWheel) and reload data to change
 */
@property (readonly, strong, nonatomic) UIView *backgroundView;

/**
 *  This view will be masked and animated with the wheel view. It will be 'cutout' to exactly fit the wheel view
 */
@property (weak, nonatomic) UIView *wheelCutoutView;

/**
 *  Array of currently selected combination items. Reset every release of wheel
 */
@property (strong, nonatomic) NSMutableArray *wheelCombinationSelection;

/**
 *  Angle of the needle in radians, defaults to pi/2
 */
@property (nonatomic) CGFloat needleAngle;

- (void)reloadData;

@end




