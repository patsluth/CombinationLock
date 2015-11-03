//
//  SWCombinationLockPSListController.m
//  combinationlockprefs
//
//  Created by Pat Sluth on 2015-04-25.
//
//

#import "SWCombinationLockPSListController.h"

#import <Preferences/Preferences.h>

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/SWPSTwitterCell.h"





@interface SWCombinationLockPSListController()
{
}

@end





@implementation SWCombinationLockPSListController

#pragma mark Twitter

- (void)viewTwitterProfile:(PSSpecifier *)specifier
{
    [SWPSTwitterCell performActionWithSpecifier:specifier];
}

@end




