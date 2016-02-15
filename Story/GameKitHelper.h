//
//  GameKitHelper.h
//  Story
//
//  Created by George Ashton on 26/01/2015.
//  Copyright (c) 2015 George Ashton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>


@protocol GameKitHelperDelegate // Notify other objects of when important events happen, such as the match starting, ending, or receiving data from the other party.

- (void)authenticationChanged:(BOOL)successFlag;

// Once upon a time

- (void)enterNewGame:(GKTurnBasedMatch *)match;

// View a match where it’s another player’s turn. Prevents player from sending a turn in this case. UI updates to reflect current state of the match.

- (void)layoutMatch:(GKTurnBasedMatch *)match;

// Our players turn, but it's an existing match. For when our player chooses an existing match from the GKTurnBasedMatchmakerViewController, or when a new turn notification comes in.

- (void)takeTurn:(GKTurnBasedMatch *)match;

// When a match has ended on our player’s turn, or when we receive a notification that has a match has ended on another player’s turn. End the game when close to current NSData turn-based game size limit (4096 bytes).

- (void)recieveEndGame:(GKTurnBasedMatch *)match;

// When we receive an event (update turn, end game) on a match that isn’t one we’re currently looking at. If we receive an end game notice on a match that we’ve got loaded into our currentMatch variable, we’ll update the UI to reflect the current state of that match.

- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match;

//- (void)match:(GKMatch *)match didReceiveData:(NSData *)data
//   fromPlayer:(NSString *)playerID;
//
//extern NSString *const PresentAuthenticationViewController;
//extern NSString *const LocalPlayerIsAuthenticated;

@end



@interface GameKitHelper: NSObject<GKTurnBasedMatchmakerViewControllerDelegate, GKLocalPlayerListener>
{
//    GKTurnBasedMatch *currentMatch;
////    id <GameKitHelperDelegate> delegate;
 UIViewController *presentingViewController;
}


@property (nonatomic, weak) id <GameKitHelperDelegate> delegate;

@property (assign) BOOL userAuthenticated;

@property (nonatomic, readonly) NSError* lastError; // keep track of most recent error with GC API

@property (strong) GKTurnBasedMatch *currentMatch;
//@property(readonly, retain, nonatomic) GKPlayer *player;


//@property (nonatomic, readonly) UIViewController *authenticationViewController; // defines a view controller


//+ (instancetype)sharedGameKitHelper;
+(GameKitHelper *)sharedInstance;

- (void)authenticateLocalUser;

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController *)viewController;
//                       delegate:(id<GameKitHelperDelegate>)delegate;
@end
