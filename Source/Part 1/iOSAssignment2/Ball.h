//
//  Ball.h
//  iOSAssignment2
//
//  Created by ChristoferKlassen on 2016-03-18.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#ifndef Ball_h
#define Ball_h

#import "btBulletDynamicsCommon.h"
#import "Sprite.h"


@interface Ball : Sprite

-(id)initWithPosition:(GLKVector3)position world:(btDiscreteDynamicsWorld*)world;

-(void)updatePosition:(GLKVector3)position;

@end

#endif /* Ball_h */
