pragma solidity ^0.5.1;


import "./ERC223Token.sol";

contract  CryptoHarborExchangeGameToken is ERC223Token {

    string public name = "CryptoHarborExchangeGameToken";

    string public symbol = "CHEG";

    uint public decimals = 8;

    uint256 public initialSupply = 1e8 * 1e8;

    uint256 public _totalSupply;
    
    address public owner;
    
    bool public mintingFinished;

    mapping (address => bool) public frozenAccount;
    mapping (address => uint256) public unlockUnixTime;
    event FrozenFunds(address indexed target, bool frozen);
    event LockedFunds(address indexed target, uint256 locked);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Burn(address indexed from, uint256 amount);
    event Mint(address indexed _to, uint256 _unitAmount);
    event MintFinished();

    constructor() public {
        _totalSupply = initialSupply;
        balances[msg.sender] = initialSupply;
        owner = msg.sender;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param _from The address that will burn the tokens.
     * @param _unitAmount The amount of token to be burned.
     */
    function burn(address _from, uint256 _unitAmount) onlyOwner public {
        require(_unitAmount > 0
                && balances[_from] >= _unitAmount);

        balances[_from] = balances[_from].sub(_unitAmount);
        _totalSupply = _totalSupply.sub(_unitAmount);
        emit Burn(_from, _unitAmount);
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _unitAmount The amount of tokens to mint.
     */
    
    function mint(address _to, uint256 _unitAmount) onlyOwner canMint public returns (bool) {
        require(_unitAmount > 0);
        
        _totalSupply = _totalSupply.add(_unitAmount);
        balances[_to] = balances[_to].add(_unitAmount);
        emit Mint(_to, _unitAmount);
        emit Transfer(address(0), _to, _unitAmount);
        return true;
    }
    
        modifier canMint() {
        require(!mintingFinished);
        _;
    }
   
       /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    } 
    
        /**
     * @dev Function to stop minting new tokens.
     */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }

    /**
     * @dev Prevent targets from sending or receiving tokens
     * @param targets Addresses to be frozen
     * @param isFrozen either to freeze it or not
     */
    function freezeAccounts(address[] memory targets, bool isFrozen) onlyOwner public {
        require(targets.length > 0);

        for (uint j = 0; j < targets.length; j++) {
            require(targets[j] != owner);
            frozenAccount[targets[j]] = isFrozen;
            emit FrozenFunds(targets[j], isFrozen);
        }
    }

    /**
     * @dev Prevent targets from sending or receiving tokens by setting Unix times
     * @param targets Addresses to be locked funds
     * @param unixTimes Unix times when locking up will be finished
     */
    function lockupAccounts(address[] memory targets, uint[] memory unixTimes) onlyOwner public {
        require(targets.length > 0
                && targets.length == unixTimes.length);
                
        for(uint j = 0; j < targets.length; j++){
            require(unlockUnixTime[targets[j]] < unixTimes[j]);
            unlockUnixTime[targets[j]] = unixTimes[j];
            emit LockedFunds(targets[j], unixTimes[j]);
        }
    }


    function transfer(address _to, uint _value, bytes memory _data) public  returns (bool success) {
        require(_value > 0
                && frozenAccount[msg.sender] == false 
                && frozenAccount[_to] == false
                && now > unlockUnixTime[msg.sender] 
                && now > unlockUnixTime[_to]);

        if (!isContract(_to)) {
            return transferToAddress(_to, _value, _data);
        }
    }

    /**
     * @dev Standard function transfer similar to ERC20 transfer with no _data
     *      Added due to backwards compatibility reasons
     */
    function transfer(address _to, uint _value) public returns (bool success) {
        require(_value > 0
                && frozenAccount[msg.sender] == false 
                && frozenAccount[_to] == false
                && now > unlockUnixTime[msg.sender] 
                && now > unlockUnixTime[_to]);

        bytes memory empty;
        if (!isContract(_to)) {
            return transferToAddress(_to, _value, empty);
        }
    }

    // assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length > 0);
    }

    // function that is called when transaction target is an address
    function transferToAddress(address _to, uint _value, bytes memory  _data) private returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }



}