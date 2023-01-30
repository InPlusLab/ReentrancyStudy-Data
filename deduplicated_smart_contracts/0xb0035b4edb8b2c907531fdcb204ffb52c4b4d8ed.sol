pragma solidity ^0.5.7;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./ERC20Burnable.sol";

 
contract Token is ERC20, ERC20Detailed, ERC20Burnable {
    uint8 public constant DECIMALS = 18;
    // uint256 public constant INIT_SUPPLY = 10000000000 * (10 ** uint256(DECIMALS));
     
    // address private constant ADDR_TOKEN_SWAP = address(0x1234);
    // address private constant ADDR_OPERATION = address(0x1234);
    // address private constant ADDR_REWARD = address(0x1234);
    // address private constant ADDR_TEAM = address(0x1234);
    // address private constant ADDR_PARTNER = address(0x1234);
    
    // 2019.06.01 ~ 2021.12.01.
    uint[31] private TIME_TABLE = [ 1559347200,
        1561939200, 1564617600, 1567296000, 1569888000, 1572566400, 1575158400, 
        1577836800, 1580515200, 1583020800, 1585699200, 1588291200, 1590969600, 
        1593561600, 1596240000, 1598918400, 1601510400, 1604188800, 1606780800,
        1609459200, 1612137600, 1614556800, 1617235200, 1619827200, 1622505600, 
        1625097600, 1627776000, 1630454400, 1633046400, 1635724800, 1638316800];
        
    
    // event Mint(address indexed to, uint256 amount);
    // event FininshedMint();

    struct TimeMint {
        address beneficiary;
        uint256 releaseTime;
        uint256 value;
    }
    
    TimeMint[] timeMintList;

    address owner;
    bool mintingAvail = true;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier canMint() {
        require(mintingAvail);
        _;
    }

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("HAMA token", "HAMA", DECIMALS) {
        
        // All tokens will provide by insertTimeMintTimeTable
        // _mint(msg.sender, INITIAL_SUPPLY);
        owner = msg.sender;
        // _initMintScheuld();
    }
    
    /**
     * @dev Initialize supplying tokens. But This code occuers an error: out of gas
     */
    // function _initMintScheuld() internal{
        // insertTimeMint(ADDR_TOKEN_SWAP, TIME_TABLE[0], 1500000000);
        // insertTimeMint(ADDR_TOKEN_SWAP, TIME_TABLE[2], 200000000);
        // insertTimeMint(ADDR_TOKEN_SWAP, TIME_TABLE[3], 100000000);
        // insertTimeMint(ADDR_TOKEN_SWAP, TIME_TABLE[4], 300000000);
        // insertTimeMint(ADDR_TOKEN_SWAP, TIME_TABLE[5], 100000000);
        // insertTimeMint(ADDR_TOKEN_SWAP, TIME_TABLE[6], 300000000);
        // insertTimeMint(ADDR_TOKEN_SWAP, TIME_TABLE[7], 100000000);
        // insertTimeMint(ADDR_TOKEN_SWAP, TIME_TABLE[8], 300000000);
        // insertTimeMint(ADDR_TOKEN_SWAP, TIME_TABLE[9], 100000000);
        // insertTimeMint(ADDR_TOKEN_SWAP, TIME_TABLE[10], 300000000);
        // insertTimeMint(ADDR_TOKEN_SWAP, TIME_TABLE[11], 100000000);
        // insertTimeMint(ADDR_TOKEN_SWAP, TIME_TABLE[12], 100000000);
        
        // for (uint i=0; i<10; i+=3) {
        //     insertTimeMint(ADDR_OPERATION, TIME_TABLE[i], 375000000);
        // }
        
        // insertTimeMint(ADDR_REWARD, TIME_TABLE[0], 3000000000);
        
        // for (uint i=7; i<25; i++) {
        //     insertTimeMint(ADDR_TEAM, TIME_TABLE[i], 38920000);
        // }
        
        // for (uint i=0; i<25; i+=3) {
        //     insertTimeMint(ADDR_PARTNER, TIME_TABLE[i], 162500000);
        // }
    // }

    /**
     * @dev Getting the number of release tokens schedules.
     */
    function getTimeTimeLength() view public returns(uint256) {
        return timeMintList.length;
    }

    /**
     * @dev Getting the number of release tokens schedules.
     */
    function getTimeTimeMint(uint index) view public returns(address, uint256, uint256) {
        return (timeMintList[index].beneficiary, timeMintList[index].releaseTime, timeMintList[index].value);
    }

    /**
     * @dev Insert a minting tokens schedule. This method use index of TimeTable instead of timestamp.
     */
    function insertTimeMintTimeTable(address _beneficiary, uint256 index, uint256 _value) onlyOwner canMint public returns (bool){
        require(_beneficiary != address(0));
        require(index >= 0 && index < TIME_TABLE.length, "insertTimeMint: index out of range");
        return insertTimeMint(_beneficiary, TIME_TABLE[index], _value);
    }
    
    /**
     * @dev Insert a minting tokens schedule.
     */
    function insertTimeMint(address _beneficiary, uint256 _releaseTime, uint256 _value) onlyOwner canMint public returns (bool){
        require(_beneficiary != address(0));
        require(_releaseTime > block.timestamp, "TokenTimelock: release time is before current time");
        TimeMint memory item = TimeMint({
            beneficiary: _beneficiary,
            releaseTime: _releaseTime,
            value: _value
        });
        timeMintList.push(item);
        return true;
    }
    
    /**
     * @dev Remove a minting tokens schedule with index. The timeMintList length reduce one because "delete" is set value to empty.
     */
    function removeTimeMint(uint index) onlyOwner canMint public returns (bool){
        require(index >= 0 && index < timeMintList.length, "removeTimeMint: index out of range.");
        timeMintList[index] = timeMintList[timeMintList.length-1];
        delete timeMintList[timeMintList.length-1];
        timeMintList.length--;
        return true;
    }
    
 /**
     * @dev Releasing tokens any scheduled over release Time.
     */
    function releaseTimeMintToken() onlyOwner canMint public returns (bool) {
        require(timeMintList.length > 0);
        uint i = 0;
        while (i < timeMintList.length) {
            if (block.timestamp >= timeMintList[i].releaseTime) {           // 0. if True
                if (_mintForTime(timeMintList[i])) {                        // 1. Mining according to timeMintList[i].
                    timeMintList[i] = timeMintList[timeMintList.length-1];  // 2.  Note: timeMintList[timeMintList.length-1] is timeMintList[i] NOW !!
                    delete timeMintList[timeMintList.length-1];
                    timeMintList.length--;
                    continue;   // To solve the problem.
                }
            }
            i++;    // 3. BUT we skipped the check of timeMintList[i](i.e. timeMintList[timeMintList.length-1]) with `i++`, 
        }
    }
    
    function _mintForTime(TimeMint memory item) onlyOwner canMint private returns (bool) {
        require(block.timestamp >= item.releaseTime, "TokenTimelock: current time is before release time");
        _mint(item.beneficiary, item.value);
        // emit Mint(item.beneficiary, item.value);
        return true;
    }
    
    /**
     * @dev block mint function.
     */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingAvail = false;
        // emit FininshedMint();
        return true;
    }

}