/**

 *Submitted for verification at Etherscan.io on 2019-03-21

*/



pragma solidity >=0.4.22 <0.6.0;



contract WotChain {



    string public name;

    string public symbol;

    uint8 public decimals = 18;

    uint256 public totalSupply;



    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Burn(address indexed from, uint256 value);



    constructor(

        uint256 initialSupply,

        string memory tokenName,

        string memory tokenSymbol

    ) public {

        totalSupply = initialSupply * 10 ** uint256(decimals);

        balanceOf[msg.sender] = totalSupply;

        name = tokenName;

        symbol = tokenSymbol;

    }



    /**

    * Internal transfer, only can be called by this contract

    */

    function _transfer(address _from, address _to, uint _value) internal {

        require(_to != address(0x0));

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value >= balanceOf[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }



    /**

    * Transfer tokens

    *

    * Send `_value` tokens to `_to` from your account

    *

    * @param _to The address of the recipient

    * @param _value the amount to send

    */

    function transfer(address _to, uint256 _value) public returns (bool success) {

        _transfer(msg.sender, _to, _value);

        return true;

    }



    /**

    * Transfer tokens from other address

    *

    * Send `_value` tokens to `_to` on behalf of `_from`

    *

    * @param _from The address of the sender

    * @param _to The address of the recipient

    * @param _value the amount to send

    */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;

    }



    /**

    * Set allowance for other address

    *

    * Allows `_spender` to spend no more than `_value` tokens on your behalf

    *

    * @param _spender The address authorized to spend

    * @param _value the max amount they can spend

    */

    function approve(address _spender, uint256 _value) public

        returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    /**

    * Destroy tokens

    *

    * Remove `_value` tokens from the system irreversibly

    *

    * @param _value the amount of money to burn

    */

    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;

        totalSupply -= _value;

        emit Burn(msg.sender, _value);

        return true;

    }



    /**

    * Destroy tokens from other account

    *

    * Remove `_value` tokens from the system irreversibly on behalf of `_from`.

    *

    * @param _from the address of the sender

    * @param _value the amount of money to burn

    */

    function burnFrom(address _from, uint256 _value) public returns (bool success) {

        require(balanceOf[_from] >= _value);

        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;

        allowance[_from][msg.sender] -= _value;

        totalSupply -= _value;

        emit Burn(_from, _value);

        return true;

    }



}