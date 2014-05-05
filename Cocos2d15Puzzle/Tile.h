//
//  Tile.h
//  Cocos2d15Puzzle
//
//  Created by 篠原正樹 on 2014/05/05.
//  Copyright 2014年 masakishinohara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


//長押し
#define TILE_MSG_NOTIFY_TOUCH_HOLD  @"TileMsgNotifyTouchHold"

//タッチ終了
#define TILE_MSG_NOTIFY_TOUCH_END  @"TileMsgNotifyTouchEnd"

//タッチ座標移動
#define TILE_MSG_NOTIFY_TOUCH_MOVE  @"TileMsgNotifyTouchMove"

//正解位置のガイドナンバー表示
#define TILE_MSG_NOTIFY_SHOW_NUMBER  @"TileMsgNotifyShowNumber"

//正解位置のガイドナンバー非表示
#define TILE_MSG_NOTIFY_HIDE_NUMBER  @"TileMsgNotifyHideNumber"

//タッチイベントメッセージ
#define TILE_MSG_NOTIFY_TAP @"TileMsgNotifyTap"


@interface Tile : CCSprite <CCTouchOneByOneDelegate>{
    
    CCSprite * _imgFrame;//不正解用の枠
    CCSprite * _imgBlinkFrame;//正解用の枠
    CCLabelTTF * _lblAnswer;//正解位置の表示用ラベル
    int _answer;//正解位置
    int _now; //現在位置
    BOOL _isTouchBegin; //自分の領域でタッチイベントが発生したか
    CGPoint _touchLocation; //タッチか開始した座上
    ccTime _deltaTime; //タッチ開始からの経過時間
    BOOL _isBlank; //ブランクタイルか
    
}

@property(nonatomic, readwrite) int Answer;
@property(nonatomic, readwrite)int Now;
@property(nonatomic, readonly) BOOL IsTouchHold;
@property(nonatomic, readwrite) BOOL IsBlank;



//枠作成メソッド
-(void) createFrame;

@end
