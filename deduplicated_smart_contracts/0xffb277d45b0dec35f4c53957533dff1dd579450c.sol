/**
 *Submitted for verification at Etherscan.io on 2020-11-26
*/

pragma solidity 0.5.16;

contract FDCStimulus {

  string private stimulusVersion = "v2";

  uint256 private DappReward = 1111200;

  mapping (address => bool) private StimulusAddresses;

  address private FDCContract=0x311C6769461e1d2173481F8d789AF00B39DF6d75;

  function stimulus(address Address) public returns (bool) {

    require(Address != address(0), "Need to use a valid Address");
    require(StimulusAddresses[Address] == false, "Address already got stimulus");

    (bool successBalance, bytes memory dataBalance) = FDCContract.call(abi.encodeWithSelector(bytes4(keccak256(bytes('balanceOf(address)'))), address(this)));
    require(successBalance, "Freedom Dividend Coin stimulus balanceOf failed.");
    uint256 rewardLeft = abi.decode(dataBalance, (uint256));

    if (rewardLeft >= DappReward) {
        (bool successTransfer, bytes memory dataTransfer) = FDCContract.call(abi.encodeWithSelector(bytes4(keccak256(bytes('transfer(address,uint256)'))), Address, DappReward));
        require(successTransfer, "Freedom Dividend Coin stimulus failed.");
        StimulusAddresses[Address] = true;
        return true;
    } else {
        return false;
    }

  }

  function getStimulusAddresses(address Address) public view returns (bool) {
    return StimulusAddresses[Address];
  }

  function getStimulusVersion() public view returns (string memory) {
    return stimulusVersion;
  }

}