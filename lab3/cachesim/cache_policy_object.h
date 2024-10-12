#ifndef CACHE_POLICY_OBJECT_H
#define CACHE_POLICY_OBJECT_H

#include "cache_organize_component.h"
#include <iostream>

namespace Ripes {

class CachePolicyBase
{
public:
    CachePolicyBase(int number_ways, int number_sets, int number_blocks): ways(number_ways), sets(number_sets), blocks(number_blocks) {}
    virtual void locateEvictionWay(std::pair<unsigned, CacheWay*>& ew, CacheSet& cacheSet, unsigned setIdx) = 0;
    virtual void updateCacheSetReplFields(CacheSet& cacheSet, unsigned int setIdx, unsigned wayIdx, bool isHit) = 0;
    virtual void revertCacheSetReplFields(CacheSet& cacheSet, const CacheWay& oldWay, unsigned wayIdx) = 0;
    virtual ~CachePolicyBase() {}
protected:
    int ways;
    int sets;
    int blocks;
};

class RandomPolicy : public CachePolicyBase {
public:
    RandomPolicy(int number_ways, int number_sets, int number_blocks) : CachePolicyBase(number_ways, number_sets, number_blocks) {}
    void locateEvictionWay(std::pair<unsigned, CacheWay*>& ew, CacheSet& cacheSet, unsigned setIdx) override;
    void updateCacheSetReplFields(CacheSet& cacheSet, unsigned int setIdx, unsigned wayIdx, bool isHit) override;
    void revertCacheSetReplFields(CacheSet& cacheSet, const CacheWay& oldWay, unsigned wayIdx) override;
    ~RandomPolicy() {}
};


class LruPolicy : public CachePolicyBase {
public:
    LruPolicy(int number_ways, int number_sets, int number_blocks) : CachePolicyBase(number_ways, number_sets, number_blocks) {}
    void locateEvictionWay(std::pair<unsigned, CacheWay*>& ew, CacheSet& cacheSet, unsigned setIdx) override;
    void updateCacheSetReplFields(CacheSet& cacheSet, unsigned int setIdx, unsigned wayIdx, bool isHit) override;
    void revertCacheSetReplFields(CacheSet& cacheSet, const CacheWay& oldWay, unsigned wayIdx) override;
    ~LruPolicy() {}
};

class LruLipPolicy : public CachePolicyBase {
public:
    LruLipPolicy(int number_ways ,int number_sets, int number_blocks) :
        CachePolicyBase(number_ways, number_sets, number_blocks){}
    void locateEvictionWay(std::pair<unsigned, CacheWay*>& ew, CacheSet& cacheSet, unsigned setIdx) override;
    void updateCacheSetReplFields(CacheSet& cacheSet, unsigned int setIdx, unsigned wayIdx, bool isHit) override;
    void revertCacheSetReplFields(CacheSet& cacheSet, const CacheWay& oldWay, unsigned wayIdx) override;
    ~LruLipPolicy() {}
};

class DipPolicy : public CachePolicyBase {
public:
    DipPolicy(int number_ways, int number_sets, int number_blocks) : CachePolicyBase(number_ways, number_sets, number_blocks) {
        PSEL = 0;
    }
    void locateEvictionWay(std::pair<unsigned, CacheWay*>& ew, CacheSet& cacheSet, unsigned setIdx) override;
    void updateCacheSetReplFields(CacheSet& cacheSet, unsigned int setIdx, unsigned wayIdx, bool isHit) override;
    void revertCacheSetReplFields(CacheSet& cacheSet, const CacheWay& oldWay, unsigned wayIdx) override;
    ~DipPolicy() {}
private: 
    // 2-bit saturate counter
    // if 0 <= PSEL <= 1, choose LRU; if 2 <= PSEL <= 3, choose LRU-LIP
    // if set 0 miss, PSEL ++; if set 1 miss, PSEL --
    int PSEL = 0; 
    // since we use a saturate counter, the adaptibility is promised, so we do not reset the periodically
};


class PlruPolicy : public CachePolicyBase {
public:
    PlruPolicy(int number_ways, int number_sets, int number_blocks) : CachePolicyBase(number_ways, number_sets, number_blocks) {
        PlruTree = new bool*[number_sets];
        for(int i=0; i<number_sets; i++) {
            PlruTree[i] = new bool[number_ways - 1](); // use an array to represent the BST
            //memset(PlruTree[i], 0, sizeof(PlruTree[i]));
        }
    }
    void locateEvictionWay(std::pair<unsigned, CacheWay*>& ew, CacheSet& cacheSet, unsigned setIdx) override;
    void updateCacheSetReplFields(CacheSet& cacheSet, unsigned int setIdx, unsigned wayIdx, bool isHit) override;
    void revertCacheSetReplFields(CacheSet& cacheSet, const CacheWay& oldWay, unsigned wayIdx) override;
    ~PlruPolicy() {}
private: 
    bool **PlruTree;
};


}

#endif // CACHE_POLICY_OBJECT_H
