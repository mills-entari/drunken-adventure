#import <Foundation/Foundation.h>
#import "chipmunk.h"
//#import "GameManager.h"
#import "GameBounds.h"
#import "GameView.h"
#import "GameViewFactory.h"
#import "GameRegion.h"
#import "Actor2D.h"
#import "GameReactionTimeTest.h"
#import "GameScreen.h"
#import "LevelResults.h"
#import "GameZoneData.h"

//@protocol GameZoneDelegate <NSObject>
//
//@optional
//-(void)gameZoneFinished:(GameZoneData*)gameZoneData;
//
//@end

@interface GameZone : GameScreen <GameViewDelegate, GameRegionDelegate, UIAccelerometerDelegate>

//@property(nonatomic, weak) id<GameZoneDelegate> gameZoneDelegate;

-(id)initWithRect:(CGRect)rect screenScale:(CGFloat)screenScale gameScale:(CGSize)gameScale gameZoneId:(NSString*)zoneId gameZoneMode:(GameZoneMode)gameZoneMode;

@end
