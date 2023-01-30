/**
 *Submitted for verification at Etherscan.io on 2020-12-14
*/

pragma solidity 0.5.12;
// https://github.com/dapphub/ds-pause
contract DSPauseAbstract {
    function delay() public view returns (uint256);
    function plot(address, bytes32, bytes memory, uint256) public;
    function exec(address, bytes32, bytes memory, uint256) public returns (bytes memory);
}

contract JugLike {
    function file(bytes32 ilk, bytes32 what, uint data) external;
    function drip(bytes32 ilk) external;
}

contract SpellAction {
    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    string constant public description = "2020-12-14 Change Jut duty value (4% -> 0.1%)";

    address constant public MCD_JUG             = 0xF38d987939084c68a2078Ff6FC8804a994197eBC;
    function execute() external {
        JugLike(MCD_JUG).drip("ETH-A");
        JugLike(MCD_JUG).file("ETH-A", "duty", 1000000000031693947650284507);
        JugLike(MCD_JUG).drip("ETH-A");
        
        JugLike(MCD_JUG).drip("WBTC-A");
        JugLike(MCD_JUG).file("WBTC-A", "duty", 1000000000031693947650284507);
        JugLike(MCD_JUG).drip("WBTC-A");
    }
}
contract ChangeDutySpell {
    DSPauseAbstract  public pause = DSPauseAbstract(0xD4A71B333607549386aDCf528bAd2D096122F31c);
    address          public action;
    bytes32          public tag;
    uint256          public eta;
    bytes            public sig;
    uint256          public expiration;
    bool             public done;
    
    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;
    }
    function description() public view returns (string memory) {
        return SpellAction(action).description();
    }
    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + pause.delay();
        pause.plot(action, tag, sig, eta);
    }
    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}