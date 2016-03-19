//
//  EnemyPaddle.m
//  iOSAssignment2
//
//  Created by ChristoferKlassen on 2016-03-19.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnemyPaddle.h"

@interface EnemyPaddle ()
{
	b2World* world;
	b2BodyDef bodyDef;
	b2Body *body;
	
	Ball *ball;
}

@end


@implementation EnemyPaddle

static const NSString* FILE_NAME = @"Paddle.png";
static const float MAX_MOVE_SPEED = 20.0f;
static const int BUFFER = 32;

-(id)initWithPosition:(GLKVector3)position world:(b2World *)physicsWorld ball:(Ball *)gameBall;
{
	self = [super initWithTextureFile:FILE_NAME];
	
	self.position = position;
	world = physicsWorld;
	
	// Create physics object
	bodyDef.type = b2_kinematicBody;
	bodyDef.position.Set(position.x, position.y);
	body = world->CreateBody(&bodyDef);
	
	// Create physics fixture
	b2PolygonShape boundingShape;
	boundingShape.SetAsBox(48, 16);
	b2FixtureDef fixture;
	fixture.shape = &boundingShape;
	fixture.density = 1.0f;
	fixture.friction = 0.0f;
	fixture.restitution = 1.0f;
	body->CreateFixture(&fixture);
	
	ball = gameBall;
	
	return self;
}

-(void)update
{
	b2Vec2 pos = body->GetPosition();
	self.position = GLKVector3Make(pos.x, pos.y, 0);
	
	// Try to follow the ball
	if ([ball position].x > pos.x + BUFFER)
	{
		b2Vec2 *spd = new b2Vec2(MAX_MOVE_SPEED, 0);
		[self updatePosition:GLKVector3Make(spd->x, 0, 0)];
	}
	else if ([ball position].x < pos.x - BUFFER)
	{
		b2Vec2 *spd = new b2Vec2(-MAX_MOVE_SPEED, 0);
		[self updatePosition:GLKVector3Make(spd->x, 0, 0)];
	}
		
	
	// If we are outside the correct range, reverse x velocity
	if (pos.x > 50 || pos.x < -50)
	{
		b2Vec2 spd = body->GetLinearVelocity();
		[self updatePosition:GLKVector3Make(-spd.x, 0, 0)];
	}
}


-(void)updatePosition:(GLKVector3)speed
{
	b2Vec2 *impulse = new b2Vec2(speed.x, 0);
	
	body->SetLinearVelocity(*impulse);
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