pragma solidity ^0.4.25;

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC223_receiving_contract.sol";

/**
 * @title Standard ERC20 token + Detailed + Capped + Burnable with Dexaran's ERC223 extension
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract SelfmakerERC2xxToken is IERC20, Ownable {
    using SafeMath for uint256;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    uint256 private _maxSupply;

    event Transfer(address indexed from, address indexed to, uint256 value, bytes data); // ERC223
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    constructor() public {
        _name = "SelfMaker";
        _symbol = "SELF";
        _decimals = 0;
        _totalSupply = 25000000 * (10 ** uint256(_decimals));
	    _maxSupply = 35000000 * (10 ** uint256(_decimals));
        if (_totalSupply > 0) {
			_balances[msg.sender] = _totalSupply;
			bytes memory empty;
			emit Transfer(address(0), msg.sender, _totalSupply);
			emit Transfer(address(0), msg.sender, _totalSupply, empty);
    	}
    }

    /**
    * @return the name of the token.
    */
    function name() public view returns(string) {
        return _name;
    }

    /**
    * @return the symbol of the token.
    */
    function symbol() public view returns(string) {
        return _symbol;
    }

    /**
    * @return the number of decimals of the token.
    */
    function decimals() public view returns(uint8) {
        return _decimals;
    }

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @return the maximum supply of the token.
    */
    function maxSupply() public view returns(uint256) {
        return _maxSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param owner address The address which owns the funds.
    * @param spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address owner, address spender) public view returns (uint256)
    {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
    * @dev Transfer token for a specified address (ERC223)
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    * @param data Transaction metadata.
    */
    function transfer(address to, uint256 value, bytes data) public returns (bool) { // ERC223
        _transfer223(msg.sender, to, value, data);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param spender The address which will spend the funds.
    * @param value The amount of tokens to be spent.
    */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Spender address must be set.");
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address from, address to, uint256 value) public returns (bool)
    {
        require(value <= _allowed[from][msg.sender], "Value must not be higher than allowed.");
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param spender The address which will spend the funds.
    * @param addedValue The amount of tokens to increase the allowance by.
    */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool)
    {
        require(spender != address(0), "Spender address must be set.");
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed_[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param spender The address which will spend the funds.
    * @param subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool)
    {
        require(spender != address(0), "Spender address must be set.");
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(value <= _balances[from], "Value must not be higher than sender's balance.");
        require(to != address(0), "Receiver address must be set.");

        uint256 codeLength;
        assembly {
             codeLength := extcodesize(to)
        }

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);

        if(codeLength>0) { // odbiorca jest kontraktem, nie walletem
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            bytes memory empty;
            receiver.tokenFallback(msg.sender, value, empty);
        }

        emit Transfer(from, to, value);
        emit Transfer(from, to, value, empty);
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    * @param data Transaction metadata to be forwarded to the receiving smart contract.
    */
    function _transfer223(address from, address to, uint256 value, bytes data) internal { // ERC223
        require(value <= _balances[from], "Value must not be higher than sender's balance.");
        require(to != address(0), "Receiver address must be set.");

        uint256 codeLength;
        assembly {
            codeLength := extcodesize(to)
        }

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);

        if(codeLength>0) { // receiver is a contract address
            ERC223ReceivingContract receiver = ERC223ReceivingContract(to);
            receiver.tokenFallback(msg.sender, value, data);
        }

        emit Transfer(from, to, value);
        emit Transfer(from, to, value, data);
    }

    /* change owner address for allowing execution for the new owner */
    function setOwnerAddr(address _address) public onlySuperOwner {
        ownerAddr = _address;
    }

    /* add API address for allowing execution from the API */
    function addApiAddr(address _address) public onlyOwner {
        ApiAddr[_address] = true;
    }
    /* remove API address from allowing execution from the API */
    function removeApiAddr(address _address) public onlyOwner {
        ApiAddr[_address] = false;
    }

    /* add Contract address for allowing execution from the Contract */
    function addContractAddr(address _address) public onlyOwner {
        ContractAddr[_address] = true;
    }
    /* remove Contract address from allowing execution from the Contract */
    function removeContractAddr(address _address) public onlyOwner {
        ContractAddr[_address] = false;
    }

    /**
    * @dev Internal function that mints an amount of the token and assigns it to
    * an account. This encapsulates the modification of balances such that the
    * proper events are emitted.
    * @param account The account that will receive the created tokens.
    * @param value The amount that will be created.
    */
    function _mint(address account, uint256 value) internal {
        require(account != 0, "Receiver address must be set.");
        require(totalSupply().add(value) <= _maxSupply, "Maximum token supply exceeded.");
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        bytes memory empty;
        emit Transfer(address(0), account, value);
        emit Transfer(address(0), account, value, empty);
    }

    /**
    * @dev Function to mint tokens
    * @param to The address that will receive the minted tokens.
    * @param value The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(address to, uint256 value) public onlyOwnerOrApiOrContract returns (bool)
    {
        _mint(to, value);
        return true;
    }

    /**
    * @dev Internal function that burns an amount of the token of a given
    * account.
    * @param account The account whose tokens will be burnt.
    * @param value The amount that will be burnt.
    */
    function _burn(address account, uint256 value) internal {
        require(account != 0, "Target address must be set.");
        require(value <= _balances[account], "Amount must not be higher than balance.");
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        bytes memory empty;
        emit Transfer(account, address(0), value);
        emit Transfer(account, address(0), value, empty);
    }

    /**
    * @dev Burns a specific amount of tokens.
    * @param value The amount of token to be burned.
    */
    function burn(uint256 value) public onlyOwnerOrApiOrContract {
        _burn(msg.sender, value);
    }

    /**
    * @dev Internal function that burns an amount of the token of a given
    * account, deducting from the sender's allowance for said account. Uses the
    * internal burn function.
    * @param account The account whose tokens will be burnt.
    * @param value The amount that will be burnt.
    */
    function _burnFrom(address account, uint256 value) internal {
        require(value <= _allowed[account][msg.sender], "Amount must not be higher than allowed balance.");
        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }

    /**
    * @dev Burns a specific amount of tokens from the target address and decrements allowance
    * @param from address The address which you want to send tokens from
    * @param value uint256 The amount of token to be burned
    */
    function burnFrom(address from, uint256 value) public onlyOwnerOrApiOrContract {
        _burnFrom(from, value);
    }

}
