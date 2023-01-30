/**
 *Submitted for verification at Etherscan.io on 2020-11-18
*/

pragma solidity 0.6.8;


// SPDX-License-Identifier: MIT


library SafeMath128{

    //Custom addition
    function safemul(uint128 a, uint128 b) internal pure returns (uint128) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint128 c = a * b;
        if(!(c / a == b)){
            c = (2**128)-1;
        }

        return c;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath104 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint112 a, uint112 b) internal pure returns (uint112) {
        uint112 c = a + b;
        if(!(c >= a)){
            c = (2**112)-1;
        }
        require(c >= a, "addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint112 a, uint112 b) internal pure returns (uint112) {
        if(!(b <= a)){
            return 0;
        }
        uint112 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint112 a, uint112 b) internal pure returns (uint112) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint112 c = a * b;
        if(!(c / a == b)){
            c = (2**112)-1;
        }

        return c;
    }


    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint112 a, uint112 b) internal pure returns (uint112) {
        require(b > 0, "div by zero");
        uint112 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Caller is not the owner");
        _;
    }
    
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}

//Restrictions:
//only 2^32 Users
//Maximum of 2^104 / 10^18 Ether investment. Theoretically 20 Trl Ether, practically 100000000000 Ether compiles
//Maximum of (2^104 / 10^18 Ether) investment. Theoretically 20 Trl Ether, practically 100000000000 Ether compiles
contract PrestigeClub is Ownable() {

    using SafeMath104 for uint112;
    using SafeMath128 for uint128;

    struct User {
        uint112 deposit; //265 bits together
        uint112 payout;
        uint32 position;
        uint8 qualifiedPools;
        uint8 downlineBonus;
        address referer;
        address[] referrals;

        uint112 directSum;
        uint40 lastPayout;

        uint112[5] downlineVolumes;
    }
    
    event NewDeposit(address indexed addr, uint112 amount);
    event PoolReached(address indexed addr, uint8 pool);
    event DownlineBonusStageReached(address indexed adr, uint8 stage);
    
    event Payout(address indexed addr, uint112 interest, uint112 direct, uint112 pool, uint112 downline, uint40 dayz); 
    
    event Withdraw(address indexed addr, uint112 amount);
    
    mapping (address => User) public users;
    address[] public userList;

    uint32 public lastPosition;
    
    uint128 public depositSum;
    
    Pool[8] public pools;
    
    struct Pool {
        uint112 minOwnInvestment;
        uint8 minDirects;
        uint112 minSumDirects;
        uint8 payoutQuote; //ppm
        uint32 numUsers;
    }

    PoolState[] public states;

    struct PoolState {
        uint128 totalDeposits;
        uint32 totalUsers;
        uint32[8] numUsers;
    }
    
    DownlineBonusStage[4] downlineBonuses;
    
    struct DownlineBonusStage {
        uint32 minPool;
        uint64 payoutQuote; //ppm
    }
    
    uint40 public pool_last_draw;
    
    constructor() public {
 
        uint40 timestamp = uint40(block.timestamp);
        pool_last_draw = timestamp - (timestamp % payout_interval) - (2 * payout_interval);


        pools[0] = Pool(3 ether, 1, 3 ether, 130, 0);
        pools[1] = Pool(15 ether, 3, 5 ether, 130, 0);
        pools[2] = Pool(15 ether, 4, 44 ether, 130, 0);
        pools[3] = Pool(30 ether, 10, 105 ether, 130, 0);
        pools[4] = Pool(45 ether, 15, 280 ether, 130, 0);
        pools[5] = Pool(60 ether, 20, 530 ether, 130, 0);
        pools[6] = Pool(150 ether, 20, 1470 ether, 80, 0);
        pools[7] = Pool(300 ether, 20, 2950 ether, 80, 0);

        downlineBonuses[0] = DownlineBonusStage(3, 50);
        downlineBonuses[1] = DownlineBonusStage(4, 100);
        downlineBonuses[2] = DownlineBonusStage(5, 160);
        downlineBonuses[3] = DownlineBonusStage(6, 210);

        userList.push(address(0));
        
    }
    
    uint112 internal minDeposit = 1 ether;
    uint112 internal minWithdraw = 1000 wei; 
    
    uint40 constant internal payout_interval = 1 days;
    
    function recieve() public payable {
        require((users[msg.sender].deposit * 20 / 19) >= minDeposit || msg.value >= minDeposit, "Mininum deposit value not reached");
        
        address sender = msg.sender;

        uint112 value = uint112(msg.value).mul(19) / 20;

        bool userExists = users[sender].position != 0;
        
        triggerCalculation();

        // Create a position for new accounts
        if(!userExists){
            lastPosition++;
            users[sender].position = lastPosition;
            users[sender].lastPayout = (pool_last_draw + 1);
            userList.push(sender);
        }

        address referer = users[sender].referer; //can put outside because referer is always set since setReferral() gets called before recieve() in recieve(address)

        if(referer != address(0)){
            updateUpline(sender, referer, value);
        }

        //Update Payouts
        if(userExists){
            updatePayout(sender);
        }

        users[sender].deposit = users[sender].deposit.add(value);
        
        //Transfer fee
        payable(owner()).transfer(msg.value - value);
        
        emit NewDeposit(sender, value);
        
        updateUserPool(sender);
        updateDownlineBonusStage(sender);
        if(referer != address(0)){
            users[referer].directSum = users[referer].directSum.add(value);

            updateUserPool(referer);
            updateDownlineBonusStage(referer);
        }
        
        depositSum = depositSum + value; //Won´t do an overflow since value is uint112 and depositSum 128

    }
    
    
    function recieve(address referer) public payable {
        
        _setReferral(referer);
        recieve();
        
    }

    uint8 public downlineLimit = 31;

    function updateUpline(address reciever, address adr, uint112 addition) private {
        
        address current = adr;
        uint8 bonusStage = users[reciever].downlineBonus;
        
        uint8 downlineLimitCounter = downlineLimit - 1;
        
        while(current != address(0) && downlineLimitCounter > 0){

            updatePayout(current);

            users[current].downlineVolumes[bonusStage] = users[current].downlineVolumes[bonusStage].add(addition);
            uint8 currentBonus = users[current].downlineBonus;
            if(currentBonus > bonusStage){
                bonusStage = currentBonus;
            }

            current = users[current].referer;
            downlineLimitCounter--;
        }
        
    }
    
    function updatePayout(address adr) private {
        
        uint40 dayz = (uint40(block.timestamp) - users[adr].lastPayout) / (payout_interval);
        if(dayz >= 1){
            
            uint112 interestPayout = getInterestPayout(adr);
            uint112 poolpayout = getPoolPayout(adr, dayz);
            uint112 directsPayout = getDirectsPayout(adr);
            uint112 downlineBonusAmount = getDownlinePayout(adr);
            
            
            uint112 sum = interestPayout.add(directsPayout).add(downlineBonusAmount); 
            sum = (sum.mul(dayz)).add(poolpayout);
            
            users[adr].payout = users[adr].payout.add(sum);
            users[adr].lastPayout += (payout_interval * dayz);
            
            emit Payout(adr, interestPayout, directsPayout, poolpayout, downlineBonusAmount, dayz);
            
        }
    }
    
    function getInterestPayout(address adr) public view returns (uint112){
        //Calculate Base Payouts
        uint8 quote;
        uint112 deposit = users[adr].deposit;
        if(deposit >= 30 ether){
            quote = 15;
        }else{
            quote = 10;
        }
        
        return deposit.mul(quote) / 10000;
    }
    
    function getPoolPayout(address adr, uint40 dayz) public view returns (uint112){

        uint40 length = (uint40)(states.length);

        uint112 poolpayout = 0;

        if(users[adr].qualifiedPools > 0){
            for(uint40 day = length - dayz ; day < length ; day++){


                uint32 numUsers = states[day].totalUsers;
                uint112 streamline = uint112(states[day].totalDeposits.safemul(numUsers - users[adr].position)).div(numUsers);


                uint112 payout_day = 0; //TODO Merge into poolpayout, only for debugging
                uint32 stateNumUsers = 0;
                for(uint8 j = 0 ; j < users[adr].qualifiedPools ; j++){
                    uint112 pool_base = streamline.mul(pools[j].payoutQuote) / 1000000;

                    stateNumUsers = states[day].numUsers[j];

                    if(stateNumUsers != 0){
                        payout_day += pool_base.div(stateNumUsers);
                    }
                }

                poolpayout = poolpayout.add(payout_day);

            }
        }
        
        return poolpayout;
    }

    function getDownlinePayout(address adr) public view returns (uint112){

        //Calculate Downline Bonus
        uint112 downlinePayout = 0;
        
        uint8 downlineBonus = users[adr].downlineBonus;
        
        if(downlineBonus > 0){
            
            uint64 ownPercentage = downlineBonuses[downlineBonus - 1].payoutQuote;

            for(uint8 i = 0 ; i < downlineBonus; i++){

                uint64 quote = 0;
                if(i > 0){
                    quote = downlineBonuses[i - 1].payoutQuote;
                }else{
                    quote = 0;
                }

                uint64 percentage = ownPercentage - quote;
                if(percentage > 0){ //Requiring positivity and saving gas for 0, since that returns 0

                    downlinePayout = downlinePayout.add(users[adr].downlineVolumes[i].mul(percentage) / 1000000); 

                }

            }

            if(downlineBonus == 4){
                downlinePayout = downlinePayout.add(users[adr].downlineVolumes[downlineBonus].mul(50) / 1000000);
            }

        }

        return downlinePayout;
        
    }

    function getDirectsPayout(address adr) public view returns (uint112) {
        
        //Calculate Directs Payouts
        uint112 directsDepositSum = users[adr].directSum;

        uint112 directsPayout = directsDepositSum.mul(5) / 10000;

        return (directsPayout);
        
    }

    function pushPoolState() private {
        uint32[8] memory temp;
        for(uint8 i = 0 ; i < 8 ; i++){
            temp[i] = pools[i].numUsers;
        }
        states.push(PoolState(depositSum, lastPosition, temp));
        pool_last_draw += payout_interval;
    }
    
    function updateUserPool(address adr) private {
        
        if(users[adr].qualifiedPools < pools.length){
            
            uint8 poolnum = users[adr].qualifiedPools;
            
            uint112 sumDirects = users[adr].directSum;
            
            //Check if requirements for next pool are met
            if(users[adr].deposit >= pools[poolnum].minOwnInvestment && users[adr].referrals.length >= pools[poolnum].minDirects && sumDirects >= pools[poolnum].minSumDirects){
                users[adr].qualifiedPools = poolnum + 1;
                pools[poolnum].numUsers++;
                
                emit PoolReached(adr, poolnum + 1);
                
                updateUserPool(adr);
            }
            
        }
        
    }
    
    function updateDownlineBonusStage(address adr) private {

        uint8 bonusstage = users[adr].downlineBonus;

        if(bonusstage < downlineBonuses.length){

            //Check if requirements for next stage are met
            if(users[adr].qualifiedPools >= downlineBonuses[bonusstage].minPool){
                users[adr].downlineBonus += 1;
                
                //Update data in upline
                uint112 value = users[adr].deposit;  //Value without current stage, since that must not be subtracted

                for(uint8 i = 0 ; i <= bonusstage ; i++){
                    value = value.add(users[adr].downlineVolumes[i]);
                }

                uint8 currentBonusStage = bonusstage + 1;
                uint8 lastBonusStage = bonusstage;

                address current = users[adr].referer;
                while(current != address(0)){

                    
                    users[current].downlineVolumes[lastBonusStage] = users[current].downlineVolumes[lastBonusStage].sub(value);
                    users[current].downlineVolumes[currentBonusStage] = users[current].downlineVolumes[currentBonusStage].add(value);

                    uint8 currentDB = users[current].downlineBonus;
                    if(currentDB > currentBonusStage){
                        currentBonusStage = currentDB;
                    }
                    if(currentDB > lastBonusStage){
                        lastBonusStage = currentDB;
                    }

                    if(lastBonusStage == currentBonusStage){
                        break;
                    }

                    current = users[current].referer;
                }

                emit DownlineBonusStageReached(adr, users[adr].downlineBonus);
                
                updateDownlineBonusStage(adr);
            }
        }
        
    }
    
    function calculateDirects(address adr) external view returns (uint112, uint32) {
        
        address[] memory referrals = users[adr].referrals;
        
        uint112 sum = 0;
        for(uint32 i = 0 ; i < referrals.length ; i++){
            sum = sum.add(users[referrals[i]].deposit);
        }
        
        return (sum, (uint32)(referrals.length));
        
    }
    
    //Endpoint to withdraw payouts
    function withdraw(uint112 amount) public {
        
        updatePayout(msg.sender);

        require(amount > minWithdraw, "Minimum Withdrawal amount not met");
        require(users[msg.sender].payout >= amount, "Not enough payout available");
        
        uint112 transfer = amount * 19 / 20;
        
        users[msg.sender].payout -= amount;
        
        payable(msg.sender).transfer(transfer);
        
        payable(owner()).transfer(amount - transfer);
        
        emit Withdraw(msg.sender, amount);
        
    }

    function _setReferral(address referer) private {
        
        if(users[msg.sender].referer == referer){
            return;
        }
        
        if(users[msg.sender].position != 0 && users[msg.sender].position < users[referer].position) {
            return;
        }
        
        require(users[msg.sender].referer == address(0), "Referer can only be set once");
        require(users[referer].position > 0, "Referer does not exist");
        require(msg.sender != referer, "Cant set oneself as referer");
        
        users[referer].referrals.push(msg.sender);
        users[msg.sender].referer = referer;

        if(users[msg.sender].deposit > 0){
            users[referer].directSum = users[referer].directSum.add(users[msg.sender].deposit);
        }
        
    }
    
    
    function invest(uint amount) public onlyOwner {
        
        payable(owner()).transfer(amount);
    }
    
    function reinvest() public payable onlyOwner {
    }
    
    function setLimits(uint112 _minDeposit, uint112 _minWithdrawal) public onlyOwner {
        minDeposit = _minDeposit;
        minWithdraw = _minWithdrawal;
    }

    function setDownlineLimit(uint8 limit) public onlyOwner {
        downlineLimit = limit;
    }

    //Only for BO
    function getDownline() external view returns (uint112, uint){
        uint112 sum;
        for(uint8 i = 0 ; i < users[msg.sender].downlineVolumes.length ; i++){
            sum += users[msg.sender].downlineVolumes[i];
        }

        uint numUsers = getDownlineUsers(msg.sender);

        return (sum, numUsers);
    }

    function getDownlineUsers(address adr) public view returns (uint128){

        uint128 sum = 0;
        uint32 length = uint32(users[adr].referrals.length);
        sum += length;
        for(uint32 i = 0; i < length ; i++){
            sum += getDownlineUsers(users[adr].referrals[i]);
        }
        return sum;
    }
    
    function reCalculateImported(uint64 from, uint64 to) public onlyOwner {
        uint40 time = pool_last_draw + 1;
        for(uint64 i = from ; i < to + 1 ; i++){
            address adr = userList[i];
            users[adr].payout = 0;
            users[adr].lastPayout = time;
            updatePayout(adr);
        }
    }
    
    function _import(address[] memory sender, uint112[] memory deposit, address[] memory referer) public onlyOwner {
        for(uint64 i = 0 ; i < sender.length ; i++){
            importUser(sender[i], deposit[i], referer[i]);
        }
    }
    
    function importUser(address sender, uint112 deposit, address referer) internal onlyOwner {
        
        if(referer != address(0)){
            users[referer].referrals.push(sender);
            users[sender].referer = referer;
        }

        uint112 value = deposit;

        // Create a position for new accounts
        lastPosition++;
        users[sender].position = lastPosition;
        users[sender].lastPayout = pool_last_draw;
        userList.push(sender);

        if(referer != address(0)){
            updateUpline(sender, referer, value);
        }

        users[sender].deposit += value;
        
        emit NewDeposit(sender, value);
        
        updateUserPool(sender);
        updateDownlineBonusStage(sender);
        
        if(referer != address(0)){
            users[referer].directSum += value;
    
            updateUserPool(referer);
            updateDownlineBonusStage(referer);
        }
        
        depositSum += value;
        
    }

    function getUserReferrals(address adr) public view returns (address[] memory referrals){
        return users[adr].referrals;
    }
    
    function getUserList() public view returns (address[] memory){  
        return userList;
    }
    
    function triggerCalculation() public {
        if(block.timestamp > pool_last_draw + payout_interval){
            pushPoolState();
        }
    }
}