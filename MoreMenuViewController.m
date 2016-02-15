//
//  MoreMenuViewController.m
//  Story
//
//  Created by George Ashton on 20/02/2015.
//  Copyright (c) 2015 George Ashton. All rights reserved.
//

#import "MoreMenuViewController.h"
#import "GameKitHelper.h"
#import <GameKit/GameKit.h>

@implementation MoreMenuViewController

- (IBAction)backButton:(UIButton *)sender {
}

- (IBAction)tellFriend:(id)sender {
    
    NSString *shareText = [NSString stringWithFormat:@"Check out Stories With Friends, a new word game for iPhone!"]; // Share message
    NSArray *itemsToShare = @[shareText];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare                                                                                                applicationActivities:nil];
    activityVC.excludedActivityTypes = @[];
    [self presentViewController:activityVC animated:YES completion:nil];
    
}

- (IBAction)sendFriendRequest:(id)sender {
    
    GKFriendRequestComposeViewController *friendRequestViewController = [[GKFriendRequestComposeViewController alloc] init];
    
    friendRequestViewController.composeViewDelegate = self;
    
    [friendRequestViewController addRecipientPlayers: nil];
    
    [self presentViewController:friendRequestViewController animated:YES completion:nil];
    
    
}


@end
