pragma solidity 0.4.26;


import "./SafeMath.sol";
import "./Ownable.sol";
import "./SlrsToken.sol";

contract SlrsTokenItoContract  is Ownable{
    using SafeMath for uint256;
    SlrsToken public slrs;
    uint    public  startTime;
    address public vestingAddress;
    address public heliosEnergy;
    address public tapRootConsulting;

    mapping(address => bool) public isWhitelisted;
	mapping(address => bool) public isAdminlisted;

	event WhitelistSet(address indexed _address, bool _state);
	event AdminlistSet(address indexed _address, bool _state);


	constructor(address token, uint _startTime, address _vestingAddress, address _heliosEnergy, address _tapRootConsulting) public{
        require(token != address(0));
        require(_startTime > 1564646400); // unix timestamp 1564646400 1st August 2019 09:00 am
        require(_vestingAddress != address(0));
        require(_heliosEnergy != address(0));
        require(_tapRootConsulting != address(0));
		slrs = SlrsToken(token);
		require(slrs.owner() == msg.sender);
		startTime = _startTime;
        vestingAddress = _vestingAddress; // address of teamVesting Wallet
        heliosEnergy = _heliosEnergy; // address of HeliosEnergy wallet
        tapRootConsulting = _tapRootConsulting; // address of TapRootConulting wallet
	}

  modifier onlyOwners() {
		require (isAdminlisted[msg.sender] == true || msg.sender == owner);
		_;
	}

	modifier onlyWhitelisted() {
		require (isWhitelisted[msg.sender] == true);
		_;
	}
    // accept funds only from whitelisted wallets
  function () public payable onlyWhitelisted{
    require(now >= startTime);
  }

    // transfer ETH from contract to predifined wallets
  function transferFundsToWallet(address to, uint256 weiAmount) public onlyOwner {
        require(msg.sender==owner);
        require(weiAmount > 0);
        require(to == address(heliosEnergy) || to == address(tapRootConsulting));
        to.transfer(weiAmount);
    }

  // minting to whitelisted investors wallets
  function mintInvestorToken(address beneficiary, uint256 tokenamount) public onlyOwners {
    require(isWhitelisted[beneficiary] == true);
    require(tokenamount > 0);
    slrs.mintFromContract(beneficiary, tokenamount);
  }

  // minting to vesting wallet for team tokens
  function mintTeamToken(address beneficiary, uint256 tokenamount) public onlyOwners {
    require(beneficiary == address(vestingAddress));
    require(tokenamount > 0);
    slrs.mintFromContract(beneficiary, tokenamount);
  }

    function setAdminlist(address _addr, bool _state) public onlyOwner {
    require(_addr != address(0));
		isAdminlisted[_addr] = _state;
		emit AdminlistSet(_addr, _state);
	}

    function setWhitelist(address _addr, bool _state) public onlyOwners {
        require(_addr != address(0));
        isWhitelisted[_addr] = _state;
        emit WhitelistSet(_addr, _state);
    }

    // Set whitelist state for multiple addresses
    function setManyWhitelist(address[] _addr) public onlyOwners {
        uint length = _addr.length;
        for (uint256 i = 0; i < length; i++) {
            setWhitelist(_addr[i], true);
        }
    }

	// @return true if sale has started
	function hasStarted() public view returns (bool) {
		return now >= startTime;
	}

  function checkInvestorHoldingToken(address investor) public view returns (uint256){
    require(investor != address(0));
    return slrs.balanceOf(investor);
  }

  // Owner can transfer out any accidentally sent ERC20 tokens
  function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
    return ERC20Interface(tokenAddress).transfer(owner, tokens);
  }

	function kill() public onlyOwner{
    selfdestruct(owner);
  }
}
