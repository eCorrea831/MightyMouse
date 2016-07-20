//
//  GameViewController.m
//  MightyMouse
//
//  Created by Aditya Narayan on 6/27/16.
//  Copyright © 2016 TurnToTech. All rights reserved.
//

#import "GameViewController.h"

//test

@interface GameViewController ()

@property (weak, nonatomic) IBOutlet UIImageView * ball;
@property (weak, nonatomic) IBOutlet UIImageView * katie;
@property (weak, nonatomic) IBOutlet UIButton * startButton;
@property (weak, nonatomic) IBOutlet UILabel * currentScoreLabel;
@property (strong, nonatomic) UIDynamicAnimator * animator;
@property (nonatomic) long currentScore;
@property (retain, nonatomic) ScoreViewController * scoreVC;

- (IBAction)startButtonClicked:(id)sender;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.scoreVC = [storyboard instantiateViewControllerWithIdentifier:@"ScoreViewController"];
    
    self.ball.layer.cornerRadius = 20;
    self.ball.layer.masksToBounds = YES;
    
    self.katie.layer.cornerRadius = 40;
    self.ball.layer.masksToBounds = YES;

    //allow katie to pan
    self.katie.userInteractionEnabled = true;
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.katie addGestureRecognizer:panGesture];
    panGesture.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.startButton.hidden = NO;
    self.currentScore = 0;
    self.currentScoreLabel.text = @"0";
    self.ball.frame = CGRectMake(94, 128, 40, 40);
    self.katie.frame = CGRectMake(144, 551, 86, 116);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)startButtonClicked:(id)sender {
    
    self.startButton.hidden = YES;
    [self initAnimation];
}

- (void)handlePanGesture: (UIPanGestureRecognizer*) panGesture {
    
    CGPoint touchLocation = [panGesture locationInView:self.view];
    CGPoint center = panGesture.view.center;
    center.x = touchLocation.x;
    self.katie.center = center;
    [self.animator updateItemUsingCurrentState:self.katie];
}

- (void)initAnimation {
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UIGravityBehavior * gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.ball]];
    [self.animator addBehavior:gravityBehavior];
    
    UIDynamicItemBehavior * ballAnimationProperties = [[UIDynamicItemBehavior alloc]initWithItems:@[self.ball]];
    ballAnimationProperties.elasticity = 1.0;
    ballAnimationProperties.friction = 0.0;
    ballAnimationProperties.resistance = 0.0;
    [self.animator addBehavior:ballAnimationProperties];
    
    UIDynamicItemBehavior * katieAnimationProperties = [[UIDynamicItemBehavior alloc] initWithItems:@[self.katie]];
    katieAnimationProperties.allowsRotation = NO;
    katieAnimationProperties.density = 1000.0f;
    [self.animator addBehavior:katieAnimationProperties];
    
    UICollisionBehavior * collision = [[UICollisionBehavior alloc] initWithItems:@[self.ball, self.katie]];
    collision.translatesReferenceBoundsIntoBoundary = YES;
    collision.collisionDelegate = self;
    collision.collisionMode = UICollisionBehaviorModeEverything;
    [self makeSidesForCollision:collision];
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
    animation.duration = 1.0f;
    animation.repeatCount = 1;
    [self.ball.layer addAnimation:animation forKey:@"SpinAnimation"];
}

- (void)makeSidesForCollision:(UICollisionBehavior *)collision {
    
    CGPoint lL = CGPointMake(0, self.view.bounds.size.height);
    CGPoint lR = CGPointMake(self.view.bounds.size.width, self.view.bounds.size.height);
    CGPoint tL = CGPointMake(0, 0);
    CGPoint tR = CGPointMake(self.view.bounds.size.width, 0);
    
    [collision addBoundaryWithIdentifier:@"bottom" fromPoint:lL toPoint:lR];
    [collision addBoundaryWithIdentifier:@"top" fromPoint:tL toPoint:tR];
    [collision addBoundaryWithIdentifier:@"left" fromPoint:tL toPoint:lL];
    [collision addBoundaryWithIdentifier:@"right" fromPoint:tR toPoint:lR];
    [self.animator addBehavior:collision];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
    
    NSString * string = [NSString stringWithFormat:@"%@", identifier];
    if ([string isEqualToString:@"bottom"] && item == self.ball) {
        [self.animator removeAllBehaviors];
        
        [self.scoreVC setModalPresentationStyle:UIModalPresentationFullScreen];
        [self.scoreVC setCurrentScore:self.currentScore];
        [self presentViewController:self.scoreVC animated:YES completion:nil];
    } else {
        UIPushBehavior * pusher = [[UIPushBehavior alloc] initWithItems:@[self.ball] mode:UIPushBehaviorModeInstantaneous];
        pusher.pushDirection = CGVectorMake(0.5, 1.0);
        pusher.magnitude = 0.1f;
        pusher.active = YES;
        [self.animator addBehavior:pusher];
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2 atPoint:(CGPoint)p {
    
    if ((item1 == self.ball && item2 == self.katie) || (item1 == self.katie && item2 == self.ball)) {
        self.currentScore += 1;
        NSString * scoreString = [NSString stringWithFormat:@"%ld", self.currentScore];
        self.currentScoreLabel.text = scoreString;
    }
}

@end
