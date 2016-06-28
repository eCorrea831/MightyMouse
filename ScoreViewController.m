//
//  ScoreViewController.m
//  MightyMouse
//
//  Created by Aditya Narayan on 6/28/16.
//  Copyright © 2016 TurnToTech. All rights reserved.
//

#import "ScoreViewController.h"

@interface ScoreViewController ()

@property (weak, nonatomic) IBOutlet UILabel * currentScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel * topScoreLabel;
@property (nonatomic) long topScore;
@property (nonatomic, retain) NSUserDefaults * defaults;

- (IBAction)playAgainClicked:(id)sender;

@end

@implementation ScoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.defaults = [NSUserDefaults standardUserDefaults];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString * currentScoreString = [NSString stringWithFormat:@"%lu", self.currentScore];
    self.currentScoreLabel.text = currentScoreString;
    
    self.topScore = [[self.defaults valueForKey:@"highScore"]longValue];
    if (self.currentScore > self.topScore) {
        self.topScore = self.currentScore;
        [self.defaults setInteger:self.topScore forKey:@"highScore"];
    }
    
    NSString * topScoreString = [NSString stringWithFormat:@"%lu", self.topScore];
    self.topScoreLabel.text = topScoreString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)playAgainClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
