/**
 *Submitted for verification at Etherscan.io on 2020-04-02
*/

// File: contracts\interfaces\dss\IVat.sol

pragma solidity 0.5.17;

interface IVat {
    function hope(address usr) external;
    function gem(bytes32, address) external view returns (uint);
    function dai(address) external view returns (uint);
}

// File: contracts\interfaces\dss\ITokenJoin.sol

pragma solidity 0.5.17;

interface ITokenJoin {
    function join(address usr, uint wad) external;
    function exit(address usr, uint wad) external;
}

// File: contracts\interfaces\dss\IFlip.sol

pragma solidity 0.5.17;

contract IFlip {
    function tick(uint id) external;
    function tend(uint id, uint lot, uint bid) external;
    function dent(uint id, uint lot, uint bid) external;
    function deal(uint id) external;
}

// File: contracts\interfaces\dss\IFlap.sol

pragma solidity 0.5.17;

contract IFlap {
    function tick(uint id) external;
    function tend(uint id, uint lot, uint bid) external;
    function deal(uint id) external;
}

// File: contracts\interfaces\dss\IFlop.sol

pragma solidity 0.5.17;

contract IFlop {
    function tick(uint id) external;
    function dent(uint id, uint lot, uint bid) external;
    function deal(uint id) external;
}

// File: contracts\interfaces\token\IERC20.sol

pragma solidity 0.5.17;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts\proxy\ProxyActionsStorage.sol

pragma solidity 0.5.17;







/*
    Central storage for common variables
    across all proxies.
*/
contract ProxyActionsStorage {

    IVat public vat;
    IFlap public flap;
    IFlop public flop;

    mapping(bytes32 => IERC20) public tokens;
    mapping(bytes32 => uint) public decimals;
    mapping(bytes32 => bytes32) public ilks;
    mapping(bytes32 => ITokenJoin) public tokenJoins;
    mapping(bytes32 => IFlip) public flips;

    constructor() public {

        vat = IVat(address(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B));
        flap = IFlap(address(0xdfE0fb1bE2a52CDBf8FB962D5701d7fd0902db9f));
        flop = IFlop(address(0x4D95A049d5B0b7d32058cd3F2163015747522e99));

        tokens["ETH"] = IERC20(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)); // WETH
        tokens["DAI"] = IERC20(address(0x6B175474E89094C44Da98b954EedeAC495271d0F));
        tokens["BAT"] = IERC20(address(0x0D8775F648430679A709E98d2b0Cb6250d2887EF));
        tokens["USDC"] = IERC20(address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48));
        tokens["MKR"] = IERC20(address(0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2));

        decimals["ETH"] = 18;
        decimals["BAT"] = 18;
        decimals["USDC"] = 6;

        ilks["ETH"] = "ETH-A";
        ilks["BAT"] = "BAT-A";
        ilks["USDC"] = "USDC-A";

        tokenJoins["ETH"] = ITokenJoin(address(0x2F0b23f53734252Bda2277357e97e1517d6B042A));
        tokenJoins["DAI"] = ITokenJoin(address(0x9759A6Ac90977b93B58547b4A71c78317f391A28));
        tokenJoins["BAT"] = ITokenJoin(address(0x3D0B1912B66114d4096F48A8CEe3A56C231772cA));
        tokenJoins["USDC"] = ITokenJoin(address(0xA191e578a6736167326d05c119CE0c90849E84B7));

        flips["ETH"] = IFlip(address(0xd8a04F5412223F513DC55F839574430f5EC15531));
        flips["BAT"] = IFlip(address(0xaA745404d55f88C108A28c86abE7b5A1E7817c07));
        flips["USDC"] = IFlip(address(0xE6ed1d09a19Bd335f051d78D5d22dF3bfF2c28B1));
    }
}