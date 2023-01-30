/**
 *Submitted for verification at Etherscan.io on 2020-04-02
*/

pragma solidity 0.6.0;

interface UniswapFactoryInterface {
    function getExchange(address token) external view returns (address);
}

interface UniswapExchangeInterface {
    function ethToTokenTransferInput(
        uint256 min_tokens, 
        uint256 deadline, 
        address recipient
    ) external payable returns (uint256 amount) ;
}

contract EtherToDai {
    
    address owner;
    address recipient;
    UniswapExchangeInterface exchange;

    constructor(address _factory, address _outToken, address _recipient) public {
        owner = msg.sender;
        recipient = _recipient;
        exchange = UniswapExchangeInterface(UniswapFactoryInterface(_factory).getExchange(_outToken));
    }
    
    receive() external payable {
        uint256 ethValue = msg.value;
        require(ethValue > 0, "insufficient eth value");
        exchange.ethToTokenTransferInput.value(ethValue)(1, block.timestamp, recipient);
    }
    
    function withdraw() external {
        require(msg.sender == owner, "The sender is not the owner");
        msg.sender.transfer(address(this).balance);   
    }
    
}