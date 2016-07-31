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


- (IBAction)sliderChanged:(id)sender {
    
    NSString *params = [NSString stringWithFormat:@"%f, %f, %f, %f",
                        _scaleSlider.value, 0.0, 0.f, 0.f];
    
    [_scnView.technique setValue:params forKey:@"paramSymbol" ];
    NSLog(@"Set params to %@", params);
    
    
}


- (void) renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time
{
    _cameraView = SCNMatrix4ToGLKMatrix4(_scnView.pointOfView.transform);
}

- (void) loadTechniques
{
    NSURL *url;
    url = [[NSBundle mainBundle] URLForResource:@"MandelBox" withExtension:@"plist"];
    SCNTechnique *technique0 = [SCNTechnique techniqueWithDictionary:[NSDictionary dictionaryWithContentsOfURL:url]];
    [technique0
     handleBindingOfSymbol:@"modelViewSymbol"
     usingBlock:^(unsigned int programID, unsigned int location, SCNNode* _Nonnull renderedNode, SCNRenderer* _Nonnull renderer) {
         float t = 0.5 + CACurrentMediaTime()/300.;
         GLKVector3 tr = GLKVector3Make(-.81 + 3. * sin(2.14*t), .05+2.5 * sin(.942*t+1.3), .05 + 3.5 * cos(3.594*t));
         _cameraView.m30 = tr.x;
         _cameraView.m31 = tr.y;
         _cameraView.m32 = tr.z;
         
         glUniformMatrix4fv(location, 1, GL_FALSE, _cameraView.m);     }
     ];
    
    
    url = [[NSBundle mainBundle] URLForResource:@"torusField" withExtension:@"plist"];
    SCNTechnique *technique1 = [SCNTechnique techniqueWithDictionary:[NSDictionary dictionaryWithContentsOfURL:url]];
    [technique1
     handleBindingOfSymbol:@"modelViewSymbol"
     usingBlock:^(unsigned int programID, unsigned int location, SCNNode* _Nonnull renderedNode, SCNRenderer* _Nonnull renderer) {
         
         float t = 0.5 + CACurrentMediaTime()/100.;
         _cameraView = GLKMatrix4Translate(_cameraView, -.81 + 3. * sin(2.14*t), .05+2.5 * sin(.942*t+1.3), .05 + 3.5 * cos(3.594*t));
         NSLog(@"BINDING: %@", NSStringFromGLKMatrix4(_cameraView));
         glUniformMatrix4fv(location, 1, GL_FALSE, _cameraView.m);
         
     }
     ];
    _techniques = @[technique0, technique1];
}
- (void) setupUniforms
{
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"LOaded");
    // create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    // create and add a camera to the scene
    _cameraNode = [SCNNode node];
    _cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:_cameraNode];
    
    // place the camera
    _cameraNode.position = SCNVector3Make(0, 0, 15);
    
    // retrieve the SCNView
    _scnView = (SCNView *)self.view;
    _scnView.delegate = self;
    _scnView.playing = true;
    
    // set the scene to the view
    _scnView.scene = scene;
    
    // allows the user to manipulate the camera
    _scnView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    _scnView.showsStatistics = YES;
    
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:_scnView.gestureRecognizers];
    _scnView.gestureRecognizers = gestureRecognizers;
    
    
    [self loadTechniques];
    
    _cameraView = GLKMatrix4Identity;
    
    //    currentTechnique = arc4random() %2;
    _scnView.technique = _techniques[0];
    //    [scnView.technique setValue:@"1000,700,2" forKey:@"resolutionSymbol" ];
    NSLog(@"Scale factor is %f", _scnView.contentScaleFactor);
    _scnView.contentScaleFactor = 1;
    //    [motionManager startDeviceMotionUpdates];
    
    //      ]ToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *devMotion, NSError *error) {
    //        NSLog(@"%f", devMotion.attitude.quaternion.x);
    //    }];
    
    
    
    CGRect frame = CGRectMake(0.0, 10.0, 600.0, 20.0);
    
    _scaleSlider = [[UISlider alloc] initWithFrame:frame];
    [_scaleSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_scaleSlider setBackgroundColor:[UIColor clearColor]];
    _scaleSlider.minimumValue = -3.0;
    _scaleSlider.maximumValue = 3.0;
    _scaleSlider.continuous = YES;
    _scaleSlider.value = 2.0;
    
    [self.view addSubview:_scaleSlider];
    
    
}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    
    
    //    CGPoint location = [[gestureRecognize locationInView:self.view]];
    NSLog(@"5555");
    
    
    
    //    currentTechnique++;
    //    currentTechnique%=2;
    //    scnView.technique = techniques[currentTechnique];
    //    GLKVector4 t = GLKVector4Make(0,0,0.001, 1.0);
    //
    //    vec3 p = GLKVector( );
    //
    //    t = GLKMatrix4MultiplyVector4(cameraView, t);
    //
    
}

- (BOOL)shouldAutorotate
{
    
    NSString *res = [NSString stringWithFormat:@"%f, %f, %f", _scnView.frame.size.width, _scnView.frame.size.height, _scnView.contentScaleFactor];
    
    [_scnView.technique setValue:res forKey:@"resolutionSymbol" ];
    NSLog(@"Set REs to %@", res);
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