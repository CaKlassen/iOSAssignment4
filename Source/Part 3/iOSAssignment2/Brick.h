//
//  Brick.hpp
//  iOSAssignment2
//
//  Created by Alexandra Kabak on 2016-03-20.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#ifndef Brick_h
#define Brick_h

#include <stdio.h>
#import <Box2D/Box2D.h>
#import "Sprite.h"

@interface Brick : Sprite

-(id)initWithPosition:(GLKVector3)position world:(b2World*)world;
-(void)updatePosition:(GLKVector3)position;

@property (assign) bool alive;

@end

#endif /* Brick_hpp */
