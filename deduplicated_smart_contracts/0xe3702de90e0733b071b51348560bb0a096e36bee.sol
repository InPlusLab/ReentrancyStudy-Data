/**

 *Submitted for verification at Etherscan.io on 2018-12-26

*/



pragma solidity ^0.4.23;

        // -------------------------------------------------------------------------

        //Sperma token contract

        // -------------------------------------------------------------------------

        

        contract Vaginati 

        {

        string public constant symbol = 'VGN';

        string public constant name = 'Vaginati';

        uint8 public constant decimals = 18;

        uint256 _totalSupply = 1000000 * 10 **18;

        

        // Owner of this contract

        address public owner = 0x36EaD5904808bbEF2cF2D12B41e6382D54E82b53;

        

        uint256 priceoftoken_1ether = 1;





        // Balances for each account

        mapping(address => uint256) balances;

    

        // Owner of account approves the transfer of an amount to another account

        mapping(address => mapping (address => uint256)) allowed;



        // Triggered when tokens are transferred.

        event Transfer(address indexed _from, address indexed _to, uint256 _value);

    

        // Triggered whenever approve(address _spender, uint256 _value) is called.

        event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    

        // Functions with this modifier can only be executed by the owner

        modifier onlyOwner() {

            if (msg.sender != owner) {

                throw;

            }

            _;

        }

    

        // Constructor

        function Vaginati() {



            balances[address(this)] =_totalSupply;

            Transfer(0x00,address(this),_totalSupply);





        }

        

        function () payable

        {

            

            uint256 token_to_send = msg.value * priceoftoken_1ether;

            require(balances[address(this)] >= token_to_send);

            balances[msg.sender] += token_to_send;

            balances[address(this)] -= token_to_send;



            Transfer(address(this),msg.sender,token_to_send);

        }

    

        function totalSupply() constant returns (uint256 totalSupply) {

            return _totalSupply;

        }

    

        // What is the balance of a particular account?

        function balanceOf(address _owner) constant returns (uint256 balance) {

            return balances[_owner];

        }

    

        // Transfer the balance from owner's account to another account

        function transfer(address _to, uint256 _amount) returns (bool success) {

            if (balances[msg.sender] >= _amount 

                && _amount > 0

                && balances[_to] + _amount > balances[_to]) {

                balances[msg.sender] -= _amount;

                balances[_to] += _amount;

                Transfer(msg.sender, _to, _amount);

                return true;

            } else {

                return false;}

        }

    

        // Send _value amount of tokens from address _from to address _to

        function transferFrom(

            address _from,

            address _to,

            uint256 _amount

        ) returns (bool success) {

            if (balances[_from] >= _amount

                && allowed[_from][msg.sender] >= _amount

                && _amount > 0

                && balances[_to] + _amount > balances[_to]) {

                balances[_from] -= _amount;

                allowed[_from][msg.sender] -= _amount;

                balances[_to] += _amount;

                Transfer(_from, _to, _amount);

                return true;

            } else {

                return false;}

        }



        function approve(address _spender, uint256 _amount) 

            returns (bool success) {

            allowed[msg.sender][_spender] = _amount;

            Approval(msg.sender, _spender, _amount);

            return true;

        }



        function allowance(address _owner, address _spender) 

            constant returns (uint256 remaining) {

            return allowed[_owner][_spender];

                

            }

            

            function drain() external onlyOwner {

                owner.transfer(this.balance);

             }

             

                 //used by wallet during token buying procedure 

    function transferby(address _from,address _to,uint256 _amount) public onlyOwner returns(bool success) {

        if (balances[_from] >= _amount &&

            _amount > 0 &&

            balances[_to] + _amount > balances[_to]) {

                 

            balances[_from] -= _amount;

            balances[_to] += _amount;

            Transfer(_from, _to, _amount);

            return true;

        } else {

            return false;

        }

    }

             

             	//In case the ownership needs to be transferred

	function transferOwnership(address newOwner)public onlyOwner

	{

	    require( newOwner != 0x0);

	    balances[newOwner] = balances[newOwner] + (balances[owner]);

	    balances[owner] = 0;

	    owner = newOwner;

	    Transfer(owner, newOwner, balances[newOwner]);

	}

        }