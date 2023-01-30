pragma solidity ^0.5.0;

import "./OwnableCustom.sol";
import "./IERC20.sol";
import "./SafeMath.sol";

contract SanStorage is Ownable {
  using SafeMath for uint256;

  uint256 public allBalances;

  mapping(address => bool) public operators;
  mapping(address => uint256) public balances;
  mapping(address => uint256) public balancesForWithdraw;
  address public SAN_TOKEN_ADDRESS;

  modifier onlyOperator() {
    require(operators[msg.sender], "Ownable: caller is not the operator");
    _;
  }

  event SetOperator(address indexed operator, bool indexed authorized);

  function deposit(uint256 amount, address signalOwner) public onlyOperator {
    require(IERC20(SAN_TOKEN_ADDRESS).allowance(signalOwner, address(this)) >= amount, "SanStorage: not enough allowed tokens");
    IERC20(SAN_TOKEN_ADDRESS).transferFrom(signalOwner, address(this), amount);
    balances[signalOwner] = balances[signalOwner].add(amount);

    allBalances = allBalances.add(amount);
  }

  function closeSignal(uint256 amount, address signalOwner) public onlyOperator {
    balances[signalOwner] = balances[signalOwner].sub(amount);
    balancesForWithdraw[signalOwner] = balancesForWithdraw[signalOwner].add(amount);
  }

  function withdrawAll() public {
    IERC20(SAN_TOKEN_ADDRESS).transfer(msg.sender, balancesForWithdraw[msg.sender]);

    allBalances = allBalances.sub(balancesForWithdraw[msg.sender]);

    balancesForWithdraw[msg.sender] = 0;
  }

  function setTokenAddress(address santoken) public onlyOwner {
    SAN_TOKEN_ADDRESS = santoken;
  }

  function setOperator(address operator, bool authorized) public onlyOwner {
    require(operator != address(0));
    // Action Blocked - Not a valid address
    operators[operator] = authorized;
    emit SetOperator(operator, authorized);
  }

  function sendTokens(uint256 amount, address tokenAddress, address to) public onlyOwner {
    if (tokenAddress == SAN_TOKEN_ADDRESS) {
      require(IERC20(tokenAddress).balanceOf(address(this)).sub(allBalances) >= amount, "SanStorage: not enough owned excess san tokens");
    } else {
      require(IERC20(tokenAddress).balanceOf(address(this)) >= amount, "SanStorage: not enough owned tokens");
    }

    IERC20(tokenAddress).transfer(to, amount);
  }

  function sendETH(uint256 amount, address payable to) public onlyOwner {
    (bool success, ) = to.call.value(amount)('');
    require(success, 'transfer failed');
  }
}
