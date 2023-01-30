/**

 *Submitted for verification at Etherscan.io on 2019-05-28

*/



pragma solidity ^0.5.1;



contract RobetTest {

    string public name;

    mapping (address => mapping (string => uint256)) private bets;

    constructor()  public {

        name = 'RobetTest';

    }

    function insertBet(string memory bid, address addr, uint256 _value) public returns (bool success) {

        bets[addr][bid] = _value;

        return true;

    }

}