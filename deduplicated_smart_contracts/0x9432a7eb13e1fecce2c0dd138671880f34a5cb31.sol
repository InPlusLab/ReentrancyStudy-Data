/**

 *Submitted for verification at Etherscan.io on 2018-11-12

*/



pragma solidity 0.4.25;



contract Math {



    ////////////////////////

    // Internal functions

    ////////////////////////



    // absolute difference: |v1 - v2|

    function absDiff(uint256 v1, uint256 v2)

        internal

        pure

        returns(uint256)

    {

        return v1 > v2 ? v1 - v2 : v2 - v1;

    }



    // divide v by d, round up if remainder is 0.5 or more

    function divRound(uint256 v, uint256 d)

        internal

        pure

        returns(uint256)

    {

        return add(v, d/2) / d;

    }



    // computes decimal decimalFraction 'frac' of 'amount' with maximum precision (multiplication first)

    // both amount and decimalFraction must have 18 decimals precision, frac 10**18 represents a whole (100% of) amount

    // mind loss of precision as decimal fractions do not have finite binary expansion

    // do not use instead of division

    function decimalFraction(uint256 amount, uint256 frac)

        internal

        pure

        returns(uint256)

    {

        // it's like 1 ether is 100% proportion

        return proportion(amount, frac, 10**18);

    }



    // computes part/total of amount with maximum precision (multiplication first)

    // part and total must have the same units

    function proportion(uint256 amount, uint256 part, uint256 total)

        internal

        pure

        returns(uint256)

    {

        return divRound(mul(amount, part), total);

    }



    //

    // Open Zeppelin Math library below

    //



    function mul(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;

    }



    function sub(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        assert(b <= a);

        return a - b;

    }



    function add(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }



    function min(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        return a < b ? a : b;

    }



    function max(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        return a > b ? a : b;

    }

}



/// @title uniquely identifies deployable (non-abstract) platform contract

/// @notice cheap way of assigning implementations to knownInterfaces which represent system services

///         unfortunatelly ERC165 does not include full public interface (ABI) and does not provide way to list implemented interfaces

///         EIP820 still in the making

/// @dev ids are generated as follows keccak256("neufund-platform:<contract name>")

///      ids roughly correspond to ABIs

contract IContractId {

    /// @param id defined as above

    /// @param version implementation version

    function contractId() public pure returns (bytes32 id, uint256 version);

}



/// @title set terms of Platform (investor's network) of the ETO

contract PlatformTerms is Math, IContractId {



    ////////////////////////

    // Constants

    ////////////////////////



    // fraction of fee deduced on successful ETO (see Math.sol for fraction definition)

    uint256 public constant PLATFORM_FEE_FRACTION = 3 * 10**16;

    // fraction of tokens deduced on succesful ETO

    uint256 public constant TOKEN_PARTICIPATION_FEE_FRACTION = 2 * 10**16;

    // share of Neumark reward platform operator gets

    // actually this is a divisor that splits Neumark reward in two parts

    // the results of division belongs to platform operator, the remaining reward part belongs to investor

    uint256 public constant PLATFORM_NEUMARK_SHARE = 2; // 50:50 division

    // ICBM investors whitelisted by default

    bool public constant IS_ICBM_INVESTOR_WHITELISTED = true;



    // minimum ticket size Platform accepts in EUR ULPS

    uint256 public constant MIN_TICKET_EUR_ULPS = 100 * 10**18;

    // maximum ticket size Platform accepts in EUR ULPS

    // no max ticket in general prospectus regulation

    // uint256 public constant MAX_TICKET_EUR_ULPS = 10000000 * 10**18;



    // min duration from setting the date to ETO start

    uint256 public constant DATE_TO_WHITELIST_MIN_DURATION = 7 days;

    // token rate expires after

    uint256 public constant TOKEN_RATE_EXPIRES_AFTER = 4 hours;



    // duration constraints

    uint256 public constant MIN_WHITELIST_DURATION = 0 days;

    uint256 public constant MAX_WHITELIST_DURATION = 30 days;

    uint256 public constant MIN_PUBLIC_DURATION = 0 days;

    uint256 public constant MAX_PUBLIC_DURATION = 60 days;



    // minimum length of whole offer

    uint256 public constant MIN_OFFER_DURATION = 1 days;

    // quarter should be enough for everyone

    uint256 public constant MAX_OFFER_DURATION = 90 days;



    uint256 public constant MIN_SIGNING_DURATION = 14 days;

    uint256 public constant MAX_SIGNING_DURATION = 60 days;



    uint256 public constant MIN_CLAIM_DURATION = 7 days;

    uint256 public constant MAX_CLAIM_DURATION = 30 days;



    ////////////////////////

    // Public Function

    ////////////////////////



    // calculates investor's and platform operator's neumarks from total reward

    function calculateNeumarkDistribution(uint256 rewardNmk)

        public

        pure

        returns (uint256 platformNmk, uint256 investorNmk)

    {

        // round down - platform may get 1 wei less than investor

        platformNmk = rewardNmk / PLATFORM_NEUMARK_SHARE;

        // rewardNmk > platformNmk always

        return (platformNmk, rewardNmk - platformNmk);

    }



    function calculatePlatformTokenFee(uint256 tokenAmount)

        public

        pure

        returns (uint256)

    {

        // mind tokens having 0 precision

        return proportion(tokenAmount, TOKEN_PARTICIPATION_FEE_FRACTION, 10**18);

    }



    function calculatePlatformFee(uint256 amount)

        public

        pure

        returns (uint256)

    {

        return decimalFraction(amount, PLATFORM_FEE_FRACTION);

    }



    //

    // Implements IContractId

    //



    function contractId() public pure returns (bytes32 id, uint256 version) {

        return (0x95482babc4e32de6c4dc3910ee7ae62c8e427efde6bc4e9ce0d6d93e24c39323, 0);

    }

}