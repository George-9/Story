//
//  ViewController.m
//  Story
//
//  Created by George Ashton on 26/01/2015.
//  Copyright (c) 2015 George Ashton. All rights reserved.
//

#import "ViewController.h"
#import "GameKitHelper.h"
#import "GameViewController.h"

//@interface ViewController()
//
//@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    GKTurnBasedMatch *matchToLoad = [GameKitHelper sharedInstance].currentMatch;
    
    if (matchToLoad)
    {
        
        [self performSegueWithIdentifier:@"GamePlayScene" sender:nil];

    }
     

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)findGame:(UIButton *)sender {
    
    [[GameKitHelper sharedInstance]
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:self]; // Start matchmaking when pressing the find game button
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GamePlayScene"])
    {
        GameViewController* gameVC = (GameViewController*)segue.destinationViewController;
        gameVC.match = [GameKitHelper sharedInstance].currentMatch;
    }
}


@end
