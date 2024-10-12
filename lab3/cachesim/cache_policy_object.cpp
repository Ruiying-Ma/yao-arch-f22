#include "cache_policy_object.h"
#include "cache_organize_component.h"
#include <iostream>


namespace Ripes {


void RandomPolicy::locateEvictionWay(std::pair<unsigned, CacheWay*>& ew,
                                     CacheSet& cacheSet, unsigned setIdx) {
    ew.first = std::rand() % ways;
    ew.second = &cacheSet[ew.first];
}

void RandomPolicy::updateCacheSetReplFields(CacheSet &cacheSet, unsigned int setIdx,
                                            unsigned int wayIdx, bool isHit) {
    // No information needs to be updated
    return;
}

void RandomPolicy::revertCacheSetReplFields(CacheSet &cacheSet,
                                            const CacheWay &oldWay,
                                            unsigned int wayIdx) {
    // No information needs to be updated
    return;
}


void LruPolicy::locateEvictionWay(std::pair<unsigned, CacheWay*>& ew,
                                   CacheSet& cacheSet, unsigned setIdx) {
    if (ways == 1) {
        // Nothing to do if we are in LRU and only have 1 set
        ew.first = 0;
        ew.second = &cacheSet[ew.first];
    } else {
        // Lazily all ways in the cache set before starting to iterate
        for (int i = 0; i < ways; i++) {
            cacheSet[i];
        }
        // If there is an invalid cache cacheSet, select that
        for (auto& idx_way : cacheSet) {
            if (!idx_way.second.valid) {
                ew.first = idx_way.first;
                ew.second = &idx_way.second;
                break;
            }
        }
        if (ew.second == nullptr) {
            // Else, Find LRU way
            for (auto& idx_way : cacheSet) {
                if (idx_way.second.counter == ways - 1) {
                    ew.first = idx_way.first;
                    ew.second = &idx_way.second;
                    break;
                }
            }
        }
    }
}

void LruPolicy::updateCacheSetReplFields(CacheSet &cacheSet,unsigned int setIdx,
                                         unsigned int wayIdx, bool isHit) {
    const unsigned preLRU = cacheSet[wayIdx].counter;
    for (auto& idx_way : cacheSet) {
        if (idx_way.second.valid && idx_way.second.counter < preLRU) {
            idx_way.second.counter++;
        }
    }
    cacheSet[wayIdx].counter = 0;
}

void LruPolicy::revertCacheSetReplFields(CacheSet &cacheSet,
                                         const CacheWay &oldWay,
                                         unsigned int wayIdx) {
    for (auto& idx_way : cacheSet) {
        if (idx_way.second.valid && idx_way.second.counter <= oldWay.counter) {
            idx_way.second.counter--;
        }
    }
    cacheSet[wayIdx].counter = oldWay.counter;
}

void LruLipPolicy::locateEvictionWay(std::pair<unsigned, CacheWay*>& ew,
                                        CacheSet& cacheSet, unsigned setIdx) {
    // ---------------------Part 2. TODO ------------------------------
    // LRU-LIP has exactly the same locateEvictionWay method as that of LRU
    if (ways == 1) {
        // Nothing to do if we are in LRU-LIP and only have 1 set
        ew.first = 0;
        ew.second = &cacheSet[ew.first];
    } else {
        // Lazily intialize all ways in the cache set before starting to iterate
        for (int i = 0; i < ways; i++) {
            cacheSet[i];
        }
        // If there is an invalid cache cacheSet, select that
        for (auto& idx_way : cacheSet) {
            if (!idx_way.second.valid) {
                ew.first = idx_way.first;
                ew.second = &idx_way.second;
                break;
            }
        }
        if (ew.second == nullptr) {
            // Else, Find LRU way
            for (auto& idx_way : cacheSet) {
                if (idx_way.second.counter == ways - 1) {
                    ew.first = idx_way.first;
                    ew.second = &idx_way.second;
                    break;
                }
            }
        }
    }
}

void LruLipPolicy::updateCacheSetReplFields(CacheSet &cacheSet, unsigned int setIdx,
                                               unsigned int wayIdx, bool isHit) {
    // ---------------------Part 2. TODO ------------------------------
    //const unsigned preLRU = cacheSet[wayIdx].counter;
    for (auto& idx_way : cacheSet) {
        if (idx_way.second.valid && idx_way.second.counter < ways - 1) {
            idx_way.second.counter++;
        }
    }
    cacheSet[wayIdx].counter = isHit ? 0 : ways-1;
}

void LruLipPolicy::revertCacheSetReplFields(CacheSet &cacheSet,
                                               const CacheWay &oldWay,
                                               unsigned int wayIdx) {
    // ---------------------Part 2. TODO (optional)------------------------------
}

void DipPolicy::locateEvictionWay(std::pair<unsigned, CacheWay*>& ew,
                                        CacheSet& cacheSet, unsigned setIdx) {
    // ---------------------Part 2. TODO ------------------------------
    // update PSEL
    if (setIdx == 0) { // if there is a miss in set 0
        PSEL += (PSEL < 3) ? 1 : 0;
    }
    if (setIdx == 1) { // if there is a miss in set 1
        PSEL += (PSEL > 0) ? -1 : 0;
    }
    // locate eviction way (same as that in LRU policy)
    if (ways == 1) {
        // Nothing to do if we are in DIP and only have 1 set
        ew.first = 0;
        ew.second = &cacheSet[ew.first];
    } else {
        // Lazily initialize all ways in the cache set before starting to iterate
        for (int i = 0; i < ways; i++) {
            cacheSet[i];
        }
        // If there is an invalid cache cacheSet, select that
        for (auto& idx_way : cacheSet) {
            if (!idx_way.second.valid) {
                ew.first = idx_way.first;
                ew.second = &idx_way.second;
                break;
            }
        }
        if (ew.second == nullptr) {
            // Else, Find LRU way
            for (auto& idx_way : cacheSet) {
                if (idx_way.second.counter == ways - 1) {
                    ew.first = idx_way.first;
                    ew.second = &idx_way.second;
                    break;
                }
            }
        }
    }
}

void DipPolicy::updateCacheSetReplFields(CacheSet &cacheSet, unsigned int setIdx,
                                               unsigned int wayIdx, bool isHit) {
    // ---------------------Part 2. TODO ------------------------------
    for (auto& idx_way : cacheSet) {
        if (idx_way.second.valid && idx_way.second.counter < ways - 1) {
            idx_way.second.counter++;
        }
    }
    if (PSEL <= 1 || setIdx == 0) { // choose LRU policy
        cacheSet[wayIdx].counter = 0;
    } else { // choose LRU-LIP policy
        cacheSet[wayIdx].counter = isHit ? 0 : ways-1;  
    }
    
}

void DipPolicy::revertCacheSetReplFields(CacheSet &cacheSet,
                                               const CacheWay &oldWay,
                                               unsigned int wayIdx) {
    // ---------------------Part 2. TODO (optional)------------------------------
}

void PlruPolicy::locateEvictionWay(std::pair<unsigned, CacheWay*>& ew,
                                        CacheSet& cacheSet, unsigned setIdx) {
    // ---------------------Part 2. TODO ------------------------------
    if (ways == 1) {
        // Nothing to do if we are in PLRU and only have 1 set
        ew.first = 0;
        ew.second = &cacheSet[ew.first];
    } else {
        // Lazily initialize all ways in the cacheSet
        for(int i=0; i<ways; i++) {
            cacheSet[i];
        }
        // Find Plru way
        bool* root = PlruTree[setIdx];
        ew.first = 0;
        int i = 0;
        while (i < ways-1) {
            ew.first = (ew.first << 1) + (root[i] ? 1 : 0);
            i = root[i] ? (2 + (i << 1)) : (1 + (i << 1));
        }
        ew.second = &cacheSet[ew.first];
    }
}

void PlruPolicy::updateCacheSetReplFields(CacheSet &cacheSet, unsigned int setIdx,
                                               unsigned int wayIdx, bool isHit) {
    // ---------------------Part 2. TODO ------------------------------
    // Reverse the path
    if (ways == 1) {
        return;
    }
    bool* root = PlruTree[setIdx];
    unsigned wayMask = ways >> 1;
    int i = 0;
    while (wayMask > 0) {
        if ((wayIdx & wayMask) == 0) { // root[i] == 0
            root[i] = 1;
            i = 1 + (i << 1);
        } else { // root[i] == 1
            root[i] = 0;
            i = 2 + (i << 1);
        }
        wayMask >>= 1;
    }

}

void PlruPolicy::revertCacheSetReplFields(CacheSet &cacheSet,
                                               const CacheWay &oldWay,
                                               unsigned int wayIdx) {
    // ---------------------Part 2. TODO (optional) ------------------------------
}






}
