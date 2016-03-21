//
//  Brick.cpp
//  iOSAssignment2
//
//  Created by Alexandra Kabak on 2016-03-20.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Brick.h"

@interface Brick()
{
    b2World* world;
    b2BodyDef bodyDef;
    b2Body* body;
}

@end

@implementation Brick

static const NSString* FILE_NAME = @"Brick.png";

-(id)initWithPosition:(GLKVector3)position world:(b2World *)PhysicsWorld;
{
    self = [super initWithTextureFile:@"Brick.png"];
    
    self.alive = true;
    
    self.position = position;
    world = PhysicsWorld;
    
    //create physics object (brick does not move; no gravity)
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(position.x, position.y);
    body = world->CreateBody(&bodyDef);
    
    //create physics fixture
    b2PolygonShape boundingShape;
    boundingShape.SetAsBox(34, 11);
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
    //if hit then set alive to false
    
}

-(void)draw:(Program *)program camera:(Camera *)camera
{
    // Set up the model matrix
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, 0, 0, -200);
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, 0);
    
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
