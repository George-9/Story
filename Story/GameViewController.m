//
//  GameViewController.m
//  Story
//
//  Created by George Ashton on 26/01/2015.
//  Copyright (c) 2015 George Ashton. All rights reserved.
//

#import "GameViewController.h"
#import "GameKitHelper.h"
#import <GameKit/GameKit.h>

@implementation GameViewController


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [GameKitHelper sharedInstance].delegate = self;
    
    inputText.delegate = self;
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if(localPlayer.isAuthenticated ==NO)
    {
        [self authenticationChanged:NO];
    }
    else
    {
        inputText.enabled = NO; // makes keyboard appear
      //  statusLabel.text = @"Welcome. Press the button to get started.";
    }
    

}

- (void)viewDidUnload
{
    mainTextController = nil;
    inputView = nil;
    inputText = nil;
    characterCount = nil;
   // statusLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
    NSLog(@"text view up");
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    const int movementDistance = 210; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    
    int textFieldMovement = movement * 0.75;
    inputView.frame = CGRectOffset(inputView.frame, 0, movement);
    mainTextController.frame = CGRectMake(mainTextController.frame.origin.x, mainTextController.frame.origin.y, mainTextController.frame.size.width, mainTextController.frame.size.height + textFieldMovement);
    [UIView commitAnimations];
    NSLog(@"%f", mainTextController.frame.size.height);
}

#pragma mark - Handler of User Interaction
- (IBAction)sendTurn:(id)sender {
    
    GKTurnBasedMatch *currentMatch = // Set up currentMatch variable by retrieving the match from GameKitHelper singleton, only display one match at a time - keep track of this one match in our currrent match variable.
    [[GameKitHelper sharedInstance] currentMatch];
    NSString *newStoryString;
    if ([inputText.text length] > 250) {
        newStoryString = [inputText.text substringToIndex:249]; // Check if length of string in text is too long. If more than 250 characters we cut it off using the substringToIndex call. If not, we just pass the string into our variable.
    } else {
        newStoryString = inputText.text;
    }
    NSString *sendString = [NSString stringWithFormat:@"%@ %@",
                            mainTextController.text, newStoryString];
    NSData *data = // Created by combining the string thats in mainTextController with the string we just created.
    [sendString dataUsingEncoding:NSUTF8StringEncoding ];
    //cachedOldStory used to rollback in case of failing to send out data
    NSString *cachedOldStory = [mainTextController.text copy];
    mainTextController.text = sendString;
    
    inputText.text = @"";
    characterCount.text = @"250";
    characterCount.textColor = [UIColor blackColor];
    
    NSUInteger currentIndex = [currentMatch.participants // For every turn sent, information about the next person in turn roatation is
                               indexOfObject:currentMatch.currentParticipant];
    
    GKTurnBasedParticipant *nextParticipant;
    for (int i = 0; i < [currentMatch.participants count]; i++)
    {
    
    NSUInteger nextIndex = (currentIndex +1 + i) %
                        [currentMatch.participants count];
    nextParticipant = [currentMatch.participants objectAtIndex:nextIndex];
            if (nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            break;
        }
    }
    
    NSArray *nextParticipants = [[NSArray alloc] initWithObjects:nextParticipant, nil];
    [currentMatch endTurnWithNextParticipants:nextParticipants
                                  turnTimeout:GKExchangeTimeoutDefault
                                    matchData:data
                            completionHandler:^(NSError *error)
     {
         if (error)
         {
             NSLog(@"%@", error);
           //  statusLabel.text = @"Error, check Network and Game Center. Please try again.";
             mainTextController.text = cachedOldStory;
         }
         else
         {
             // statusLabel.text = @"Your turn is over.";
             inputText.enabled = NO;
         }
     }
     ];
    
    NSLog(@"Send Turn, %@, %@", data, nextParticipant);

}

- (IBAction)backButton:(UIButton *)sender {
    


}


- (IBAction)updateCount:(id)sender { // Amount of characters allowed
    
    UITextField *tf = (UITextField *)sender;
    int len = [tf.text length];
    int remain = 250 - len;
    characterCount.text = [NSString stringWithFormat:@"%d", remain];
    if (remain < 0) {
        characterCount.textColor = [UIColor redColor];
    } else {
        characterCount.textColor = [UIColor blackColor];
    }
    
}


//    
//    [currentMatch endTurnWithNextParticipants:(currentMatch.participants) turnTimeout:(326.4/60) matchData:data completionHandler:^(NSError *error) {
//        if (error) {
//            NSLog(@"%@", error);
//        }
//    }];
//    NSLog(@"Send Turn, %@, %@", data, nextParticipant);
//    inputText.text = @"";
//    characterCount.text = @"250";
//    characterCount.textColor = [UIColor blackColor];
//    
//}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)authenticationChanged:(BOOL)successFlag
{

}


-(void)checkForEnding:(NSData *)matchData {
    if ([matchData length] > 3000) {
        // statusLabel.text = [NSString stringWithFormat:@"%@, only about %d letter left", statusLabel.text, 4000 - [matchData length]];
    }
}

#pragma mark GameKitHelperDelegate

- (void)enterNewGame:(GKTurnBasedMatch *)match {
    NSLog(@"Entering new game...");
    
  //  statusLabel.text = @"Player 1's Turn (that's you)";
    inputText.enabled = YES; // player can type once in game
    mainTextController.text = @"Once upon a time";
}


-(void)takeTurn:(GKTurnBasedMatch *)match
{
    NSLog(@"Taking turn for existing game...");
    
    // int playerNum = [match.participants indexOfObject:match.currentParticipant] + 1;
    
// NSString *statusString = [NSString stringWithFormat:@"Player %d's Turn (that's you)", playerNum];
    
    // statusLabel.text = statusString;
    inputText.enabled = YES;
    
    if ([match.matchData bytes])
    {
        NSString *storySoFar = [NSString stringWithUTF8String:[match.matchData bytes]];
        mainTextController.text = storySoFar;
        [self checkForEnding:match.matchData];
    }
}

-(void)layoutMatch:(GKTurnBasedMatch *)match {
    
    NSLog(@"Viewing match where it's not our turn...");
    NSString *statusString;
    
    if (match.status == GKTurnBasedMatchStatusEnded)
    {
        statusString = @"Match Ended";
    }
    else
    {
        int playerNum = [match.participants indexOfObject:match.currentParticipant] + 1;
        statusString = [NSString stringWithFormat:@"Player %d's Turn", playerNum];
    }
   // statusLabel.text = statusString;
    inputText.enabled = NO;
    NSString *storySoFar = [NSString stringWithUTF8String:[match.matchData bytes]];
    mainTextController.text = storySoFar;
    [self checkForEnding:match.matchData];
}

-(void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:
                       @"Another game needs your attention!"
                        message:notice
                        delegate:self
                        cancelButtonTitle:@"Sweet!" otherButtonTitles:nil];
    [av show];
    //    [av release];
}


- (void)recieveEndGame:(GKTurnBasedMatch *)match {
    [self layoutMatch:match];
    NSLog(@"Match ended");
}

- (IBAction)inputText:(UITextField *)sender { // Where you enter story text
}



- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    NSLog(@"Received data");
}


- (void)playerAuthenticated { // find match by presenting matchmaker view controller
//    [[GameKitHelper sharedGameKitHelper] findMatchWithMinPlayers:2 maxPlayers:12 viewController:self delegate:self];
}

#pragma mark - View lifecycle -- Second Part

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//
//    
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end
