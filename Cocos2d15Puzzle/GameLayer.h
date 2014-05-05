//
//  GameLayer.h
//  Cocos2d15Puzzle
//
//  Created by 篠原正樹 on 2014/04/30.
//  Copyright 2014年 masakishinohara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Tile.h"

@interface GameLayer : CCLayer {
 
    int _tileCount;//総タイル数
    CCArray * _tileList;//tileオブジェクトを格納する配列
    int _actionCount;//タイル移動アクション総数
    int _finishedActionCount;//完了したタイル指導アクション数
}

+(CCScene *) scene;

@end
