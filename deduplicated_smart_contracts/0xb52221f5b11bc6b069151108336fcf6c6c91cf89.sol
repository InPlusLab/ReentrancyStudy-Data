/**
 *Submitted for verification at Etherscan.io on 2019-10-24
*/

pragma solidity ^0.5.10;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract IERC223ReceivingContract {

    /// @dev Standard ERC223 function that will handle incoming token transfers.
    /// @param _from  Token sender address.
    /// @param _value Amount of tokens.
    /// @param _data  Transaction metadata.
    function tokenFallback(address _from, uint _value, bytes memory _data) public;

}

contract IDetherToken {
    function mintingFinished() view public returns(bool);
    function name() view public returns(string memory);
    function approve(address _spender, uint256 _value) public returns(bool);
    function totalSupply() view public returns(uint256);
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool);
    function decimals() view public returns(uint8);
    function mint(address _to, uint256 _amount) public returns(bool);
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns(bool);
    function balanceOf(address _owner) view public returns(uint256 balance);
    function finishMinting() public returns(bool);
    function owner() view public returns(address);
    function symbol() view public returns(string memory);
    function transfer(address _to, uint256 _value) public returns(bool);
    function transfer(address _to, uint256 _value, bytes memory _data) public returns(bool);
    function increaseApproval(address _spender, uint256 _addedValue) public returns(bool);
    function allowance(address _owner, address _spender) view public returns(uint256);
    function transferOwnership(address newOwner) public;
}



contract TaxCollector is IERC223ReceivingContract, Ownable {

    // Address where collected taxes are sent to
    address public taxRecipient;
    bool public unchangeable;
    IDetherToken public dth;
    // Daily tax rate (there are no floats in solidity)
    event ReceivedTaxes(address indexed tokenFrom, uint taxes, address indexed from);

    constructor (address _dth, address _taxRecipient) public {
        dth = IDetherToken(_dth);
        taxRecipient = _taxRecipient;
    }

    function unchangeableRecipient()
      onlyOwner
      external
    {
        unchangeable = true;
    }

    function changeRecipient(address _newRecipient)
      external 
      onlyOwner
    {
        require(!unchangeable, 'Impossible to change the recipient');
        taxRecipient = _newRecipient;
    }

    function collect()
      public
    {
        uint balance = dth.balanceOf(address(this));
        dth.transfer(taxRecipient, balance);
    }

    function tokenFallback(address _from, uint _value, bytes memory _data) 
      public
    {
      emit ReceivedTaxes(msg.sender, _value, _from);
    }
}