pragma solidity ^0.4.18;

/**
* A contract that pays off, if a user is able to produce a valid solution
* for the Fermat&#39;s last theorem
*/

contract Fermat {

    /**
    *  The owner is the creator of the contract.

    *  The owner will be able to withdraw the
    *  bounty after the releaseTime has passed.

    *  The release time is set to 8640000 seconds (= 100 days)
    *  in the future from the timestamp of the contract creation
    */
    address public owner = msg.sender;
    uint releaseTime = now + 8640000;

    /**
    * This function is used to increase the bounty
    */
    function addBalance() public payable {

    }

    function getOwner() view public returns (address)  {
        return owner;
    }

    /*
    * Returns the time when it is possible for the owner
    * to withdraw the deposited funds from the contract.
    */
    function getReleaseTime() view public returns (uint)  {
        return releaseTime;
    }

    /**
     * Allow the owner of the contract to
     * withdraw the bounty after the release time has passed
     */
    function withdraw() public {
        require(msg.sender == owner);
        require(now >= releaseTime);

        msg.sender.transfer(this.balance);
    }

    function getBalance() view public returns (uint256) {
        return this.balance;
    }

    /**
     * The function that is used to claim the bounty.
     * If the caller is able to provide satisfying values for a,b,c and n
     * the balance of the contract (the bounty) is transferred to the caller
    */
    function claim(int256 a, int256 b, int256 c, int256 n) public {
        uint256 value = solve(a, b, c, n);
        if (value == 0) {
            msg.sender.transfer(this.balance);
        }
    }



    /*
     * The "core" logic of the smart contract.
     * Calculates the equation with provided values for Fermat&#39;s last theorem.
     * Returns the value of a^n + b^n - c^n, n > 2
     */
    function solve(int256 a, int256 b, int256 c, int256 n) pure public returns (uint256) {
        assert(n > 2);
        uint256 aExp = power(a, n);
        uint256 bExp = power(b, n);
        uint256 cExp = power(c, n);

        uint256 sum = add(aExp, bExp);
        uint256 difference = sub(sum, cExp);
        return difference;
    }

    /*
     A safe way to handle exponentiation. Throws error on overflow.
    */
    function power(int256 a, int256 pow) internal pure returns (uint256) {
        assert(a >= 0);
        assert(pow >= 0);
        int256 result = 1;
        for (int256 i = 0; i < pow; i++) {
            result = result * a;
            assert(result >= a);
        }
        return uint256(result);
    }

    /*
     A safe way to handle addition. Throws error on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /*
     A safe way to handle subtraction. Throws error on underflow.
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }


}