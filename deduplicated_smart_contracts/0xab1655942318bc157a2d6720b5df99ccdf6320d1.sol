/**

 *Submitted for verification at Etherscan.io on 2018-11-29

*/



pragma solidity 0.4.23;



contract ERC20BasicInterface {

    event Transfer(address indexed from, address indexed to, uint256 value);



    function decimals() public view returns (uint8);

    function name() public view returns (string);

    function symbol() public view returns (string);

    function totalSupply() public view returns (uint256 supply);

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

}



contract ERC20Interface is ERC20BasicInterface {

    event Approval(address indexed owner, address indexed spender, uint256 value);



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

}



/**

 * @title ERC20Lock

 *

 * This contract keeps token till the unlock date and sends it to predefined destination.

 */

contract BLOKLock {

    ERC20BasicInterface constant TOKEN = ERC20BasicInterface(0xFFc7A65176b532dB7e1Ac26c522Ca07123f952e1);

    address constant OWNER = 0xe686E973621713Ce05725C084648b3e9bD35BbC2;

    address constant DESTINATION = 0x620C847dB4c21dF362Fbc0C27ca254991752Bfb1;

    uint constant UNLOCK_DATE = 1553990400; // Sunday, 31 March 2019, 00:00:00



    function unlock() public returns(bool) {

        require(now > UNLOCK_DATE, 'Tokens are still locked');

        return TOKEN.transfer(DESTINATION, TOKEN.balanceOf(address(this)));

    }



    function recoverTokens(ERC20BasicInterface _token, address _to, uint _value) public returns(bool) {

        require(msg.sender == OWNER, 'Access denied');

        // This token meant to be recovered by calling unlock().

        require(address(_token) != address(TOKEN), 'Can not recover this token');

        return _token.transfer(_to, _value);

    }

}