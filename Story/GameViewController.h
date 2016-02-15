//
//  GameViewController.h
//  Story
//
//  Created by George Ashton on 26/01/2015.
//  Copyright (c) 2015 George Ashton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameKitHelper.h"

@interface GameViewController : UIViewController <UITextFieldDelegate, GameKitHelperDelegate>
{
    
    __weak IBOutlet UITextView *mainTextController;
    __weak IBOutlet UIView *inputView;
    __weak IBOutlet UITextField *inputText;
    __weak IBOutlet UILabel *characterCount;
    
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up;

- (IBAction)updateCount:(id)sender;
- (IBAction)sendTurn:(id)sender;

- (IBAction)backButton:(UIButton *)sender;


@property (assign, nonatomic) GKTurnBasedMatch *match;

@end
