//
//  FPFlickScene.m
//  Flick
//
//  Created by Andrea Mazzini on 07/05/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "FPFlickScene.h"

@interface FPFlickScene ()

@property (nonatomic, assign) BOOL moving;
@property (nonatomic, strong) NSMutableArray *balls;
@property (nonatomic, weak) SKNode *selectedNode;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation FPFlickScene

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [self addChild:[self createFloor]];
        self.balls = [@[] mutableCopy];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)generateObjects
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self addBallAtLocation:(CGPoint){160, 600}];
    });
}

- (void)addBallAtLocation:(CGPoint)location
{
    SKNode *ball = [self ballForLocation:location];
    [self addChild:ball];
    [self.balls addObject:ball];
    
    [self generateObjects];
}

- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:_panGesture];
    [self generateObjects];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = [self convertPointFromView:touchLocation];
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        CGPoint velocity = [recognizer velocityInView:self.view];
        velocity = [self convertPointFromView:velocity];
        self.selectedNode.physicsBody.affectedByGravity = YES;
        self.selectedNode.physicsBody.collisionBitMask = 0xFFFFFFFF;
        [self.selectedNode.physicsBody applyForce:CGVectorMake(velocity.x, velocity.y)];
        self.selectedNode = nil;
    } else {
        _selectedNode.position = CGPointMake(touchLocation.x, touchLocation.y);
    }
}

- (SKSpriteNode *)createFloor
{
    SKSpriteNode *floor = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:(CGSize){self.frame.size.width, 1}];
    [floor setAnchorPoint:(CGPoint){0, 0}];
    [floor setName:@"floor"];
    [floor setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:floor.frame]];
    floor.physicsBody.dynamic = NO;
    
    return floor;
}

- (SKShapeNode *)ballForLocation:(CGPoint)location
{
    SKShapeNode *ball = [SKShapeNode node];
    
    CGPathRef path = CGPathCreateWithEllipseInRect((CGRect){{-20, -20}, {40, 40}}, NULL);
    [ball setPath:path];
    [ball setStrokeColor:[UIColor colorWithRed:0.617 green:0.000 blue:0.000 alpha:1.000]];
    CGPathRelease(path);
    
    [ball setPosition:location];
    [ball setName:@"ball"];
    [ball setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:20.0]];
    ball.physicsBody.dynamic = YES;
    ball.physicsBody.restitution = 0.7;
    
    return ball;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.selectedNode = nil;
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    for (SKNode *node in self.balls) {
        if ([node containsPoint:location]) {
            self.selectedNode = node;
        }
    }
    
    if (self.selectedNode) {
        self.selectedNode.physicsBody.affectedByGravity = NO;
        self.selectedNode.physicsBody.collisionBitMask = 0;
        self.selectedNode.physicsBody.velocity = CGVectorMake(0, 0);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.selectedNode) {
        self.selectedNode.physicsBody.affectedByGravity = YES;
        self.selectedNode.physicsBody.collisionBitMask = 0xFFFFFF;
    }
}

- (void)didSimulatePhysics {
    [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0) {
            [node removeFromParent];
        }
    }];
}

@end
