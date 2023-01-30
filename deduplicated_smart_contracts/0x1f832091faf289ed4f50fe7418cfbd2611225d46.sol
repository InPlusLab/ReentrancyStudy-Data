/**
 *Submitted for verification at Etherscan.io on 2020-12-10
*/

pragma solidity 0.6.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

//  voting contract 
interface Nest_3_VoteFactory {
    //  Check address 
	function checkAddress(string calldata name) external view returns (address contractAddress);
	//  check whether the administrator 
	function checkOwners(address man) external view returns (bool);
}

/**
 * @title NToken contract 
 * @dev Include standard erc20 method, mining method, and mining data 
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Nest_NToken is IERC20 {
    using SafeMath for uint256;
    
    mapping (address => uint256) private _balances;                                 //  Balance ledger 
    mapping (address => mapping (address => uint256)) private _allowed;             //  Approval ledger 
    uint256 private _totalSupply = 0 ether;                                         //  Total supply 
    string public name;                                                             //  Token name 
    string public symbol;                                                           //  Token symbol 
    uint8 public decimals = 18;                                                     //  Precision
    uint256 public _createBlock;                                                    //  Create block number
    uint256 public _recentlyUsedBlock;                                              //  Recently used block number
    Nest_3_VoteFactory _voteFactory;                                                //  Voting factory contract
    address _bidder;                                                                //  Owner
    
    /**
    * @dev Initialization method
    * @param _name Token name
    * @param _symbol Token symbol
    * @param voteFactory Voting factory contract address
    * @param bidder Successful bidder address
    */
    constructor (string memory _name, string memory _symbol, address voteFactory, address bidder) public {
    	name = _name;                                                               
    	symbol = _symbol;
    	_createBlock = block.number;
    	_recentlyUsedBlock = block.number;
    	_voteFactory = Nest_3_VoteFactory(address(voteFactory));
    	_bidder = bidder;
    }
    
    /**
    * @dev Reset voting contract method
    * @param voteFactory Voting contract address
    */
    function changeMapping (address voteFactory) public onlyOwner {
    	_voteFactory = Nest_3_VoteFactory(address(voteFactory));
    }
    
    /**
    * @dev Additional issuance
    * @param value Additional issuance amount
    */
    function increaseTotal(uint256 value) public {
        address offerMain = address(_voteFactory.checkAddress("nest.nToken.offerMain"));
        require(address(msg.sender) == offerMain, "No authority");
        _balances[offerMain] = _balances[offerMain].add(value);
        _totalSupply = _totalSupply.add(value);
        _recentlyUsedBlock = block.number;
    }

    /**
    * @dev Check the total amount of tokens
    * @return Total supply
    */
    function totalSupply() override public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Check address balance
    * @param owner Address to be checked
    * @return Return the balance of the corresponding address
    */
    function balanceOf(address owner) override public view returns (uint256) {
        return _balances[owner];
    }
    
    /**
    * @dev Check block information
    * @return createBlock Initial block number
    * @return recentlyUsedBlock Recently mined and issued block
    */
    function checkBlockInfo() public view returns(uint256 createBlock, uint256 recentlyUsedBlock) {
        return (_createBlock, _recentlyUsedBlock);
    }

    /**
     * @dev Check owner's approved allowance to the spender
     * @param owner Approving address
     * @param spender Approved address
     * @return Approved amount
     */
    function allowance(address owner, address spender) override public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer method
    * @param to Transfer target
    * @param value Transfer amount
    * @return Whether the transfer is successful
    */
    function transfer(address to, uint256 value) override public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approval method
     * @param spender Approval target
     * @param value Approval amount
     * @return Whether the approval is successful
     */
    function approve(address spender, uint256 value) override public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens when approved
     * @param from Transfer-out account address
     * @param to Transfer-in account address
     * @param value Transfer amount
     * @return Whether approved transfer is successful
     */
    function transferFrom(address from, address to, uint256 value) override public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the allowance
     * @param spender Approval target
     * @param addedValue Amount to increase
     * @return whether increase is successful
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the allowance
     * @param spender Approval target
     * @param subtractedValue Amount to decrease
     * @return Whether decrease is successful
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer method
    * @param to Transfer target
    * @param value Transfer amount
    */
    function _transfer(address from, address to, uint256 value) internal {
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }
    
    /**
    * @dev Check the creator
    * @return Creator address
    */
    function checkBidder() public view returns(address) {
        return _bidder;
    }
    
    /**
    * @dev Transfer creator
    * @param bidder New creator address
    */
    function changeBidder(address bidder) public {
        require(address(msg.sender) == _bidder);
        _bidder = bidder; 
    }
    
    // Administrator only
    modifier onlyOwner(){
        require(_voteFactory.checkOwners(msg.sender));
        _;
    }
}