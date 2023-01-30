/**
 *Submitted for verification at Etherscan.io on 2020-07-09
*/

pragma solidity 0.6.4;

interface Vether {
    function withdrawShareForMember(uint era, uint day, address member) external returns (uint value);
    function getDaysContributedForEra(address member, uint era) external view returns(uint);
    function mapMemberEra_Days(address member, uint era, uint day) external view returns(uint);
}
contract BatchWithdraw {
    address VETH;
    constructor () public {
        VETH = 0x4Ba6dDd7b89ed838FEd25d208D4f644106E34279;
    }

    function batchWithdraw(uint era, uint[] memory arrayDays, address member) public {
        for(uint i = 0; i < arrayDays.length; i++){
            Vether(VETH).withdrawShareForMember(era, arrayDays[i], member);
        }
    }
    function withdrawAll(uint era, address member) public {
        uint length = Vether(VETH).getDaysContributedForEra(member, era);
        for(uint i = 0; i < length; i++){
            uint day = Vether(VETH).mapMemberEra_Days(member, era, i);
            Vether(VETH).withdrawShareForMember(era, day, member);
        }
    }
}