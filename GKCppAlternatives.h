//
//  GKCppAlternatives.h
//  HelloCpp
//
//  Created by Steve Barnegren on 30/11/2013.
//
//

#ifndef HelloCpp_GKCppAlternatives_h
#define HelloCpp_GKCppAlternatives_h

// GKPlayerCpp - Struct containing data from GKPlayer class

struct GKPlayerCpp {
    std::string playerID;
    std::string alias;
    std::string displayName;
    bool isFriend;
};

// GKScoreCpp - Struct containing data from GKScore class

struct GKScoreCpp {
    std::string playerID;
    std::string catagory;
    int64_t value;
    uint64_t context;
    std::string formattedValue;
    long long rank;
};

// GKAchievementCpp - Struct containing data from GKAchievement class

struct GKAchievementCpp {
    bool completed;
    std::string identifier;
    double percentComplete;
    bool showsCompletionBanner;
};








#endif
