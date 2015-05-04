//
//  ViewController.m
//  SWCombinationWheel
//
//  Created by Pat Sluth on 2015-04-04.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import "ViewController.h"
#import "SWCombinationItem.h"
#import "NSTimer+SW.h"





@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIVisualEffectView *blur;
@property (strong, nonatomic) SWCombinationWheel *wheel;

@end





@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.wheel = [[SWCombinationWheel alloc] init];
    self.wheel.wheelCutoutView = self.blur;
    
    [self.view addSubview:self.wheel];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wheel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.wheel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.view
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self.view layoutIfNeeded];
    
    self.wheel.delegate = self;
    self.wheel.dataSource = self; //triggers reload data
}

#pragma mark SWCombinationWheelDataSource

- (CGFloat)diamaterForCombinationWheel:(SWCombinationWheel *)swCombinationWheel
{
    return fmin(self.view.bounds.size.width, self.view.bounds.size.height);
}

- (CGFloat)diamaterForCombinationWheelInnerMask:(SWCombinationWheel *)swCombinationWheel
{
    return [self diamaterForCombinationWheel:swCombinationWheel] * 0.5; //50%
}

- (CGSize)sizeForCombinationNeedleView:(SWCombinationWheel *)swCombinationWheel
{
    return CGSizeMake(40, 30);
}

- (NSUInteger)numberOfCombinationItemsInCircumferenceWheel:(SWCombinationWheel *)swCombinationWheel
{
    return 10;
}

- (SWCombinationItem *)swCombinationWheel:(SWCombinationWheel *)swCombinationWheel
                  combinationItemForIndex:(NSUInteger)index
{
    SWCombinationItem *item = [[SWCombinationItem alloc] init];
    
    //make the width evenly distributed on the inner mask circle, so none of the items overlap
    CGFloat width = (M_PI * [self diamaterForCombinationWheelInnerMask:swCombinationWheel]) / [self numberOfCombinationItemsInCircumferenceWheel:swCombinationWheel];
    //make the height exactly equal to the size of the wheel
    CGFloat height = ([self diamaterForCombinationWheel:swCombinationWheel] - [self diamaterForCombinationWheelInnerMask:swCombinationWheel]) / 2.0;
   
    item.frame = CGRectIntegral(CGRectMake(0, 0, width, height));
    
    item.label.text =  [NSString stringWithFormat:@"%lu", (unsigned long)index];
    
    return item;
}

- (UIView *)backgroundViewForCombinationWheel:(SWCombinationWheel *)swCombinationWheel
{
    return [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
}

#pragma mark SWCombinationWheelDelegate

- (void)swCombinationWheel:(SWCombinationWheel *)swCombinationWheel didSelectCombinationItem:(SWCombinationItem *)item
{
    NSLog(@"%@", item.identifier);
}

- (void)swCombinationWheel:(SWCombinationWheel *)swCombinationWheel didEnterCombination:(NSArray *)combination
{
    NSMutableString *combinationString = [NSMutableString string];
    
    for (SWCombinationItem *item in combination){
        [combinationString appendString:[NSString stringWithFormat:@"%@ - ", item.identifier]];
    }
    
    NSLog(@"%@", combinationString);
}

#pragma mark Other

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
