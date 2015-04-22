//
//  SWCombinationItem.h
//  SWCombinationWheel
//
//  Created by Pat Sluth on 2015-04-04.
//  Copyright (c) 2015 Pat Sluth. All rights reserved.
//

#import <UIKit/UIKit.h>





@interface SWCombinationItem : UIVisualEffectView

@property (strong, nonatomic) NSString *identifier;

@property (strong, nonatomic) UILabel *label;

- (void)didGetSelected;

@end




