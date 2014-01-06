//
//  GKHDelegate.cpp
//  HelloCpp
//
//  Created by Steve Barnegren on 29/11/2013.
//
//

#include "GKHDelegate.h"
#include "GKCppAlternatives.h"
//#include "GKHWrapperCpp.h"

GKHDelegate::GKHDelegate(){
    
    _debug = true;
    
}

#pragma mark Players

void GKHDelegate::onLocalPlayerAuthenticationChanged(){
    
    if (_debug) {
        std::cout << "\nGKHDelegate onLocalPlayerAuthenticationChanged";
    }
    
}

void GKHDelegate::onFriendsListRecieved(std::vector<std::string> friends){
    
    if (_debug) {
        std::cout << "\nGKHDelegate onFriendsListRecieved";
        std::cout << "\nNumber Of Friends: " << friends.size();
        std::cout << "\nFriend ID's:";
        
        for (int i = 0; i < friends.size(); i++) {
            
            std::cout << std::endl << friends.at(i);
            
        }

    }
}

void GKHDelegate::onPlayerInfoReceived(std::vector<GKPlayerCpp> playerInfo){

    if (_debug) {
        std::cout << "\nGKHDelegate onPlayerInfoReceived";
        std::cout << "\nPlayers:";
        
        for (int i = 0; i < playerInfo.size(); i++) {
            std::cout << std::endl << i+1 << ".";
            std::cout << std::endl << "PlayerID: " << playerInfo.at(i).playerID;
            std::cout << std::endl << "Alias: " << playerInfo.at(i).alias;
            std::cout << std::endl << "Display Name: " << playerInfo.at(i).displayName;
            std::string isFriend;
            playerInfo.at(i).isFriend ? isFriend = "Yes" : isFriend = "No";
            std::cout << std::endl << "Is Friend: " << isFriend;
        }

    }
    
}

#pragma mark Scores

void GKHDelegate::onScoresSubmitted(bool success){
    
    if (_debug) {
        std::cout << "\nGKHDelegate onScoresSubmitted - ";
        
        if (success) {std::cout << "Score submitted Successfully";}
        else{std::cout << "Score submission unsuccessful";}

    }

}

void GKHDelegate::onScoresReceived(std::vector<GKScoreCpp> scores){
    
    if (_debug) {
        std::cout << "\nGKHDelegate onScoresReceived";
        std::cout << "\nScores:";
        int count = 1;
        
        for (std::vector<GKScoreCpp>::iterator it= scores.begin(); it != scores.end(); it++) {
            
            std::cout << std::endl << count << ".";
            std::cout << "\nPlayerID: " << it->playerID;
            std::cout << "\nCatagory: " << it->catagory;
            std::cout << "\nValue: " << it->value;
            std::cout << "\nContext: " << it->context;
            std::cout << "\nFormatted Value: " << it->formattedValue;
            std::cout << "\nRank: " << it->rank;
            count++;
        }

    }
    
    
}

#pragma mark Achievements

void GKHDelegate::onAchievementReported(GKAchievementCpp achievement){
    
    if (_debug) {
        std::cout << "\nGKHDelegate onAchievementReported";
        
        std::cout << "\nIdentifier: " << achievement.identifier;
        std::cout << "\nPercentComplete: " << achievement.percentComplete;
        std::cout << "\nIs Completed: ";
        std::string isComplete;
        achievement.completed ? isComplete = "Yes" : isComplete = "No";
        std::cout << isComplete;
        std::cout << "\nShows Completion Banner: ";
        std::string showsCompletionBanner;
        achievement.showsCompletionBanner ? showsCompletionBanner = "Yes" : showsCompletionBanner = "No";
        std::cout << showsCompletionBanner;

    }

}

void GKHDelegate::onAchievementsLoaded(std::map<std::string, GKAchievementCpp> achievements){
    
    if (_debug) {
        std::cout << "\nGKHDelegate onAchievementsLoaded";
    }

}


void GKHDelegate::onResetAchievements(bool success){
    
    if (_debug) {
        std::cout << "\nGKHDelegate onResetAchievements - ";
        
        if (success) {std::cout << "Achievements reset successfully";}
        else{std::cout << "Reset Achievements unsuccessful";}
    }
}


#pragma mark Game Centre Views

void GKHDelegate::onLeaderboardViewDismissed(){
    
    if (_debug) {
        std::cout << "\nGKHDelegate onLeaderboardViewDismissed";

    }
    
}

void GKHDelegate::onAchievementsViewDismissed(){
    
    if (_debug) {
        std::cout << "\nGKHDelegate onAchievementsViewDismissed";
    }
}


