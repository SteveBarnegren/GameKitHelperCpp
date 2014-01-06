//
//  GameCentreManager.h
//  HelloCpp
//
//  Created by Steve Barnegren on 28/11/2013.
//
//

#ifndef __HelloCpp__GameCentreManager__
#define __HelloCpp__GameCentreManager__

#include <iostream>
#include <vector>
#include "GKCppAlternatives.h"

class GKHDelegate;


class GKHWrapperCpp {

public:
    
    GKHWrapperCpp();
    
    // Players
    void authenticateLocalPlayer();
    bool isLocalPlayerAuthenticated();
    void getLocalPlayerFriends();
    void getPlayerInfo(std::vector<std::string>playerList);

    // Scores
    void submitScoreToCatagory(int64_t s, std::string c);
    void retrieveTopTenAllTimeGlobalScores(std::string catagory);
    void retrieveScoresForPlayersToday(std::vector<std::string> *playerIDs, std::string catagory, int startIndex, int numPlayers, bool friendsOnly);
    void retrieveScoresForPlayersThisWeek(std::vector<std::string> *playerIDs, std::string catagory, int startIndex, int numPlayers, bool friendsOnly);
    void retrieveScoresForPlayersAllTime(std::vector<std::string> *playerIDs, std::string catagory, int startIndex, int numPlayers, bool friendsOnly);
    
    // Achivements
    GKAchievementCpp getAchievementByID(std::string identifier);
    void reportAchievement(std::string identifier, float percentComplete, bool showCompletionBanner);
    void resetAchievements();
    void reportCachedAchievements();
    void saveCachedAchievements();
    
    // Game Center Views
    void showLeaderBoard();
    void showAchievements();
    
    //delegate
    void setDelegate(GKHDelegate* gkhDelegate);
    
};

#endif /* defined(__HelloCpp__GameCentreManager__) */
