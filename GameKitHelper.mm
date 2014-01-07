/*
 * cocos2d-project http://www.learn-cocos2d.com
 *
 * Copyright (c) 2010 Steffen Itterheim
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "GameKitHelper.h"

static NSString* kCachedAchievementsFile = @"CachedAchievements.archive";

@interface GameKitHelper (Private)
-(void) registerForLocalPlayerAuthChange;
-(void) setLastError:(NSError*)error;
-(void) initCachedAchievements;
-(void) cacheAchievement:(GKAchievement*)achievement;
-(void) uncacheAchievement:(GKAchievement*)achievement;
-(void) loadAchievements;
-(void) initMatchInvitationHandler;
-(UIViewController*) getRootViewController;
@end

@implementation GameKitHelper{
    
    GKHDelegate *_gkhDelegate;

}

static GameKitHelper *instanceOfGameKitHelper;

#pragma mark Singleton stuff
+(id) alloc
{
	@synchronized(self)
	{
		NSAssert(instanceOfGameKitHelper == nil, @"Attempted to allocate a second instance of the singleton: GameKitHelper");
		instanceOfGameKitHelper = [[super alloc] retain];
		return instanceOfGameKitHelper;
	}
	
	// to avoid compiler warning
	return nil;
}

+(GameKitHelper*) sharedGameKitHelper
{
	@synchronized(self)
	{
		if (instanceOfGameKitHelper == nil)
		{
			[[GameKitHelper alloc] init];
		}
		
		return instanceOfGameKitHelper;
	}
	
	// to avoid compiler warning
	return nil;
}

#pragma mark Init & Dealloc

//@synthesize delegate;
@synthesize isGameCenterAvailable;
@synthesize lastError;
@synthesize achievements;
@synthesize currentMatch;
@synthesize matchStarted;

-(id) init
{
	if ((self = [super init]))
	{
        
        _gkhDelegate = nullptr;
        
		// Test for Game Center availability
		Class gameKitLocalPlayerClass = NSClassFromString(@"GKLocalPlayer");
		bool isLocalPlayerAvailable = (gameKitLocalPlayerClass != nil);
		
		// Test if device is running iOS 4.1 or higher
		NSString* reqSysVer = @"4.1";
		NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
		bool isOSVer41 = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
		
		isGameCenterAvailable = (isLocalPlayerAvailable && isOSVer41);
		NSLog(@"GameCenter available = %@", isGameCenterAvailable ? @"YES" : @"NO");
        
		[self registerForLocalPlayerAuthChange];
        
		[self initCachedAchievements];
	}
	
	return self;
}

-(void) dealloc
{
	//CCLOG(@"dealloc %@", self);
    
    NSLog(@"dealloc %@", self);
    
	
	[instanceOfGameKitHelper release];
	instanceOfGameKitHelper = nil;
	
	[lastError release];
	
	[self saveCachedAchievements];
	[cachedAchievements release];
	[achievements release];
    
	[currentMatch release];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[super dealloc];
}

#pragma mark setLastError

-(void) setLastError:(NSError*)error
{
	[lastError release];
	lastError = [error copy];
	
	if (lastError)
	{
		NSLog(@"GameKitHelper ERROR: %@", [[lastError userInfo] description]);
	}
}

#pragma mark Player Authentication

-(void) authenticateLocalPlayer
{
	if (isGameCenterAvailable == NO)
		return;
    
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	if (localPlayer.authenticated == NO)
	{
		// Authenticate player, using a block object. See Apple's Block Programming guide for more info about Block Objects:
		// http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html
		[localPlayer authenticateWithCompletionHandler:^(NSError* error)
         {
             [self setLastError:error];
             
             if (error == nil)
             {
                 [self initMatchInvitationHandler]; //are not using achievements so commented out these three lines
                 [self reportCachedAchievements];
                 [self loadAchievements];
             }
         }];
		
		/*
		 // NOTE: bad example ahead!
		 
		 // If you want to modify a local variable inside a block object, you have to prefix it with the __block keyword.
		 __block bool success = NO;
		 
		 [localPlayer authenticateWithCompletionHandler:^(NSError* error)
		 {
         success = (error == nil);
		 }];
		 
		 // CAUTION: success will always be NO here! The block isn't run until later, when the authentication call was
		 // confirmed by the Game Center server. Set a breakpoint inside the block to see what is happening in what order.
		 if (success)
         NSLog(@"Local player logged in!");
		 else
         NSLog(@"Local player NOT logged in!");
		 */
	}
}

-(void) onLocalPlayerAuthenticationChanged
{
	//[delegate onLocalPlayerAuthenticationChanged];
    
    NSLog(@"Game Kit Helper - On local player authentication changed");
    
    if (_gkhDelegate != nullptr) {
        _gkhDelegate->onLocalPlayerAuthenticationChanged();
    }
    
}

-(void) registerForLocalPlayerAuthChange
{
	if (isGameCenterAvailable == NO)
		return;
    
	// Register to receive notifications when local player authentication status changes
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(onLocalPlayerAuthenticationChanged)
			   name:GKPlayerAuthenticationDidChangeNotificationName
			 object:nil];
}

-(BOOL) isLocalPlayerAuthenticated{
    
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	return localPlayer.authenticated;
}




#pragma mark Friends & Player Info

-(void) getLocalPlayerFriends
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	if (localPlayer.authenticated)
	{
		// First, get the list of friends (player IDs)
		[localPlayer loadFriendsWithCompletionHandler:^(NSArray* friends, NSError* error)
         {
             [self setLastError:error];
             //[delegate onFriendListReceived:friends];
             if (_gkhDelegate != nullptr) {
                 std::vector<std::string> vector = [self convertNSArrayOfStringToCppVector:friends];
                 _gkhDelegate->onFriendsListRecieved(vector);
             }
         }];
	}
}

-(void) getPlayerInfo:(NSArray*)playerList
{
	if (isGameCenterAvailable == NO)
		return;
    
	// Get detailed information about a list of players
	if ([playerList count] > 0)
	{
		[GKPlayer loadPlayersForIdentifiers:playerList withCompletionHandler:^(NSArray* players, NSError* error)
         {
             [self setLastError:error];
             //[delegate onPlayerInfoReceived:players];
             NSLog(@"about to store players");
             [self storePlayers:players];
             
             if (_gkhDelegate != nullptr) {
                 std::vector<GKPlayerCpp> vector = [self convertNSArrayOfGKPlayersToCppVector:players];
                 _gkhDelegate->onPlayerInfoReceived(vector);
             }
             
         }];
	}
}

#pragma mark Scores & Leaderboard

-(void) submitScore:(int64_t)score category:(NSString*)category
{
	if (isGameCenterAvailable == NO)
		return;
    
	GKScore* gkScore = [[[GKScore alloc] initWithCategory:category] autorelease];
	gkScore.value = score;
    
	[gkScore reportScoreWithCompletionHandler:^(NSError* error)
     {
         [self setLastError:error];
         
         bool success = (error == nil);
         //[delegate onScoresSubmitted:success];
         if (_gkhDelegate != nullptr) {
             _gkhDelegate->onScoresSubmitted(success);
         }
     }];
}

-(void) retrieveScoresForPlayers:(NSArray*)players
						category:(NSString*)category
						   range:(NSRange)range
					 playerScope:(GKLeaderboardPlayerScope)playerScope
					   timeScope:(GKLeaderboardTimeScope)timeScope
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLeaderboard* leaderboard = nil;
	if ([players count] > 0)
	{
		leaderboard = [[[GKLeaderboard alloc] initWithPlayerIDs:players] autorelease];
	}
	else
	{
		leaderboard = [[[GKLeaderboard alloc] init] autorelease];
		leaderboard.playerScope = playerScope;
	}
	
	if (leaderboard != nil)
	{
		leaderboard.timeScope = timeScope;
		leaderboard.category = category;
		leaderboard.range = range;
		[leaderboard loadScoresWithCompletionHandler:^(NSArray* scores, NSError* error)
         {
             [self setLastError:error];
             //[delegate onScoresReceived:scores];
             if (_gkhDelegate != nullptr) {
                 _gkhDelegate->onScoresReceived([self convertNSArrayOfGKScoresToCppVector:scores]);
             }
         }];
	}
}

-(void) retrieveTopTenAllTimeGlobalScoresForCatagory:(NSString*)catagory
{
	[self retrieveScoresForPlayers:nil
						  category:catagory
							 range:NSMakeRange(1, 10)
					   playerScope:GKLeaderboardPlayerScopeGlobal
						 timeScope:GKLeaderboardTimeScopeAllTime];
}

#pragma mark Achievements

-(void) loadAchievements
{
	if (isGameCenterAvailable == NO)
		return;
    
	[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray* loadedAchievements, NSError* error)
     {
         [self setLastError:error];
		 
         if (achievements == nil)
         {
             achievements = [[NSMutableDictionary alloc] init];
         }
         else
         {
             [achievements removeAllObjects];
         }
         
         for (GKAchievement* achievement in loadedAchievements)
         {
             [achievements setObject:achievement forKey:achievement.identifier];
         }
         
         //send all achivements in the achievements disctionary to fthe delegate as a std::map
         if (_gkhDelegate != nullptr) {
             _gkhDelegate->onAchievementsLoaded([self convertNSDictionaryOfGKAchievementTostdMap:achievements]);
         }
         
         //[delegate onAchievementsLoaded:achievements];
         
     }];
}

-(GKAchievement*) getAchievementByID:(NSString*)identifier
{
	if (isGameCenterAvailable == NO)
		return nil;
    
	// Try to get an existing achievement with this identifier
	GKAchievement* achievement = [achievements objectForKey:identifier];
	
	if (achievement == nil)
	{
		// Create a new achievement object
		achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
		[achievements setObject:achievement forKey:achievement.identifier];
	}
	
	return [[achievement retain] autorelease];
}

-(void) reportAchievementWithID:(NSString*)identifier percentComplete:(float)percent showCompletionBanner:(BOOL)showBanner
{
	if (isGameCenterAvailable == NO)
		return;
    
	GKAchievement* achievement = [self getAchievementByID:identifier];
	if (achievement != nil && achievement.percentComplete < percent)
	{
		achievement.percentComplete = percent;
        achievement.showsCompletionBanner = showBanner;
		[achievement reportAchievementWithCompletionHandler:^(NSError* error)
         {
             [self setLastError:error];
             
             bool success = (error == nil);
             if (success == NO)
             {
                 // Keep achievement to try to submit it later
                 [self cacheAchievement:achievement];
             }
             
             //[delegate onAchievementReported:achievement];
             if (_gkhDelegate != nullptr) {
                _gkhDelegate->onAchievementReported([self convertGKAchievementToGKAchievementStruct:achievement]);
             }
             
         }];
	}
}

-(void) resetAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	[achievements removeAllObjects];
	[cachedAchievements removeAllObjects];
	
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError* error)
     {
         [self setLastError:error];
         bool success = (error == nil);
         //[delegate onResetAchievements:success];
         if (_gkhDelegate != nullptr) {
             _gkhDelegate->onResetAchievements(success);
         }
         
     }];
}

-(void) reportCachedAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	if ([cachedAchievements count] == 0)
		return;
    
	for (GKAchievement* achievement in [cachedAchievements allValues])
	{
		[achievement reportAchievementWithCompletionHandler:^(NSError* error)
         {
             bool success = (error == nil);
             if (success == YES)
             {
                 [self uncacheAchievement:achievement];
             }
         }];
	}
}

-(void) initCachedAchievements
{
	NSString* file = [NSHomeDirectory() stringByAppendingPathComponent:kCachedAchievementsFile];
	id object = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
	
	if ([object isKindOfClass:[NSMutableDictionary class]])
	{
		NSMutableDictionary* loadedAchievements = (NSMutableDictionary*)object;
		cachedAchievements = [[NSMutableDictionary alloc] initWithDictionary:loadedAchievements];
	}
	else
	{
		cachedAchievements = [[NSMutableDictionary alloc] init];
	}
}

-(void) saveCachedAchievements
{
	NSString* file = [NSHomeDirectory() stringByAppendingPathComponent:kCachedAchievementsFile];
	[NSKeyedArchiver archiveRootObject:cachedAchievements toFile:file];
}

-(void) cacheAchievement:(GKAchievement*)achievement
{
	[cachedAchievements setObject:achievement forKey:achievement.identifier];
	
	// Save to disk immediately, to keep achievements around even if the game crashes.
	[self saveCachedAchievements];
}

-(void) uncacheAchievement:(GKAchievement*)achievement
{
	[cachedAchievements removeObjectForKey:achievement.identifier];
	
	// Save to disk immediately, to keep the removed cached achievement from being loaded again
	[self saveCachedAchievements];
}

#pragma mark Matchmaking

-(void) disconnectCurrentMatch
{
	[currentMatch disconnect];
	currentMatch.delegate = nil;
	[currentMatch release];
	currentMatch = nil;
}

-(void) setCurrentMatch:(GKMatch*)match
{
	if ([currentMatch isEqual:match] == NO)
	{
		[self disconnectCurrentMatch];
		currentMatch = [match retain];
		currentMatch.delegate = self;
	}
}

-(void) initMatchInvitationHandler
{
	if (isGameCenterAvailable == NO)
		return;
    
	[GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite* acceptedInvite, NSArray* playersToInvite)
	{
		[self disconnectCurrentMatch];
		
		if (acceptedInvite)
		{
			[self showMatchmakerWithInvite:acceptedInvite];
		}
		else if (playersToInvite)
		{
			GKMatchRequest* request = [[[GKMatchRequest alloc] init] autorelease];
			request.minPlayers = 2;
			request.maxPlayers = 4;
			request.playersToInvite = playersToInvite;
            
			[self showMatchmakerWithRequest:request];
		}
	};
}

-(void) findMatchForRequest:(GKMatchRequest*)request
{
	if (isGameCenterAvailable == NO)
		return;
	
	[[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch* match, NSError* error)
     {
         [self setLastError:error];
         
         if (match != nil)
         {
             [self setCurrentMatch:match];
             [delegate onMatchFound:match];
         }
     }];
}

-(void) addPlayersToMatch:(GKMatchRequest*)request
{
	if (isGameCenterAvailable == NO)
		return;
    
	if (currentMatch == nil)
		return;
	
	[[GKMatchmaker sharedMatchmaker] addPlayersToMatch:currentMatch matchRequest:request completionHandler:^(NSError* error)
     {
         [self setLastError:error];
         
         bool success = (error == nil);
         [delegate onPlayersAddedToMatch:success];
     }];
}

-(void) cancelMatchmakingRequest
{
	if (isGameCenterAvailable == NO)
		return;
    
	[[GKMatchmaker sharedMatchmaker] cancel];
}

-(void) queryMatchmakingActivity
{
	if (isGameCenterAvailable == NO)
		return;
    
	[[GKMatchmaker sharedMatchmaker] queryActivityWithCompletionHandler:^(NSInteger activity, NSError* error)
     {
         [self setLastError:error];
         
         if (error == nil)
         {
             [delegate onReceivedMatchmakingActivity:activity];
         }
     }];
}

#pragma mark Match Connection

-(void) match:(GKMatch*)match player:(NSString*)playerID didChangeState:(GKPlayerConnectionState)state
{
	switch (state)
	{
		case GKPlayerStateConnected:
			[delegate onPlayerConnected:playerID];
			break;
		case GKPlayerStateDisconnected:
			[delegate onPlayerDisconnected:playerID];
			break;
	}
	
	if (matchStarted == NO && match.expectedPlayerCount == 0)
	{
		matchStarted = YES;
		[delegate onStartMatch];
	}
}

-(void) sendDataToAllPlayers:(void*)data length:(NSUInteger)length
{
	if (isGameCenterAvailable == NO)
		return;
	
	NSError* error = nil;
	NSData* packet = [NSData dataWithBytes:data length:length];
	[currentMatch sendDataToAllPlayers:packet withDataMode:GKMatchSendDataUnreliable error:&error];
	[self setLastError:error];
}

-(void) match:(GKMatch*)match didReceiveData:(NSData*)data fromPlayer:(NSString*)playerID
{
	[delegate onReceivedData:data fromPlayer:playerID];
}

#pragma mark Views (Leaderboard, Achievements)

// Helper methods

-(UIViewController*) getRootViewController
{
	return [UIApplication sharedApplication].keyWindow.rootViewController;
}

-(void) presentViewController:(UIViewController*)vc
{
	UIViewController* rootVC = [self getRootViewController];
	[rootVC presentModalViewController:vc animated:YES];
}

-(void) dismissModalViewController
{
	UIViewController* rootVC = [self getRootViewController];
	[rootVC dismissModalViewControllerAnimated:YES];
}

// Leaderboards

-(void) showLeaderboard
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLeaderboardViewController* leaderboardVC = [[[GKLeaderboardViewController alloc] init] autorelease];
	if (leaderboardVC != nil)
	{
		leaderboardVC.leaderboardDelegate = self;
		[self presentViewController:leaderboardVC];
	}
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
	[self dismissModalViewController];
	//[delegate onLeaderboardViewDismissed];
    if (_gkhDelegate != nullptr) {
        _gkhDelegate->onLeaderboardViewDismissed();
    }
    
}

// Achievements

-(void) showAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKAchievementViewController* achievementsVC = [[[GKAchievementViewController alloc] init] autorelease];
	if (achievementsVC != nil)
	{
		achievementsVC.achievementDelegate = self;
		[self presentViewController:achievementsVC];
	}
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController*)viewController
{
	[self dismissModalViewController];
	//[delegate onAchievementsViewDismissed];
    if (_gkhDelegate != nullptr) {
        _gkhDelegate->onAchievementsViewDismissed();
    }

}

// Matchmaking

-(void) showMatchmakerWithInvite:(GKInvite*)invite
{
	GKMatchmakerViewController* inviteVC = [[[GKMatchmakerViewController alloc] initWithInvite:invite] autorelease];
	if (inviteVC != nil)
	{
		inviteVC.matchmakerDelegate = self;
		[self presentViewController:inviteVC];
	}
}

-(void) showMatchmakerWithRequest:(GKMatchRequest*)request
{
	GKMatchmakerViewController* hostVC = [[[GKMatchmakerViewController alloc] initWithMatchRequest:request] autorelease];
	if (hostVC != nil)
	{
		hostVC.matchmakerDelegate = self;
		[self presentViewController:hostVC];
	}
}

-(void) matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)viewController
{
	[self dismissModalViewController];
	[delegate onMatchmakingViewDismissed];
}

-(void) matchmakerViewController:(GKMatchmakerViewController*)viewController didFailWithError:(NSError*)error
{
	[self dismissModalViewController];
	[self setLastError:error];
	[delegate onMatchmakingViewError];
}

-(void) matchmakerViewController:(GKMatchmakerViewController*)viewController didFindMatch:(GKMatch*)match
{
	[self dismissModalViewController];
	[self setCurrentMatch:match];
	[delegate onMatchFound:match];
}

#pragma mark Delegate

-(void)setDelegate:(GKHDelegate*)gkhDelegate{
    
    _gkhDelegate = gkhDelegate;
    
}


#pragma mark C++/Objective-C type converters

-(std::vector<std::string>)convertNSArrayOfStringToCppVector:(NSArray*)array{
    
    std::vector<std::string> vector;
    vector.reserve(array.count);
    
    for (NSString *objcString in array) {
        
        std::string cppString = [objcString UTF8String];
        vector.push_back(cppString);
        
    }
    
    return vector;
    
}

-(NSArray*)convertCppVectorOfStringToNSArray:(std::vector<std::string>)vector{
    
    NSMutableArray *array = [[[NSMutableArray alloc]init]autorelease];
    
    for (std::vector<std::string>::iterator it = vector.begin(); it != vector.end(); it++) {
        
        NSString *string = [NSString stringWithUTF8String:it->c_str()];
        [array addObject:string];
        
    }
    
    return array;

}


-(GKPlayerCpp)convertGKPLayerToGKPLayerStruct:(GKPlayer*)player{
    
    GKPlayerCpp gkPlayerCpp;
    
    gkPlayerCpp.playerID = player.playerID.UTF8String;
    gkPlayerCpp.alias = player.alias.UTF8String;
    gkPlayerCpp.displayName = player.displayName.UTF8String;
    gkPlayerCpp.isFriend = player.isFriend;
    
    return gkPlayerCpp;
    
}

-(std::vector<GKPlayerCpp>)convertNSArrayOfGKPlayersToCppVector:(NSArray*)array{
    
    std::vector<GKPlayerCpp> vector;
    
    for (GKPlayer *gkPlayer in array) {
        
        GKPlayerCpp gkPlayerCpp = [self convertGKPLayerToGKPLayerStruct:gkPlayer];
        vector.push_back(gkPlayerCpp);
    
    }
    
    return vector;

}

-(GKScoreCpp)convertGKScoreToGKScoreStruct:(GKScore*)gkScore{
    
    GKScoreCpp gkScoreCpp;
    
    gkScoreCpp.playerID = gkScore.playerID.UTF8String;
    gkScoreCpp.catagory = gkScore.category.UTF8String;
    gkScoreCpp.value = gkScore.value;
    gkScoreCpp.context = gkScore.context;
    gkScoreCpp.formattedValue = gkScore.formattedValue.UTF8String;
    gkScoreCpp.rank = gkScore.rank;
    
    return gkScoreCpp;
}

-(std::vector<GKScoreCpp>)convertNSArrayOfGKScoresToCppVector:(NSArray*)array{
    
    std::vector<GKScoreCpp> vector;
    
    for (GKScore *gkScore in array) {
        
        GKScoreCpp gkScoreCpp = [self convertGKScoreToGKScoreStruct:gkScore];
        vector.push_back(gkScoreCpp);
        
    }
    
    return vector;
}

-(GKAchievementCpp)convertGKAchievementToGKAchievementStruct:(GKAchievement*)a{
    
    GKAchievementCpp achievement;
    achievement.completed = a.completed;
    achievement.identifier = [a.identifier UTF8String];
    achievement.percentComplete = a.percentComplete;
    achievement.showsCompletionBanner = a.showsCompletionBanner;
    
    return achievement;

}

-(std::map<std::string, GKAchievementCpp>)convertNSDictionaryOfGKAchievementTostdMap:(NSDictionary*)dict{

    std::map<std::string, GKAchievementCpp> map;
    
    for (NSString *key in dict) {
        
        GKAchievement *a = [dict objectForKey:key];
        
        GKAchievementCpp achievement;

        achievement.completed = a.completed;
        achievement.identifier = [a.identifier UTF8String];
        achievement.percentComplete = a.percentComplete;
        achievement.showsCompletionBanner = a.showsCompletionBanner;
        
        map[achievement.identifier] = achievement;
        
    }
    
    return map;
    
}

@end
