//
//  FPViewController.m
//  Flick
//
//  Created by Andrea Mazzini on 07/05/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "FPViewController.h"
#import "FPFlickScene.h"

@implementation FPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [FPFlickScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

@end
