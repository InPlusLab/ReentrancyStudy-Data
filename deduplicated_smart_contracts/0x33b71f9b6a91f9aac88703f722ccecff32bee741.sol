/**
 *Submitted for verification at Etherscan.io on 2020-03-30
*/

pragma solidity ^0.5.0;

interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    function allocateTo(address recipient, uint256 value) external;
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract CTokenInterface is ERC20 {
    function mint(uint256 mintAmount) external returns (uint256);

    function mint() external payable;

    function redeem(uint256 redeemTokens) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function repayBorrow() external payable;

    function repayBorrowBehalf(address borrower, uint256 repayAmount) external returns (uint256);

    function repayBorrowBehalf(address borrower) external payable;

    function liquidateBorrow(address borrower, uint256 repayAmount, address cTokenCollateral)
        external
        returns (uint256);

    function liquidateBorrow(address borrower, address cTokenCollateral) external payable;

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function borrowRatePerBlock() external returns (uint256);

    function totalReserves() external returns (uint256);

    function reserveFactorMantissa() external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function totalBorrowsCurrent() external returns (uint256);

    function getCash() external returns (uint256);

    function balanceOfUnderlying(address owner) external returns (uint256);

    function underlying() external returns (address);
}

contract CEtherInterface {
    function mint() external payable;
    function repayBorrow() external payable;
}


contract ComptrollerInterface {
    function enterMarkets(address[] calldata cTokens) external returns (uint[] memory);
    function exitMarket(address cToken) external returns (uint);
}

contract CompoundBasicProxy {

    address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public constant COMPTROLLER = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;

    /// @dev User needs to approve the DSProxy to pull the _tokenAddr tokens
    function deposit(address _tokenAddr, address _cTokenAddr, uint _amount, bool _inMarket) public payable {
        approveCToken(_tokenAddr, _cTokenAddr);

        if (!_inMarket) {
            enterMarket(_cTokenAddr);
        }

        if (_tokenAddr != ETH_ADDRESS) {
            require(CTokenInterface(_cTokenAddr).mint(_amount) == 0);
        } else {
            CEtherInterface(_cTokenAddr).mint.value(msg.value)(); // reverts on fail
        }
    }

    /// @param _isCAmount If true _amount is cTokens if falls _amount is underlying tokens
    function withdraw(address _tokenAddr, address _cTokenAddr, uint _amount, bool _isCAmount) public {

        if (_isCAmount) {
            require(CTokenInterface(_cTokenAddr).redeem(_amount) == 0);
        } else {
            require(CTokenInterface(_cTokenAddr).redeemUnderlying(_amount) == 0);
        }

        // withdraw funds to msg.sender
        if (_tokenAddr != ETH_ADDRESS) {
            ERC20(_tokenAddr).transfer(msg.sender, ERC20(_tokenAddr).balanceOf(address(this)));
        } else {
            msg.sender.transfer(address(this).balance);
        }

    }

    function borrow(address _tokenAddr, address _cTokenAddr, uint _amount, bool _inMarket) public {
        if (!_inMarket) {
            enterMarket(_cTokenAddr);
        }

        require(CTokenInterface(_cTokenAddr).borrow(_amount) == 0);

        // withdraw funds to msg.sender
        if (_tokenAddr != ETH_ADDRESS) {
            ERC20(_tokenAddr).transfer(msg.sender, ERC20(_tokenAddr).balanceOf(address(this)));
        } else {
            msg.sender.transfer(address(this).balance);
        }
    }

    /// @dev User needs to approve the DSProxy to pull the _tokenAddr tokens
    function payback(address _tokenAddr, address _cTokenAddr, uint _amount) public payable {
        approveCToken(_tokenAddr, _cTokenAddr);

        if (_tokenAddr != ETH_ADDRESS) {
            require(CTokenInterface(_cTokenAddr).repayBorrow(_amount) == 0);
        } else {
            CEtherInterface(_cTokenAddr).repayBorrow.value(msg.value)();
            msg.sender.transfer(address(this).balance); // compound will send back the extra eth
        }
    }

    function withdrawTokens(address _tokenAddr) public {
        if (_tokenAddr != ETH_ADDRESS) {
            ERC20(_tokenAddr).transfer(msg.sender, ERC20(_tokenAddr).balanceOf(address(this)));
        } else {
            msg.sender.transfer(address(this).balance);
        }
    }

    function enterMarket(address _cTokenAddr) public {
        address[] memory markets = new address[](1);
        markets[0] = _cTokenAddr;

        ComptrollerInterface(COMPTROLLER).enterMarkets(markets);
    }

    function exitMarket(address _cTokenAddr) public {
        ComptrollerInterface(COMPTROLLER).exitMarket(_cTokenAddr);
    }

    function approveCToken(address _tokenAddr, address _cTokenAddr) internal {
        if (_tokenAddr != ETH_ADDRESS) {
            ERC20(_tokenAddr).approve(_cTokenAddr, uint(-1));
        }
    }
}