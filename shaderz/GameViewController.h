//
//  GameViewController.h
//  shaderz
//

//  Copyright (c) 2016 Nicholas Shelton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>

#import <ReplayKit/ReplayKit.h>
@import CoreMotion;

typedef NS_ENUM(NSInteger, UITouchControlState) {
    UITouchControlStatePan,
    UITouchControlStateRotate,
    UITouchControlStateNone

};

@interface GameViewController<SCNSceneRendererDelegate> : UIViewController

{
    UITouchControlState controlState;
    
    float _rotation;
    GLKMatrix4 _rotMatrix;
    GLKVector3 _anchor_position;
    GLKVector3 _current_position;
    GLKQuaternion _quatStart;
    GLKQuaternion _quat;
    

    GLKVector3 _translation;
    GLKVector3 _drag_amount;
    
    int _colorMap;
    float _renderStyle;
    float _integrationWeight;
    float _filterType;
}



@property (strong, nonatomic) IBOutlet UISlider *radSlider;

@property (strong, nonatomic) IBOutlet UISlider *scaleSlider;
@property (strong, nonatomic) IBOutlet UISlider *threshSlider;
@property (strong, nonatomic) IBOutlet UISlider *integrateSlider;

@property (nonatomic, weak) SCNView*        scnView;
@property (nonatomic, strong) NSArray*      techniques;
@property (nonatomic, weak) SCNNode*        cameraNode;
@property (nonatomic, ) GLKMatrix4            cameraView;
@property (nonatomic, ) GLKMatrix4            lastFrameCameraView;

@property (nonatomic)   RPScreenRecorder *  screenRecorder;




//
- (IBAction)sliderChanged:(id)sender;
//
@end
