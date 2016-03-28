//
//  Wall.h
//  iOSAssignment2
//
//  Created by ChristoferKlassen on 2016-03-19.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#ifndef Wall_h
#define Wall_h

#import <GLKit/GLKit.h>
#import <Box2D/Box2D.h>
#import "Entity.h"

@interface Wall : Entity

-(id)initWithPosition:(GLKVector3) pos world:(b2World*)world top:(bool) top;

@end

#endif /* Wall_h */
