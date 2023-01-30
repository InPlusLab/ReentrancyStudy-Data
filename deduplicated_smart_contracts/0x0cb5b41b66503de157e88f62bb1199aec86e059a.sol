/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

pragma solidity 0.6.12;

// SPDX-License-Identifier: GPL-3.0-only


library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }


  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }


  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }

}

interface IPreETHToken{
    function mint(uint256 _preETHAmount, address _to) external;
    function burn(uint256 _preETHAmount) external;
    function contractBurn(uint256 _preETHAmount, address _burnAddress) external;
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
}

interface IEstReward{
    function contractStake(uint256 amount, address _user) external;
    function getReward(address _address) external;
    function userStakeFromInvite(address _user, uint256 _amount) external;
}

interface IDepositContract {
    event DepositEvent(
        bytes pubkey,
        bytes withdrawal_credentials,
        bytes amount,
        bytes signature,
        bytes index
    );

    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable;
    function get_deposit_root() external view returns (bytes32);
    function get_deposit_count() external view returns (bytes memory);
}


contract ESTDepositPool {
  using SafeMath for uint;
  uint256 private base = 100;
  uint256 public minimumDeposit = 1 ether / base;
  uint256 public refRatio = 10;
  uint256 public totalLockedPreETHAmount = 0;
  address public owner;
  address public preETH;
  address public estRewardAddress;
  mapping(address=>uint) public userPreETHAmount;
  mapping(address=>uint) public userInviteCount;
  
  mapping(address=>address) public userRef;
  bool public isNeedStaked = true;
  IDepositContract public DepositContract = IDepositContract(0x00000000219ab540356cBB839Cbe05303d7705Fa); // mainnet
//   IDepositContract public DepositContract = IDepositContract(0x8c5fecdC472E27Bc447696F431E425D02dd46a8c); // prymont test
   
    // Events
    event DepositReceived(address indexed from, uint256 amount, uint256 time);
    
    // Construct
    constructor ()  public {
        owner = msg.sender;
    }

   /**
    * @dev Modifier to scope access to admins
    */
    modifier onlyOwner() {
        require(owner == msg.sender, "Account is not owner");
        _;
    }

    function setAddresses(address _preEth,address _estReward) public onlyOwner {
        preETH = _preEth;
        estRewardAddress = _estReward;
    }

    function setIsNeedStaked(bool isNeed) public onlyOwner {
      isNeedStaked = isNeed;
    }

    // Accept a deposit from a user
    function deposit(address _ref) external payable {
        require(msg.sender != _ref, "The sender address is the same of referer");
        require(msg.value >= minimumDeposit, "The deposited amount is less than the minimum deposit size");
        require(estRewardAddress != address(0),"Invalid EST award contract address!");
        
        if(_ref != address(0) && userRef[msg.sender] == address(0)){
          userRef[msg.sender] = _ref;
          userInviteCount[msg.sender] = userInviteCount[msg.sender].add(1);
        }

        // Mint preETH to this contract account
        IPreETHToken(preETH).mint(msg.value, estRewardAddress);
        
        if(isNeedStaked){
          if(userPreETHAmount[userRef[msg.sender]] > 0){
            IEstReward(estRewardAddress).contractStake(msg.value,msg.sender);
            IEstReward(estRewardAddress).contractStake(msg.value.mul(refRatio).div(base), userRef[msg.sender]);
            IEstReward(estRewardAddress).userStakeFromInvite(userRef[msg.sender], msg.value.mul(refRatio).div(base));
          } else {
            IEstReward(estRewardAddress).contractStake(msg.value,msg.sender);
          }
        } else {
          if(userRef[msg.sender] != address(0)){
            IEstReward(estRewardAddress).contractStake(msg.value.div(base),msg.sender);
            IEstReward(estRewardAddress).contractStake(msg.value.mul(refRatio).div(base), userRef[msg.sender]);
            IEstReward(estRewardAddress).userStakeFromInvite(userRef[msg.sender], msg.value.mul(refRatio).div(base));
          } else {
            IEstReward(estRewardAddress).contractStake(msg.value,msg.sender);
          }
           
        }
        
        // Emit deposit received event
        emit DepositReceived(msg.sender, msg.value, now);
        // Process deposit
        processDeposit(msg.sender, msg.value);
    }
    
    function getUserInfo(address _user) external view returns(uint256 userDeposit,uint256 inviteCount){
        userDeposit = userPreETHAmount[_user];
        inviteCount = userInviteCount[_user];
    }

    function getUserPreETHBalance(address _user) public view returns(uint){
      return userPreETHAmount[_user];
    }

    function processDeposit(address _user, uint _value) private {
      // add user preETH amount
      userPreETHAmount[_user] = userPreETHAmount[_user].add(_value);
      totalLockedPreETHAmount = totalLockedPreETHAmount.add(_value);
    }

    function getUserPreETHPropotion(address _user) public view returns(uint256 totalLockedAmount,uint256 userAmount){
      totalLockedAmount = totalLockedPreETHAmount;
      userAmount = userPreETHAmount[_user];
    }
 
    
    function burnPreETH(uint256 _preETHAmount) public {
        require(_preETHAmount>0, "Invalid amount");
        // IPreETHToken(preETH).burn(_preETHAmount);
        IPreETHToken(preETH).contractBurn(_preETHAmount, msg.sender);
        userPreETHAmount[msg.sender] = userPreETHAmount[msg.sender].sub(_preETHAmount);
        msg.sender.transfer(_preETHAmount);
    }
    
    function stakeETH( 
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root) public onlyOwner{
        DepositContract.deposit{value:32 ether}(pubkey,withdrawal_credentials,signature,deposit_data_root);
    }
    
    fallback () payable external {}
    receive () payable external {}
   
   

    
}