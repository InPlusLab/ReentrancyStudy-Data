/**
 *Submitted for verification at Etherscan.io on 2020-06-12
*/

pragma solidity ^0.4.24;

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Erc20 {
    function balanceOf(address _owner) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
    function approve(address _spender, uint256 _value) public;
}

contract Exchange {
    function trade(
        address src,
        uint256 srcAmount,
        address dest,
        address destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address walletId
    ) public payable returns (uint256);
}

contract LendingPool {
    function deposit( address _reserve, uint256 _amount, uint16 _referralCode) external payable;
}

contract aUSDTGateway is Ownable {
    Exchange constant kyberEx = Exchange(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
    LendingPool constant lendingPool = LendingPool(0x398eC7346DcD622eDc5ae82352F02bE94C62d119);

    Erc20 constant USDT = Erc20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    Erc20 constant aUSDT = Erc20(0x71fc860F7D3A592A4a98740e39dB31d25db65ae8);
    address constant etherAddr = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    uint16 constant referral = 47;

    constructor () public {
        USDT.approve(0x3dfd23A6c5E8BbcFc9581d2E864a68feb6a076d3, uint256(-1));
    }

    function() external payable {
        etherToaUSDT(msg.sender);
    }

    function etherToaUSDT(address to)
        public
        payable
        returns (uint256 outAmount)
    {
        uint256 in_eth = (msg.value * 994) / 1000;
        uint256 amount = kyberEx.trade.value(in_eth)(
            etherAddr,
            in_eth,
            address(USDT),
            address(this),
            10**28,
            1,
            owner
        );
        lendingPool.deposit(address(USDT), amount, referral);
        outAmount = aUSDT.balanceOf(address(this));
        aUSDT.transfer(to, outAmount);
    }

    function makeprofit() public {
        owner.transfer(address(this).balance);
    }

}