//
//  TitleLayer.m
//  Cocos2d15Puzzle
//
//  Created by 篠原正樹 on 2014/04/30.
//  Copyright 2014年 masakishinohara. All rights reserved.
//

#import "TitleLayer.h"
#import "GameLayer.h"


@implementation TitleLayer

+(CCScene *) scene
{
    
    CCScene * scene = [CCScene node];
    
    TitleLayer *layer = [TitleLayer node];
    
    [scene addChild:layer];
    
    return scene;
}

-(void)onEnter
{
    
    [super onEnter];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    CCSprite * backImage = [CCSprite spriteWithFile:@"image.png"];
    
    backImage.position = CGPointMake(winSize.width / 2, winSize.height / 2);
    
    backImage.color = ccc3(100, 100, 100);
    
    [self addChild:backImage z:0];
    
    
    
    [CCMenuItemFont setFontName:@"Helvetica-BoldOblique"];
    
    [CCMenuItemFont setFontSize:60];
    
    CCMenuItemFont * item = [CCMenuItemFont itemWithString:@"ゲームスタート" block:^(id sender)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameLayer scene] withColor:ccWHITE]];
        
    }];
    
        CCMenu * menu = [CCMenu menuWithItems:item, nil];
        
        menu.position = CGPointMake(winSize.width / 2, 60);
        
        [self addChild:menu];

}

                             
@end
