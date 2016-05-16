//
//  GameViewController.h
//  shaderz
//

//  Copyright (c) 2016 Nicholas Shelton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
@import CoreMotion;


@interface GameViewController<SCNSceneRendererDelegate> : UIViewController

{

    
    SCNView* scnView;

    NSArray *techniques;
    int currentTechnique;

    SCNNode *cameraNode;
    
    CMMotionManager *motionManager;
    GLKMatrix4 cameraView;
}

@end
