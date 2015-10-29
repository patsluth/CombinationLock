
@interface SBUIPasscodeEntryField : UIView <UITextFieldDelegate>
{
}

- (BOOL)_hasAnyCharacters;

@property(copy, nonatomic) NSString *stringValue;

@end




