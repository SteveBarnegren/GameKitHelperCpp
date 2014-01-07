/*
 * www.stevebarnegren.com
 *
 * Copyright (c) 2013 Steve Barnegren
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

#include "GKHWrapperCpp.h"
#import "GameKitHelper.h"

GKHWrapperCpp::GKHWrapperCpp(){
    
    [GameKitHelper sharedGameKitHelper];
    
}

#pragma mark Players


void GKHWrapperCpp::authenticateLocalPlayer(){
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [gameKitHelper authenticateLocalPlayer];
    
}

bool GKHWrapperCpp::isLocalPlayerAuthenticated(){
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    return [gameKitHelper isLocalPlayerAuthenticated];
    
}

void GKHWrapperCpp::getLocalPlayerFriends(){
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [gameKitHelper getLocalPlayerFriends];
    
}

void GKHWrapperCpp::getPlayerInfo(std::vector<std::string>playerList){
    
    NSMutableArray *objcArray = [NSMutableArray array];
    
    for (int i = 0; i < playerList.size(); i++) {
        
        NSString *playerID = [NSString stringWithUTF8String:playerList.at(i).c_str()];
        [objcArray addObject:playerID];
        
    }
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [gameKitHelper getPlayerInfo:objcArray];
    
}



#pragma mark Scores


void GKHWrapperCpp::submitScoreToCatagory(int64_t s, std::string c){
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];

    NSString *catagory = [NSString stringWithUTF8String:c.c_str()];
    [gameKitHelper submitScore:s category:catagory];
    
}

void GKHWrapperCpp::retrieveTopTenAllTimeGlobalScores(std::string catagory){

    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [gameKitHelper retrieveTopTenAllTimeGlobalScoresForCatagory:[NSString stringWithUTF8String:catagory.c_str()]];
    
}

void GKHWrapperCpp::retrieveScoresForPlayersToday(std::vector<std::string> *playerIDs, std::string catagory, int startIndex, int numPlayers, bool friendsOnly){
    
    GKLeaderboardPlayerScope playerScope;
    
    if (friendsOnly) {playerScope = GKLeaderboardPlayerScopeFriendsOnly;}
    else {playerScope = GKLeaderboardPlayerScopeGlobal;}

    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
    NSArray *playerIDsArray = nil;
    if (playerIDs != nullptr) {
        playerIDsArray = [gameKitHelper convertCppVectorOfStringToNSArray:*playerIDs];
    }
    
    [gameKitHelper retrieveScoresForPlayers:playerIDsArray
                                   category:[NSString stringWithUTF8String:catagory.c_str()]
                                      range:NSMakeRange(startIndex, numPlayers)
                                playerScope:playerScope
                                  timeScope:GKLeaderboardTimeScopeToday];

}

void GKHWrapperCpp::retrieveScoresForPlayersThisWeek(std::vector<std::string> *playerIDs, std::string catagory, int startIndex, int numPlayers, bool friendsOnly){
        
    GKLeaderboardPlayerScope playerScope;
    
    if (friendsOnly) {playerScope = GKLeaderboardPlayerScopeFriendsOnly;}
    else {playerScope = GKLeaderboardPlayerScopeGlobal;}
    
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
    NSArray *playerIDsArray = nil;
    if (playerIDs != nullptr) {
        playerIDsArray = [gameKitHelper convertCppVectorOfStringToNSArray:*playerIDs];
    }
    
    [gameKitHelper retrieveScoresForPlayers:playerIDsArray
                                   category:[NSString stringWithUTF8String:catagory.c_str()]
                                      range:NSMakeRange(startIndex, numPlayers)
                                playerScope:playerScope
                                  timeScope:GKLeaderboardTimeScopeWeek];

}

void GKHWrapperCpp::retrieveScoresForPlayersAllTime(std::vector<std::string> *playerIDs, std::string catagory, int startIndex, int numPlayers, bool friendsOnly){
    
    GKLeaderboardPlayerScope playerScope;
    
    if (friendsOnly) {playerScope = GKLeaderboardPlayerScopeFriendsOnly;}
    else {playerScope = GKLeaderboardPlayerScopeGlobal;}
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
    NSArray *playerIDsArray = nil;
    if (playerIDs != nullptr) {
        playerIDsArray = [gameKitHelper convertCppVectorOfStringToNSArray:*playerIDs];
    }

    [gameKitHelper retrieveScoresForPlayers:playerIDsArray
                                   category:[NSString stringWithUTF8String:catagory.c_str()]
                                      range:NSMakeRange(startIndex, numPlayers)
                                playerScope:playerScope
                                  timeScope:GKLeaderboardTimeScopeAllTime];

}

#pragma mark Achievements

GKAchievementCpp GKHWrapperCpp::getAchievementByID(std::string identifier){
    
    NSString *nssid = [NSString stringWithUTF8String:identifier.c_str()];
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    GKAchievement *achievement = [gameKitHelper getAchievementByID:nssid];
    
    GKAchievementCpp gkaCpp = [gameKitHelper convertGKAchievementToGKAchievementStruct:achievement];
    return gkaCpp;
}


void GKHWrapperCpp::reportAchievement(std::string identifier, float percentComplete, bool showCompletionBanner){

    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    
    NSString *nssIndentifier = [NSString stringWithUTF8String:identifier.c_str()];
    
    [gameKitHelper reportAchievementWithID:nssIndentifier percentComplete:percentComplete showCompletionBanner:showCompletionBanner];
}


void GKHWrapperCpp::resetAchievements(){
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [gameKitHelper resetAchievements];
    
}

void GKHWrapperCpp::reportCachedAchievements(){
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [gameKitHelper reportCachedAchievements];
    
}

void GKHWrapperCpp::saveCachedAchievements(){
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [gameKitHelper saveCachedAchievements];
    
}


#pragma mark Game Centre Views

void GKHWrapperCpp::showLeaderBoard(){
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [gameKitHelper showLeaderboard];
    
}


void GKHWrapperCpp::showAchievements(){
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [gameKitHelper showAchievements];

}


#pragma mark Delegate

void GKHWrapperCpp::setDelegate(GKHDelegate* delegate){
    
    GameKitHelper *gameKitHelper = [GameKitHelper sharedGameKitHelper];
    [gameKitHelper setDelegate:delegate];
    
}









