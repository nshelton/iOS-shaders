//
//  GameViewController.m
//  shaderz
//
//  Created by Nicholas Shelton on 5/12/16.
//  Copyright (c) 2016 Nicholas Shelton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameViewController.h"
#import <GLKit/GLKit.h>

@interface GameViewController () <SCNSceneRendererDelegate, RPPreviewViewControllerDelegate>
{

}
@end

@implementation GameViewController




- (void) renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time
{
//    _cameraView = SCNMatrix4ToGLKMatrix4(_scnView.pointOfView.transform);
    _translation = GLKVector3Add(_drag_amount, _translation);
    [self update];

}

- (void) loadTechniques
{
    NSURL *url;
    url = [[NSBundle mainBundle] URLForResource:@"MandelBox" withExtension:@"plist"];
    SCNTechnique *technique0 = [SCNTechnique techniqueWithDictionary:[NSDictionary dictionaryWithContentsOfURL:url]];
    [technique0
     handleBindingOfSymbol:@"modelViewSymbol"
     usingBlock:^(unsigned int programID, unsigned int location, SCNNode* _Nonnull renderedNode, SCNRenderer* _Nonnull renderer) {

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
    _cameraNode.position = SCNVector3Make(0, 0 ,3);
    
    // retrieve the SCNView
    _scnView = (SCNView *)self.view;
    _scnView.delegate = self;
    _scnView.playing = true;
    
    // set the scene to the view
    _scnView.scene = scene;
    
    // allows the user to manipulate the camera
//    _scnView.allowsCameraControl = YES;
    
    // show statistics such as fps and timing information
    _scnView.showsStatistics = YES;
    
    // add a tap gesture recognizer
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];

    
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObjectsFromArray:_scnView.gestureRecognizers];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObject:pinchGesture];

    
    _scnView.multipleTouchEnabled = YES;
    
    _scnView.gestureRecognizers = gestureRecognizers;
    
    
    
    
    [self loadTechniques];
    
    _cameraView = GLKMatrix4Identity;

    _scnView.technique = _techniques[0];

    NSLog(@"Scale factor is %f", _scnView.contentScaleFactor);
//    _scnView.contentScaleFactor = 0.5;
    
    

        CGRect frame = CGRectMake(0.0, 10.0, 600.0, 20.0);
        
        _scaleSlider = [[UISlider alloc] initWithFrame:frame];
        [_scaleSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
        [_scaleSlider setBackgroundColor:[UIColor clearColor]];
        _scaleSlider.minimumValue = -5.0;
        _scaleSlider.maximumValue = 5.0;
        _scaleSlider.continuous = YES;
        _scaleSlider.value = 2.0;
    
        [self.view addSubview:_scaleSlider];

    frame = CGRectMake(0.0, 50.0, 600.0, 20.0);
    
    _threshSlider = [[UISlider alloc] initWithFrame:frame];
    [_threshSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_scaleSlider setBackgroundColor:[UIColor clearColor]];
    _threshSlider.minimumValue = 0;
    _threshSlider.maximumValue = 10.0;
    _threshSlider.continuous = YES;
    _threshSlider.value = 2.0;
    
    [self.view addSubview:_threshSlider];
    frame = CGRectMake(0.0, 30.0, 600.0, 20.0);

    _radSlider = [[UISlider alloc] initWithFrame:frame];
    [_radSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_radSlider setBackgroundColor:[UIColor clearColor]];
    _radSlider.minimumValue = 0;
    _radSlider.maximumValue = 1.0;
    _radSlider.continuous = YES;
    _radSlider.value = 0.25;
    
    [self.view addSubview:_radSlider];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button addTarget:self
               action:@selector(toggleNormals:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Shaded" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 100, 100.0, 20.0);
    [self.view addSubview:button];
    
//    [self.view  becomeFirstResponder];
    [self becomeFirstResponder];
    
    _rotMatrix = GLKMatrix4Identity;
    _quat = GLKQuaternionMake(0, 0, 0, 1);
    _quatStart = GLKQuaternionMake(0, 0, 0, 1);
    
    _translation = GLKVector3Make(0, 0.5, -0.51);
    _colorMap = 0.0;
    _renderStyle = 0.0;
    
    controlState = UITouchControlStateNone;
    [self update];
    [self updateUniforms];

}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (void) handlePinch:(UIPinchGestureRecognizer*)recognizer
{
//    _camDistance *= sqrt(sqrt(sqrt(sqrt(recognizer.scale))));
    [self update];
//    NSLog(@"pinch scale is %f", recognizer.scale);
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


//----------------------------------------------------------------------


- (void)update {

    
    _cameraView = GLKMatrix4MakeTranslation(_translation.x, _translation.y, _translation.z);
    _rotMatrix = GLKMatrix4MakeWithQuaternion(_quat);
    
    _cameraView = GLKMatrix4Multiply(_cameraView, GLKMatrix4Transpose(_rotMatrix));
}

- (GLKVector3) projectOntoSurface:(GLKVector3) touchPoint
{
    float radius = self.view.bounds.size.width/3;
    GLKVector3 center = GLKVector3Make(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 0);
    GLKVector3 P = GLKVector3Subtract(touchPoint, center);
    
    // Flip the y-axis because pixel coords increase toward the bottom.
    P = GLKVector3Make(P.x, -P.y, P.z);
    
    float radius2 = radius * radius;
    float length2 = P.x*P.x + P.y*P.y;
    
    if (length2 <= radius2)
        P.z = sqrt(radius2 - length2);
    else
    {
        /*
         P.x *= radius / sqrt(length2);
         P.y *= radius / sqrt(length2);
         P.z = 0;
         */
        P.z = radius2 / (2.0 * sqrt(length2));
        float length = sqrt(length2 + P.z * P.z);
        P = GLKVector3DivideScalar(P, length);
    }
    
    return GLKVector3Normalize(P);
}

- (void)computeIncremental {
    
    GLKVector3 axis = GLKVector3CrossProduct(_anchor_position, _current_position);
    float dot = GLKVector3DotProduct(_anchor_position, _current_position);
    float angle = acosf(dot);
    
    GLKQuaternion Q_rot = GLKQuaternionMakeWithAngleAndVector3Axis(angle * 2, axis);
    Q_rot = GLKQuaternionNormalize(Q_rot);
    
    // TODO: Do something with Q_rot...
    _quat = GLKQuaternionMultiply(Q_rot, _quatStart);

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if ([touches count] ==3)
    {
        [self handleTripleTap];
        return;
    }
    if ([touches count] == 4)
    {
        _translation = GLKVector3Make(0, 0, 0);
        [self update];
        NSLog(@"Back to Center");
        return;
    }
    
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    
    _anchor_position = GLKVector3Make(location.x, location.y, 0);
    controlState = UITouchControlStatePan;

    if (location.x < self.view.frame.size.width * 0.6) {
        controlState = UITouchControlStateRotate;

        _anchor_position = [self projectOntoSurface:_anchor_position];
        
        _current_position = _anchor_position;
        _quatStart = _quat;
    }

    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    

    if (controlState == UITouchControlStatePan) {
        UITouch * touch = [touches anyObject];
        CGPoint location = [touch locationInView:self.view];
        
        GLKVector3 p = GLKVector3Make(location.x, location.y, 0);
        p = GLKVector3Subtract(_anchor_position, p);

        
        _drag_amount = GLKVector3Make(-0.05 * p.x/self.view.frame.size.width,
                                      0,
                                      0.05 * p.y/self.view.frame.size.height);

        GLKMatrix4 rotMatrixInv = GLKMatrix4Transpose(_rotMatrix);
        _drag_amount = GLKMatrix4MultiplyVector3(_cameraView, _drag_amount);
        
        NSLog( @"Translate %@", NSStringFromGLKVector3( _drag_amount) );
        
    }
    if (controlState == UITouchControlStateRotate) {

        UITouch * touch = [touches anyObject];
        CGPoint location = [touch locationInView:self.view];
        CGPoint lastLoc = [touch previousLocationInView:self.view];
        CGPoint diff = CGPointMake(lastLoc.x - location.x, lastLoc.y - location.y);
        
        float rotX = -1 * GLKMathDegreesToRadians(diff.y / 2.0);
        float rotY = -1 * GLKMathDegreesToRadians(diff.x / 2.0);
        
        bool isInvertible;
        GLKVector3 xAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix, &isInvertible), GLKVector3Make(1, 0, 0));
        _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotX, xAxis.x, xAxis.y, xAxis.z);
        GLKVector3 yAxis = GLKMatrix4MultiplyVector3(GLKMatrix4Invert(_rotMatrix, &isInvertible), GLKVector3Make(0, 1, 0));
        _rotMatrix = GLKMatrix4Rotate(_rotMatrix, rotY, yAxis.x, yAxis.y, yAxis.z);
        
        _current_position = GLKVector3Make(location.x, location.y, 0);
        _current_position = [self projectOntoSurface:_current_position];
        
        [self computeIncremental];
    }
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    _drag_amount = GLKVector3Make(0,0,0);

    controlState = UITouchControlStateNone;
}
//- ( void) touches


// ---------------------------------------------------------------------
// UI DELEGATES

- (void) updateUniforms
{
    NSString *params = [NSString stringWithFormat:@"%f, %f, %f, %f",
                        _scaleSlider.value, _threshSlider.value, _radSlider.value , 0.f];
    
    
    
    [_scnView.technique setValue:params forKey:@"paramSymbol" ];
    
    NSString *render_params = [NSString stringWithFormat:@"%f, %f, %d, %f",
                        _renderStyle, 0.0, _colorMap, 0.f];
    
    [_scnView.technique setValue:render_params forKey:@"renderParamSymbol" ];
    NSLog(@"Set params to %@", render_params);
    
}

- (IBAction)sliderChanged:(id)sender
{
    [self updateUniforms];
}

- (void)handleTripleTap
{

    if( _screenRecorder == nil) {
        _screenRecorder = [RPScreenRecorder sharedRecorder];
    }

    if(! _screenRecorder.isRecording &&  _screenRecorder.isAvailable)
    {
        [ _screenRecorder startRecordingWithMicrophoneEnabled:NO handler:^(NSError * _Nullable error) {
            NSLog(@"Error Starting = %@", error);
        }];
    }
    else
    {
        [ _screenRecorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
            if(error != nil)
            {
                NSLog(@"Error Ending = %@", error);
            }
            else
            {
                previewViewController.previewControllerDelegate = self;
                previewViewController.popoverPresentationController.sourceView = self.view;
                [self presentViewController:previewViewController animated:YES completion:nil];
            }
        }];
    }
}

- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController
{
    [previewController dismissViewControllerAnimated:YES completion:nil];
}

-(void) toggleNormals:(UIButton*)sender
{
    _renderStyle  = ((int)_renderStyle + 1 ) % 3;
    
    [self updateUniforms];
}



- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    _colorMap = (int)(_colorMap + 1. ) % 15;
    
    [self updateUniforms];
}


//- (void)doubleTap:(UITapGestureRecognizer *)tap {
//    
//    _slerping = YES;
//    _slerpCur = 0;
//    _slerpMax = 1.0;
//    _slerpStart = _quat;
//    _slerpEnd = GLKQuaternionMake(0, 0, 0, 1);
//    
//}


@end