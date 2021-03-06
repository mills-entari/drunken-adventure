#import "GameRegion.h"

#define kGameRegionGroundThickness 10.0f
#define kGameRegionZoneBoundsWidth 20.0f
#define kItemDeltaOffset 20.0f

@interface GameRegion()
{
@private
    BOOL mIsEnabled;
    int mRegionIndex;
    CGSize mRegionSize;
    GameView* mRegionView;
    cpSpace* mSpace;
    NSMutableArray* mGameBoundsList;
    NSMutableArray* mGameItemList;
    //Actor2D* mPlayer;
    NSMutableArray* mPlayerList;
    float mRegionYOrigin;
    float mRegionYEnd;
    __weak id<GameRegionDelegate> mRegionDelegate;
    BOOL mIsGroundRegion;
    int mGameRegionGameItemColumnIndex;
    int mPreviousGameRegionGameItemColIndex;
    
    //int mItemGrid[kNumberItemRows][kNumberItemColumns];
    CGSize mGridItemSize;
}

//cpBool beginItemCollision(cpArbiter *arb, cpSpace *space, void *unused);
cpBool preSolveItemCollision(cpArbiter *arb, cpSpace *space, void *unused);
cpBool beginGroundCollision(cpArbiter *arb, cpSpace *space, void *unused);
void postStepRemove(cpSpace* space, cpShape* shape, void* userData);

@end

@implementation GameRegion

@synthesize isEnabled = mIsEnabled;
@synthesize gameRegionIndex = mRegionIndex;
@synthesize gameView = mRegionView;
@synthesize gameRegionSize = mRegionSize;
@synthesize gameRegionDelegate = mRegionDelegate;
//@synthesize player = mPlayer;
@synthesize playerList = mPlayerList;
@synthesize isGroundRegion = mIsGroundRegion;
@synthesize gameRegionGameItemColumnIndex = mGameRegionGameItemColumnIndex;
@synthesize previousGameRegionGameItemColumnIndex = mPreviousGameRegionGameItemColIndex;

-(id)initWithGameRegionIndex:(int)regionIndex withSize:(CGSize)regionSize withSpace:(cpSpace*)space gameScale:(CGSize)gameScale
{
	if (self = [super init]) 
	{
        mIsEnabled = YES;
        mRegionIndex = regionIndex;
        mRegionSize = regionSize;
        mSpace = space;
        mRegionYOrigin = mRegionSize.height * mRegionIndex;
        mRegionYEnd = mRegionYOrigin + mRegionSize.height;
        mPreviousGameRegionGameItemColIndex = -1;
        
        mGameBoundsList = [[NSMutableArray alloc] initWithCapacity:4];
        mGameItemList = [[NSMutableArray alloc] initWithCapacity:4];
        mPlayerList = [[NSMutableArray alloc] initWithCapacity:2];
        
        mRegionView = [GameViewFactory makeNewGameViewWithFrame:CGRectMake(0, 0, mRegionSize.width, mRegionSize.height)];
        
        [self initItemGrid:gameScale];
    }
    
    return self;
}

-(void)initItemGrid:(CGSize)gameScale
{
    //float itemWidth = mRegionSize.width / kNumberItemColumns;
    //float itemHeight = mRegionSize.height / kNumberItemRows;
    float itemWidth = 40.0f * gameScale.width;
    float itemHeight = 25.0f * gameScale.height;
    mGridItemSize = CGSizeMake(itemWidth, itemHeight);
    //mGridItemSize = CGSizeMake(50, 25);
    //int numItemPositions = kNumberItemColumns * kNumberItemRows;
    
    //int grid[kNumberItemRows][kNumberItemColumns];
    
//    for (int i = 0; i < kNumberItemRows; i++)
//    {
//        for (int j = 0; j < kNumberItemColumns; j++)
//        {
//            mItemGrid[i][j] = 0;
//        }
//    }
}

-(void)registerCurrentRegionCallbacks
{
    cpCollisionHandler* collisionHandler = cpSpaceAddCollisionHandler(mSpace, GameCollisionTypeActor, GameCollisionTypeItem);
    collisionHandler->preSolveFunc = &preSolveItemCollision;
    collisionHandler->userData = (__bridge void*)self;
    
    //cpSpaceAddCollisionHandler(mSpace, GameCollisionTypeActor, GameCollisionTypeItem, NULL, preSolveItemCollision, NULL, NULL, (__bridge void*)self);
    //cpSpaceAddCollisionHandler(mSpace, GameCollisionTypeActor, GameCollisionTypeItem, beginCollision, NULL, NULL, NULL, NULL);
}

-(void)setupRandomGameRegion
{
    //[self createZoneBounds];
    [self createRandomGameItems];
}

-(void)setupGroundGameRegion
{
    //[self createZoneBounds];
    [self createGround];
    //cpSpaceAddCollisionHandler(mSpace, GameCollisionTypeActor, GameCollisionTypeGround, beginGroundCollision, NULL, NULL, NULL, (__bridge void*)self);
    
    cpCollisionHandler* collisionHandler = cpSpaceAddCollisionHandler(mSpace, GameCollisionTypeActor, GameCollisionTypeGround);
    collisionHandler->preSolveFunc = &beginGroundCollision;
    collisionHandler->userData = (__bridge void*)self;
    
    mIsGroundRegion = YES;
    
    [self createRandomGameItems];
}

-(void)createZoneBounds
{
    float thickness = 20;
    //float thickness = mRegionSize.height;
    float boundsWidth = kGameRegionZoneBoundsWidth;
    float boundsYPos = mRegionSize.height * mRegionIndex;
    CGRect leftBoundsWorldRect = CGRectMake(-boundsWidth, boundsYPos, boundsWidth, mRegionSize.height);
    //CGRect leftBoundsWorldRect = CGRectMake(-20, 0, 20, 480);
    CGRect rightBoundsWorldRect = CGRectMake(mRegionSize.width, boundsYPos, boundsWidth, mRegionSize.height);
    
    GameBounds* leftBounds = [[GameBounds alloc] initWithWorldRect:leftBoundsWorldRect withSpace:mSpace withThickness:thickness];
    GameBounds* rightBounds = [[GameBounds alloc] initWithWorldRect:rightBoundsWorldRect withSpace:mSpace withThickness:thickness];
    
    [mGameBoundsList addObject:leftBounds];
    [mGameBoundsList addObject:rightBounds];
}

-(void)createGround
{
    float thickness = kGameRegionGroundThickness;
    CGRect groundWorldRect = CGRectMake(0, (mRegionSize.height * (mRegionIndex + 1)) - thickness, mRegionSize.width, thickness);
    //CGRect groundRect = CGRectMake(0, thickness, zoneSize.width, thickness);
    float screenYPos = mRegionSize.height - thickness;
    
    GameBounds* ground = [[GameBounds alloc] initWithWorldRect:groundWorldRect withSpace:mSpace withThickness:thickness isGround:YES];
    [ground setupSprite:screenYPos];
    [mRegionView addSprite:ground.sprite];
    [mGameBoundsList addObject:ground];
}

-(void)createRandomGameItems
{
    CGPoint itemPos = [self getUnusedGameItemPosition];
    
    [self createGameItemAtLocalPosition:itemPos];
}

-(CGPoint)getUnusedGameItemPosition
{
    int rowIndex = 0;
    
    if (kFirstItemRow < kNumberItemRows)
    {
        rowIndex = (arc4random() % (kNumberItemRows - kFirstItemRow)) + kFirstItemRow;
    }
    else
    {
        rowIndex = kFirstItemRow - 1;
    }
    
    int colIndex = 0;
    
    if (mPreviousGameRegionGameItemColIndex == -1)
    {
        colIndex = arc4random() % kNumberItemColumns;
        //colIndex = kNumberItemColumns / 2;
        //colIndex = 0;
    }
    else
    {
        colIndex = [self getGaussianGameItemColumnIndex:mPreviousGameRegionGameItemColIndex asMirror:NO];
        //colIndex = 7;
    }
    
    DLog("Col Index = %i", colIndex);
    mGameRegionGameItemColumnIndex = colIndex;
    
    // Get position for center of item.
    //CGPoint itemPos = CGPointMake((colIndex * mGridItemSize.width) + (mGridItemSize.width / 2.0f), (rowIndex * mGridItemSize.height) + (mGridItemSize.height / 2.0f));
    //CGPoint itemPos = CGPointMake((mRegionSize.width / 2.0f) - (mGridItemSize.width / 2.0f), (rowIndex * mGridItemSize.height) + (mGridItemSize.height / 2.0f));
    //CGPoint itemPos = CGPointMake(mRegionSize.width / 2.0f, mRegionSize.height - (mGridItemSize.height / 2.0f)); // Middle and bottom of screen.
    
    float itemYCenterPos = 0;
    
    if (mIsGroundRegion)
    {
        itemYCenterPos = mRegionSize.height - kItemDeltaOffset - (mGridItemSize.height / 2.0f);
    }
    else
    {
        itemYCenterPos = mRegionSize.height - (mGridItemSize.height / 2.0f);
    }
    
    float itemXPosOffset = mRegionSize.width / kNumberItemColumns;
    CGPoint itemPos = CGPointMake((itemXPosOffset * colIndex) + (mGridItemSize.width / 2.0f), itemYCenterPos);
    //CGPoint itemPos = CGPointMake((colIndex * mGridItemSize.width) + (mGridItemSize.width / 2.0f), itemYCenterPos);
    
    // Record this grid position.
    //mItemGrid[rowIndex][colIndex] = 1;
    
    return itemPos;
}

-(int)getGaussianGameItemColumnIndex:(int)previousGameItemColIndex asMirror:(bool)mirror
{
    int colIndex = -1;
    
    // Assumes that kNumberItemColumns is an even number.
    double dGauss = drand_gauss(0, 1);
    colIndex = getDiscreteGauss(dGauss, -2, 2);
    DLog("dGauss = %.4f, colIndex = %i", dGauss, colIndex);
    
    if (mirror)
    {
        //int mirrorColIndex = ((previousGameItemColIndex + (kNumberItemColumns / 2)) + gauss) % kNumberItemColumns;
        int mirrorColIndex = (kNumberItemColumns - previousGameItemColIndex - 1 + colIndex) % kNumberItemColumns;
        
        //DLog("mirrorColIndex = %i", mirrorColIndex);
        colIndex = mirrorColIndex;
    }
    else
    {
        colIndex = (previousGameItemColIndex + colIndex) % kNumberItemColumns;
    }
    
    if (colIndex < 0)
    {
        colIndex += kNumberItemColumns;
    }
    
    return colIndex;
}

-(void)createGameItemAtLocalPosition:(CGPoint)localPos
{
    float screenHeight = mRegionSize.height;
    float worldYPos = (screenHeight * mRegionIndex) + localPos.y;
    //CGPoint localPos = CGPointMake(40, 40);
    CGPoint worldPos = CGPointMake(localPos.x, worldYPos);
    //CGSize itemSize = CGSizeMake(mGridItemSize.width, mGridItemSize.height);
    
    NSString* itemName = nil;
    
    if (!mIsGroundRegion)
    {
        itemName = @"Pillow.png";
    }
    else
    {
        itemName = @"Basket.png";
    }
    
    GameItem* item = [[GameItem alloc] initWithSize:mGridItemSize atWorldPosition:worldPos atScreenYPosition:localPos.y withSpace:mSpace withImageNamed:itemName];
    
    [mGameItemList addObject:item];
    [mRegionView addSprite:item.sprite];
}

-(void)addPlayer:(Actor2D*)player
{
    if (player != nil)
    {
        [mPlayerList addObject:player];
        //mPlayer = player;
        [mRegionView addSprite:player.sprite];
    }
}

-(void)removePlayer
{
    // Remove all player objects in this region.
    for (int i = 0; i < mPlayerList.count; i++)
    {
        Actor2D* player = (Actor2D*)[mPlayerList objectAtIndex:i];
        
        // Remove the sprite from the region view management, but don't remove it from the super view yet.
        // We do this since removing a player usually only happens when the player is moving to a new region.
        // The process of moving to a new region automatically removes a sprites super view when it is added to a new one.
        [mRegionView removeSprite:player.sprite andRemoveFromSuperview:NO];
    }
    
    [mPlayerList removeAllObjects];
}

-(void)removePlayer:(Actor2D*)player
{
    [mRegionView removeSprite:player.sprite];
    //mPlayer = nil;
    [mPlayerList removeObject:player];
    
}

-(void)update:(GameTime*)gameTime
{
    for (int i = 0; i < mPlayerList.count; i++)
    {
        Actor2D* player = (Actor2D*)[mPlayerList objectAtIndex:i];

        if (player.isParentActor)
        {
            // Check if player reached bottom of screen.
            if ((player.position.y - (player.size.height / 2.0f)) > mRegionYEnd)
            {
                //DLog("player fell off screen!");
                [self firePlayerExitedRegionDelegate:player];
                //[self removePlayer:mPlayer];
            }
        }
    }
}

-(void)firePlayerExitedRegionDelegate:(Actor2D*)player
{
    if (mRegionDelegate != nil && [mRegionDelegate respondsToSelector:@selector(playerExitedRegion:)])
	{ 
		[mRegionDelegate playerExitedRegion:player];
	}
}

-(void)firePlayerHitGameItemDelegate:(GameItem*)gameItem
{
    if (mRegionDelegate != nil && [mRegionDelegate respondsToSelector:@selector(playerHitGameItem:)])
	{ 
		[mRegionDelegate playerHitGameItem:gameItem];
	}
}

-(void)firePlayerHitGroundDelegate
{
    if (mRegionDelegate != nil && [mRegionDelegate respondsToSelector:@selector(playerHitGround)])
	{ 
		[mRegionDelegate playerHitGround];
	}
}

//cpBool beginItemCollision(cpArbiter* arbiter, cpSpace* space, void* userData)
cpBool preSolveItemCollision(cpArbiter* arbiter, cpSpace* space, void* userData)
{
    //DLog("touch");
    cpBool continueCollisionProcessing = TRUE;
    
    if (userData != NULL)
    {
        GameRegion* region = (__bridge GameRegion*)userData;
        
        // Get the cpShapes involved in the collision
        // The order will be the same as you defined in the handler definition
        // a->collision_type will be GameCollisionTypeActor and b->collision_type will be GameCollisionTypeItem
        cpShape* a;
        cpShape* b;
        
        cpArbiterGetShapes(arbiter, &a, &b);
        
        if (a != NULL && b != NULL)
        {
            Actor2D* player = (__bridge Actor2D*)cpShapeGetUserData(a);
            GameItem* gameItem = (__bridge GameItem*)cpShapeGetUserData(b);
            
            // Check if we have reached middle of game item to be considered a real collision.
            // This is inefficient and simplistic for now.
            float gameItemHalfWidth = gameItem.size.width * 0.5;
            float itemXMin = (gameItem.position.x - gameItemHalfWidth);
            float itemXMax = (gameItem.position.x + gameItemHalfWidth);
            //DLog("Player: %.2f", player.position.x);
            //DLog("Box: %.2f, %.2f", itemXMin, itemXMax);
            
            if (player.position.x >= itemXMin && player.position.x <= itemXMax)
            {
                player = [Actor2D getRootActor:player];
                
                if (!region.isGroundRegion)
                {
                    player.actorState = ActorStateFallingPillow;
                    gameItem.sprite.hidden = YES;
                }
                else
                {
                    if (player.actorState == ActorStateFallingPillow)
                    {
                        player.actorState = ActorStateSleeping;
                        gameItem.sprite.hidden = YES;
                    }
                }
                
                // Change color of the GameItem to let the user know they hit it.
                gameItem.sprite.color = ColorMakeFromUIColor([UIColor yellowColor]);
                
                [region firePlayerHitGameItemDelegate:gameItem];
                
                // Add a post step callback to safely remove the body and shape from the space.
                // Calling cpSpaceRemove*() directly from a collision handler callback can cause crashes.
                //cpSpaceAddPostStepCallback(space, (cpPostStepFunc)postStepRemove, b, NULL);
            }
            
            continueCollisionProcessing = FALSE;
        }
    }
    
    return continueCollisionProcessing;
}

cpBool beginGroundCollision(cpArbiter* arbiter, cpSpace* space, void* userData)
{
    cpBool continueCollisionProcessing = TRUE;
    
    if (userData != NULL)
    {
        GameRegion* region = (__bridge GameRegion*)userData;
        
        cpShape* a;
        cpShape* b;
        
        cpArbiterGetShapes(arbiter, &a, &b);
        
        if (a != NULL && b != NULL)
        {
            Actor2D* player = (__bridge Actor2D*)cpShapeGetUserData(a);
            player = [Actor2D getRootActor:player];
            
            if (player.actorState != ActorStateSleeping && player.actorState != ActorStateSplat && player.actorState != ActorStateSplatPillow)
            {
                if (player.actorState == ActorStateFallingPillow)
                {
                    player.actorState = ActorStateSplatPillow;
                }
                else
                {
                    player.actorState = ActorStateSplat;
                }
            }
            
            [region firePlayerHitGroundDelegate];
        }
    }
    
    return continueCollisionProcessing;
}

//void postStepRemove(cpSpace* space, cpShape* shape, void* userData)
//{
//    cpSpaceRemoveBody(space, shape->body);
//    cpBodyFree(shape->body);
//    
//    cpSpaceRemoveShape(space, shape);
//    cpShapeFree(shape);
//}


@end
