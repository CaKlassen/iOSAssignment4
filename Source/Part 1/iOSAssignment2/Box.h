//
//  PlayerPaddle.h
//  iOSAssignment2
//
//  Created by ChristoferKlassen on 2016-03-17.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#ifndef Box_h
#define Box_h

#import "btBulletDynamicsCommon.h"
#import "Sprite.h"


@interface Box : Sprite

-(id)initWithPosition:(GLKVector3)position world:(btDiscreteDynamicsWorld*)world;

-(void)updatePosition:(GLKVector3)position;

@end

#endif /* PlayerPaddle_h */
