//
//  Tile.m
//  Cocos2d15Puzzle
//
//  Created by 篠原正樹 on 2014/04/30.
//  Copyright 2014年 masakishinohara. All rights reserved.
//

#import "Tile.h"


@interface  Tile()

//画像を自己と同じサイズに加工して返す
-(UIImage*) shapingImageNamed:(NSString *)imageNamed;

//通知センターからの通知イベント
-(void) NotifyFromNotificationCenter:(NSNotification *)notification;

//ボタン内の座標にタッチ座標が含まれているかを返す
-(BOOL) containsTouchLocation:(UITouch *)touch;

//タッチ地点移動によるガイドナンバー表示
-(void) showGuideNumByTouch:(UITouch *)touch;

//スケジュールイベント：画像長押し
-(void) scheduleEventTouchHold:(ccTime)delta;

//正解フレームのアニメーション表示
-(void) blinkFrame;

@end


@implementation Tile


@dynamic Answer;
-(int) Answer
{
    return _answer;
}


//ガイドナンバー表示用のラベル生成処理
-(void) setAnswer:(int)Answer
{
    _answer = Answer;
    
    if (_lblAnswer == nil) {
        
        _lblAnswer = [CCLabelTTF labelWithString:@"99" fontName:@"Arial-BoldMT" fontSize:40];
        
        _lblAnswer.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
        
        _lblAnswer.color = ccc3(250, 100, 40);
        
        [self addChild:_lblAnswer z:2];
        
        _lblAnswer.visible = NO;
        
        _lblAnswer.scale = MIN((self.contentSize.width * 0.8) / _lblAnswer.contentSize.width, (self.contentSize.height * 0.8) / _lblAnswer.contentSize.height);
        
        if (_lblAnswer.scale > 1.0) {
            _lblAnswer.scale = 1.0;
        }
        
    }
    
    [_lblAnswer setString:[NSString stringWithFormat:@"%d", Answer + 1]];
    
}


//自タイルが空白タイルであるか
@dynamic IsBlank;
-(BOOL) IsBlank{
    
    return _isBlank;
    
}


-(void) setIsBlank:(BOOL)IsBlank
{
    _isBlank = IsBlank;
    
    if (_isBlank) {
        self.opacity = 0;
    }
    else{
        self.opacity = 255;
    }
    
}


@synthesize Now = _now;
@synthesize IsTouchHold = _IsTouchHold;


//初期化処理
-(id) init
{
    if (self = [super init]) {
        
        //メンバー初期化
        _imgFrame = nil;
        _imgBlinkFrame = nil;
        _lblAnswer = nil;
        _answer = 0;
        _now = 0;
        _isTouchBegin = NO;
        _IsTouchHold = NO;
        _touchLocation = CGPointZero;
        _deltaTime = 0.0;
        _isBlank = NO;
        
    }
    
    return self;
    
}


-(void) onEnter
{
    [super onEnter];
    
    [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:-9 swallowsTouches:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotifyFromNotificationCenter:) name:nil object:nil];
    
}


-(void) onExit
{
    
    [super onExit];
    
    [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}



//画像を自己と同じサイズに加工して返す
-(UIImage*) shapingImageNamed:(NSString *)imageNamed
{
    UIImage * resultImage = [UIImage imageNamed:imageNamed];
    //タイル画像内に表示
    UIGraphicsBeginImageContext(CGSizeMake(self.contentSize.width, self.contentSize.height));
    
    [resultImage drawInRect:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
    
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}



//枠作成
-(void) createFrame
{
    
    //既に枠がある場合　解放する
    if (_imgFrame != nil){
        [_imgFrame removeFromParentAndCleanup:YES];
        _imgFrame = nil;
        
    }
    
    
    if(_imgBlinkFrame != nil){
        [_imgBlinkFrame removeFromParentAndCleanup:YES];
        _imgBlinkFrame = nil;
    }
    
    //フレームを作成
    //フレームの拡大縮小処理
    _imgFrame = [CCSprite spriteWithCGImage:[self shapingImageNamed:@"Frame.png"].CGImage key:nil];
    //フレームをタイル画像の中心に設定
    _imgFrame.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
    //透明度設定
    _imgFrame.opacity = 127;
    [self addChild:_imgFrame z:1];
    _imgFrame.visible = NO;
    
    _imgBlinkFrame = [CCSprite spriteWithCGImage:[self shapingImageNamed:@"BlinkFrame.png"].CGImage key:nil];
    _imgBlinkFrame.position = CGPointMake(self.contentSize.width / 2, self.contentSize.height / 2);
    _imgBlinkFrame.opacity = 127;
    [self addChild:_imgBlinkFrame z:1];
    _imgBlinkFrame.visible = NO;
    
}




//タッチ開始
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    BOOL bResult = NO;
    
    _IsTouchHold = NO;
    
    if ([self containsTouchLocation:touch]) {
        
        CGPoint touchLocation = [touch locationInView:[touch view]];
        
        _touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
        
        _deltaTime = 0.0;
        
        [self schedule:@selector(scheduleEventTouchHold:)];
        
        _isTouchBegin = YES;
        
        bResult = YES;
        
    }
    return bResult;
}


//ボタンタッチ中移動通知
-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView: [touch view]];
    
    CGPoint currentTouchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    
    CGPoint difference = ccpSub(_touchLocation, currentTouchLocation);
    
    float factor = 20;
    
    if ((abs(difference.x) > factor) || (abs(difference.y) > factor))
    {
        NSDictionary * dic  = [NSDictionary dictionaryWithObject:touch forKey:TILE_MSG_NOTIFY_TOUCH_MOVE];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TILE_MSG_NOTIFY_TOUCH_MOVE object:self userInfo:dic];
        
        _touchLocation = currentTouchLocation;
        
    }
    
}


//ボタンタッチ終了通知
-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self unschedule:@selector(scheduleEventTouchHold:)];
    
    if (_isTouchBegin == YES) {
        if ([self containsTouchLocation:touch]) {
            if (_IsTouchHold == NO) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TILE_MSG_NOTIFY_TAP object:self];
                
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TILE_MSG_NOTIFY_TOUCH_END object:self];
    
    _isTouchBegin = NO;
    
}


//ボタン内の座標中にタッチ座標が含まれているかを返す
-(BOOL)containsTouchLocation:(UITouch *)touch
{
    
    CGPoint touchLocation = [touch locationInView:[touch view]];
    
    CGPoint location = [[CCDirector sharedDirector] convertToGL:touchLocation];
    
    CGRect boundingBox = self.boundingBox;
    
    CCNode * parent = self.parent;
    
    while (parent != nil) {
        if ([parent isKindOfClass:[CCLayer class]]) {
            break;
        }
        else{
            parent = parent.parent;
        }
    }
    
    if (parent != nil) {
        boundingBox.origin = ccpAdd(boundingBox.origin, parent.position);
    }
    return CGRectContainsPoint(boundingBox, location);
}




//正解フレームのアニメーション表示
-(void) blinkFrame
{
    float maxOpacity = 127;
    
    _imgBlinkFrame.opacity = maxOpacity;
    _imgBlinkFrame.visible = YES;
    
    id fadeOut = [CCFadeTo actionWithDuration:0.3 opacity:0];
    
    id fadeIn = [CCFadeTo actionWithDuration:0.8 opacity:maxOpacity];
    
    id seq = [CCSequence actions:fadeOut, fadeIn, nil];
    
    id rep = [CCRepeatForever actionWithAction:seq];
    
    [_imgBlinkFrame runAction:rep];
    
}



//通知センターからの通知イベント
-(void) NotifyFromNotificationCenter:(NSNotification *)notification
{
    if (notification.name == TILE_MSG_NOTIFY_TOUCH_HOLD) {
        
        if (_isBlank == NO)
        {
            if (_answer == _now)
            {
                [self blinkFrame];
            }else
            {
                _lblAnswer.visible = YES;
                _imgFrame.visible =YES;
            }
        }
        else
        {
            _imgFrame.visible = YES;
        }
    }

    else if(notification.name  == TILE_MSG_NOTIFY_TOUCH_END){
        _lblAnswer.visible = NO;
        _imgFrame.visible = NO;
        [_imgBlinkFrame stopAllActions];
        _imgBlinkFrame.visible = NO;
        
    }
    
    else if (notification.name  == TILE_MSG_NOTIFY_TOUCH_MOVE)
    {
        if (((Tile *)notification.object).IsTouchHold)
        {
            [self showGuideNumByTouch:[notification.userInfo objectForKey:TILE_MSG_NOTIFY_TOUCH_MOVE]];
            
        }
    }
    
    else if (notification.name == TILE_MSG_NOTIFY_SHOW_NUMBER)
    {
        
        if ((_answer == _now) && (_isBlank == NO))
        {
            
            _lblAnswer.visible = YES;
            
        }
        
        else if (_isBlank && notification.object != self)
        {
            _lblAnswer.visible = NO;
        }
    }
    
    else if (notification.name  == TILE_MSG_NOTIFY_HIDE_NUMBER)
    {
        
        if (_isBlank || (_answer == _now)) {
            
            _lblAnswer.visible = NO;
        }
    }
    
}


//タッチ地点移動によるガイドナンバー表示
-(void) showGuideNumByTouch:(UITouch*)touch
{
    
    if ([self containsTouchLocation:touch])
    {
        if ((_answer == _now) || _isBlank) {
            _lblAnswer.visible = YES;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TILE_MSG_NOTIFY_SHOW_NUMBER object:self];
        }
        
        else if (_answer != _now)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:TILE_MSG_NOTIFY_HIDE_NUMBER object:self];
        }
    }
}


//スケジュールイベント　画像長押し
-(void)scheduleEventTouchHold:(ccTime)delta
{
    if(_isTouchBegin == NO){
       
        return;
    }
    
    _deltaTime += delta;
    
    
    if (_deltaTime > 2.0) {
        
        _IsTouchHold = YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TILE_MSG_NOTIFY_TOUCH_HOLD object:self];
        
        [self unschedule:_cmd];
        
        if ((_answer == _now) || _isBlank) {
        
            _lblAnswer.visible = YES;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TILE_MSG_NOTIFY_SHOW_NUMBER object:self];
        }
    }
}


@end