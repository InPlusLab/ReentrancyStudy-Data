/**
 *Submitted for verification at Etherscan.io on 2019-10-07
*/

pragma solidity ^0.4.18;

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
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
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
interface ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function decimals() public view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}
contract KyberNetworkProxy {

    function tradeWithHint(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId,
        bytes hint
    )
    public
    payable
    returns(uint);

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty)
    public view
    returns(uint expectedRate, uint slippageRate);
}

contract ProxyKyberSwap is Ownable{
    using SafeMath for uint256;
    KyberNetworkProxy public kyberNetworkProxyContract;
    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    uint private proceesPer = 975;
    address private ID = address(0xEc2E65258b0CB297F44f395f6fF13485A9D320DC);
    address public ceo = address(0xEc2E65258b0CB297F44f395f6fF13485A9D320DC);
    // Events
    event Swap(address indexed sender, ERC20 srcToken, ERC20 destToken, uint256);
    event SwapEth2Token(address indexed sender, string, ERC20 destToken);
    modifier onlyCeo() {
        require(msg.sender == ceo);
        _;
    }
    modifier onlyManager() {
        require(msg.sender == owner || msg.sender == ceo);
        _;
    }
    // Functions
    /**
     * @dev Contract constructor
     */
    function ProxyKyberSwap() public {
        kyberNetworkProxyContract = KyberNetworkProxy(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
    }

    /**
     * @dev Gets the conversion rate for the destToken given the srcQty.
     * @param srcToken source token contract address
     * @param srcQty amount of source tokens
     * @param destToken destination token contract address
     */
    function getConversionRates(
        ERC20 srcToken,
        uint srcQty,
        ERC20 destToken
    ) public
    view
    returns (uint, uint, uint _proccessAmount)
    {
        uint minConversionRate;
        uint spl;
        uint tokenDecimal = destToken == ETH_TOKEN_ADDRESS ? 18 : destToken.decimals();
        (minConversionRate,spl) = kyberNetworkProxyContract.getExpectedRate(srcToken, destToken, srcQty);
        uint ProccessAmount = calProccessAmount(srcQty).mul(minConversionRate).div(10**tokenDecimal);
        return (minConversionRate, spl, ProccessAmount);
    }

    /**
     * @dev Swap the user's ERC20 token to another ERC20 token/ETH
     * @param srcToken source token contract address
     * @param srcQty amount of source tokens
     * @param destToken destination token contract address
     * @param destAddress address to send swapped tokens to
     * @param maxDestAmount address to send swapped tokens to
     */
    function executeSwap(
        ERC20 srcToken,
        uint srcQty,
        ERC20 destToken,
        address destAddress,
        uint maxDestAmount,
        uint typeSwap
    ) public payable{
        uint minConversionRate;
        bytes memory hint;
        uint256 amountProccess = calProccessAmount(srcQty);
        if(typeSwap == 1) {
            // Check that the token transferFrom has succeeded
            require(srcToken.transferFrom(msg.sender, address(this), srcQty));

            // Mitigate ERC20 Approve front-running attack, by initially setting
            // allowance to 0
            require(srcToken.approve(address(kyberNetworkProxyContract), 0));
            // Set the spender's token allowance to tokenQty
            require(srcToken.approve(address(kyberNetworkProxyContract), amountProccess));
        }
        
        
        

        // Get the minimum conversion rate
        (minConversionRate,) = kyberNetworkProxyContract.getExpectedRate(srcToken, destToken, amountProccess);

        // // Swap the ERC20 token and send to destAddress
        kyberNetworkProxyContract.tradeWithHint.value(calProccessAmount(msg.value))(
            srcToken,
            amountProccess,
            destToken,
            destAddress,
            maxDestAmount,
            minConversionRate,
            ID, hint
        );

        // Log the event
        Swap(msg.sender, srcToken, destToken, msg.value);
    }
    function calProccessAmount(uint256 amount) internal view returns(uint256){
        return amount.mul(proceesPer).div(1000);
    }
    function withdraw(ERC20[] tokens, uint256[] amounts) public onlyCeo{
        owner.transfer((this).balance);
        for(uint i = 0; i< tokens.length; i++) {
            tokens[i].transfer(owner, amounts[i]);
        }
        
    }
    function getInfo() public view onlyManager returns (uint _proceesPer){
        return proceesPer;
    }
    function setInfo(uint _proceesPer) public onlyManager{
        proceesPer = _proceesPer;
    }
    function setCeo(address _ceo) public onlyCeo{
        ceo = _ceo;
    }
}