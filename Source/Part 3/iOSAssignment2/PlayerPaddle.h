//
//  PlayerPaddle.h
//  iOSAssignment2
//
//  Created by ChristoferKlassen on 2016-03-17.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#ifndef PlayerPaddle_h
#define PlayerPaddle_h

#import <Box2D/Box2D.h>
#import "Sprite.h"


@interface PlayerPaddle : Sprite

-(id)initWithPosition:(GLKVector3)position world:(b2World*)world;

-(void)updatePosition:(GLKVector3)position;

-(void)removeFromBox2D;

@end

#endif /* PlayerPaddle_h */
