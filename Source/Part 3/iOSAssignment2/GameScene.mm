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
#import "Brick.h"
#import "Overlay.h"
#import "MathUtils.h"

#import <Box2D/Box2D.h>

const float MAX_TIMESTEP = 1.0f/60.0f;
const int NUM_VEL_ITERATIONS = 10;
const int NUM_POS_ITERATIONS = 3;


/** CUSTOM CONTACT LISTENER STARTS HERE **/

class CustomContactListener : public b2ContactListener
{
public:
	void BeginContact(b2Contact* contact) {
        //this is where we check what hit what
        
        void* bodyUserData = contact->GetFixtureA()->GetBody()->GetUserData();
        
        if(bodyUserData){
            Sprite* a = (__bridge Sprite*)bodyUserData;
            if(a.TypeTag == BRICK)
            {
                Brick* b = (Brick*)a;
                b.alive = false;
            }
        }
        
        void* bodyUserDataB = contact->GetFixtureB()->GetBody()->GetUserData();
        
        if(bodyUserDataB){
            Sprite* b = (__bridge Sprite*)bodyUserDataB;
            if(b.TypeTag == BRICK)
            {
                Brick* br = (Brick*)b;
                br.alive = false;
            }
        }
    };
	
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
	//EnemyPaddle *enemyPaddle;
	Ball *ball;
	Wall *wallLeft;
	Wall *wallRight;
    Wall *wallTop;
    NSMutableArray *bricks;
    Overlay *ggOverlay;
	
	b2World *world;
	CustomContactListener *contactListener;
    
    bool gameover;
}

@end


@implementation GameScene

static const int PADDLE_OFF = 140;
static const int WALL_OFF = 115;
static const int BRICK_W = 68;
static const int BRICK_H = 22;

-(id)init
{
	self = [super init];
	
    gameover = false;
    
	basicProgram = [[BasicProgram alloc] init];
	spriteProgram = [[SpriteProgram alloc] init];
	
	[self initCamera];
	
	// Create the Box2D world
	b2Vec2 *gravity = new b2Vec2(0.0, 0.0f);
    world = new b2World(*gravity);
	contactListener = new CustomContactListener();
	world->SetContactListener(contactListener);
	
	// Create the game objects
    wallLeft = [[Wall alloc] initWithPosition:GLKVector3Make(-WALL_OFF, 0, 0) world:world top:false];
	wallRight = [[Wall alloc] initWithPosition:GLKVector3Make(WALL_OFF, 0, 0) world:world top:false];
    wallTop = [[Wall alloc] initWithPosition:GLKVector3Make(0, 200, 0) world:world top:true];
	
	playerPaddle = [[PlayerPaddle alloc] initWithPosition:GLKVector3Make(0, -PADDLE_OFF, 0) world:world];
	//enemyPaddle = [[EnemyPaddle alloc] initWithPosition:GLKVector3Make(0, PADDLE_OFF, 0) world:world];    +34
	ball = [[Ball alloc] initWithPosition:GLKVector3Make(0, -PADDLE_OFF + 34, 0) world:world];
    [self setupBricks];
	
    ggOverlay = [[Overlay alloc] initWithPosition:GLKVector3Make(0, 0, -150) world:world];
    
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
	//[enemyPaddle update];
	[ball update];

    
    for (NSInteger i = bricks.count - 1; i >= 0; i--)
    {
        [[bricks objectAtIndex:i] update];
        if(![[bricks objectAtIndex:i]alive])
        {
            [bricks removeObjectAtIndex:i];
        }
    }
    
    if(ball.position.y < playerPaddle.position.y - 40)
    {
        //game over
        [self GameOver];
        [playerPaddle updatePosition:GLKVector3Make(0, 0, 0)];
        [ball updatePosition:GLKVector3Make(0, 0, 0)];
    }
}

-(void)GameOver
{
    gameover = true;
    
}


-(void)reset
{
    for (NSInteger i = bricks.count - 1; i >= 0; i--)
    {
        [[bricks objectAtIndex:i] removeFromBox2D];
        [bricks removeObjectAtIndex:i];
    }
    
    [self setupBricks];
    
    [playerPaddle removeFromBox2D];
    playerPaddle = [[PlayerPaddle alloc] initWithPosition:GLKVector3Make(0, -PADDLE_OFF, 0) world:world];
    
    [ball removeFromBox2D];
    ball = [[Ball alloc] initWithPosition:GLKVector3Make(0, -PADDLE_OFF + 34, 0) world:world];
    
    gameover = false;
}

-(void)draw
{
	glClearColor(0.5f, 0.5f, 0.5f, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	
	[playerPaddle draw:spriteProgram camera:camera];
	//[enemyPaddle draw:spriteProgram camera:camera];
	[ball draw:spriteProgram camera:camera];
    
    for(Brick *b in bricks)
    {
        [b draw:spriteProgram camera:camera];
    }
    
    if(gameover)
        [ggOverlay draw:spriteProgram camera:camera];
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
			
			if (playerX <= 58 && playerX >= -60)
				[playerPaddle updatePosition:GLKVector3Make(dis.x, 0, 0)];
		}
	}
}

-(void)tap:(UITapGestureRecognizer *)recognizer
{
    if(!gameover)
    {
        if(![ball launched])
        {
            [ball launchBall];
        }
    }else
    {
        //reset
        [self reset];
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

-(void)setupBricks
{
    bricks = [NSMutableArray new];
    //row 1
    [bricks insertObject:[[Brick alloc] initWithPosition:GLKVector3Make(-BRICK_W -5, 160, 0) world:world] atIndex:0];
    [bricks insertObject:[[Brick alloc] initWithPosition:GLKVector3Make(0, 160, 0) world:world] atIndex:1];
    [bricks insertObject:[[Brick alloc] initWithPosition:GLKVector3Make(BRICK_W + 5, 160, 0) world:world] atIndex:2];
    
    //row 2
    [bricks insertObject:[[Brick alloc] initWithPosition:GLKVector3Make(-BRICK_W -5, 160 - BRICK_H - 5, 0) world:world] atIndex:3];
    [bricks insertObject:[[Brick alloc] initWithPosition:GLKVector3Make(0, 160 - BRICK_H - 5, 0) world:world] atIndex:4];
    [bricks insertObject:[[Brick alloc] initWithPosition:GLKVector3Make(BRICK_W + 5, 160 - BRICK_H - 5, 0) world:world] atIndex:5];
    
    //row 3
    [bricks insertObject:[[Brick alloc] initWithPosition:GLKVector3Make(-BRICK_W -5, 160 - BRICK_H * 2 - 10, 0) world:world] atIndex:6];
    [bricks insertObject:[[Brick alloc] initWithPosition:GLKVector3Make(0, 160 - BRICK_H * 2 - 10, 0) world:world] atIndex:7];
    [bricks insertObject:[[Brick alloc] initWithPosition:GLKVector3Make(BRICK_W + 5, 160 - BRICK_H * 2 - 10, 0) world:world] atIndex:8];
}

@end