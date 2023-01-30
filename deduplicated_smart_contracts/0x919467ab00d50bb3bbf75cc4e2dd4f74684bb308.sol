pragma solidity ^0.4.24;

contract BasicTokenInterface{
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    event ApprovalReceived(address indexed from, uint256 indexed amount, address indexed tokenAddr, bytes data);
    function receiveApproval(address from, uint256 amount, address tokenAddr, bytes data) public{
        emit ApprovalReceived(from, amount, tokenAddr, data);
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20TokenInterface is BasicTokenInterface, ApproveAndCallFallBack{
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);   
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function transferTokens(address token, uint amount) public returns (bool success);
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

pragma experimental "v0.5.0";

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a && c >= b);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || b == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(a > 0 && b > 0);
        c = a / b;
    }
}

contract BasicToken is BasicTokenInterface{
    using SafeMath for uint;
    
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX
    uint public totalSupply;
    mapping (address => uint256) internal balances;
    
    modifier checkpayloadsize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    } 

    function transfer(address _to, uint256 _value) public checkpayloadsize(2*32) returns (bool success) {
        require(balances[msg.sender] >= _value);
        success = true;
        balances[msg.sender] -= _value;

        //If sent to contract address reduce the supply
        if(_to == address(this)){
            totalSupply = totalSupply.sub(_value);
        }else{
            balances[_to] += _value;
        }
        emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
        return success;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}

contract ManagedToken is BasicToken {
    address manager;
    modifier restricted(){
        require(msg.sender == manager,"Function can only be used by manager");
        _;
    }

    function setManager(address newManager) public restricted{
        balances[newManager] = balances[manager];
        balances[manager] = 0;
        manager = newManager;
    }

}

contract ERC20Token is ERC20TokenInterface, ManagedToken{

    mapping (address => mapping (address => uint256)) internal allowed;

    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address _from,address _to,uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }


    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner,address _spender) public view returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    //Permit manager to sweep any tokens that landed here
    function transferTokens(address token,uint _value) public restricted returns (bool success){
        return ERC20Token(token).transfer(msg.sender,_value);
    }



}

contract FlairDrop is ERC20Token {

    address flairdrop;
    uint tokenPrice;
    event AirDropEvent(address indexed tokencontract, address[] destinations,uint[] indexed amounts);
    
    function() external payable {
        buyTokens();
    }

    function buyTokens() public payable{
        address(manager).transfer(msg.value);
        uint tokensBought = msg.value.div(tokenPrice);
        balances[msg.sender] = balances[msg.sender].add(tokensBought);
        totalSupply += tokensBought;
        emit Transfer(address(this),msg.sender,tokensBought);
    }

    constructor() public {
        flairdrop = address(this);
        name = "FlairDrop! Airdrops With Pizzazz!";
        symbol = "FLAIRDROP";
        decimals = 0;
        totalSupply = 0;
        tokenPrice = 10000000000000; //0.01 finney
        manager = msg.sender;
        balances[manager] = 100000000;
        totalSupply = balances[manager];
        emit Transfer(address(this),manager,balances[manager]);
        
    }

    function airDrop(address parent, uint[] amounts, address[] droptargets) public payable {
        if(msg.value > 0){
            buyTokens();
        }
        
        require(balances[msg.sender] >= droptargets.length,"Insufficient funds to execute this airdrop");
        //Step 1 check our allowance with parent contract
        ERC20TokenInterface parentContract = ERC20TokenInterface(parent);
        uint allowance = parentContract.allowance(msg.sender, flairdrop);

        uint amount = amounts[0];
    
        uint x = 0;

        address target;
        
        while(gasleft() > 21000 && x <= droptargets.length - 1 ){
            target = droptargets[x];
            
            if(amounts.length == droptargets.length){
                amount = amounts[x];
            }
            if(allowance >=amount){
                parentContract.transferFrom(msg.sender,target,amount);
                allowance -= amount;
            }
            x++;
        }
        
        balances[msg.sender] -= x;
        totalSupply  = totalSupply >= x ? totalSupply - x : 0;
    
        emit Transfer(msg.sender, address(0), x);
        emit AirDropEvent(parent,droptargets,amounts);
    }

    function setTokenPrice(uint price) public restricted{
        tokenPrice = price;
    }

    function getTokenPrice() public view returns(uint){
        return tokenPrice;
    }
}