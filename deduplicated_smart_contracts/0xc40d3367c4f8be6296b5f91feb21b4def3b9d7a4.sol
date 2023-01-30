/**

 *Submitted for verification at Etherscan.io on 2019-04-11

*/



pragma solidity ^0.4.25;



contract SafeMath {

    function safeAdd(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        assert(c >= a);

    }



    function safeSub(uint a, uint b) internal pure returns (uint c) {

        c = a - b;

        assert(c <= a);

    }

}



contract ERC20Interface {

    event Transfer(address indexed _from, address indexed _to, uint _tokens);

    event Approval(address indexed _tokenOwner, address indexed _spender, uint _tokens);

    

    function name() external view returns (string _name);

    function symbol() external view returns (string _symbol);

    function decimals() external view returns (uint8 _decimal);

    function totalSupply() external view returns (uint _totalSupply);

    function balanceOf(address _tokenOwner) external view returns (uint _balance);

    function allowance(address _tokenOwner, address _spender) external view returns (uint _remaining);

    function transfer(address _to, uint _tokens) public returns (bool _success);

    function approve(address _spender, uint _tokens) public returns (bool _success);

    function transferFrom(address _from, address _to, uint _tokens) public returns (bool _success);

}



// abstract contract

interface tokenRecipient {

    function recieveApproval(address _from, uint _tokens, address _token, bytes _data) external;

}



contract Owned {

    address public owner;



    constructor() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }

}



contract WhiteXToken is ERC20Interface, Owned, SafeMath {

    string public name;

    string public symbol;

    uint8 public decimals;

    uint public totalSupply;

    

    mapping(address => uint) public balances;

    mapping(address => mapping(address => uint)) public allowed;

    mapping(address => bool) public frozenAccount;

    

    event FrozenFunds(address _target, bool _frozen);



    constructor() public {

        name = "White X Chain";

        symbol = "XPS";

        decimals = 18;

        totalSupply = 1000000000 * 10 ** 18;

        balances[msg.sender] = totalSupply;

        emit Transfer(address(0), owner, totalSupply);

    }

    

    // destroy contract

    function kill() external onlyOwner {

        selfdestruct(owner);

    }



    // transfer contract administrator

    function transferOwnership(address _newOwner) external onlyOwner {

        require(_newOwner != address(0));

        emit Transfer(owner, _newOwner, balances[owner]);

        balances[_newOwner] = safeAdd(balances[_newOwner], balances[owner]);

        balances[owner] = 0;

        owner = _newOwner;

    }

    

    // reissuing token

    function mintToken(uint _mintedAmount) external onlyOwner {

        balances[owner] = safeAdd(balances[owner], _mintedAmount);

        totalSupply = safeAdd(totalSupply, _mintedAmount);

        emit Transfer(address(0), owner, _mintedAmount);

    }

    

    // freeze account

    function freezeAccount(address _target, bool _freeze) external onlyOwner {

        frozenAccount[_target] = _freeze;

        emit FrozenFunds(_target, _freeze);

    }

    

    function name() external view returns (string _name) {

        _name = name;

    }

    

    function symbol() external view returns (string _symbol) {

        _symbol = symbol;

    }

    

    function decimals() external view returns (uint8 _decimals) {

        _decimals = decimals;

    }

    

    function totalSupply() external view returns (uint _totalSupply) {

        _totalSupply =  totalSupply - balances[address(0)];

    }



    function balanceOf(address _tokenOwner) external view returns (uint _balance) {

        _balance = balances[_tokenOwner];

    }



    function transfer(address _to, uint _tokens) public returns (bool _success) {

        require(!frozenAccount[msg.sender]);

        require(_tokens > 0);

        require(balances[msg.sender] >= _tokens);

        balances[msg.sender] = safeSub(balances[msg.sender], _tokens);

        balances[_to] = safeAdd(balances[_to], _tokens);

        emit Transfer(msg.sender, _to, _tokens);

        _success = true;

    }



    function approve(address _spender, uint _tokens) public returns (bool _success) {

        allowed[msg.sender][_spender] = _tokens;

        emit Approval(msg.sender, _spender, _tokens);

        _success = true;

    }



    function transferFrom(address _from, address _to, uint _tokens) public returns (bool _success) {

        require(!frozenAccount[msg.sender]);

        require(_tokens > 0);

        require(allowed[_from][msg.sender] >= _tokens);

        require(balances[msg.sender] >= _tokens);

        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _tokens);

        balances[_from] = safeSub(balances[_from], _tokens);

        balances[_to] = safeAdd(balances[_to], _tokens);

        emit Transfer(_from, _to, _tokens);

        _success = true;

    }



    function allowance(address _tokenOwner, address _spender) external view returns (uint _remaining) {

        _remaining = allowed[_tokenOwner][_spender];

    }



    function approveAndCall(address _spender, uint _tokens, bytes _data) external returns (bool _success) {

        require(approve(_spender, _tokens));

        tokenRecipient(_spender).recieveApproval(msg.sender, _tokens, this, _data);

        _success = true;

    }



    // Don't accept ETH

    function () external payable {

        revert();

    }

}