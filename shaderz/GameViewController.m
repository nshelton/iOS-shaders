//
//  GameViewController.m
//  shaderz
//
//  Created by Nicholas Shelton on 5/12/16.
//  Copyright (c) 2016 Nicholas Shelton. All rights reserved.
//

#import "GameViewController.h"
#import <GLKit/GLKit.h>

@interface GameViewController () <SCNSceneRendererDelegate>
{

}
@end

@implementation GameViewController


- (void) renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time
{
    cameraView = SCNMatrix4ToGLKMatrix4(scnView.pointOfView.transform);
}

- (void) loadTechniques
{
    NSURL *url;
    url = [[NSBundle mainBundle] URLForResource:@"MandelBox" withExtension:@"plist"];
    SCNTechnique *technique0 = [SCNTechnique techniqueWithDictionary:[NSDictionary dictionaryWithContentsOfURL:url]];
    [technique0
     handleBindingOfSymbol:@"modelViewSymbol"
     usingBlock:^(unsigned int programID, unsigned int location, SCNNode* _Nonnull renderedNode, SCNRenderer* _Nonnull renderer) {
         glUniformMatrix4fv(location, 1, GL_FALSE, cameraView.m);
     }
     ];
    
    
    url = [[NSBundle mainBundle] URLForResource:@"torusField" withExtension:@"plist"];
    SCNTechnique *technique1 = [SCNTechnique techniqueWithDictionary:[NSDictionary dictionaryWithContentsOfURL:url]];
    [technique1
     handleBindingOfSymbol:@"modelViewSymbol"
     usingBlock:^(unsigned int programID, unsigned int location, SCNNode* _Nonnull renderedNode, SCNRenderer* _Nonnull renderer) {
         glUniformMatrix4fv(location, 1, GL_FALSE, cameraView.m);
     }
     ];
    techniques = @[technique0, technique1];
}
- (void) setupUniforms
{
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    // create and add a camera to the scene
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 15);
    
    // retrieve the SCNView
    scnView = (SCNView *)self.view;
    scnView.delegate = self;
    scnView.playing = true;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
        
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;
    
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestureRecognizers;


    [self loadTechniques];
    
    cameraView = GLKMatrix4Identity;

//    currentTechnique = arc4random() %2;
    scnView.technique = techniques[0];
    
//    [motionManager startDeviceMotionUpdates];
    
//      ]ToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *devMotion, NSError *error) {
//        NSLog(@"%f", devMotion.attitude.quaternion.x);
//    }];

}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    CGPoint location = [gestureRecognize locationInView:self.view];
    
    NSLog(NSStringFromCGPoint(location));
    currentTechnique++;
    currentTechnique%=2;
    scnView.technique = techniques[currentTechnique];
    
}

- (BOOL)shouldAutorotate
{
    
    NSString *res = [NSString stringWithFormat:@"%f, %f, %f", scnView.frame.size.width, scnView.frame.size.height, scnView.contentScaleFactor];

    [scnView.technique setValue:res forKey:@"resolutionSymbol" ];

    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end