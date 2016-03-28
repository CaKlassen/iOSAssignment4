//
//  Overlay.m
//  iOSAssignment2
//
//  Created by Alexandra Kabak on 2016-03-27.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Overlay.h"


@implementation Overlay

static const NSString* FILE_NAME = @"Game Over.png";

-(id)initWithPosition:(GLKVector3)position world:(b2World *)world;
{
    self = [super initWithTextureFile:FILE_NAME];
    
    self.position = position;
    
    return self;
}

-(void)draw:(Program *)program camera:(Camera *)camera
{
    // Set up the model matrix
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, 0, 0, -190);
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, 0);
    modelMatrix = GLKMatrix4Scale(modelMatrix, 0.7, 0.7, 1);
    
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