
@class SBUIPasscodeEntryField;

@interface SBUIPasscodeLockViewBase : UIView
{
    NSString *_passcode;
    SBUIPasscodeEntryField *_entryField;
}

@property(retain, nonatomic) SBUIPasscodeEntryField *_entryField;

@end




