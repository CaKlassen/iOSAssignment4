//
//  PlayerPaddle.mm
//  iOSAssignment2
//
//  Created by ChristoferKlassen on 2016-03-17.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ground.h"

@interface Ground ()
{
	btDiscreteDynamicsWorld* world;
	btCollisionShape *shape;
	btDefaultMotionState *motionState;
	btRigidBody *rigidBody;
	
	float rotation;
}

@end


@implementation Ground

static const NSString* FILE_NAME = @"Paddle.png";


-(id)initWithPosition:(GLKVector3)position world:(btDiscreteDynamicsWorld *)physicsWorld;
{
	self = [super initWithTextureFile:FILE_NAME];
	
	self.position = position;
	world = physicsWorld;
	rotation = -0.1f;
	
	// Create the rigid body
	shape = new btBoxShape(btVector3(48, 16, 1));
	motionState = new btDefaultMotionState(btTransform(btQuaternion(0, 0, 0, 1), btVector3(position.x, position.y, position.z)));
	btRigidBody::btRigidBodyConstructionInfo rigidBodyCI(0, motionState, shape, btVector3(0, 0, 0));
	rigidBody = new btRigidBody(rigidBodyCI);
	
	// Set up the default rotation
	btTransform transform;
	transform.setIdentity();
	btQuaternion quat;
	quat.setEulerZYX(rotation, 0, 0);
	transform.setRotation(quat);
	transform.setOrigin(btVector3(position.x, position.y, position.z));
	
	rigidBody->setCenterOfMassTransform(transform);
	
	// Add the rigid body to the game world
	physicsWorld->addRigidBody(rigidBody);
	
	return self;
}

-(void)update
{
}


-(void)rotate:(float)rot
{
	rotation = MAX(-0.2f, MIN(0.2f, rotation + rot));
	
	// Set up the rotation
	btTransform transform;
	transform.setIdentity();
	btQuaternion quat;
	quat.setEulerZYX(rotation, 0, 0);
	transform.setRotation(quat);
	transform.setOrigin(btVector3(self.position.x, self.position.y, self.position.z));
	
	rigidBody->setCenterOfMassTransform(transform);
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
	modelMatrix = GLKMatrix4RotateZ(modelMatrix, rotation);
	
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