//
//  Wall.m
//  iOSAssignment2
//
//  Created by ChristoferKlassen on 2016-03-19.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wall.h"

@interface Wall ()
{
	b2World* world;
	b2BodyDef bodyDef;
	b2Body *body;
}

@end

@implementation Wall

-(id)initWithPosition:(GLKVector3)position world:(b2World *)physWorld;
{
	self = [super init];
	
	self.position = position;
	world = physWorld;
	
	// Create physics object
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(position.x, position.y);
	body = world->CreateBody(&bodyDef);
	
	// Create physics fixture
	b2PolygonShape boundingShape;
	boundingShape.SetAsBox(1, 600);
	b2FixtureDef fixture;
	fixture.shape = &boundingShape;
	fixture.density = 1.0f;
	fixture.friction = 0.0f;
	fixture.restitution = 1.0f;
	body->CreateFixture(&fixture);
	
	return self;
}

-(void)update
{
	
}

-(void)draw:(Program *)program camera:(Camera *)camera
{
	
}

@end