pragma solidity ^0.4.18;
/**
* TOKEN Contract
* ERC-20 Token Standard Compliant
* @author Fares A. Akel C. <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c9afe7a8a7bda6a7a0a6e7a8a2aca589aea4a8a0a5e7aaa6a4">[email&#160;protected]</a>
*/

/**
 * @title SafeMath by OpenZeppelin
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

/**
 * Token contract interface for external use
 */
contract ERC20TokenInterface {

    function balanceOf(address _owner) public constant returns (uint256 value);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    }


/**
* @title Admin parameters
* @dev Define administration parameters for this contract
*/
contract admined { //This token contract is administered
    address public admin; //Admin address is public
    bool public lockSupply; //Mint and Burn Lock flag

    /**
    * @dev Contract constructor
    * define initial administrator
    */
    function admined() internal {
        admin = msg.sender; //Set initial admin to contract creator
        Admined(admin);
    }

    modifier onlyAdmin() { //A modifier to define admin-only functions
        require(msg.sender == admin);
        _;
    }

    modifier supplyLock() { //A modifier to lock mint and burn transactions
        require(lockSupply == false);
        _;
    }

   /**
    * @dev Function to set new admin address
    * @param _newAdmin The address to transfer administration to
    */
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered
        require(_newAdmin != 0);
        admin = _newAdmin;
        TransferAdminship(admin);
    }

   /**
    * @dev Function to set mint and burn locks
    * @param _set boolean flag (true | false)
    */
    function setSupplyLock(bool _set) onlyAdmin public { //Only the admin can set a lock on supply
        lockSupply = _set;
        SetSupplyLock(_set);
    }

    //All admin actions have a log for public review
    event SetSupplyLock(bool _set);
    event TransferAdminship(address newAdminister);
    event Admined(address administer);

}

/**
* @title Token definition
* @dev Define token paramters including ERC20 ones
*/
contract ERC20Token is ERC20TokenInterface, admined { //Standard definition of a ERC20Token
    using SafeMath for uint256;
    uint256 public totalSupply;
    mapping (address => uint256) balances; //A mapping of all balances per address
    mapping (address => mapping (address => uint256)) allowed; //A mapping of all allowances

    /**
    * @dev Get the balance of an specified address.
    * @param _owner The address to be query.
    */
    function balanceOf(address _owner) public constant returns (uint256 value) {
      return balances[_owner];
    }

    /**
    * @dev transfer token to a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0)); //If you dont want that people destroy token
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev transfer token from an address to another specified address using allowance
    * @param _from The address where token comes.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0)); //If you dont want that people destroy token
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Assign allowance to an specified address to use the owner balance
    * @param _spender The address to be allowed to spend.
    * @param _value The amount to be allowed.
    */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Get the allowance of an specified address to use another address balance.
    * @param _owner The address of the owner of the tokens.
    * @param _spender The address of the allowed spender.
    */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
    * @dev Mint token to an specified address.
    * @param _target The address of the receiver of the tokens.
    * @param _mintedAmount amount to mint.
    */
    function mintToken(address _target, uint256 _mintedAmount) onlyAdmin supplyLock public {
        require(_target != address(0));
        balances[_target] = SafeMath.add(balances[_target], _mintedAmount);
        totalSupply = SafeMath.add(totalSupply, _mintedAmount);
        Transfer(0, this, _mintedAmount);
        Transfer(this, _target, _mintedAmount);
    }

    /**
    * @dev Burn token.
    * @param _burnedAmount amount to burn.
    */
    function burnToken(uint256 _burnedAmount) supplyLock public {
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _burnedAmount);
        totalSupply = SafeMath.sub(totalSupply, _burnedAmount);
        Burned(msg.sender, _burnedAmount);
    }

    /**
    * @dev Log Events
    */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burned(address indexed _target, uint256 _value);
}

/**
* @title Asset
* @dev Initial supply creation
*/
contract Asset is ERC20Token {
    string public name = &#39;Equitybase&#39;;
    uint8 public decimals = 18;
    string public symbol = &#39;BASE&#39;;
    string public version = &#39;1&#39;;

    /**
    * @dev Asset constructor.
    * @param _privateSaleWallet The wallet address for the private sale distribution.
    * @param _companyReserveAndBountyWallet The wallet address of the company to handle also reserve and bounties.
    */
    function Asset(address _privateSaleWallet, address _companyReserveAndBountyWallet) public {
        //Sanity checks
        require(msg.sender != _privateSaleWallet);
        require(msg.sender != _companyReserveAndBountyWallet);
        require(_privateSaleWallet != _companyReserveAndBountyWallet);
        require(_privateSaleWallet != 0);
        require(_companyReserveAndBountyWallet != 0);

        totalSupply = 360000000 * (10**uint256(decimals)); //initial token creation
        
        balances[msg.sender] = 180000000 * (10**uint256(decimals)); //180 Million for crowdsale
        balances[_privateSaleWallet] = 14400000 * (10**uint256(decimals)); //14.4 Million for crowdsale
        balances[_companyReserveAndBountyWallet] = 165240000 * (10**uint256(decimals)); //165.24 Million for crowdsale
        balances[0xA6bc924715A0B63C6E0a7653d3262D26F254EcFd] = 360000 * (10**uint256(decimals)); //360k for contract writer (0.1%)

        setSupplyLock(true);

        Transfer(0, this, totalSupply);
        Transfer(this, msg.sender, balances[msg.sender]);
        Transfer(this, _privateSaleWallet, balances[_privateSaleWallet]);
        Transfer(this, _companyReserveAndBountyWallet, balances[_companyReserveAndBountyWallet]);
        Transfer(this, 0xA6bc924715A0B63C6E0a7653d3262D26F254EcFd, balances[0xA6bc924715A0B63C6E0a7653d3262D26F254EcFd]);
    }
    
    /**
    *@dev Function to handle callback calls
    */
    function() public {
        revert();
    }
}