pragma solidity >= 0.5.0 < 0.6.0;

import "./provableAPI_0.5.sol";

library SafeMath {
  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    require(c >= a);
  }
  function sub(uint a, uint b) internal pure returns (uint c) {
    require(b <= a);
    c = a - b;
  }
  function mul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
  function div(uint a, uint b) internal pure returns (uint c) {
    require(b > 0);
    c = a / b;
  }
}

interface IERC20 {

  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Owned {
  address public owner;
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    newOwner = _newOwner;
  }
  function acceptOwnership() public {
    require(msg.sender == newOwner);
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }
}


contract ShittyDice is usingProvable, Owned {

  using SafeMath for uint;

  constructor() public {
    provable_setProof(proofType_Ledger);
    provable_setCustomGasPrice(5000000000);
  }
  uint256 GAS_FOR_CALLBACK = 200000;

  event LogNewProvableQuery(string description);

  event playerRoll(address player, uint256 betamount, bytes32 queryId);
  event playerWithdrawal(address player, uint256 amount);
  event playerDeposit(address player, uint256 amount);
  event rolloutcome(address player, uint256 betamount, uint256 payout, uint256 outcome, bytes32 queryId);


  struct sidestruct {
    uint256 m;
    uint256 d;
  }

  uint256 public sides;

  struct proll {
    uint256 outcome;
    address addr;
    uint256 amount;
  }

  mapping(uint256 => sidestruct) public sideoutcome;
  mapping(address => uint256) public balance;

  mapping(bytes32 => proll) public playerrolls;


  IERC20 SHIT = IERC20(0xaa7FB1c8cE6F18d4fD4Aabb61A2193d4D441c54F);

  //PLAYER FUNCTIONS
  function Roll(uint256 amount) payable public {
    require(amount <= balance[msg.sender]);
    require(balance[address(this)] >= amount * 4);

    if (provable_getPrice("random") > msg.value) {
      emit LogNewProvableQuery("you need to pay for gas, bitch");
    }
    else {
      balance[msg.sender] = balance[msg.sender].sub(amount);
      balance[address(this)] = balance[address(this)].add(amount);

      uint256 QUERY_EXECUTION_DELAY = 0;

      bytes32 _queryId =  provable_newRandomDSQuery(
        QUERY_EXECUTION_DELAY,
        NUM_RANDOM_BYTES_REQUESTED,
        GAS_FOR_CALLBACK
      );

      playerrolls[_queryId].addr = msg.sender;
      playerrolls[_queryId].amount = amount;

      emit playerRoll(msg.sender, amount, _queryId);
    }
  }

  function deposit(uint256 amount) public {
    SHIT.transferFrom(msg.sender, address(this), amount);
    balance[msg.sender] = balance[msg.sender].add(amount);
    emit playerDeposit(msg.sender, amount);
  }

  function withdrawal(uint256 amount) public {
    require(balance[msg.sender] >= amount);
    balance[msg.sender] = balance[msg.sender].sub(amount);
    SHIT.transfer(msg.sender, amount);
    emit playerWithdrawal(msg.sender, amount);
  }
  //VIEW FUNCTIONS
  function viewbal(address _addr) public view returns(uint256){
    return(balance[_addr]);
  }
  //ADMIN ONLY FUNCTIONS
  function setsides(uint256 _sides) public onlyOwner() {
    sides = _sides;
  }
  function setsideoutcome(uint256 _side, uint256 _m, uint256 _d) public onlyOwner() {
    sideoutcome[_side].m = _m;
    sideoutcome[_side].d = _d;
  }
  function admindeposit(IERC20 token, uint256 amount) public onlyOwner() {
    token.transferFrom(msg.sender, address(this), amount);
    if (token == SHIT) {
      balance[address(this)] = balance[address(this)].add(amount);
    }
  }
  function adminwithdrawal(IERC20 token, uint256 amount) public onlyOwner() {
    if (token == SHIT) {
      require(balance[address(this)] >= amount);
      balance[address(this)] = balance[address(this)].sub(amount);
    }
    token.transfer(msg.sender, amount);
  }
  function clearETH() public onlyOwner() {
    address payable _owner = msg.sender;
    _owner.transfer(address(this).balance);
  }
  function setprovablegasprice(uint256 _price) public onlyOwner() {
    provable_setCustomGasPrice(_price);
  }
  function setgasforcallback(uint256 _gas) public onlyOwner() {
    GAS_FOR_CALLBACK = _gas;
  }




  uint256 constant MAX_INT_FROM_BYTE = 256;
  uint256 constant NUM_RANDOM_BYTES_REQUESTED = 7;



  function __callback(
    bytes32 _queryId,
    string memory _result,
    bytes memory _proof
  )
  public
  {
    require(msg.sender == provable_cbAddress());

    if (
      provable_randomDS_proofVerify__returnCode(
        _queryId,
        _result,
        _proof
      ) != 0
    ) {

    } else {

      if(playerrolls[_queryId].outcome == 0){
        uint256 _rnum = uint256(keccak256(abi.encodePacked(_result))) % sides + 1;
        address addr = playerrolls[_queryId].addr;
        uint256 amount = playerrolls[_queryId].amount;
        playerrolls[_queryId].outcome = _rnum;
        uint256 tmp;

        if (sideoutcome[_rnum].m != 0) {
          tmp = amount.mul(sideoutcome[_rnum].m);
          tmp = tmp.div(sideoutcome[_rnum].d);
          balance[addr] = balance[addr].add(tmp);
          balance[address(this)] = balance[address(this)].sub(tmp);
        }

        emit rolloutcome(addr, amount, tmp, _rnum, _queryId);
      }

    }
  }
  function() external payable {

  }
}
