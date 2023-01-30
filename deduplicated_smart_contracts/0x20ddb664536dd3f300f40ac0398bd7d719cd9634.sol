pragma solidity ^0.4.23;

import './StandardBurnableToken.sol';
import './AuthRepo.sol';
import './SafeMath.sol';

/**
 * The Sample contract does this and that...
 */

contract TempoToken is StandardBurnableToken {
    using SafeMath for uint256;
    constructor (uint256 initialSupply, address _authRepoAddress) public {
        totalSupply_ = initialSupply;
        balances[msg.sender] = initialSupply;
        authRepoAddress = _authRepoAddress;
    }


    bool public authorization;
    address authRepoAddress;

    event Transfer(
                   address indexed from,
                   address indexed to,
                   uint256 value
                   );


    function getAuthorization() public returns (bool) {
        AuthRepo instanceAuthRepo = AuthRepo(authRepoAddress);
        return instanceAuthRepo.authorizeContract();
    }

    function transferFrom(
                          address _from,
                          address _to,
                          uint256 _value
                          )
        public
        returns (bool)
    {
        require(_value <= balances[_from]);
        // require(_value <= allowed[_from][msg.sender]);
        require(_to != address(0));
        authorization = getAuthorization();
        // TODO update this when auth repo is returning things other than just true
        require(authorization == true);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        // allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
}
