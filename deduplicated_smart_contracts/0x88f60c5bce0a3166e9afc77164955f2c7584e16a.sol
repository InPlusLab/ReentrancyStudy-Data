/**
 *Submitted for verification at Etherscan.io on 2020-11-29
*/

pragma solidity ^0.5.12;

contract VatLike {
    function urns(bytes32 ilk, address u) public view returns (uint ink, uint art);
}

contract DssManagerLike {
    function urns(uint cdp) public view returns(address urn);
    function ilks(uint cdp) public view returns(bytes32);
    function owns(uint cdp) public view returns(address);
    function vat() public view returns(address);
    function cdpi() public view returns(uint);
}

contract ERC20Like {
    function transfer(address _to, uint256 _value) public returns (bool success);
}

contract DSProxyLike {
    function owner() public returns (address);
}

contract BlackFriday {
    uint campaignEndTime = 1606744800;
    ERC20Like dai = ERC20Like(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    DssManagerLike BProtocol = DssManagerLike(0x3f30c2381CD8B917Dd96EB2f1A4F96D91324BBed);
    uint reward = 100e18;
    
    function raffle() public returns(uint) {
        require(now >= campaignEndTime, "too-early");
        
        bytes32 seed = blockhash(block.number - 1);
        VatLike vat = VatLike(BProtocol.vat());
        uint cdpi = BProtocol.cdpi();
        
        for(uint i = 0 ; i < 10 ; i++) {
            seed = keccak256(abi.encodePacked(seed));
            uint cdp = 1 + (uint(seed) % cdpi);
            
            address urn = BProtocol.urns(cdp);
            bytes32 ilk = BProtocol.ilks(cdp);
            
            (, uint art) = vat.urns(ilk, urn);
            if(art == 0) continue;
            
            address winner = BProtocol.owns(cdp);
            require(dai.transfer(DSProxyLike(winner).owner(), reward));
            return cdp;
        }
        
        return 0;
    }
}