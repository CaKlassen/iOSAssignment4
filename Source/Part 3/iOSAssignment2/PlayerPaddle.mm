//
//  PlayerPaddle.mm
//  iOSAssignment2
//
//  Created by ChristoferKlassen on 2016-03-17.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerPaddle.h"

@interface PlayerPaddle ()
{
	b2World* world;
	b2BodyDef bodyDef;
	b2Body *body;
}

@end


@implementation PlayerPaddle

static const NSString* FILE_NAME = @"Paddle.png";


-(id)initWithPosition:(GLKVector3)position world:(b2World *)physicsWorld;
{
	self = [super initWithTextureFile:FILE_NAME];
    self.TypeTag = PADDLE;//tag
	self.position = position;
	world = physicsWorld;
	
	// Create physics object
	bodyDef.type = b2_kinematicBody;
	bodyDef.position.Set(position.x, position.y);
    //bodyDef.userData = &self;
	body = world->CreateBody(&bodyDef);
	
    //set user data
    body->SetUserData((__bridge void*)self);
    
	// Create physics fixture
	b2PolygonShape boundingShape;
	boundingShape.SetAsBox(48, 16);
	b2FixtureDef fixture;
	fixture.shape = &boundingShape;
	fixture.density = 1.0f;
	fixture.friction = 0.0f;
	fixture.restitution = 1.0f;
	body->CreateFixture(&fixture);
    
    
	return self;
}


-(void)removeFromBox2D
{
    world->DestroyBody(body);
}

-(void)update
{
	b2Vec2 pos = body->GetPosition();
	self.position = GLKVector3Make(pos.x, pos.y, 0);
	
	// If we are outside the correct range, reverse x velocity
	if (pos.x > 58 || pos.x < -60)
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