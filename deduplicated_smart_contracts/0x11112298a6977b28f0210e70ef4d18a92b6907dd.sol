pragma solidity ^0.6.0;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ECCBToken is ERC20, Ownable {
    event MintAndSwap(bytes32 ellipticoin_transaction_hash);
    event SwapAndBurn(bytes32 ellipticoin_address, uint256 amount);
    IUniswapV2Router02 router;

    constructor(IUniswapV2Router02 _router)
        ERC20("Ellipitcoin Community Bridge Token", "ECCB")
      public {
        _setupDecimals(4);
        router = _router;

    }

    function mint(uint amount, address addr) public onlyOwner {
        _mint(addr, amount);
    }

    function mintAndSwap(
        uint amountIn,
        uint amountOutMin,
        address[] memory path,
        address to,
        uint deadline,
        bytes32 ellipticoin_transaction_hash
    )
        public
        returns (uint[] memory amounts)
    {
        _mint(address(this), amountIn);
        TransferHelper.safeApprove(address(this), address(router), amountIn);

        amounts = router.swapExactTokensForETH(
          amountIn,
          amountOutMin,
          path,
          to,
          deadline
        );
        emit MintAndSwap(ellipticoin_transaction_hash);
    }

    function swapAndBurn(
        uint amountOutMin,
        address[] memory path,
        bytes32 to,
        uint deadline
    )
        public
        payable
        returns (uint[] memory amounts)
    {
        amounts = router.swapExactETHForTokens{value: msg.value}(
          amountOutMin,
          path,
          msg.sender,
          deadline
        );
        _burn(msg.sender, amounts[1]);
        SwapAndBurn(to, amounts[1]);
    }
}