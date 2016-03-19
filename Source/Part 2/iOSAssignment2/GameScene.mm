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
#import "PlayerPaddle.h"
#import "EnemyPaddle.h"
#import "Ball.h"
#import "Wall.h"
#import "MathUtils.h"

#import <Box2D/Box2D.h>

const float MAX_TIMESTEP = 1.0f/60.0f;
const int NUM_VEL_ITERATIONS = 10;
const int NUM_POS_ITERATIONS = 3;


/** CUSTOM CONTACT LISTENER STARTS HERE **/

class CustomContactListener : public b2ContactListener
{
public:
	void BeginContact(b2Contact* contact) {};
	
	void EndContact(b2Contact* contact) {};
	
	void PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
	{
		/*
		b2WorldManifold worldManifold;
		contact->GetWorldManifold(&worldManifold);
		b2PointState state1[2], state2[2];
		b2GetPointStates(state1, state2, oldManifold, contact->GetManifold());
		if (state2[0] == b2_addState)
		{
			b2Body* bodyA = contact->GetFixtureA()->GetBody();
			CBox2D *parentObj = (__bridge CBox2D *)(bodyA->GetUserData());
			[parentObj RegisterHit];
		}*/
	}
	
	void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {};
};


/** GAME SCENE STARTS HERE **/

@interface GameScene ()
{
	Camera *camera;
	BasicProgram *basicProgram;
	SpriteProgram *spriteProgram;
	CGPoint touchStart;
	
	PlayerPaddle *playerPaddle;
	EnemyPaddle *enemyPaddle;
	Ball *ball;
	Wall *wallLeft;
	Wall *wallRight;
	
	b2World *world;
	CustomContactListener *contactListener;
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
	
	// Create the Box2D world
	b2Vec2 *gravity = new b2Vec2(0.0, 0.0f);
	world = new b2World(*gravity);
	contactListener = new CustomContactListener();
	world->SetContactListener(contactListener);
	
	// Create the game objects
	wallLeft = [[Wall alloc] initWithPosition:GLKVector3Make(-WALL_OFF, 0, 0) world:world];
	wallRight = [[Wall alloc] initWithPosition:GLKVector3Make(WALL_OFF, 0, 0) world:world];
	
	playerPaddle = [[PlayerPaddle alloc] initWithPosition:GLKVector3Make(0, -PADDLE_OFF, 0) world:world];
	enemyPaddle = [[EnemyPaddle alloc] initWithPosition:GLKVector3Make(0, PADDLE_OFF, 0) world:world];
	ball = [[Ball alloc] initWithPosition:GLKVector3Make(0, 0, 0) world:world];
	
	return self;
}

-(void)update:(float)elapsedTime
{
	while (elapsedTime >= MAX_TIMESTEP)
	{
		world->Step(MAX_TIMESTEP, NUM_VEL_ITERATIONS, NUM_POS_ITERATIONS);
		elapsedTime -= MAX_TIMESTEP;
	}
	
	if (elapsedTime > 0.0f)
	{
		world->Step(elapsedTime, NUM_VEL_ITERATIONS, NUM_POS_ITERATIONS);
	}
	
	[playerPaddle update];
	[enemyPaddle update];
	[ball update];
}

-(void)draw
{
	glClearColor(0.5f, 0.5f, 0.5f, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	
	[playerPaddle draw:spriteProgram camera:camera];
	[enemyPaddle draw:spriteProgram camera:camera];
	[ball draw:spriteProgram camera:camera];
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
			
			// Only move if we are inside the correct range
			float playerX = [playerPaddle position].x;
			
			if (playerX <= 50 && playerX >= -50)
				[playerPaddle updatePosition:GLKVector3Make(dis.x, 0, 0)];
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