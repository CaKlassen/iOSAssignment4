//
//  Ball.m
//  iOSAssignment2
//
//  Created by ChristoferKlassen on 2016-03-18.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ball.h"

@interface Ball ()
{
	btDiscreteDynamicsWorld* world;
}

@end


@implementation Ball

static const NSString* FILE_NAME = @"Ball.png";
static const int BALL_SPEED = -120;
static const int OUTSIDE_OFF = 240;


-(id)initWithPosition:(GLKVector3)position world:(btDiscreteDynamicsWorld *)physicsWorld;
{
	self = [super initWithTextureFile:FILE_NAME];
	
	self.position = position;
	world = physicsWorld;
	
	return self;
}

-(void)update
{

}

-(void)reset
{

}


-(void)updatePosition:(GLKVector3)speed
{

}

-(void)draw:(Program *)program camera:(Camera *)camera
{
	// Set up the model matrix
	GLKMatrix4 modelMatrix = GLKMatrix4Identity;
	modelMatrix = GLKMatrix4Translate(modelMatrix, 0, 0, -200);
	modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, self.position.z);
	
	_normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelMatrix), NULL);
	
	[self setTexture];
	
	GLKVector3 eyeDir = GLKVector3Make([[camera lookAt] x], [[camera lookAt] y], [[camera lookAt] z]);
	
	GLKMatrix4 viewProj = [camera perspective];
	
	// Set up the shader uniforms
	[program setUniform:@"ViewProj" value:&viewProj size:sizeof(viewProj)];
	[program setUniform:@"World" value:&modelMatrix size:sizeof(modelMatrix)];
	[program setUniform:@"normalMatrix" value:&_normalMatrix size:sizeof(_normalMatrix)];
	[program setUniform:@"EyeDirection" value:&eyeDir size:sizeof(eyeDir)];
	
	[program useProgram:_vertexArray];
	
	// Draw the sprite
	glDrawArrays(GL_TRIANGLES, 0, NumVertices);
}

@end