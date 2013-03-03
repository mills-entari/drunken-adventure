#import <Foundation/Foundation.h>
#import "GameScreen.h"

@class UserScreen;

@protocol UserScreenDelegate <NSObject>

@optional
-(void)okButtonClicked:(UserScreen*)sender;
-(void)cancelButtonClicked:(UserScreen*)sender;

@end

@interface UserScreen : GameScreen <UIAlertViewDelegate>

@property(nonatomic, weak) id<UserScreenDelegate> userScreenDelegate;
@property(nonatomic) NSString* userName;

-(void)displayUserNameInput:(NSString*)currentUserName;
-(void)displayEnterUserNamePrompt;

@end
