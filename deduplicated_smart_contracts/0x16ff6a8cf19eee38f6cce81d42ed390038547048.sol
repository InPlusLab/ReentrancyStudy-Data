pragma solidity ^0.4.20;
    
// Simple contract to split stakes coming into Locus | One Puzzle. 
// 80% of buy in goes to the jackpot, and the remaining 20% goes 
// to a dev wallet to support future puzzle development. 
   
contract LocusOne {

    	address devAcct;
    	address potAcct;
    	uint fee;
    	uint pot;
        address public owner;
        
        // PAUSE EVENTS - onlyOwner can pause contract to lock new registration
        // once the bounty has reached its goal.
        
        event Pause();
        event Unpause();

        bool public paused = false;
        
        
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }
        
    function LocusOne () public payable {
        owner = msg.sender;
    }
    
      modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

    function() public payable {
    require (!paused);    
    _split(msg.value);
    }

    function _split(uint _stake) internal {
        // protects users from staking less than the required amount to claim the bounty
        require (msg.value >= 0.1 ether);
        // Define the Locus dev account
        devAcct = 0x1daa0BFDEDfB133ec6aEd2F66D64cA88BeC3f0B4;
        // Define the Locus Pot account (what you're all playing for)      
        potAcct = 0x708294833AEF21a305200b3463A832Ac97852f2e;

        // 20% of the total Ether sent will be used to pay devs/support project.
        fee = div(_stake, 5);
        
        // The remaining amount of Ether wll be sent to fund/stake the pot.
        pot = sub(_stake, fee);

        devAcct.transfer(fee);
        potAcct.transfer(pot);

    }


  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }

            // The below are safemath implementations of the four arithmetic operators
    // designed to explicitly prevent over- and under-flows of integer values.

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    // not needed until later
    //function sumproduct(uint256 sn, uint256 %cl) internal pure returns (uint256) {
    //    uint256 c = a * b;
    //    assert(c / a == b);
    //    return c;
    //}
 }