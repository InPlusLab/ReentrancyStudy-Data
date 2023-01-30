/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

pragma solidity ^0.5.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimals() external view returns (uint);
    function name() external view returns (string memory);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface Controller {
    function vaults(address) external view returns (address);
    function rewards() external view returns (address);
}

/*

 A strategy must implement the following calls;
 
 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()
 
 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller
 
*/



interface UniswapRouter {
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external;
}
interface For{
    function deposit(address token, uint256 amount) external payable;
    function withdraw(address underlying, uint256 withdrawTokens) external;
    function withdrawUnderlying(address underlying, uint256 amount) external;
    function controller() view external returns(address);

}
interface IFToken {
    function balanceOf(address account) external view returns (uint256);

    function calcBalanceOfUnderlying(address owner)
        external
        view
        returns (uint256);
}

interface IBankController {

    function getFTokeAddress(address underlying)
        external
        view
        returns (address);
}
interface ForReward{
    function claimReward() external;
}

interface ICurveFi {
  function exchange(
    int128 from, int128 to, uint256 _from_amount, uint256 _min_to_amount
  ) external;
}
contract StrategyFortubeHBTC {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address constant public want = address(0x0316EB71485b0Ab14103307bf65a021042c6d380); //hbtc
    address constant public output = address(0x1FCdcE58959f536621d76f5b7FfB955baa5A672F); //for
    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant public weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); 

    address constant public gof = address(0x488E0369f9BC5C40C002eA7c1fe4fd01A198801c);

    address constant public fortube = address(0xdE7B3b2Fe0E7b4925107615A5b199a4EB40D9ca9);//主合约.
    address constant public fortube_reward = address(0xF8Df2E6E46AC00Cdf3616C4E35278b7704289d82); //领取奖励的合约

    address constant public usdt = address(0xdAC17F958D2ee523a2206206994597C13D831ec7); //usdt /for->usdt
    address constant public wbtc = address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599); //for wbtc
    address constant public curve = address(0x4CA9b3063Ec5866A4B82E437059D2C43d1be596F); //wbtc hbtc


    
    uint public burnfee = 400;
    uint public fee = 100;
    uint public foundationfee = 400;
    uint public callfee = 100;
    uint constant public max = 1000;

    uint public withdrawalFee = 0;
    uint constant public withdrawalMax = 10000;
    
    address public governance;
    address public strategyDev;
    address public controller;
    address public foundationAddress = 0x1250E38187Ff89d05f99F3fa0E324241bbE2120C;
    address public burnAddress;

    string public getName;

    address[] public swap2GOFRouting;
    address[] public swap2TokenRouting;
    
    
    constructor(address _controller, address _burnAddress) public {
        governance = msg.sender;
        strategyDev = tx.origin;
        controller = _controller;
        burnAddress = _burnAddress;

        getName = string(
            abi.encodePacked("golff:Strategy:", 
                abi.encodePacked(IERC20(want).name(),":The Force Token"
                )
            ));

        swap2GOFRouting = [output,usdt,weth,gof];
        swap2TokenRouting = [output,usdt,weth,wbtc]; //for -> wbtc
        doApprove();
    }

    function doApprove () public{
        IERC20(output).safeApprove(unirouter, 0);
        IERC20(output).safeApprove(unirouter, uint(-1));
    }
    
    
    function deposit() public {
        uint _want = IERC20(want).balanceOf(address(this));
        address _controller = For(fortube).controller();
        if (_want > 0) {
            // IERC20(want).safeApprove(_controller, 0);
            IERC20(want).safeApprove(_controller, _want);
            For(fortube).deposit(want,_want);
        }
        
    }
    
    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "Golff:!controller");
        require(want != address(_asset), "Golff:want");
        require(wbtc != address(_asset), "Golff:wbtc");
        address _controller = For(fortube).controller();
        require(IBankController(_controller).getFTokeAddress(want) != address(_asset),"Golff:fToken");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }
    
    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "Golff:!controller");
        uint _balance = IERC20(want).balanceOf(address(this));
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
        
        uint _fee = 0;
        if (withdrawalFee>0){
            _fee = _amount.mul(withdrawalFee).div(withdrawalMax);        
            IERC20(want).safeTransfer(Controller(controller).rewards(), _fee);
        }
        
        
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "Golff:!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, _amount.sub(_fee));
    }
    
    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() external returns (uint balance) {
        require(msg.sender == controller || msg.sender == governance,"Golff:!governance");
        _withdrawAll();
        
        
        balance = IERC20(want).balanceOf(address(this));
        
        address _vault = Controller(controller).vaults(address(want));
        require(_vault != address(0), "Golff:!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
    }
    
    function _withdrawAll() internal {
        address _controller = For(fortube).controller();
        IFToken fToken = IFToken(IBankController(_controller).getFTokeAddress(want));
        uint b = fToken.balanceOf(address(this));
        For(fortube).withdraw(want,b);
    }
    
    function harvest() public {
        require(msg.sender == strategyDev,"Golff:!strategyDev");
        ForReward(fortube_reward).claimReward();
        doswap();
        dosplit();//分gof
        deposit();
    }

    function doswap() internal {
        uint256 _2token = IERC20(output).balanceOf(address(this)).mul(90).div(100); //90%
        uint256 _2gof = IERC20(output).balanceOf(address(this)).mul(10).div(100);  //10%
        UniswapRouter(unirouter).swapExactTokensForTokens(_2token, 0, swap2TokenRouting, address(this), now.add(1800));
        UniswapRouter(unirouter).swapExactTokensForTokens(_2gof, 0, swap2GOFRouting, address(this), now.add(1800));

         //wbtc -> hbtc curve:
        uint _wbtc = IERC20(wbtc).balanceOf(address(this));
        if (_wbtc > 0) {
            IERC20(wbtc).safeApprove(curve, 0);
            IERC20(wbtc).safeApprove(curve, _wbtc);
            ICurveFi(curve).exchange(1, 0, _wbtc, 0);
        }

    }
    function dosplit() internal{
        uint b = IERC20(gof).balanceOf(address(this));
        uint _fee = b.mul(fee).div(max);
        uint _callfee = b.mul(callfee).div(max);
        uint _foundationfee = b.mul(foundationfee).div(max);
        IERC20(gof).safeTransfer(Controller(controller).rewards(), _fee); 
        IERC20(gof).safeTransfer(msg.sender, _callfee); 
        IERC20(gof).safeTransfer(foundationAddress, _foundationfee); 

        if (burnfee >0){
            uint _burnfee = b.mul(burnfee).div(max); 
            IERC20(gof).safeTransfer(burnAddress, _burnfee);
        }
    }
    
    function _withdrawSome(uint256 _amount) internal returns (uint) {
        For(fortube).withdrawUnderlying(want,_amount);
        return _amount;
    }
    
    function balanceOfWant() public view returns (uint) {
        return IERC20(want).balanceOf(address(this));
    }
    
    function balanceOfPool() public view returns (uint) {
        address _controller = For(fortube).controller();
        IFToken fToken = IFToken(IBankController(_controller).getFTokeAddress(want));
        return fToken.calcBalanceOfUnderlying(address(this));
    }
    
    
    function balanceOf() public view returns (uint) {
        return balanceOfWant()
               .add(balanceOfPool());
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "Golff:!governance");
        governance = _governance;
    }
    
    function setController(address _controller) external {
        require(msg.sender == governance, "Golff:!governance");
        controller = _controller;
    }

    function setFees(uint256 _fee, uint256 _callfee, uint256 _burnfee, uint256 _foundationfee) external{
        require(msg.sender == governance, "Golff:!governance");
        require(max == _fee.add(_callfee).add(_burnfee).add(_foundationfee), "Golff:Invalid fees");

        fee = _fee;
        callfee = _callfee;
        burnfee = _burnfee;
        foundationfee = _foundationfee;
    }

    function setFoundationAddress(address _foundationAddress) public{
        require(msg.sender == governance, "Golff:!governance");
        foundationAddress = _foundationAddress;
    }

    function setWithdrawalFee(uint _withdrawalFee) external {
        require(msg.sender == governance, "Golff:!governance");
        require(_withdrawalFee <=100,"fee > 1%"); //max:1%
        withdrawalFee = _withdrawalFee;
    }
        
    function setBurnAddress(address _burnAddress) public {
        require(msg.sender == governance, "Golff:!governance");
        burnAddress = _burnAddress;
    }

    function setStrategyDev(address _strategyDev) public {
        require(msg.sender == governance, "Golff:!governance");
        strategyDev = _strategyDev;
    }

    function setSwap2GOF(address[] memory _path) public{
        require(msg.sender == governance, "Golff:!governance");
        swap2GOFRouting = _path;
    }
    function setSwap2Token(address[] memory _path) public{
        require(msg.sender == governance, "Golff:!governance");
        swap2TokenRouting = _path;
    }
}