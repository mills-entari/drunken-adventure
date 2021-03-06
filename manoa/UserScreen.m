#import "UserScreen.h"

#define kUserScreenTitle @"User Name"
#define kUserScreenMessage @"Please enter your email address."
#define kUserScreenCancelButtonTitle @"Cancel"
#define kUserScreenOkButtonTitle @"OK"
#define kUserScreenUserNameMessage @"You must enter a user name."

typedef enum
{
    UserScreenModeUnknown = 0,
    UserScreenModeEnterUserName,
    UserScreenModePromptEnterUserName
} UserScreenMode;

@interface UserScreen()
{
@private
//    GameButton* mCancelButton;
//    GameButton* mOkButton;
    UserScreenMode mUserScreenMode;
    __weak id<UserScreenDelegate> mUserScreenDelegate;
    NSString* mUserName;
}

@end

@implementation UserScreen

@synthesize userScreenDelegate = mUserScreenDelegate;
@synthesize userName = mUserName;

-(id)initWithRect:(CGRect)rect screenScale:(CGFloat)screenScale gameScale:(CGSize)gameScale
{
    if (self = [super initWithRect:rect screenScale:screenScale gameScale:gameScale])
    {
        mMainView.backgroundColor = [UIColor yellowColor];
        mUserScreenMode = UserScreenModeUnknown;
        
//        int numButtons = 2;
//        float buttonWidth = 120.0f;
//        float buttonHeight = 40.0f;
//        float buttonGap = 20.0f;
//        float buttonYPos = rect.size.height * 0.6f;
//        float cancelButtonXPos = (rect.size.width / 2.0f) - ((buttonWidth / 2.0f) * numButtons) - ((buttonGap / 2.0f) * (numButtons - 1));
//        
//        CGRect cancelButtonRect = CGRectMake(cancelButtonXPos, buttonYPos, buttonWidth, buttonHeight);
//        mCancelButton = [[GameButton alloc] initWithFrame:cancelButtonRect];
//        mCancelButton.backgroundColor = [UIColor grayColor];
//        mCancelButton.name = kUserScreenCancelButtonName;
//        mCancelButton.text = kUserScreenCancelButtonTitle;
//        [mMainView addSubview:mCancelButton];
//        
//        CGRect okButtonRect = CGRectMake(cancelButtonRect.origin.x + buttonWidth + buttonGap, buttonYPos, buttonWidth, buttonHeight);
//        mOkButton = [[GameButton alloc] initWithFrame:okButtonRect];
//        mOkButton.backgroundColor = [UIColor whiteColor];
//        mOkButton.name = kUserScreenOkButtonName;
//        mOkButton.text = kUserScreenOkButtonTitle;
//        [mMainView addSubview:mOkButton];
//        
//        CGRect textViewRect = CGRectMake(cancelButtonRect.origin.x, cancelButtonRect.origin.y - buttonHeight - buttonGap, (buttonWidth * numButtons) + (buttonGap * (numButtons - 1)), buttonHeight);
//        UITextView* textView = [[UITextView alloc] initWithFrame:textViewRect];
//        [mMainView addSubview:textView];
    }
    
    return self;
}

-(void)displayUserNameInput:(NSString*)currentUserName
{
    mUserScreenMode = UserScreenModeEnterUserName;
    
    //UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:kUserScreenTitle message:kUserScreenMessage delegate:self cancelButtonTitle:kUserScreenCancelButtonTitle otherButtonTitles:nil];
    
    //[alertView addButtonWithTitle:kUserScreenOkButtonTitle];
    //alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    //if (currentUserName != nil)
    //{
    //    UITextField* textField = [alertView textFieldAtIndex:0];
    //    textField.text = currentUserName;
    //}
    
    //[alertView show];
    
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:kUserScreenTitle message:kUserScreenMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField)
     {
         textField.placeholder = NSLocalizedString(@"User Name", @"User Name");
     }];
    
    UIAlertAction* okAction = [UIAlertAction
                               actionWithTitle:kUserScreenOkButtonTitle
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField* userNameTextField = alertController.textFields.firstObject;
                                   mUserName = userNameTextField.text;
                                   
                                   DLog("User Name: %@", mUserName);
                                   
                                   // Validate the user name. Very simple for now, just make sure they put in something.
                                   // TODO: Make user validation more sophisticated.
                                   if ([mUserName length] > 0)
                                   {
                                       [self fireOkButtonClickedDelegate];
                                   }
                                   else
                                   {
                                       // Invalid user name, let the user know.
                                       [self displayEnterUserNamePrompt];
                                   }

                               }];
    
    UIAlertAction* cancelAction = [UIAlertAction
                                   actionWithTitle:kUserScreenCancelButtonTitle
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       mUserName = nil;
                                       [self fireCancelButtonClickedDelegate];
                                   }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    //[self presentViewController:alertController animated:YES completion:nil];
    [alertController show];
}

-(void)displayEnterUserNamePrompt
{
    mUserScreenMode = UserScreenModePromptEnterUserName;
    
//    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:kUserScreenTitle message:kUserScreenUserNameMessage delegate:self cancelButtonTitle:kUserScreenOkButtonTitle otherButtonTitles:nil];
//    alertView.alertViewStyle = UIAlertViewStyleDefault;
//    [alertView show];
    
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:kUserScreenTitle message:kUserScreenUserNameMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction
                               actionWithTitle:kUserScreenOkButtonTitle
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self displayUserNameInput:nil];
                               }];
    
    [alertController addAction:okAction];
    //[self presentViewController:alertController animated:YES completion:nil];
    [alertController show];
}

-(void)fireOkButtonClickedDelegate
{
    if (mUserScreenDelegate != nil && [mUserScreenDelegate respondsToSelector:@selector(okButtonClicked:)])
    {
        [mUserScreenDelegate okButtonClicked:self];
    }
}

-(void)fireCancelButtonClickedDelegate
{
    if (mUserScreenDelegate != nil && [mUserScreenDelegate respondsToSelector:@selector(cancelButtonClicked:)])
    {
        [mUserScreenDelegate cancelButtonClicked:self];
    }
}

@end

//@implementation UserScreen(UIAlertViewDelegate)
//
//-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    NSString* buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
//    
//    if (mUserScreenMode == UserScreenModeEnterUserName)
//    {
//        if([buttonTitle isEqualToString:kUserScreenCancelButtonTitle])
//        {
//            mUserName = nil;
//            [self fireCancelButtonClickedDelegate];
//        }
//        else if([buttonTitle isEqualToString:kUserScreenOkButtonTitle])
//        {
//            UITextField* textField = [alertView textFieldAtIndex:0];
//            mUserName = textField.text;
//            
//            DLog("User Name: %@", mUserName);
//            
//            // Validate the user name. Very simple for now, just make sure they put in something.
//            // TODO: Make user validation more sophisticated.
//            if ([mUserName length] > 0)
//            {
//                [self fireOkButtonClickedDelegate];
//            }
//            else
//            {
//                // Invalid user name, let the user know.
//                [self displayEnterUserNamePrompt];
//            }
//        }
//    }
//    else if (mUserScreenMode == UserScreenModePromptEnterUserName)
//    {
//        [self displayUserNameInput:nil];
//    }
//}

//-(void)fireOkButtonClickedDelegate
//{
//    if (mUserScreenDelegate != nil && [mUserScreenDelegate respondsToSelector:@selector(okButtonClicked:)])
//	{
//		[mUserScreenDelegate okButtonClicked:self];
//	}
//}

//-(void)fireCancelButtonClickedDelegate
//{
//    if (mUserScreenDelegate != nil && [mUserScreenDelegate respondsToSelector:@selector(cancelButtonClicked:)])
//	{
//		[mUserScreenDelegate cancelButtonClicked:self];
//	}
//}

//@end
