pragma solidity ^0.5.0;

import "./Tradable.sol";
import "./DateTime.sol";

contract StableCoin is Tradable, DateTime{

    using SafeMath for uint256;

    uint8 _dec = uint8(Tradable.decimals_t);

    event oxydated(address holder, uint amount);
    event timestampComparaison0(uint256 t1, uint256 t2);

    constructor(string memory _tokenName, string memory _tokenSymbol, uint8 _decimals) payable
        ERC20(_tokenName, _tokenSymbol, _decimals)
        public {
           // require(msg.value > 0.009 ether, "Need more than 0.01 Ether to deploy");
    }

    function transfer(address _to, uint256 _value) public returns (bool){
        ERC20.transfer(_to, _value);
        Tradable.storeNewHolder(msg.sender, _to);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        ERC20.transferFrom(_from,_to,_value);
        Tradable.storeNewHolder(_from, _to);
    }

    function approve(address _spender, uint256 _value) public returns  (bool){
        ERC20.approve(_spender, _value);
    }

    function mint(address _to, uint _tokenAmount) public onlyOwner {
        _mint(_to,_tokenAmount);
        Tradable.storeNewHolder(address(0), _to);
    }

    function burn(address _account, uint256 _value) public onlyOwner {
        _burn(_account, _value);
        Tradable.storeNewHolder(address(0), _account);
    }

    function getBalanceEthSmartContract() public view returns (uint256) {
        return address(this).balance;
    }

    function retrieveEth(uint amount) public onlyOwner returns (bool){
        msg.sender.transfer(amount);
        return true;
    }

    function oxydation() public {
        for(uint i = 0 ; i < currentHolders.length ; i++) {
            emit timestampComparaison0(lastUsed[currentHolders[i]] + 21600, now);
            if(lastUsed[currentHolders[i]] + 21600 < now){   // more than 6 hours
                emit timestampComparaison0(lastOxydation[currentHolders[i]] + 86400, now);
                if(lastOxydation[currentHolders[i]] + 86400 < now) {  // more than 1 day
                    uint balanceCurrent = balanceOf(currentHolders[i]);
                    lastOxydation[currentHolders[i]] = now;
                    _burn(currentHolders[i], balanceCurrent/5000);  // 0.02%
                    _mint(Ownable.owner(), balanceCurrent/5000);
                    emit oxydated(currentHolders[i], balanceCurrent/5000);
                }
            }
        }
    }
}
