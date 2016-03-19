//
//  EnemyPaddle.h
//  iOSAssignment2
//
//  Created by ChristoferKlassen on 2016-03-19.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#ifndef EnemyPaddle_h
#define EnemyPaddle_h

#import "Sprite.h"
#import <Box2D/Box2D.h>


@interface EnemyPaddle : Sprite

-(id)initWithPosition:(GLKVector3)position world:(b2World*)world;

-(void)updatePosition:(GLKVector3)position;

@end


#endif /* EnemyPaddle_h */
