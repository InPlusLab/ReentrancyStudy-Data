/**

 *Submitted for verification at Etherscan.io on 2019-09-11

*/



pragma solidity ^0.5.9;



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

//  ercERC

contract ERC20 {

    function totalSupply() public view returns (uint supply);

    function balanceOf( address who ) public view returns (uint value);

    function allowance( address owner, address spender ) public view returns (uint _allowance);



    function transfer( address to, uint256 value) external;

    function transferFrom( address from, address to, uint value) public;

    function approve( address spender, uint value ) public returns (bool ok);



    event Transfer( address indexed from, address indexed to, uint value);

    event Approval( address indexed owner, address indexed spender, uint value);

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {

    int256 constant private INT256_MIN = -2**255;



    /**

    * @dev Multiplies two unsigned integers, reverts on overflow.

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

    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two unsigned integers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



// We can define a library for explicitly converting ``address``

// to ``address payable`` as a workaround.

library address_make_payable {

   function make_payable(address x) internal pure returns (address payable) {

      return address(uint160(x));

   }

}



//  Lending Data Contract

contract NEST_ToLoanDataContract {

    //  Add address

    function addContractAddress(address contractAddress) public;

    //  Check the contract address

    function checkContract(address contractAddress) public view returns (bool);

}



//  Mapping contract

contract IBMapping {

    //  Query address

	function checkAddress(string memory name) public view returns (address contractAddress);

	//  See if you have permission to modify

	function checkOwners(address man) public view returns (bool);

}



//  Lending and mining contracts

contract NEST_LoanMachinery {

    function startMining(address borrower, address lender, address token, uint256 interest, uint256 time) public payable;

}

//  Verification of price contracts

contract NEST_PriceCheck {

    //  Validation of loan contract price

    function checkContract(address borrowAddress, uint256 borrowAmount, address lenderAddress, uint256 lenderAmount, uint256 mortgageRate, uint256 limitdays,uint256 interestRate ) public view returns (bool);

}



//  Lending Factory Contract

contract NEST_LoanFactoryContract {

    

    using SafeMath for uint256;

    using address_make_payable for address;

    NEST_ToLoanDataContract dataContract;                   

    IBMapping mappingContract;                              

    mapping(uint256 => address) loanTokenAddress;           

    mapping(address => uint256) mortgageRate;               

    mapping(string => uint256) parameter;                   

    NEST_PriceCheck priceCheck;                             

    event ContractAddress(address contractAddress);

    

    constructor (address map) public {

        mappingContract = IBMapping(map);

        dataContract = NEST_ToLoanDataContract(address(mappingContract.checkAddress("toLoanData")));

        priceCheck = NEST_PriceCheck(address(mappingContract.checkAddress("priceCheck")));

        setupParameter();

    }

    function changeMapping(address map) public onlyOwner {

        mappingContract = IBMapping(map);

        dataContract = NEST_ToLoanDataContract(address(mappingContract.checkAddress("toLoanData")));

        priceCheck = NEST_PriceCheck(address(mappingContract.checkAddress("priceCheck")));

    }

    

    function setupParameter() private {

        parameter["borroweCommission"] = 5;

        parameter["lenderCommission"] = 10;

        

        mortgageRate[0x0000000000000000000000000000000000000000] = 50;

        mortgageRate[0x0000000000085d4780B73119b644AE5ecd22b376] = 40;

        mortgageRate[0xdAC17F958D2ee523a2206206994597C13D831ec7] = 40;

        mortgageRate[0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359] = 40;

        mortgageRate[0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2] = 40;

        mortgageRate[0x6f259637dcD74C767781E37Bc6133cd6A68aa161] = 40;

        mortgageRate[0xA4e8C3Ec456107eA67d3075bF9e3DF3A75823DB0] = 40;

        mortgageRate[0x0D8775F648430679A709E98d2b0Cb6250d2887EF] = 40;

        mortgageRate[0x6A27348483D59150aE76eF4C0f3622A78B0cA698] = 40;

        mortgageRate[0xd26114cd6EE289AccF82350c8d8487fedB8A0C07] = 40;

        

        loanTokenAddress[1] = address(0x0000000000085d4780B73119b644AE5ecd22b376);

        loanTokenAddress[2] = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);

        loanTokenAddress[3] = address(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);

        loanTokenAddress[4] = address(0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2);

        loanTokenAddress[5] = address(0x6f259637dcD74C767781E37Bc6133cd6A68aa161);

        loanTokenAddress[6] = address(0xA4e8C3Ec456107eA67d3075bF9e3DF3A75823DB0);

        loanTokenAddress[7] = address(0x0D8775F648430679A709E98d2b0Cb6250d2887EF);

        loanTokenAddress[8] = address(0x6A27348483D59150aE76eF4C0f3622A78B0cA698);

        loanTokenAddress[9] = address(0xd26114cd6EE289AccF82350c8d8487fedB8A0C07);

        

    }

    

    function changeTokenAddress(uint256 num, address addr) public onlyOwner {

        loanTokenAddress[num] = addr;

    }



    function changeMortgageRate(address addr, uint256 num) public onlyOwner {

        mortgageRate[addr] = num;

    }



    function changeParameter(string memory name, uint256 value) public onlyOwner {

        parameter[name] = value;

    }



    function checkParameter(string memory name) public view returns(uint256) {

        return parameter[name];

    }

    

    function checkToken(uint256 num) public view returns (address) {

        return loanTokenAddress[num];

    }

    

    modifier onlyOwner(){

        require(mappingContract.checkOwners(msg.sender) == true);

        _;

    }

    

    function isContract(address addr) public view returns (bool) {

        uint size;

        assembly { size := extcodesize(addr) }

        return size > 0;

    }

    

    function createContract(uint256 borrowerAmount, uint256 borrowerId, uint256 lenderAmount, uint256 lenderId, uint256 limitdays,uint256 interestRate) public {

        if (borrowerId == 0 || lenderId == 0) {

            address borrower = address(loanTokenAddress[borrowerId]);

            address lender = address(loanTokenAddress[lenderId]);

            require(priceCheck.checkContract(borrower, borrowerAmount, lender, lenderAmount, mortgageRate[borrower],limitdays, interestRate) == true);

        }

        NEST_LoanContract newContract = new NEST_LoanContract(borrowerAmount, borrowerId, lenderAmount, lenderId, limitdays,interestRate, address(mappingContract));

        dataContract.addContractAddress(address(newContract));

 

        emit ContractAddress(address(newContract));

    }



    function transferIntoMortgaged(address contractAddress) public payable {

        require(isContract(address(msg.sender)) == false);   

        require(dataContract.checkContract(address(contractAddress)) == true);

        NEST_LoanContract newContract = NEST_LoanContract(address(contractAddress));

        require(newContract.showContractState() == 0);      

        require(address(msg.sender) == newContract.checkBorrower());   

        if (newContract.checkContractType() == 1) {

            newContract.mortgagedAssets.value(msg.value)();                 

        } else {

            require(msg.value == 0);

            newContract.mortgagedAssets();                                      

        }

        

    }



    function investmentContracts(address contractAddress) public payable {

        require(isContract(address(msg.sender)) == false);   

        require(dataContract.checkContract(address(contractAddress)) == true);

        NEST_LoanContract newContract = NEST_LoanContract(address(contractAddress));

        require(newContract.showContractState() == 1);      

        if (newContract.checkContractType() == 2) {

            newContract.sendLendAsset.value(msg.value)();

        } else {

            require(msg.value == 0);

            newContract.sendLendAsset();            

        }

        

    }



    function sendRepayment(address contractAddress) public payable {

        require(isContract(address(msg.sender)) == false);   

        require(dataContract.checkContract(address(contractAddress)) == true);

        NEST_LoanContract newContract = NEST_LoanContract(address(contractAddress));

        require(address(msg.sender) == newContract.checkBorrower());   

        require(newContract.showContractState() == 2);      

        if (newContract.checkContractType() == 2) {

            newContract.sendRepayment.value(msg.value)();

        } else {

            require(msg.value == 0);

            newContract.sendRepayment();            

        }

    }

}



//  Loan contract

contract NEST_LoanContract {

    using SafeMath for uint256;

    using address_make_payable for address;

    ERC20 Token;        

    ERC20 lenderToken;  

    uint256 _contractState;     

    address _borrower;          

    address _lender;            

    uint256 _lenderAmount;      

    uint256 _timeLimit;         

    uint256 _interest;          

    uint256 _borrowerAmount;    

    uint256 _ibasset;           

    uint256 _commissionRate;    

    uint256 _investmentTime;    

    uint256 _endTime;           

    uint256 _borrowerPayable;   

    uint256 _expireDate;        

    uint256 _createTime;        

    IBMapping mappingContract;  

    uint256  contractType;      

    uint256 version = 2;        

    

    constructor (uint256 borrowerAmount, uint256 borrowerId, uint256 lenderAmount, uint256 lenderId, uint256 limitdays,uint256 interestRate,address map) public {

        require(isContract(address(tx.origin)) == false);   

        require(borrowerAmount > 0);

        require(limitdays > 0);

        require(interestRate > 0);

        require(lenderAmount > 0);

        require(borrowerId != lenderId);

        mappingContract = IBMapping(map);



        NEST_LoanFactoryContract factory = NEST_LoanFactoryContract(address(mappingContract.checkAddress("toLoanFactory")));

        require(address(msg.sender) == address(factory));               

        _borrower = tx.origin;                  

        _borrowerAmount = borrowerAmount;       

        _contractState = 0;                     

        _lenderAmount = lenderAmount;           

        _timeLimit = limitdays.mul(1 days);     

        _interest = interestRate;               

        _borrowerPayable = _lenderAmount.mul(interestRate.mul(limitdays).add(10000)).div(10000);

        require(_borrowerPayable > 0);           

        _createTime = now;                      

        

        setcontractType(borrowerId, lenderId);             

        

        

        

        if (contractType == 1) {

            _commissionRate = factory.checkParameter("borroweCommission");                      

            address tokenAddr = factory.checkToken(lenderId);

            require(tokenAddr != address(0x0000000000000000000000000000000000000000));

            lenderToken = ERC20(tokenAddr);

            _ibasset = _borrowerAmount.mul(_commissionRate).div(1000);                          

        } else if (contractType == 2) {

            _commissionRate = factory.checkParameter("lenderCommission");                      

            address tokenAddr = factory.checkToken(borrowerId);

            require(tokenAddr != address(0x0000000000000000000000000000000000000000));

            Token = ERC20(tokenAddr);

            _ibasset = _lenderAmount.mul(_commissionRate).div(1000);                          

        } else if (contractType == 3) {

            _commissionRate = 0;

            address tokenAddr = factory.checkToken(lenderId);

            require(tokenAddr != address(0x0000000000000000000000000000000000000000));

            lenderToken = ERC20(tokenAddr);

            address token = factory.checkToken(borrowerId);

            require(token != address(0x0000000000000000000000000000000000000000));

            Token = ERC20(token);

            _ibasset = 0;

        }

    }



    function setcontractType(uint256 borrowerId, uint256 lenderId) private {

        if (borrowerId == 0) {

            contractType = 1;

        } else if (lenderId == 0) {

            contractType = 2;

        } else {

            contractType = 3;

        }

    }

    

    function mortgagedAssets() public payable onlyBorrower onlyFactory {

        require(isContract(address(tx.origin)) == false);   

        require(showContractState() == 0);

        require(address(tx.origin) == _borrower);   

        if (contractType == 1) {

            require(msg.value == checkAllEth());

        } else {

            require(msg.value == 0);

            uint256 money = _borrowerAmount;

            require(Token.balanceOf(address(tx.origin)) >= money);

            require(Token.allowance(address(tx.origin), address(this)) >= money);

            Token.transferFrom(address(tx.origin),address(this),money);         

            require(Token.balanceOf(address(this)) >= _borrowerAmount);

        }

        _contractState = 1;

    }

    

    function sendRepayment() public payable onlyBorrower onlyFactory {

        require(isContract(address(tx.origin)) == false);   

        if (contractType == 2) {

            require(msg.value == _borrowerPayable);

            repayEth(address(_lender), msg.value);

            repayToken(address(_borrower), _borrowerAmount);

        } else {

            require(msg.value == 0);

            require(lenderToken.balanceOf(tx.origin) >= _borrowerPayable);

            require(lenderToken.allowance(address(tx.origin), address(this)) >= _borrowerPayable);

            lenderToken.transferFrom(address(tx.origin),_lender,_borrowerPayable);

            if (contractType == 1) {

                repayEth(address(_borrower), _borrowerAmount);

            } else if (contractType == 3) {

                repayToken(address(_borrower), _borrowerAmount);

            }

        }

        _contractState = 3;                                 

        _endTime = now;                                     

    }

 

    function sendLendAsset() public payable onlyFactory{

        require(isContract(address(tx.origin)) == false);   

        require(showContractState() == 1);

        _lender = tx.origin;                            

        _contractState = 2;                             

        _expireDate = now + _timeLimit;                 

        _investmentTime = now;                          

        serviceChargeMining();

    }

    

    function serviceChargeMining() private {

        if (contractType == 2) {

            NEST_LoanMachinery mining = NEST_LoanMachinery(mappingContract.checkAddress("toLoanBorrowMining"));

            require(_ibasset > 0);

            require(address(this).balance >= _lenderAmount);

            uint256 _lenderasset = _lenderAmount.sub(_ibasset);

            require(_lenderasset > 0);

            repayEth(address(_borrower),_lenderasset);

            mining.startMining.value(_ibasset)(_borrower, _lender, address(Token), _interest, _timeLimit.div(1 days));

        } else {

            NEST_LoanMachinery mining = NEST_LoanMachinery(mappingContract.checkAddress("toMortgageBorrowMining"));

            require(lenderToken.balanceOf(tx.origin) >= _lenderAmount);

            require(lenderToken.allowance(address(tx.origin), address(this)) >= _lenderAmount);

            lenderToken.transferFrom(address(tx.origin),_borrower,_lenderAmount);

            if (contractType == 1) {

                require(_ibasset > 0);

                mining.startMining.value(_ibasset)(_borrower, _lender, address(Token), _interest, _timeLimit.div(1 days));

            }

        }

    }

    

    function cancelContract() public onlyBorrower{

        require(isContract(address(tx.origin)) == false);   

        require(showContractState() == 1);

        if (contractType == 1) {

            if(address(this).balance > 0) {

                repayEth(_borrower,_borrowerAmount.add(_ibasset));

            }

        } else {

            if(Token.balanceOf(address(this)) > 0) {

                repayToken(_borrower, _borrowerAmount);

            }

        }

        _contractState = 0;                            

    }

    

    function applyForAssets() public onlyLender {

        require(isContract(address(tx.origin)) == false);   

        require(showContractState() == 4);              

        if (contractType == 1) {

            repayEth(_lender, _borrowerAmount);        

        } else {

            repayToken(_lender,_borrowerAmount);      

        }

        _contractState = 5;                             

        _endTime = now;                                 

    }

    

    function showContractState() public view returns(uint256) {

        if (_contractState == 2 && now >_expireDate){

            return 4;

        }

        return _contractState;

    }

    

    function repayEth(address accountAddress, uint256 asset) internal {

        address payable addr = accountAddress.make_payable();

        addr.transfer(asset);

    }



    function repayToken(address accountAddress, uint256 asset) internal {

        Token.transfer(accountAddress, asset);

    }

    

    function checkLender() public view returns (address) {

        return _lender;

    }



    function checkBorrower() public view returns (address) {

        return _borrower;

    }



    function checkAllEth()public view returns (uint256) {

        uint256 amount = _borrowerAmount.mul(_commissionRate).div(1000);

        return _borrowerAmount.add(amount);

    }



    function checkContractType()public view returns (uint256) {

        return contractType;

    }



    modifier onlyBorrower(){

        require(address(tx.origin) == _borrower);

        _;

    }



    modifier onlyLender(){

        require(address(tx.origin) == _lender);

        _;

    }

    

    modifier onlyFactory(){

        require(address(mappingContract.checkAddress("toLoanFactory")) == address(msg.sender));

        _;

    }



    function getContractInfo() public view returns(

    uint256 state,

    address borrowerAddress,

    address investorAddress,

    uint256 amount,

    uint256 cycle,

    uint256 interest,

    uint256 mortgage,

    uint256 investmentTime,

    uint256 endtime,

    uint256 borrowerPayable,

    uint256 expiryTime,

    uint256 createTime,

    uint256 ibasset) {

        return (

        showContractState(),

        _borrower,

        _lender,

        _lenderAmount,

        _timeLimit,

        _interest,

        _borrowerAmount,

        _investmentTime,

        _endTime,

        _borrowerPayable,

        _expireDate,

        _createTime,

        _ibasset);

    }



    function getTokenInfo() public view returns (

        uint256 _contractType,

        address borrowerToken,

        address _lenderToken

        ) {

            return (

                contractType,

                address(Token),

                address(lenderToken)

                );

    }

    

    function checkVersion() public view returns(uint256) {

        return version;

    }

    

    function isContract(address addr) public view returns (bool) {

        uint size;

        assembly { size := extcodesize(addr) }

        return size > 0;

    }

    

}