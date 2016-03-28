//
//  PlayerPaddle.mm
//  iOSAssignment2
//
//  Created by ChristoferKlassen on 2016-03-17.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box.h"

@interface Box ()
{
	btDiscreteDynamicsWorld* world;
	btCollisionShape *baseShape;
	btCollisionShape *sideShape;
	btDefaultMotionState *baseMotionState;
	btDefaultMotionState *leftMotionState;
	btDefaultMotionState *rightMotionState;
	btRigidBody *baseBody;
	btRigidBody *leftBody;
	btRigidBody *rightBody;
	
	float rotation;
}

@end


@implementation Box

static const NSString* FILE_NAME = @"BoxEdge.png";


-(id)initWithPosition:(GLKVector3)position world:(btDiscreteDynamicsWorld *)physicsWorld;
{
	self = [super initWithTextureFile:FILE_NAME];
	
	self.position = position;
	world = physicsWorld;
	rotation = 0.1f;
	
	// Create the rigid bodies
	baseShape = new btBoxShape(btVector3(16, 2, 1));
	sideShape = new btBoxShape(btVector3(2, 16, 1));
	
	baseMotionState = new btDefaultMotionState(btTransform(btQuaternion(0, 0, 0, 1), btVector3(position.x, position.y - 16, position.z)));
	leftMotionState = new btDefaultMotionState(btTransform(btQuaternion(0, 0, 0, 1), btVector3(position.x - 16, position.y, position.z)));
	rightMotionState = new btDefaultMotionState(btTransform(btQuaternion(0, 0, 0, 1), btVector3(position.x + 16, position.y, position.z)));
	
	btRigidBody::btRigidBodyConstructionInfo baseRigidBodyCI(0, baseMotionState, baseShape, btVector3(0, 0, 0));
	btRigidBody::btRigidBodyConstructionInfo leftRigidBodyCI(0, leftMotionState, sideShape, btVector3(0, 0, 0));
	btRigidBody::btRigidBodyConstructionInfo rightRigidBodyCI(0, rightMotionState, sideShape, btVector3(0, 0, 0));
	
	baseBody = new btRigidBody(baseRigidBodyCI);
	leftBody = new btRigidBody(leftRigidBodyCI);
	rightBody = new btRigidBody(rightRigidBodyCI);
	
	// Add the rigid body to the game world
	physicsWorld->addRigidBody(baseBody);
	physicsWorld->addRigidBody(leftBody);
	physicsWorld->addRigidBody(rightBody);
	
	return self;
}

-(void)update
{
}


-(void)updatePosition:(GLKVector3)speed
{

}

-(void)draw:(Program *)program camera:(Camera *)camera
{
	[self setTexture];
	
	GLKVector3 eyeDir = GLKVector3Make([[camera lookAt] x], [[camera lookAt] y], [[camera lookAt] z]);
	
	GLKMatrix4 viewProj = [camera perspective];
	
	// Set up the shader uniforms
	[program setUniform:@"ViewProj" value:&viewProj size:sizeof(viewProj)];
	[program setUniform:@"EyeDirection" value:&eyeDir size:sizeof(eyeDir)];
	
	
	// BOTTOM //
	
	// Set up the model matrix
	GLKMatrix4 modelMatrix = GLKMatrix4Identity;
	modelMatrix = GLKMatrix4Translate(modelMatrix, 0, 0, -200);
	modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y - 16, self.position.z);
	
	_normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelMatrix), NULL);
	
	[program setUniform:@"World" value:&modelMatrix size:sizeof(modelMatrix)];
	[program setUniform:@"normalMatrix" value:&_normalMatrix size:sizeof(_normalMatrix)];
	
	[program useProgram:_vertexArray];
	
	// Draw the sprite
	glDrawArrays(GL_TRIANGLES, 0, NumVertices);
	
	
	// LEFT //
	
	// Set up the model matrix
	modelMatrix = GLKMatrix4Identity;
	modelMatrix = GLKMatrix4Translate(modelMatrix, 0, 0, -200);
	modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x - 16, self.position.y, self.position.z);
	modelMatrix = GLKMatrix4RotateZ(modelMatrix, M_PI / 2);
	
	_normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelMatrix), NULL);
	
	[program setUniform:@"World" value:&modelMatrix size:sizeof(modelMatrix)];
	[program setUniform:@"normalMatrix" value:&_normalMatrix size:sizeof(_normalMatrix)];
	
	[program useProgram:_vertexArray];
	
	// Draw the sprite
	glDrawArrays(GL_TRIANGLES, 0, NumVertices);
	
	
	// RIGHT //
	
	// Set up the model matrix
	modelMatrix = GLKMatrix4Identity;
	modelMatrix = GLKMatrix4Translate(modelMatrix, 0, 0, -200);
	modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x + 16, self.position.y, self.position.z);
	modelMatrix = GLKMatrix4RotateZ(modelMatrix, M_PI / 2);
	
	_normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelMatrix), NULL);
	
	[program setUniform:@"World" value:&modelMatrix size:sizeof(modelMatrix)];
	[program setUniform:@"normalMatrix" value:&_normalMatrix size:sizeof(_normalMatrix)];
	
	[program useProgram:_vertexArray];
	
	// Draw the sprite
	glDrawArrays(GL_TRIANGLES, 0, NumVertices);

}

@end