/**
 *Submitted for verification at Etherscan.io on 2020-01-10
*/

pragma solidity ^0.4.26;

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}
contract ProxyKyberSwap {

    function executeSwap(
        ERC20 srcToken,
        uint srcQty,
        ERC20 destToken,
        address destAddress,
        uint maxDestAmount,
        uint typeSwap
    ) public payable ;
    function getConversionRates(
        ERC20 srcToken,
        uint srcQty,
        ERC20 destToken
    ) public view returns (uint, uint, uint _proccessAmount);
}
contract CPProxy {
    function mint(uint256 mintAmount) public;
    function redeemUnderlying(uint256 redeemAmount) public returns (uint);
    function redeem(uint256 redeemTokens) public returns (uint);
    function exchangeRateStored() public view returns (uint);
}
contract TOMORROWPRICE is Ownable{
    using SafeMath for uint256;
    ProxyKyberSwap public proxyKyberSwap = ProxyKyberSwap(0xa7112b46BfEec68B2044b33E36b9cF83ADdF107A);
    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    ERC20 constant internal DAI_TOKEN_ADDRESS = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    ERC20 constant internal cDAI_TOKEN_ADDRESS = ERC20(address(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643));
    CPProxy public CPProxyContract = CPProxy(address(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643));

    //    address private ID = address(0xEc2E65258b0CB297F44f395f6fF13485A9D320DC);
    //    address public ceo = address(0xEc2E65258b0CB297F44f395f6fF13485A9D320DC);
    address private ID = address(0xEc2E65258b0CB297F44f395f6fF13485A9D320DC);
    address public ceo = address(0x3B8a67Ad64160e0b977B6dD877e0fB98878aB902);
    mapping(address => uint256) public usersBalance;
    struct partner {
        uint256 totalDeposit;
        uint256 totalCDAI;
        mapping(address => uint256) users;
    }
    struct award {
        bool isSet;
        uint256 totalAmount;
        address[] members;
    }
    struct awardRanking {
        bool isSet;
        uint256 totalAmount;
        address[] members;
        uint[] percens;
    }
    mapping(uint256 => award) public awards;
    uint public currentAward;
    mapping(uint256 => awardRanking) public awardRankings;
    // mapping(uint256 => awardpartner) public awardpartners;
    uint256 public totalDeposit;
    uint256 public totalAward;
    uint256 public minAward = 100 finney;
    uint256 public maxAward = 1 ether;
    uint256 public seeResultFee = 100 finney;
    uint256[] public seeResultFeePercent = [7000, 3000];
    uint256 public totalAwardSystem;
    uint256 public totalAwardRanking;
    uint256 public totalAwardPartner;
    uint[] public percenRanking = [200, 100, 50, 20, 20, 20, 20, 20, 20, 20];
    mapping(address => partner) public partners;
    address[] public partnerArr = [0x464591071CDf3ba9Cbf5915b5f79C6c0D7B089F0, 0x6E1ec1585E7b0E1Ed2Da4e04372CD6F916C24Da6];
    uint public partnerPercent = 2500;
    uint public latestDatePartnerAward;
    uint public periodPartnerAward =  86400; // 604800; 7 ngay;
    // Events
    event _deposit(address _sender, uint256 _numDAI);
    event _withdraw(address _sender, uint256 _numDAI);
    event _setAward(uint256 _awardId, address[] _members, uint256 _userAward);
    event _setAwardRanking(uint256 _awardId, address[] _members, uint[] _amounts);
    event _setAwardPartner(uint256 _weekId, address _partner, uint256 _amounts);
    event _pay2seeResult(address _sender, address _user, uint256 _userAmount, uint256 _sysAmount);
    modifier onlyCeo() {
        require(msg.sender == ceo);
        _;
    }
    modifier onlyManager() {
        require(msg.sender == owner || msg.sender == ceo);
        _;
    }

    /**
     * @dev Contract constructor
     */
    constructor() public {}
    function getConversionRates(
        ERC20 _srcToken,
        uint srcQty,
        ERC20 destToken
    ) public view returns (uint, uint, uint _proccessAmount) {
        return proxyKyberSwap.getConversionRates(_srcToken, srcQty, destToken);
    }
    function config(uint256 _minAward, uint256 _maxAward) public onlyManager{
        minAward = _minAward;
        maxAward = _maxAward;
    }
    function configPercenRanking( uint[] _percenRanking) public onlyManager{
        percenRanking = _percenRanking;
    }
    function configSeeResultFee(uint256 _seeResultFee, uint[] _seeResultFeePercent) public onlyManager{
        seeResultFee = _seeResultFee;
        seeResultFeePercent = _seeResultFeePercent;
    }
    function configPartner(uint _partnerPercent, address[] _partners, uint _periodPartnerAward) public onlyManager{
        partnerPercent = _partnerPercent;
        partnerArr = _partners;
        periodPartnerAward = _periodPartnerAward;
    }

    function depositEth(address _partner) public payable {
        uint256 minConversionRate;
        (minConversionRate,,) = proxyKyberSwap.getConversionRates(ETH_TOKEN_ADDRESS, msg.value, DAI_TOKEN_ADDRESS);
        uint256 processAmount = msg.value <= 1 ether ? minConversionRate : minConversionRate.mul(msg.value).div(1 ether);
        proxyKyberSwap.executeSwap.value(msg.value)(
            ETH_TOKEN_ADDRESS,
            msg.value,
            DAI_TOKEN_ADDRESS,
            address(this),
            processAmount,
            0
        );
        uint256 _numDAI = DAI_TOKEN_ADDRESS.balanceOf(address(this));
        processCP(_numDAI, _partner);
    }
    function depositDai(uint256 _numDAI, address _partner) public {
        require(DAI_TOKEN_ADDRESS.transferFrom(msg.sender, address(this), _numDAI));
        processCP(_numDAI, _partner);
    }
    function depositToken(
        ERC20 srcToken,
        uint srcQty, address _partner) public {
        require(srcToken != DAI_TOKEN_ADDRESS);
        uint256 minConversionRate;
        uint256 decimal = 10**srcToken.decimals();
        (minConversionRate,,) = proxyKyberSwap.getConversionRates(srcToken, srcQty, DAI_TOKEN_ADDRESS);
        uint256 processAmount = srcQty <= decimal ? minConversionRate : minConversionRate.mul(srcQty).div(decimal);
        require(srcToken.transferFrom(msg.sender, address(this), srcQty));
        srcToken.approve(address(proxyKyberSwap), srcQty);
        proxyKyberSwap.executeSwap(
            srcToken,
            srcQty,
            DAI_TOKEN_ADDRESS,
            address(this),
            processAmount,
            1
        );
        uint256 _numDAI = DAI_TOKEN_ADDRESS.balanceOf(address(this));
        processCP(_numDAI, _partner);
    }
    function processCP(uint256 _numDAI, address _partner) internal{
        DAI_TOKEN_ADDRESS.approve(address(CPProxyContract), _numDAI);
        CPProxyContract.mint(_numDAI);
        updateBalance(_numDAI, _partner);
    }
    function updateBalance(uint256 _numDAI, address _partner) internal {
        usersBalance[msg.sender] = usersBalance[msg.sender].add(_numDAI);
        totalDeposit = totalDeposit.add(_numDAI);
        if(_partner != address(0)) {
            partners[_partner].totalDeposit = partners[_partner].totalDeposit.add(_numDAI);
            partners[_partner].totalCDAI = partners[_partner].totalCDAI.add(DAI2cDAI(_numDAI));
        }
        emit _deposit(msg.sender, _numDAI);
    }
    function exchangeRateStored() public view returns (uint){
        return CPProxyContract.exchangeRateStored();
    }
    function getPartnerArr() public view returns (address[] _partners){
        return partnerArr;
    }
    function getPSeeResultFeePercent() public view returns (uint[] _seeResultFeePercen){
        return seeResultFeePercent;
    }
    function getPercenRanking() public view returns (uint[] _percenRanking){
        return percenRanking;
    }
    function DAI2cDAI(uint256 _numDAI) public view returns (uint256){
        return _numDAI.mul(10**18).div(exchangeRateStored());
    }
    function cDAI2DAI(uint256 _numcDAI) public view returns (uint256){
        return _numcDAI.mul(exchangeRateStored()).div(10**18);
    }
    function balanceOfcDai() public view returns (uint256){
        return cDAI_TOKEN_ADDRESS.balanceOf(address(this));
    }
    function balanceOfDai() public view returns (uint256){
        return balanceOfcDai().mul(exchangeRateStored()).div(10**18);
    }
    function withdrawByUser(uint _numDAI, address _partner) public {
        require(usersBalance[msg.sender] >= _numDAI);
        uint CPResult = CPProxyContract.redeem(DAI2cDAI(_numDAI));

        if(CPResult == 0) {
            DAI_TOKEN_ADDRESS.transfer(msg.sender, _numDAI);
            usersBalance[msg.sender] -= _numDAI;
            totalDeposit -= _numDAI;
            emit _withdraw(msg.sender, _numDAI);
        } else {
            uint CPResult1 = CPProxyContract.redeemUnderlying(DAI2cDAI(_numDAI));
            if(CPResult1 == 0) {
                DAI_TOKEN_ADDRESS.transfer(msg.sender, _numDAI);
                usersBalance[msg.sender] -= _numDAI;
                totalDeposit -= _numDAI;
                emit _withdraw(msg.sender, _numDAI);
            }
        }
        if(_partner != address(0)) {
            partners[_partner].totalDeposit = partners[_partner].totalDeposit.sub(_numDAI);
            partners[_partner].totalCDAI = partners[_partner].totalCDAI.sub(DAI2cDAI(_numDAI));
        }
    }
    function withdrawETHByUser(uint _numDAI, address _partner) public {
        require(usersBalance[msg.sender] >= _numDAI);
        uint CPResult = CPProxyContract.redeem(DAI2cDAI(_numDAI));

        if(CPResult == 0) {
            proccessWDToken(_numDAI, ETH_TOKEN_ADDRESS);
        } else {
            uint CPResult1 = CPProxyContract.redeemUnderlying(DAI2cDAI(_numDAI));
            if(CPResult1 == 0) {
                proccessWDToken(_numDAI, ETH_TOKEN_ADDRESS);
            }
        }
        if(_partner != address(0)) {
            partners[_partner].totalDeposit = partners[_partner].totalDeposit.sub(_numDAI);
            partners[_partner].totalCDAI = partners[_partner].totalCDAI.sub(DAI2cDAI(_numDAI));
        }
    }
    function withdrawTokenByUser(uint _numDAI, ERC20 destToken, address _partner) public {
        require(usersBalance[msg.sender] >= _numDAI);
        uint CPResult = CPProxyContract.redeem(DAI2cDAI(_numDAI));

        if(CPResult == 0) {
            proccessWDToken(_numDAI, destToken);
        } else {
            uint CPResult1 = CPProxyContract.redeemUnderlying(DAI2cDAI(_numDAI));
            if(CPResult1 == 0) {
                proccessWDToken(_numDAI, destToken);
            }
        }
        if(_partner != address(0)) {
            partners[_partner].totalDeposit = partners[_partner].totalDeposit.sub(_numDAI);
            partners[_partner].totalCDAI = partners[_partner].totalCDAI.sub(DAI2cDAI(_numDAI));
        }
    }
    function proccessWDToken(uint _numDAI, ERC20 destToken) internal {
        uint256 minConversionRate;
        (minConversionRate,,) = proxyKyberSwap.getConversionRates(DAI_TOKEN_ADDRESS, _numDAI, destToken);
        uint256 processAmount = _numDAI <= 1 ether ? minConversionRate : minConversionRate.mul(_numDAI).div(1 ether);
        DAI_TOKEN_ADDRESS.approve(address(proxyKyberSwap), _numDAI);
        proxyKyberSwap.executeSwap.value(msg.value)(
            DAI_TOKEN_ADDRESS,
            _numDAI,
            destToken,
            msg.sender,
            processAmount,
            1
        );
        usersBalance[msg.sender] -= _numDAI;
        totalDeposit -= _numDAI;
        emit _withdraw(msg.sender, _numDAI);
    }
    function __withdraw(uint256 amount) internal {
        require(address(this).balance >= amount);
        if(amount > 0) {
            msg.sender.transfer(amount);
        }
    }
    function withdraw(uint256 _ethAmount, ERC20[] memory _tokens, uint256[] memory _tokenAdmounts) public onlyCeo {
        require(_tokens.length == _tokenAdmounts.length);
        __withdraw(_ethAmount);
        for(uint256 i = 0; i < _tokens.length; i++) {
            ERC20 erc20 = ERC20(_tokens[i]);
            erc20.transfer(msg.sender, _tokenAdmounts[i]);
        }

    }
    function setCeo(address _ceo) public onlyCeo{
        ceo = _ceo;
    }
    function checkInterest() public view returns(uint256){
        uint256 interest = balanceOfDai().sub(totalDeposit);
        uint256 commission;
        for(uint8 i; i < partnerArr.length; i++){
            uint256 interest1 = cDAI2DAI(partners[i].totalCDAI).sub(partners[i].totalDeposit);
            commission += interest1.sub(interest1.mul(partnerPercent).div(10000));

        }
        return interest.sub(commission);
    }
    function setAward(uint256 _awardId, address[] _members) public onlyCeo{
        require(!awards[_awardId].isSet && _awardId > 0);
        uint256 _amount = currentAward == 0 ? minAward : (_awardId - currentAward) * minAward;
        _amount = _amount < maxAward ? _amount : maxAward;
        if(checkInterest() < _amount) {
            require(DAI_TOKEN_ADDRESS.transferFrom(msg.sender, address(this), _amount), "not enough DAI balance");
            DAI_TOKEN_ADDRESS.approve(address(CPProxyContract), _amount);
            CPProxyContract.mint(_amount);
        }

        totalDeposit += _amount;
        totalAward += _amount;
        for(uint256 i = 0; i< _members.length; i++) {
            usersBalance[_members[i]] += _amount.div(_members.length);
        }

        awards[_awardId] = award(true, _amount, _members);
        currentAward = _awardId;
        emit _setAward(_awardId, _members, _amount);
    }
    function getAward(uint256 _awardId) public view returns(bool isSet, uint256 totalAmount, address[] members) {
        return (awards[_awardId].isSet, awards[_awardId].totalAmount, awards[_awardId].members);
    }
    function setAwardRanking(uint256 _awardId, address[] _members) public onlyCeo{
        // decimal = 10000
        require(!awardRankings[_awardId].isSet && _members.length <= percenRanking.length, "_awardId ready seted or wrong member list");
        uint256 interest = balanceOfDai().sub(totalDeposit);
        uint256 total;
        for(uint256 i = 0; i< _members.length; i++) {
            uint256 amount = interest.mul(percenRanking[i]).div(10000);
            usersBalance[_members[i]] += amount;
            total += amount;
        }

        totalAwardRanking += total;
        awardRankings[_awardId] = awardRanking(true, total, _members, percenRanking);
        emit _setAwardRanking(_awardId, _members, percenRanking);
    }
    function setAwardPartner(uint256 _weekId) public onlyCeo{
        // decimal = 10000
        require(latestDatePartnerAward == 0 || _weekId - latestDatePartnerAward >= periodPartnerAward);
        require(_weekId < now);

        for(uint8 i; i < partnerArr.length; i++){
            uint256 interest = cDAI2DAI(partners[i].totalCDAI).sub(partners[i].totalDeposit);
            uint256 profit = interest.mul(partnerPercent).div(10000);
            usersBalance[partnerArr[i]] = usersBalance[partnerArr[i]].add(profit);
            totalAwardPartner = totalAwardPartner.add(profit);
            // awardpartners[_weekId] = awardpartner(true, profit);
            partners[partnerArr[i]].totalCDAI = DAI2cDAI(partners[partnerArr[i]].totalDeposit);
            emit _setAwardPartner(_weekId, partnerArr[i], profit);

        }
        latestDatePartnerAward = _weekId;
    }
    function getAwardRanking(uint256 _awardId) public view returns(bool isSet, uint256 totalAmount, address[] members) {
        return (awards[_awardId].isSet, awards[_awardId].totalAmount, awards[_awardId].members);
    }
    function checkAwardPartner(address _partner) public view returns(uint256 _totalDeposit, uint256 _totalCDAI, uint256 _interest) {
        return (partners[_partner].totalDeposit, partners[_partner].totalCDAI, cDAI2DAI(partners[_partner].totalCDAI).sub(partners[_partner].totalDeposit));
    }
    function pay2seeResult(address _user) public {
        require(DAI_TOKEN_ADDRESS.transferFrom(msg.sender, address(this), seeResultFee), "not enough DAI balance");
        uint256 sysAmount = seeResultFee.mul(seeResultFeePercent[0]).div(10000);
        uint256 userAmount = seeResultFee.mul(seeResultFeePercent[1]).div(10000);
        DAI_TOKEN_ADDRESS.transfer(ceo, sysAmount);
        DAI_TOKEN_ADDRESS.transfer(_user, userAmount);
        emit _pay2seeResult(msg.sender, _user, userAmount, sysAmount);
    }
}