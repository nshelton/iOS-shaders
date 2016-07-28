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



@property (strong, nonatomic) IBOutlet UISlider *scaleSlider;

@property (nonatomic, weak) SCNView*        scnView;
@property (nonatomic, strong) NSArray*      techniques;
@property (nonatomic) int                   currentTechnique;
@property (nonatomic, weak) SCNNode*        cameraNode;
@property (nonatomic) GLKMatrix4            cameraView;

//
- (IBAction)sliderChanged:(id)sender;
//
@end
