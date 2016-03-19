//
//  GameScene.m
//  iOSAssignment2
//
//  Created by ChristoferKlassen on 2016-02-12.
//  Copyright © 2016 Chris Klassen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameScene.h"
#import "GameViewController.h"
#import "BasicProgram.h"
#import "SpriteProgram.h"
#import "Vector.h"
#import "Camera.h"
#import "Ground.h"
#import "Ball.h"
#import "MathUtils.h"

#import "btBulletDynamicsCommon.h"

const float MAX_TIMESTEP = 1.0f/60.0f;
const int NUM_VEL_ITERATIONS = 10;
const int NUM_POS_ITERATIONS = 3;


/** GAME SCENE STARTS HERE **/

@interface GameScene ()
{
	Camera *camera;
	BasicProgram *basicProgram;
	SpriteProgram *spriteProgram;
	CGPoint touchStart;
	
	Ground *ground;
	Ball *ball;
	
	btBroadphaseInterface *broadphase;
	btDefaultCollisionConfiguration *collisionConfig;
	btCollisionDispatcher *dispatcher;
	btSequentialImpulseConstraintSolver *solver;
	btDiscreteDynamicsWorld *dynamicsWorld;
}

@end


@implementation GameScene

static const int PADDLE_OFF = 140;
static const int WALL_OFF = 115;

-(id)init
{
	self = [super init];
	
	basicProgram = [[BasicProgram alloc] init];
	spriteProgram = [[SpriteProgram alloc] init];
	
	[self initCamera];
	
	// Create the Bullet3D world
	broadphase = new btDbvtBroadphase();
	
	collisionConfig = new btDefaultCollisionConfiguration();
	dispatcher = new btCollisionDispatcher(collisionConfig);
	
	solver = new btSequentialImpulseConstraintSolver;
	dynamicsWorld = new btDiscreteDynamicsWorld(dispatcher, broadphase, solver, collisionConfig);
	dynamicsWorld->setGravity(btVector3(0, 0, 0));
	
	// Create the game objects
	ground = [[Ground alloc] initWithPosition:GLKVector3Make(0, 0, 0) world:dynamicsWorld];
	ball = [[Ball alloc] initWithPosition:GLKVector3Make(0, 0, 0) world:dynamicsWorld];
	
	return self;
}

-(void)update:(float)elapsedTime
{
	[ball update];
	
}

-(void)draw
{
	glClearColor(0.5f, 0.5f, 0.5f, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	
	[ball draw:spriteProgram camera:camera];
	[ground draw:spriteProgram camera:camera];
	
}


-(void)pan:(UIPanGestureRecognizer*)recognizer
{
	if (recognizer.numberOfTouches == 1)
	{
		CGPoint touchLocation = [recognizer locationInView:recognizer.view];
		
		if ([recognizer state] == UIGestureRecognizerStateBegan)
		{
			touchStart = touchLocation;
		}
		else
		{
			CGPoint dis;
			dis.x = (touchLocation.x - touchStart.x) * 8; // Moving
			
			touchStart = touchLocation;
		}
	}
}


-(void)doubleTap:(UITapGestureRecognizer*)recognizer
{
	
}

-(void)doubleTapTwoFingers:(UITapGestureRecognizer*)recognizer
{
	
}

-(void)pinch:(UIPinchGestureRecognizer*)recognizer
{
	
}


-(void)initCamera
{
	GameViewController *controller = [GameViewController getInstance];
	
	const GLfloat aspectRatio = (GLfloat)(controller.view.bounds.size.width)/(GLfloat)(controller.view.bounds.size.height);
	const GLfloat fov = GLKMathDegreesToRadians(90.0f);
	
	GLKMatrix4 cameraMatrix = GLKMatrix4MakePerspective(fov, aspectRatio, 0.1f, 1000.0f);
	
	camera = [[Camera alloc] initWithPerspective:cameraMatrix position:[[Vector3 alloc] initWithValue:0 yPos:0 zPos:0]];
}

@end