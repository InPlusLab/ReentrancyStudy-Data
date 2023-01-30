//
// compiler: solcjs -o ./build/contracts --optimize --abi --bin <this file>
//  version: 0.4.18+commit.9cf6e910.Emscripten.clang
//
pragma solidity ^0.4.18;

contract owned {
  address public owner;
  function owned() public { owner = msg.sender; }

  modifier onlyOwner {
    if (msg.sender != owner) { revert(); }
    _;
  }

  function changeOwner( address newown ) public onlyOwner { owner = newown; }
  function closedown() public onlyOwner { selfdestruct( owner ); }
}

// token sold by this contract must be ERC20-compliant
interface ERC20 {
  function transfer(address to, uint256 value) public;
  function balanceOf( address owner ) public constant returns (uint);
}

contract ICO is owned {

  ERC20 public tokenSC;
  address      treasury;
  uint public  start;     // seconds since Jan 1 1970 GMT
  uint public  duration;  // seconds
  uint public  tokpereth; // rate, price

  function ICO( address _erc20,
                address _treasury,
                uint _startSec,
                uint _durationSec,
                uint _tokpereth ) public
  {
    require( isContract(_erc20) );
    require( _tokpereth > 0 );

    if (_treasury != address(0)) require( isContract(_treasury) );

    tokenSC = ERC20( _erc20 );
    treasury = _treasury;
    start = _startSec;
    duration = _durationSec;
    tokpereth = _tokpereth;
  }

  function setTreasury( address treas ) public onlyOwner { treasury = treas; }
  function setStart( uint newstart ) public onlyOwner { start = newstart; }
  function setRate( uint rate ) public onlyOwner { tokpereth = rate; }
  function setDuration( uint dur ) public onlyOwner { duration = dur; }

  function() public payable {
    require( msg.value >= 500 finney );
    if (now < start || now > (start + duration)) revert();

    // quantity =
    //   amountinwei * tokpereth/weipereth * (bonus+100)/100
    // = amountinwei * tokpereth/1e18 * (bonus+100)/100
    // = msg.value * tokpereth/1e20 * (bonus+100)
    uint qty =
      multiply( divide( multiply( msg.value, tokpereth ),
                        100000000000000000000),
                (bonus() + 100) );

    if (qty > tokenSC.balanceOf(address(this)) || qty < 1)
      revert();

    tokenSC.transfer( msg.sender, qty );

    if (treasury != address(0)) treasury.transfer( msg.value );
  }

  // unsold tokens can be claimed by owner after sale ends
  function claimUnsold() public onlyOwner {
    if ( now < (start + duration) ) revert();

    tokenSC.transfer( owner, tokenSC.balanceOf(address(this)) );
  }

  function withdraw( uint amount ) public onlyOwner returns (bool) {
    require ( treasury == address(0) && amount <= this.balance );
    return owner.send( amount );
  }

  // edited : no bonus scheme this ICO
  function bonus() pure private returns(uint) { return 0; }

  function isContract( address _a ) constant private returns (bool) {
    uint ecs;
    assembly { ecs := extcodesize(_a) }
    return ecs > 0;
  }

  // ref: github.com/OpenZeppelin/zeppelin-solidity/
  //      blob/master/contracts/math/SafeMath.sol
  function multiply(uint256 a, uint256 b) pure private returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function divide(uint256 a, uint256 b) pure private returns (uint256) {
    return a / b;
  }
}