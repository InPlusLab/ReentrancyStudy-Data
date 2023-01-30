/**

 *Submitted for verification at Etherscan.io on 2019-03-27

*/



pragma solidity ^0.5.6;



/*****************************************************************************

*                *******E-MajDeals IPBO Smart Contract******                 *

*                *******************************************                 *

*                                                                            *

*                *****HuaQin Technology (China) Limited*****                 *

*                                                                            *

*                Sector: Home appliance, manufacturing and trade             *

*                Date of Foundation: 2011.11.28                              *

*                HQ Address:                                                 *

*                No.218 GongNong East Street, YanHu                          *

*                YunCheng, ShanXi, China                                     *

*                Telephone: +86 18503598913                                  *

*                Website: http://huaqinkeji.cn/3g/index.php                  *

*                CEO: Haiyang Zhang                                          *

*                COO: Qing Cai                                               *

*                CFO: Lewis Chou                                             *

*                Shares Emited: 10,000,000 HQS                               *

*                Initial Share Price (in EMDS): 0.15 EMDS                    *

*                Minimum buyable Shares: 500 HQS                             *

*                Maximum buyable Shares: 10,000,000 HQS                      *

*                                                                            *

*  Brief Description: Huaqin Technology (China) Limited is a sino-foreign    *

*  joint venture. Its headquarter is in yuncheng, Shanxi Province. It is an  *

*  innovative technology enterprise focusing on both artificial intelligence *

*  as well as research and development of environmental technology. "Live    *

*  for health" is Huaqin¡¯s product concept. It is the vision of Huaqin       *

*  company to make products with geek spirit and let everyone enjoy health.  *

*                                                                            *

*****************************************************************************/



/*****************************************************************************

*                        Safemath Library                                    *

*                        to prevent Over / Underflow                         *

*****************************************************************************/

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) { c = a + b; assert(c >= a); return c; }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) { assert(b <= a); return a - b; }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) { if (a == 0){return 0;} c = a * b; assert(c / a == b); return c; }

    function div(uint256 a, uint256 b) internal pure returns (uint256) { assert(b > 0); return a / b; }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) { assert(b != 0); return a % b;}

}



/*****************************************************************************

*                   Centralized Ownership Contract                           *

*                    for authorization Control                               *

*****************************************************************************/

contract Ownable { 

    address private _owner;

    constructor () internal { _owner = msg.sender; }

    function owner() public view returns (address) { return _owner; }

    function isOwner() public view returns (bool) { return msg.sender == _owner; }

    modifier onlyOwner() { require(isOwner()); _; }

}



/*****************************************************************************

*                       The E-MajDeals IPBO Contract                         *

*                       for HuaQin Technology (China) Limited                *

*****************************************************************************/

contract IPBO_HuaQin_Technology is Ownable {

    using SafeMath for uint256;

    

    uint256 private _availableShares;

    uint256 private _sharesRate;

    uint8 private _decimals;

    uint256 private _bottomCap;

    uint256 private _topCap;

    mapping(address => uint256) private _sharesOf;

    address private _EMDSAddress;

    //---------------------------------------------------------------

    string private _companyName;

    string private _companySector;

    string private _companyHQAddress;

    string private _companyTelephone;

    string private _companyWebsite;

    string private _companyDescription;

    string private _companySeniorStaff;

    uint private _companyFoundationDate;

    uint private _companySharesEmited;

    

    event ShareTransfer(address _beneficiary, uint256 value, uint256 _sharesAmount);



    constructor(address EMDSAddress) public{

        _companyName = "HuaQin Technology (China) Limited";

        _companySector = "Home appliance manufacturing and trade";

        _companyFoundationDate = 20111128;

        _companyHQAddress = "NO.218 GongNong East Street, YanHu, YunCheng, ShanXi, China";

        _companyTelephone = "+8618503598913";

        _companyWebsite = "http://huaqinkeji.cn/3g/index.php";

        _companyDescription = "Huaqin Technology (China) Limited is a sino-foreign joint venture. Its headquarter is in yuncheng, Shanxi Province. It is an innovative technology enterprise focusing on both artificial intelligence as well as research and development of environmental technology. \"Live for health\" is Huaqin¡¯s product concept. It is the vision of Huaqin company to make products with geek spirit and let everyone enjoy health.";

        _companySeniorStaff = "-CEO: Haiyang Zhang -COO: Qing Cai -CFO: Lewis Chou";

        _companySharesEmited = 10000000*10**uint256(_decimals);

        //---------------------------------------------------------------

        _EMDSAddress = EMDSAddress;

        _decimals = 18;

        _availableShares = _companySharesEmited*10**uint256(_decimals);

        _sharesRate = 150*10**uint256(_decimals-3);

        _bottomCap = 500*10**uint256(_decimals);

        _topCap = _companySharesEmited;

        _sharesOf[msg.sender] = _availableShares;

    }

    

    function updateRate(uint256 newRate) public onlyOwner{ _sharesRate = newRate; }

    function _getSharesAmount(uint256 value) internal view returns (uint256) { return (value.mul(10**uint256(_decimals))).div(_sharesRate); }

    function sharesOf(address target) public view returns (uint256) { return _sharesOf[target]; }

    function availableShares() public view returns (uint256) { return _availableShares; }

    function sharesRate() public view returns (uint256) { return _sharesRate; }



    //--------------------------------------Revisar----------------------------------------    

    

    function _prevalidatePurchase(address beneficiary, uint256 sharesAmount) internal view returns (bool){

        require(sharesAmount >= _bottomCap && sharesAmount <= _topCap);

        require(_availableShares.sub(sharesAmount) >= 0);

        require(_sharesOf[beneficiary].add(sharesAmount) <= _topCap);

        return true;

    }

    

    function _processPurchase(address from, uint256 sharesAmount) internal returns (bool){

        _availableShares = _availableShares.sub(sharesAmount);

        _sharesOf[from] = _sharesOf[from].add(sharesAmount);

        return true;

    }

    

    function contractFallback(address from, uint256 value, address contractAddress) external returns (bool){

        require(_EMDSAddress == contractAddress);

        uint256 sharesAmount = _getSharesAmount(value);

        _prevalidatePurchase(from, sharesAmount);

        _processPurchase(from, sharesAmount);

        emit ShareTransfer(from, value, sharesAmount);

        return true;

    }

    

    function getCompanyName() public view returns (string memory){return _companyName;}

    function getCompanySector() public view returns (string memory){return _companySector;}

    function getCompanyHQAddress() public view returns (string memory){return _companyHQAddress;}

    function getCompanyTelephone() public view returns (string memory){return _companyTelephone;}

    function getCompanyWebsite() public view returns (string memory){return _companyWebsite;}

    function getCompanyDescription() public view returns (string memory){return _companyDescription;}

    function getCompanySeniorStaff() public view returns (string memory){return _companySeniorStaff;}

    function getCompanyFoundationDate() public view returns (uint){return _companyFoundationDate;}

    function getCompanySharesEmited() public view returns (uint){return _companySharesEmited;}

}