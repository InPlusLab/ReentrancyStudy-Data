/**
 *Submitted for verification at Etherscan.io on 2020-04-01
*/

pragma solidity >=0.4.21 <0.6.0;

contract TransferableToken{
    function balanceOf(address _owner) public returns (uint256 balance) ;
    function transfer(address _to, uint256 _amount) public returns (bool success) ;
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) ;
}


contract TokenClaimer{

    event ClaimedTokens(address indexed _token, address indexed _to, uint _amount);
    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
  function _claimStdTokens(address _token, address payable to) internal {
        if (_token == address(0x0)) {
            to.transfer(address(this).balance);
            return;
        }
        TransferableToken token = TransferableToken(_token);
        uint balance = token.balanceOf(address(this));

        (bool status,) = _token.call(abi.encodeWithSignature("transfer(address,uint256)", to, balance));
        require(status, "call failed");
        emit ClaimedTokens(_token, to, balance);
  }
}

contract TokenInterface is TransferableToken{
    function destroyTokens(address _owner, uint _amount) public returns (bool);
    function generateTokens(address _owner, uint _amount) public returns (bool);
}

contract OneTimeMint{
  TokenInterface public token_contract;
  address public target_addr;
  uint public amount;
  bool public is_minted;

  constructor(address _token, address _target, uint _amount) public{
    token_contract = TokenInterface(_token);
    target_addr = _target;
    amount = _amount;
    is_minted = false;
  }

  function mint() public{
    require(is_minted == false, "already minted");
    token_contract.generateTokens(target_addr, amount);
    is_minted = true;
  }
}

contract OneTimeMintFactory{
  event NewOneTimeMint(address addr);

  function createOneTimeMint(address _token, address _target, uint _amount)public returns(address){
    OneTimeMint otm = new OneTimeMint(_token, _target, _amount);
    emit NewOneTimeMint(address(otm));
    return address(otm);
  }
}