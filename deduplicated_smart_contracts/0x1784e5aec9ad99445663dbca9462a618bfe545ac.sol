/**
 *Submitted for verification at Etherscan.io on 2019-07-15
*/

pragma solidity ^0.4.26;

//This is the public contract for the NebliDex decentralized exchange ERC20 swap with a non-ETH coin
//This exchange can be used to trade cryptocurrencies in a decentralized way without intermediaries or proxy tokens
//As of July 14th, 2019, the exchange website can be found at www.neblidex.xyz

//Contract source based on code provided from: https://github.com/jchittoda/eth-atomic-swap/

//Abstract ERC20 contract
contract ERC20 {
  uint public totalSupply;

  event Transfer(address indexed from, address indexed to, uint value);  
  event Approval(address indexed owner, address indexed spender, uint value);

  function balanceOf(address who) public constant returns (uint);
  function allowance(address owner, address spender) public constant returns (uint);

  function transfer(address to, uint value) public returns (bool ok);
  function transferFrom(address from, address to, uint value) public returns (bool ok);
  function approve(address spender, uint value) public returns (bool ok);  
}

//Main swap contract
contract NebliDex_AtomicSwap_ERC20 {

  struct Swap {
    uint256 timelock;
    uint256 erc20Value;
    address erc20Trader;
    address erc20ContractAddress; // Address of token contract
    address withdrawTrader;
    bytes32 secretLock;
    bytes secretKey;
  }

  enum States {
    INVALID,
    OPEN,
    CLOSED,
    EXPIRED
  }

  mapping (bytes32 => Swap) private swaps;
  mapping (bytes32 => States) private swapStates;

  event Open(bytes32 _swapID, address _withdrawTrader);
  event Expire(bytes32 _swapID);
  event Close(bytes32 _swapID, bytes _secretKey);

  modifier onlyInvalidSwaps(bytes32 _swapID) {
    require (swapStates[_swapID] == States.INVALID);
    _;
  }

  modifier onlyOpenSwaps(bytes32 _swapID) {
    require (swapStates[_swapID] == States.OPEN);
    _;
  }

  modifier onlyClosedSwaps(bytes32 _swapID) {
    require (swapStates[_swapID] == States.CLOSED);
    _;
  }

  modifier onlyExpiredSwaps(bytes32 _swapID) {
    require (now >= swaps[_swapID].timelock);
    _;
  }

  // Cannot redeem amount if timelock has expired
  modifier onlyNotExpiredSwaps(bytes32 _swapID) {
    require (now < swaps[_swapID].timelock);
    _;
  }

  modifier onlyWithSecretKey(bytes32 _swapID, bytes _secretKey) {
    require (_secretKey.length == 33); // The key must be this length across the board
    require (swaps[_swapID].secretLock == sha256(_secretKey));
    _;
  }

  //Unlike ETH swap, this function is not payable thus no ETH accepted
  function open(bytes32 _swapID, uint256 _erc20Value, address _erc20ContractAddress, address _withdrawTrader, uint256 _timelock) public onlyInvalidSwaps(_swapID) {
    require(swapStates[_swapID] == States.INVALID); //Redundancy for second layer re-entry protection
    // Transfer value from the ERC20 trader to this contract.
    ERC20 erc20Contract = ERC20(_erc20ContractAddress);
    require(_erc20Value > 0); //We cannot send a zero token amount
    require(_erc20Value <= erc20Contract.allowance(msg.sender, address(this))); // We must transfer less than that we approve in the ERC20 token contract
    require(erc20Contract.transferFrom(msg.sender, address(this), _erc20Value)); // Now take the tokens from the sending user and store in this contract

    // Store the details of the swap.
    Swap memory swap = Swap({
      timelock: _timelock,
      erc20Value: _erc20Value,
      erc20Trader: msg.sender,
      erc20ContractAddress: _erc20ContractAddress,
      withdrawTrader: _withdrawTrader,
      secretLock: _swapID,
      secretKey: new bytes(0)
    });
    swaps[_swapID] = swap;
    swapStates[_swapID] = States.OPEN;

    // Trigger open event
    emit Open(_swapID, _withdrawTrader);
  }

  function redeem(bytes32 _swapID, bytes _secretKey) public onlyOpenSwaps(_swapID) onlyNotExpiredSwaps(_swapID) onlyWithSecretKey(_swapID, _secretKey) {
    // Redeem the value from the contract.
    Swap memory swap = swaps[_swapID];
    swaps[_swapID].secretKey = _secretKey;
    swapStates[_swapID] = States.CLOSED;

    // Transfer the ERC20 funds from this contract to the withdrawing trader.
    ERC20 erc20Contract = ERC20(swap.erc20ContractAddress);
    require(erc20Contract.transfer(swap.withdrawTrader, swap.erc20Value));

    // Trigger close event.
    emit Close(_swapID, _secretKey);    
  }

  function refund(bytes32 _swapID) public onlyOpenSwaps(_swapID) onlyExpiredSwaps(_swapID) {
    // Expire the swap.
    Swap memory swap = swaps[_swapID];
    swapStates[_swapID] = States.EXPIRED;

    // Transfer the ERC20 value from this contract back to the ERC20 trader.
    ERC20 erc20Contract = ERC20(swap.erc20ContractAddress);
    require(erc20Contract.transfer(swap.erc20Trader, swap.erc20Value));

    // Trigger expire event.
    emit Expire(_swapID);
  }

  function check(bytes32 _swapID) public view returns (uint256 timelock, uint256 erc20Value, address erc20ContractAddress, address withdrawTrader, bytes32 secretLock) {
    Swap memory swap = swaps[_swapID];
    return (swap.timelock, swap.erc20Value, swap.erc20ContractAddress, swap.withdrawTrader, swap.secretLock);
  }

  function checkSecretKey(bytes32 _swapID) public view onlyClosedSwaps(_swapID) returns (bytes secretKey) {
    Swap memory swap = swaps[_swapID];
    return swap.secretKey;
  }
}