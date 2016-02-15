//
//  GameKitHelper.m
//  Story
//
//  Created by George Ashton on 26/01/2015.
//  Copyright (c) 2015 George Ashton. All rights reserved.
//

#import "GameKitHelper.h"
#import "GameViewController.h"

@implementation GameKitHelper

// creating & returning a singleton object
#pragma mark Initialization
static GameKitHelper *sharedGameKitHelper = nil;
+ (GameKitHelper *) sharedInstance {
    if (!sharedGameKitHelper) {
        sharedGameKitHelper = [[GameKitHelper alloc] init];
    }
    return sharedGameKitHelper;
}

#pragma mark User Functions

// Once you set an aunthetication handler, Game Kit auto authenticates the player, calling the handler as necessary to complete process. Each time game moves from background to foreground, Gamekit auto authenticates the local player game

- (void)authenticateLocalUser
{
    // Instance of the GKLocalPlayer class. This instance represents the player who is currently authenticated through Game Center on this device. Only one player may be authenticated at a time.
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController,
                                        NSError *error)
    {
        [self setLastError:error];
        
        if (viewController != nil)
            
        {
// If device does not having authetnicaed player, Game kit passes a view controller your authentication handler. When presented by the game, this view controller displays the authentication user interface.  The game should pause other acitivites that require user interaction and prsent this view controller.

            //showAuthenticationDialogWhenReasonable: is an example method name.
            //Create your own method that displays an authentication view when appropriate for
            //    your app.
            [self presentViewController:viewController];
        }
        else if ([GKLocalPlayer localPlayer].isAuthenticated)
        {
            //If the authentication process succeeded,
            //authenticatedPlayer: is an example method name. Create your own
            //method that is called after the loacal player is authenticated.
            /*
             [GKTurnBasedMatch loadMatchesWithCompletionHandler:
             ^(NSArray *matches, NSError *error)
             {
             for (GKTurnBasedMatch *match in matches)
             {
             NSLog(@"remove existed match %@", match.matchID);
             [match removeWithCompletionHandler:^(NSError *error){
             NSLog(@"%@", error);}];
             }
             }
             ];
             */
            NSLog(@"Local Player ID: %@", [GKLocalPlayer localPlayer].playerID);
            
            [[GKLocalPlayer localPlayer] registerListener:self];
            [self.delegate authenticationChanged:YES];
        }
        else
        {
            // If the authentication process failed
            [self.delegate authenticationChanged:NO];
        }
    };
    
    }
    
#pragma mark Property setters
    
-(void) setLastError:(NSError*)error
    {
        // Track the last error that occurred while communicating with the GameKit service.
        _lastError = [error copy];
        if (_lastError)
        {
            NSLog(@"GameKitHelper ERROR: %@",
                  [[_lastError userInfo] description]);
        }
    }

    
- (void)findMatchWithMinPlayers:(int)minPlayers
                     maxPlayers:(int)maxPlayers
viewController:(UIViewController *)viewController
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
   if(localPlayer.isAuthenticated == NO)
   {
       NSLog(@"localPlayer NOT authenticated in findMatchWithMinPlayers()");
             return;
   }
   presentingViewController = viewController;
    
    GKMatchRequest *request = [[GKMatchRequest alloc] init]; // Set number of players
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
    
    GKTurnBasedMatchmakerViewController *mmvc = // new instance of the GKMatchmakerViewController with the given request, sets its delegate to the GameKitHelper object, and uses the passed-in view controller to show it on the screen. Shows the user to search for a random player and start a game.
    [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.turnBasedMatchmakerDelegate = self;
    mmvc.showExistingMatches = YES;
    
//  This line of code breaks the back button on game screen
    
    
    [presentingViewController presentViewController:mmvc animated:YES completion:NULL];
    
    
}


#pragma mark GKTurnBasedMatchmakerViewControllerDelegate
             
// The user has cancelled matchmaking
- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController {
//                 [viewController dismissModalViewControllerAnimated:YES completion:nil];
    [self dismissModalViewController];
                 NSLog(@"Has cancelled");
             }
// Matchmaking has failed with an error
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
[viewController dismissViewControllerAnimated:YES completion:nil];
NSLog(@"Error finding match: %@", error.localizedDescription);
             }
             
// A peer-to-peer match has been found, the game should start
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match
{
// [presentingViewController dismissViewControllerAnimated:YES completion:nil];

//    // Dismiss the view controller
//    [viewController dismissViewControllerAnimated:YES completion:nil];
   
    
    [viewController dismissViewControllerAnimated:YES completion:^{

        // Present next controller here
    [presentingViewController performSegueWithIdentifier:@"GamePlayScene" sender:match];
     }];


    
// Removing line below fixes  Warning: Attempt to dismiss from view controller <GameNavigationController: 0x78f4f820> while a presentation or dismiss is in progress!

// [self dismissModalViewController];
    
    self.currentMatch = match;
    
    GKTurnBasedParticipant *firstParticipant =
    [match.participants objectAtIndex:0];
    if (firstParticipant.lastTurnDate == nil)
    {
        // It's a new game!
        [self.delegate enterNewGame:match];
        
    }
    else
    {
        // Entered an exisiting match
        if ([match.currentParticipant.player.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) // This fixed Player 2 not being able to take turn problem 
        {
            // It's your turn!
            [self.delegate takeTurn:match];
            
        }
        else
        {
            // It's not your turn, just display the game state.
            [self.delegate layoutMatch:match];
        }
    }
}
    //    match.delegate = self;
    //    if (!_matchStarted && match.expectedPlayerCount == 0) {



// Player quit the match
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match {
    
    NSUInteger currentPlayerIndex = [match.participants indexOfObject:match.currentParticipant];
    
    //Local player dead, find next live player and hand turn over to him.
    GKTurnBasedParticipant *livePlayer;
    
    for (int i = 0; i < [match.participants count]; i++)
    {
        livePlayer = [match.participants objectAtIndex: (currentPlayerIndex + 1 + i) % match.participants.count];
        if (livePlayer.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            break;
        }
    }
    if (livePlayer ==nil)
        return;
    NSArray* livePlayers = [[NSArray alloc] initWithObjects:livePlayer,nil];
    
    NSLog(@"playerquitforMatch, %@, %@", match, match.currentParticipant);
    
    [match participantQuitInTurnWithOutcome:GKTurnBasedMatchOutcomeQuit
                           nextParticipants:livePlayers
                            turnTimeout:GKTurnTimeoutDefault
                                  matchData:match.matchData
                                             completionHandler:nil];
}



#pragma mark methods declared in the Protocol of GKLocalPlayerListener 
     
//Handling Exchanges
- (void)player:(GKPlayer *)player
receivedExchangeCancellation:(GKTurnBasedExchange *)exchange
forMatch:(GKTurnBasedMatch *)match
{
}

-(void)player:(GKPlayer *)player
receivedExchangeReplies:(NSArray *) replies
forCompletedExchange:(GKTurnBasedMatch *)exchange
forMatch:(GKTurnBasedMatch *)match
{
}
     
- (void)player:(GKPlayer *)player
receievedExchangeRequest:(GKTurnBasedExchange *)exchange
forMatch:(GKTurnBasedMatch *)match
{
}

// Handling Match Related Events

     -(void)player:(GKPlayer *)player
                  receivedTurnEventForMatch:(GKTurnBasedMatch *)match
                            didBecomeActive:(BOOL)didBecomeActive
     {
         // This event activated the application.
         // This means the user tapped on the notification banner
         // and wants to see or play this match now
         
         if (didBecomeActive)
         {
             // ??? [self switchToMatch:match];
             NSLog(@"return from didBecomeActive branch in receievedTurnEventForMatch");
             return; // Notice Here
         }
        NSLog(@"run second part from in receivedTurnEventForMatch");
         
// Match updated - Handle the event more selectively
if ([match.matchID isEqualToString:self.currentMatch.matchID])
{
    // This is the match the user is currently playing - update to show latest state - [self refreshMatch:match];?
    if ([match.currentParticipant.player.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
    {
        // it's the current match and its our turn now
        self.currentMatch = match;
        [self.delegate takeTurn:match];
    }
    else
    {
        // it's the current match, but its someone else's turn
        self.currentMatch = match;
        [self.delegate layoutMatch:match];
    }
    
}
         else // Turn recived for different match
         {
             // It became the Player's turn in a different match
             if ([match.currentParticipant.player.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID])
             {
                 // It's not the current match and its our turn now
                 [self.delegate sendNotice:@"It's your turn for another match" forMatch:match];
             }
             else
             {
                 // it's not the current match, and its someone else's turn
             }
         }
     }

     
     
#pragma mark GKTurnBasedEventHandlerDelegate

-(void)handleInviteFromGameCenter:(NSArray *)playersToInvite {
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.recipients = playersToInvite;
    request.maxPlayers = 2;
    request.minPlayers = 2;
    GKTurnBasedMatchmakerViewController *viewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
    viewController.showExistingMatches = NO;
    viewController.turnBasedMatchmakerDelegate = self;
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

//-(void)handleTurnEventForMatch:(GKTurnBasedMatch *)match {
//    NSLog(@"Turn has happended");
//    if ([match.matchID isEqualToString:self.currentMatch.matchID]) {
//        if ([match.currentParticipant.player.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
//            // its the current and its our turn now
//            self.currentMatch = match;
//            [self.delegate takeTurn:match];
//        } else {
//            // its current match, but its someone else's turn
//            self.currentMatch = match;
//            [self.delegate layoutMatch:match];
//        }
//    } else {
//        if ([match.currentParticipant.player.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
//            // it's not the current match and its our turn now
//            [self.delegate sendNotice:@"Its your turn for another match" forMatch:match];
//        } else {
//            // its not the current match, and its someone else's turn
//        }
//    }
//}

-(void)handleMatchEnded:(GKTurnBasedMatch *)match {
    NSLog(@"Game has ended");
    if ([match.matchID isEqualToString:_currentMatch.matchID]) {
        [self.delegate recieveEndGame:match];
    } else {
        [self.delegate sendNotice:@"Another Game Ended!" forMatch:match];
    }
}

- (void)player:(GKPlayer *)player
didRequestMatchWithPlayers:(NSArray *)playerIDsToInvite
{
    
}

- (void)player:(GKPlayer *)player
matchEnded:(GKTurnBasedMatch *)match
{
    
}

#pragma mark UIViewController stuff

-(UIViewController*) getRootViewController
{
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

-(void)presentViewController:(UIViewController*)vc
{
    UIViewController* rootVC = [self getRootViewController];
    [rootVC presentViewController:vc animated:YES completion:nil];
}

- (void)dismissModalViewController
{
    UIViewController *rootVC = [self getRootViewController];
    [rootVC dismissViewControllerAnimated:YES completion:nil];
}

@end


