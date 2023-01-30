pragma solidity ^0.4.18;


contract EtheremonDataBase {
    function getMonsterObj(uint64 _objId) constant public returns(
        uint64 objId, uint32 classId, address trainer, uint32 exp, uint32 createIndex, uint32 lastClaimIndex, uint createTime
    );
}


contract EtheremonProxy {
    EtheremonDataBase Etheremon = EtheremonDataBase(0xABC1c404424BDF24C19A5cC5EF8F47781D18Eb3E);
    
    struct Result {
        uint64 objId;
        uint32 classId;
        address trainer;
        uint32 exp;
        uint32 createIndex;
        uint32 lastClaimIndex;
        uint createTime;
    }
    
    function ownerOf(uint256 objId) public view returns (address trainer) {
        uint64 id = uint64(objId);
        (, , trainer, , , , ) = Etheremon.getMonsterObj(id);
        
    }
}