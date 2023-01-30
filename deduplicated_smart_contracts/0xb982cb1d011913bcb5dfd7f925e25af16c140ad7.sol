/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

pragma solidity 0.5.12;
// https://github.com/dapphub/ds-pause
contract DSPauseAbstract {
    function delay() public view returns (uint256);
    function plot(address, bytes32, bytes memory, uint256) public;
    function exec(address, bytes32, bytes memory, uint256) public returns (bytes memory);
}

contract CatLike {
    function file(bytes32 ilk, bytes32 what, uint data) external;
}

contract SpellAction {
    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    string constant public description = "2020-12-10 Change Cat lump value (10 ETH -> 3 ETH)";

    address constant public MCD_CAT             = 0x44A0Ad6e696820fA192a3dcf37d0cC55a45cBc38;
    function execute() external {
        CatLike(MCD_CAT).file("ETH-A", "lump", 3000000000000000000);
    }
}
contract ChangeEthLumpSpell {
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