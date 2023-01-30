/**

 *Submitted for verification at Etherscan.io on 2018-12-15

*/



pragma solidity ^0.4.24;



library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns(uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function div(uint256 a, uint256 b) internal pure returns(uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  function sub(uint256 a, uint256 b) internal pure returns(uint256) {

    assert(b <= a);

    return a - b;

  }



  function add(uint256 a, uint256 b) internal pure returns(uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

}





contract EthToSmthSwaps {



  using SafeMath for uint;



  address public owner;

  address public ratingContractAddress;

  uint256 SafeTime = 1 hours; // atomic swap timeOut



  struct Swap {

    address targetWallet;

    bytes32 secret;

    bytes20 secretHash;

    uint256 createdAt;

    uint256 balance;

  }



  // ETH Owner => BTC Owner => Swap

  mapping(address => mapping(address => Swap)) public swaps;

  mapping(address => mapping(address => uint)) public participantSigns;



  constructor () public {

    owner = msg.sender;

  }









  event CreateSwap(address _buyer, address _seller, uint256 _value, bytes20 _secretHash, uint256 createdAt);



  // ETH Owner creates Swap with secretHash

  // ETH Owner make token deposit

  function createSwap(bytes20 _secretHash, address _participantAddress) public payable {

    require(msg.value > 0);

    require(swaps[msg.sender][_participantAddress].balance == uint256(0));



    swaps[msg.sender][_participantAddress] = Swap(

      _participantAddress,

      bytes32(0),

      _secretHash,

      now,

      msg.value

    );



    CreateSwap(_participantAddress, msg.sender, msg.value, _secretHash, now);

  }



  // ETH Owner creates Swap with secretHash

  // ETH Owner make token deposit

  function createSwapTarget(bytes20 _secretHash, address _participantAddress, address _targetWallet) public payable {

    require(msg.value > 0);

    require(swaps[msg.sender][_participantAddress].balance == uint256(0));



    swaps[msg.sender][_participantAddress] = Swap(

      _targetWallet,

      bytes32(0),

      _secretHash,

      now,

      msg.value

    );



    CreateSwap(_participantAddress, msg.sender, msg.value, _secretHash, now);

  }



  function getBalance(address _ownerAddress) public view returns (uint256) {

    return swaps[_ownerAddress][msg.sender].balance;

  }



  // Get target wallet (buyer check)

  function getTargetWallet(address _ownerAddress) public returns (address) {

      return swaps[_ownerAddress][msg.sender].targetWallet;

  }



  event Withdraw(address _buyer, address _seller, uint256 withdrawnAt);



  // BTC Owner withdraw money and adds secret key to swap

  // BTC Owner receive +1 reputation

  function withdraw(bytes32 _secret, address _ownerAddress) public {

    Swap memory swap = swaps[_ownerAddress][msg.sender];



    require(swap.secretHash == ripemd160(_secret));

    require(swap.balance > uint256(0));

    require(swap.createdAt.add(SafeTime) > now);



    swap.targetWallet.transfer(swap.balance);



    swaps[_ownerAddress][msg.sender].balance = 0;

    swaps[_ownerAddress][msg.sender].secret = _secret;



    Withdraw(msg.sender, _ownerAddress, now); 

  }

  // BTC Owner withdraw money and adds secret key to swap

  // BTC Owner receive +1 reputation

  function withdrawNoMoney(bytes32 _secret, address participantAddress) public {

    Swap memory swap = swaps[msg.sender][participantAddress];



    require(swap.secretHash == ripemd160(_secret));

    require(swap.balance > uint256(0));

    require(swap.createdAt.add(SafeTime) > now);



    swap.targetWallet.transfer(swap.balance);



    swaps[msg.sender][participantAddress].balance = 0;

    swaps[msg.sender][participantAddress].secret = _secret;



    Withdraw(participantAddress, msg.sender, now); 

  }

  // BTC Owner withdraw money and adds secret key to swap

  // BTC Owner receive +1 reputation

  function withdrawOther(bytes32 _secret, address _ownerAddress, address participantAddress) public {

    Swap memory swap = swaps[_ownerAddress][participantAddress];



    require(swap.secretHash == ripemd160(_secret));

    require(swap.balance > uint256(0));

    require(swap.createdAt.add(SafeTime) > now);



    swap.targetWallet.transfer(swap.balance);



    swaps[_ownerAddress][participantAddress].balance = 0;

    swaps[_ownerAddress][participantAddress].secret = _secret;



    Withdraw(participantAddress, _ownerAddress, now); 

  }



  // ETH Owner receive secret

  function getSecret(address _participantAddress) public view returns (bytes32) {

    return swaps[msg.sender][_participantAddress].secret;

  }



  event Close(address _buyer, address _seller);







  event Refund(address _buyer, address _seller);



  // ETH Owner refund money

  // BTC Owner gets -1 reputation

  function refund(address _participantAddress) public {

    Swap memory swap = swaps[msg.sender][_participantAddress];



    require(swap.balance > uint256(0));

    require(swap.createdAt.add(SafeTime) < now);



    msg.sender.transfer(swap.balance);



    clean(msg.sender, _participantAddress);



    Refund(_participantAddress, msg.sender);

  }



  function clean(address _ownerAddress, address _participantAddress) internal {

    delete swaps[_ownerAddress][_participantAddress];

    delete participantSigns[_ownerAddress][_participantAddress];

  }

}