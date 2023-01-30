pragma solidity 0.5.0;

import "./SafeMath.sol"; 
import "./SuperGlobalToken.sol";
import "./Ownable.sol";
import "./SuperGlobalReferral.sol";
import "./oraclizeAPI.sol";


contract SuperGlobalTokensale is Ownable ,usingOraclize  {
    using SafeMath for uint256;
    SuperGlobalToken public token;
    SuperGlobalReferral public referral;
    address payable public wallet;
    uint256 public _weiRaised;
    
    uint256 public ETHUSD ;
    
    uint256 weiFactor = 10 ** 18;
    uint256 ethForOracle = 2000000000000000;

   
    event LogConstructorInitiated(string nextStep);
    event LogPriceUpdated(string price);
    event LogNewOraclizeQuery(string description);
    event TokensSold(address beneficiary , uint256 amount);

    function ExampleContract()public payable {
        emit LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Provable Query.");
    }

    function __callback(bytes32 myid, string memory result) public {
        if (msg.sender != oraclize_cbAddress()) revert();
        ETHUSD = parseInt(result);
        emit LogPriceUpdated(result);
        updatePrice();
    }

    function updatePrice()public  payable {
        if (oraclize_getPrice("URL") > address(this).balance) {
            emit LogNewOraclizeQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } else {
           emit LogNewOraclizeQuery("Provable query was sent, standing by for the answer..");
            oraclize_query(1800, "URL", "json(https://api.pro.coinbase.com/products/ETH-USD/ticker).price");
        }
    
    }
    
     constructor ( address payable _wallet, SuperGlobalToken _token, SuperGlobalReferral _referral) public {
        require(_wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(_token) != address(0), "Crowdsale: token is the zero address");
        wallet = _wallet;
        token = _token;
        referral = _referral;
    }
    

    
    function getTokenPrice() public view returns(uint256) {
        uint256 supply = token.totalSupply();
        if (supply <= 1000) {
            return 1000 * weiFactor;
        }
        else if (supply <= 2000) {
            return 1500 * weiFactor;
        }
        else if (supply <= 3000) {
            return 2000 * weiFactor;
        }
        else if (supply <= 4000) {
            return 2500 * weiFactor;
        }
        else if (supply <= 5000) {
            return 3000 * weiFactor;
        }
        else {
            return 1;
        }
    }
    
    
    function buyToken(address beneficiary, uint256 _amount, string memory _investorCode) public payable {
        uint256 weiAmount = msg.value - ethForOracle;
        uint256 usdAmount = weiAmount * ETHUSD;
        
        uint256 flag = _preValidatePurchase(weiAmount, _investorCode);
        
        for (uint i = 0; i < _amount; i++) {
            uint256 tokenPrice = getTokenPrice();
            require(tokenPrice != 1, "All tokens have been sold");
            
            require(usdAmount >= tokenPrice, "Price of the token is higher than the ether sent.");
            
            usdAmount -= tokenPrice;
            
            _deliverTokens(beneficiary, 1);
            
            if (flag == 0) {
                address payable master = referral.getMasterAddress(_investorCode);
                bool isMasterValid = referral.isMasterValid(_investorCode);
                uint256 masterPercent = referral.getMasterPercent(_investorCode);
            
                uint256 walletPercent = 100 - masterPercent;
            
                uint256 weiToken = tokenPrice / ETHUSD;
            
                if (isMasterValid) {
                    uint256 masterWei = (weiToken / 100) * masterPercent;
                    master.transfer(masterWei);
                } else {
                    walletPercent += masterPercent;
                }
            
                wallet.transfer((weiToken / 100) * walletPercent);
                
            } else if (flag == 1) {
                address payable master = referral.getMasterWithSlaveAddress(_investorCode);
                address payable slave = referral.getSlaveAddress(_investorCode);
                
                bool isMasterValid = referral.isMasterWithSlaveValid(_investorCode);
                bool isSlaveValid = referral.isSlaveValid(_investorCode);
                
                uint256 masterPercent = referral.getMasterWithSlavePercent(_investorCode);
                uint256 slavePercent = referral.getSlavePercent(_investorCode);
            
                uint256 walletPercent = 100 - slavePercent - masterPercent;
            
                uint256 weiToken = tokenPrice / ETHUSD;
                
                if (isMasterValid) {
                    uint256 masterWei = (weiToken / 100) * masterPercent;
                    master.transfer(masterWei);
                    
                    if (isSlaveValid) {
                        uint256 slaveWei = (weiToken / 100) * slavePercent;
                        slave.transfer(slaveWei);
                    } else {
                        walletPercent += slavePercent;
                    }
                    
                } else {
                    walletPercent += masterPercent;
                    walletPercent += slavePercent;
                }
            
                wallet.transfer((weiToken / 100) * walletPercent);
            }
        }
        
        emit TokensSold(beneficiary , _amount);
        
        _weiRaised = _weiRaised.add(weiAmount);
        
        uint256 weiToReturn = usdAmount / ETHUSD;
        msg.sender.transfer(weiToReturn);
    }
    function setWallet(address payable _wallet) public onlyOwner {
        wallet = _wallet;
    }
    
    function setETHPrice(uint256 price) public onlyOwner{
        require(price !=0 );
        
        ETHUSD = price;
    }
    
    function withdrawFunds() external onlyOwner {
        wallet.transfer(address(this).balance);
    }
    function _preValidatePurchase(uint256 weiAmount, string memory _investorCode) internal view returns(uint256 flag) {
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");

        if (referral.getMasterIndexByInvestorCode(_investorCode) != 0) {
            flag = 0;
        }
        
        else if (referral.getMasterWithSlaveIndexByInvestorCode(_investorCode) != 0) {
            flag = 1;
        }
        
        else {
            revert();
        }
    }
    function _deliverTokens(address beneficiary, uint256 _amount) internal {
        token.mint(beneficiary, _amount);
    }
}



