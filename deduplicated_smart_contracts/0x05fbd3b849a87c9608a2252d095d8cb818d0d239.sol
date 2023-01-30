pragma solidity ^0.4.25;

import "./TokenERC865.sol";

contract TokenICBX is TokenERC865 {

//    uint256 public sellPrice;
//    uint256 public buyPrice;
    mapping (address => bool) public frozenAccount;
    mapping (address => uint256) public freezeOf;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /* This notifies clients about the amount frozen */
    event Freeze(address indexed from, uint256 value);

    /* This notifies clients about the amount unfrozen */
    event Unfreeze(address indexed from, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value);               // Check if the sender has enough
        require (balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        // balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_from] = safeSub(balanceOf[_from], _value);
        // balanceOf[_to] += _value;                           // Add the same to the recipient
        balanceOf[_to] = safeAdd(balanceOf[_to], _value);
        emit Transfer(_from, _to, _value);
    }

    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        // balanceOf[target] += mintedAmount;
        balanceOf[target] = safeAdd(balanceOf[target], mintedAmount);
        // totalSupply += mintedAmount;
        totalSupply = safeAdd(totalSupply, mintedAmount);
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }

    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

//    /// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
//    /// @param newSellPrice Price the users can sell to the contract
//    /// @param newBuyPrice Price users can buy from the contract
//    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
//        sellPrice = newSellPrice;
//        buyPrice = newBuyPrice;
//    }
//
//    /// @notice Buy tokens from contract by sending ether
//    function buy() payable public {
//        //uint amount = msg.value / buyPrice;               // calculates the amount
//        uint amount = safeDiv(msg.value, buyPrice);
//        _transfer(this, msg.sender, amount);              // makes the transfers
//    }
//
//    /// @notice Sell `amount` tokens to contract
//    /// @param amount amount of tokens to be sold
//    function sell(uint256 amount) public {
//        address myAddress = this;
//        require(myAddress.balance >= amount * sellPrice);      // checks if the contract has enough ether to buy
//        _transfer(msg.sender, this, amount);              // makes the transfers
//        //msg.sender.transfer(amount * sellPrice);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
//        msg.sender.transfer(safeMul(amount, sellPrice));
//    }

    function freeze(uint256 _value) returns (bool success) {
        require(balanceOf[msg.sender] >= _value);            // Check if the sender has enough
        require(_value > 0);
        balanceOf[msg.sender] = safeSub(balanceOf[msg.sender], _value);                      // Subtract from the sender
        freezeOf[msg.sender] = safeAdd(freezeOf[msg.sender], _value);                                // Updates totalSupply
        emit Freeze(msg.sender, _value);
        return true;
    }

    function unfreeze(uint256 _value) returns (bool success) {
        require(freezeOf[msg.sender] >= _value);            // Check if the sender has enough
        require(_value >= 0);
        freezeOf[msg.sender] = safeSub(freezeOf[msg.sender], _value);                      // Subtract from the sender
        balanceOf[msg.sender] = safeAdd(balanceOf[msg.sender], _value);
        emit Unfreeze(msg.sender, _value);
        return true;
    }

    // transfer balance to owner
    function withdrawEther(uint256 amount) onlyOwner {
        owner.transfer(amount);
    }

    // can accept ether
    function() payable {

    }

}
