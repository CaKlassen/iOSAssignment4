//
//  Overlay.h
//  iOSAssignment2
//
//  Created by Alexandra Kabak on 2016-03-27.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#ifndef Overlay_h
#define Overlay_h

#include <stdio.h>
#import <Box2D/Box2D.h>
#import "Sprite.h"

@interface Overlay : Sprite

-(id)initWithPosition:(GLKVector3)position world:(b2World*)world;
-(void)updatePosition:(GLKVector3)position;

@end
#endif /* Overlay_h */
