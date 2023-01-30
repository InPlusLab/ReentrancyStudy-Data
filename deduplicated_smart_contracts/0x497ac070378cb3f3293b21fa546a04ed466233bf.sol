/**
 *Submitted for verification at Etherscan.io on 2020-11-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function symbol() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
}

interface ICoverERC20 is IERC20 {
    function burn(uint256 _amount) external returns (bool);

    /// @notice access restriction - owner (Cover)
    function mint(address _account, uint256 _amount) external returns (bool);
    function setSymbol(string calldata _symbol) external returns (bool);
    function burnByCover(address _account, uint256 _amount) external returns (bool);
}

interface ICover {
  event NewCoverERC20(address);

  function getCoverDetails()
    external view returns (string memory _name, uint48 _expirationTimestamp, address _collateral, uint256 _claimNonce, ICoverERC20 _claimCovToken, ICoverERC20 _noclaimCovToken);
  function expirationTimestamp() external view returns (uint48);
  function collateral() external view returns (address);
  function claimCovToken() external view returns (ICoverERC20);
  function noclaimCovToken() external view returns (ICoverERC20);
  function name() external view returns (string memory);
  function claimNonce() external view returns (uint256);

  function redeemClaim() external;
  function redeemNoclaim() external;
  function redeemCollateral(uint256 _amount) external;

  /// @notice access restriction - owner (Protocol)
  function mint(uint256 _amount, address _receiver) external;

  /// @notice access restriction - dev
  function setCovTokenSymbol(string calldata _name) external;
}

interface IBalancerPool {
    function swapExactAmountIn(address, uint, address, uint, uint) external returns (uint, uint);
    function swapExactAmountOut(address, uint, address, uint, uint) external returns (uint, uint);
}

contract ArbSomeShit is Ownable {
    IERC20 public DAI;

    constructor() public Ownable() {
      DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    }

    function burningArb(
      ICover _cover,
      IBalancerPool _claimPool,
      IBalancerPool _noclaimPool,
      uint _amount
    ) external {
      // step 1
      DAI.transferFrom(msg.sender, address(this), _amount);

      // step 2
      _daiToTokenOnBalancer(_noclaimPool, _cover.noclaimCovToken(), _amount);
      _daiToTokenOnBalancer(_claimPool, _cover.claimCovToken(), _amount);
      _cover.redeemCollateral(_amount);

      // step 3
      uint256 new_balance = DAI.balanceOf(address(this));
      require(new_balance > _amount, "No arbys");
      require(DAI.transfer(msg.sender, new_balance), "ERR_TRANSFER_FAILED");
    }

    function _daiToTokenOnBalancer(
      IBalancerPool _pool,
      IERC20 _token,
      uint _amount
    ) private {
      if (DAI.allowance(address(this), address(_pool)) < _amount) {
        DAI.approve(address(_pool), _amount);
      }
      _pool.swapExactAmountOut(address(DAI), _amount, address(_token), _amount, 2**256 - 1);
    }

    function destroy() external onlyOwner {
        selfdestruct(msg.sender);
    }

    function withdraw(IERC20 _tokenAddress, address _destination) external onlyOwner {
        require(_tokenAddress.balanceOf(address(this)) > 0, "Cannot withdraw 0");
        _tokenAddress.transfer(_destination, _tokenAddress.balanceOf(address(this)));
    }

    receive() external payable {
    }
}