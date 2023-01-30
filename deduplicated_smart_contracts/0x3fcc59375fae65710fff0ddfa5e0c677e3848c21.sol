/**
 *Submitted for verification at Etherscan.io on 2020-07-02
*/

pragma solidity ^0.6.7;

interface ERC20 {
  function approve(address spender, uint256 amount) external;
}

interface CToken {
  function liquidateBorrow(address borrower, uint _amount, address _supplyAsset) external returns(uint);
}

interface CEther {
  function liquidateBorrow(address borrower, address supplyAsset) external payable;
}

contract Test {

  address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  address constant CETH = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5;
  address constant CUSDC = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;

  address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

  event LogInt(uint256 key, uint val);
  event LogAddr(uint256 key, address val);
  // event EtherReceived();

  mapping (address => address) tokens;

  receive() external payable {}

  constructor() public {

    tokens[CETH]  = ETH_ADDRESS;
    tokens[CUSDC] = USDC;

    ERC20(USDC).approve(CUSDC, 100000000000000000000000000000);
  }
  
  function depositEth() public payable {}

  function executeOperation(address _borrowCToken, uint _repayBorrowUnderlyingAmount, address _supplyCToken, address _account) public payable {
    if (_borrowCToken == CETH) {
      CEther(_borrowCToken).liquidateBorrow { value: _repayBorrowUnderlyingAmount } (_account, _supplyCToken);
    } else {
      CToken(_borrowCToken).liquidateBorrow(_account, _repayBorrowUnderlyingAmount, _supplyCToken);
    }
  }
}