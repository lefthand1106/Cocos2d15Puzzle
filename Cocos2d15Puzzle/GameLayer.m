//
//  GameLayer.m
//  Cocos2d15Puzzle
//
//  Created by 篠原正樹 on 2014/04/30.
//  Copyright 2014年 masakishinohara. All rights reserved.
//

#import "GameLayer.h"
#import "ClearLayer.h"

@interface GameLayer ()

-(void) setTiles;

-(void)shuffle;

-(Tile *) getTileAtNow:(int)now;

-(void) NotifyFromNotifiationCenter:(NSNotification*)notification;

-(void) tapTile:(Tile *)tile;

@end

@implementation GameLayer


+(CCScene *)scene
{
    
    CCScene *scene = [CCScene node];
    
    GameLayer *layer = [GameLayer node];
    
    [scene addChild:layer];
    
    return scene;
    
}

-(id) init
{
    if (self = [super init]) {
        _tileCount = 16;
        _tileList = nil;
        _actionCount = 0;
        _finishedActionCount = 0;
    }
    
    return self;
}


-(void)dealloc
{
    [_tileList release];
    [super dealloc];
}


-(void)onEnter
{
    [super onEnter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotifyFromNotifiationCenter:) name:nil object:nil];
    
    
    CCTexture2D * tex = [[[CCTexture2D alloc] initWithCGImage:[UIImage imageNamed:@"image.png"].CGImage resolutionType:kCCResolutioniPhone ] autorelease];
    
    int sideTileCount = (int)sqrt((double)_tileCount);
    
    CGSize tileSize = CGSizeMake(tex.contentSize.width / sideTileCount, tex.contentSize.height / sideTileCount);
    
    _tileList = [[CCArray alloc] initWithCapacity:_tileCount];
    
    for (int i = 0; i < _tileCount; i++) {
        Tile * tile = [Tile spriteWithTexture:tex rect:CGRectMake(tileSize.width * (i % sideTileCount), tileSize.height * (i / sideTileCount), tileSize.width, tileSize.height)];
        
        [_tileList addObject:tile];
        
        [self addChild:tile z:1];
        
        tile.Answer = i;
        
        [tile createFrame];
        
        if (i == _tileCount - 1) {
            tile.IsBlank = YES;
            
        }
    }
    
    [self setTiles];
    
    [self shuffle];
    
}

-(void) onExit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super onExit];
    
}





-(void)setTiles
{
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CGSize tileSize =((Tile *)[_tileList objectAtIndex:0]).contentSize;
    
    int sideTileCount = (int)sqrt((double)_tileCount);
    
    float blankX = (winSize.width - tileSize.width * sideTileCount) / 2;
    
    float blankY = (winSize.height - tileSize.height * sideTileCount) / 2;
    
    for (int i = 0; i < _tileList.count; i++){
        Tile * tile = [_tileList objectAtIndex:i];
        tile.position = CGPointMake(blankX + tileSize.width / 2 + tileSize.width * (i % sideTileCount), winSize.height - blankY - tileSize.height / 2 - tileSize.height * (i / sideTileCount));
        
        tile.Now = i;
    }
    
    
}



-(void)shuffle
{
    
    Tile * blankTile = [_tileList lastObject];
    
    int sideTileCount = (int)sqrt((double)_tileCount);
    
    for(int i = 0; i < _tileCount * 100; i++){
        
        int checkPosition = -1;
        
        int direction = arc4random() % 4;
        switch (direction) {
            case 0:
                checkPosition = blankTile.Now - sideTileCount;
                if (checkPosition > 0) {
                    
                }
                else{
                    checkPosition = -1;
                }
                break;
                
            case 1:
                checkPosition = blankTile.Now + 1;
                if (checkPosition % sideTileCount != 0) {
                }
                else{
                    checkPosition = -1;
                }
                break;
                
            case 2:
                checkPosition = blankTile.Now + sideTileCount;
                if (checkPosition < _tileList.count) {
                }
                else{
                    checkPosition = -1;
                }
                break;
                
            case 3:
                checkPosition = blankTile.Now - 1;
                if (checkPosition % sideTileCount != sideTileCount -1) {
                }
                else{
                    checkPosition = -1;
                }
                break;
                
            default:
                checkPosition = -1;
                break;
                
        }
        
        
        if(checkPosition > -1){
            Tile * tile = [self getTileAtNow:checkPosition];
            
            int tempIndex = blankTile.Now;
            CGPoint tempPosition = blankTile.position;
            blankTile.position = tile.position;
            blankTile.Now = tile.Now;
            tile.Now = tempIndex;
            tile.position = tempPosition;
        }
    }
}


-(Tile *) getTileAtNow:(int)now
{
    
    Tile * result = nil;
    
    for (Tile * tile in _tileList) {
        if (tile.Now == now) {
            result = tile;
            break;
        }
    }
    
    return result;
}


-(void)NotifyFromNotifiationCenter:(NSNotification *)notification
{
    
    if (notification.name  == TILE_MSG_NOTIFY_TAP)
    {
        [self tapTile:notification.object];
    }
}



-(void) tapTile:(Tile *)tile
{
    BOOL checkResult = NO;
    
    int sideTileCount = (int)sqrt((double)_tileCount);
    
    CCArray * searchList = [CCArray arrayWithCapacity:sideTileCount];
    
    Tile * blankTile = [_tileList lastObject];
    
    int checkPosition = blankTile.Now - sideTileCount;
    
    while(checkPosition > -1){
        [searchList addObject:[self getTileAtNow:checkPosition]];
        if(tile.Now == checkPosition){
            checkResult = YES;
            break;
        }
        checkPosition -= sideTileCount;
    }
    
    if(checkResult == NO){
        [searchList removeAllObjects];
        
        checkPosition = blankTile.Now + 1;

        while((checkPosition % sideTileCount != 0) && (checkPosition < _tileList.count)){
            
            [searchList addObject:[self getTileAtNow:checkPosition]];
        
            if(tile.Now == checkPosition){
            
                checkResult = YES;
                
                break;
            }
            
            checkPosition++;
        }
        
    }
    
    
    if(checkResult == NO){
        
        [searchList removeAllObjects];
        
        checkPosition = blankTile.Now + sideTileCount;
        
        while (checkPosition < _tileList.count){

            [searchList addObject:[self getTileAtNow:checkPosition]];
            
            if(tile.Now == checkPosition){

                checkResult = YES;
                
                break;
                
            }
            
            checkPosition += sideTileCount;
            
        }
    }
    
    
    if(checkResult == NO){
        
        [searchList removeAllObjects];
        
        checkPosition = blankTile.Now - 1;
        
        while((checkPosition % sideTileCount != sideTileCount - 1) && (checkPosition > -1)){
            [searchList addObject:[self getTileAtNow:checkPosition]];
            if(tile.Now == checkPosition){
                checkResult = YES;
                break;
            }
            checkPosition--;
        }
        
    }
    
    
    
    if(checkResult){
        CCArray* actionList = [CCArray arrayWithCapacity:searchList.count];
        
        _finishedActionCount = 0;
        
        for(Tile* tile in searchList){
            
            int tempIndex = blankTile.Now;
            
            id move = [CCMoveTo actionWithDuration:0.1 position:blankTile.position];
            
            id moveEnd = [CCCallBlock actionWithBlock:^{
                
                _finishedActionCount++;
                
                if (_finishedActionCount == _actionCount) {
                    BOOL isClear = YES;
                    for (Tile* tile in _tileList) {
                        if (tile.Answer != tile.Now) {
                            isClear = NO;
                            break;
                        }
                    }
                    
                    if (isClear) {
                        [self addChild:[ClearLayer node] z:2];
                    
                        ((Tile*)[_tileList lastObject]).IsBlank = NO;
                    
                    }
                }
            }];
            
            id seq = [CCSequence actions:move, moveEnd, nil];
            
            blankTile.position = tile.position;
            
            blankTile.Now = tile.Now;
            
            tile.Now = tempIndex;
            
            [actionList addObject:seq];
            
        }
        
        _actionCount = actionList.count;
        
        for(int i = 0; i < searchList.count; i++){
            
            Tile* tile = [searchList objectAtIndex:i];
            
            id action = [actionList objectAtIndex:i];
            
            [tile runAction:action];
        }
        
    }
    
}











@end
