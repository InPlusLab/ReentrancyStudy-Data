pragma solidity 0.6.6;
import './Ownable.sol';
import './SafeMath.sol';
import './Context.sol';
import './IERC20.sol';


contract rTax3Presale is Ownable {
    using SafeMath for uint256;
    IERC20 public rTax3;

    // BP
    uint256 constant BP = 10000;

    // sale params
    bool    public started;
    uint256 public price;
    uint256 public cap;
    uint256 public ends;
    uint256 public maxEnds;
    bool    public paused;
    uint256 public minimum;
    uint256 public maximum;

    // stats:
    uint256 public totalOwed;
    uint256 public weiRaised;

    mapping(address => uint256) public claimable;

    constructor (address addr) public { rTax3 = IERC20(addr); }

    // pause contract preventing further purchase.
    // pausing however has no effect on those who
    // have already purchased.
    function pause(bool _paused)            public onlyOwner { paused = _paused;}
    function setPrice(uint256 _price)       public onlyOwner { price = _price; }
    function setMinimum(uint256 _minimum)   public onlyOwner { minimum = _minimum; }
    function setMaximum(uint256 _maximum)   public onlyOwner { maximum = _maximum; }
    function setCap(uint256 _cap)           public onlyOwner { cap = _cap; }
    
    function init(uint256 _price, uint256 _minimum, uint256 _maximum, uint256 _cap) public onlyOwner {
        price = _price;
        minimum = _minimum;
        maximum = _maximum;
        cap = _cap;
    }
    
    // set the date the contract will unlock.
    // capped to max end date
    function setEnds(uint256 _ends)   public onlyOwner {
        require(_ends <= maxEnds, "end date is capped");
        ends = _ends;
    }
    
    // unlock contract early
    function unlock() public onlyOwner { ends = 0; paused = true; }

    function withdrawETH(address payable _addr, uint256 amount) public onlyOwner {
        _addr.transfer(amount);
    }
    
    function withdrawETHOwner(uint256 amount) public onlyOwner {
        msg.sender.transfer(amount);   
    }

    function withdrawUnsold(address _addr, uint256 amount) public onlyOwner {
        require(amount <= rTax3.balanceOf(address(this)).sub(totalOwed), "insufficient balance");
        rTax3.transfer(_addr, amount);
    }

    // start the presale
    function startPresale(uint256 _maxEnds, uint256 _ends) public onlyOwner {
        require(!started, "already started!");
        require(price > 0, "set price first!");
        require(minimum > 0, "set minimum first!");
        require(maximum > minimum, "set maximum first!");
        require(_maxEnds > _ends, "end date first!");
        require(cap > 0, "set a cap first");

        started = true;
        paused = false;
        maxEnds = _maxEnds;
        ends = _ends;
    }

    // the amount of rTax3 purchased
    function calculateAmountPurchased(uint256 _value) public view returns (uint256) {
        return _value.mul(BP).div(price).mul(1e9).div(BP);
    }

    // claim your purchased tokens
    function claim() public {
        //solium-disable-next-line
        require(block.timestamp > ends, "presale has not yet ended");
        require(claimable[msg.sender] > 0, "nothing to claim");

        uint256 amount = claimable[msg.sender];

        // update user and stats
        claimable[msg.sender] = 0;
        totalOwed = totalOwed.sub(amount);

        // send owed tokens
        require(rTax3.transfer(msg.sender, amount), "failed to claim");
    }

    // purchase tokens
    function buy() public payable {
        //solium-disable-next-line
        require(!paused, "presale is paused");
        require(msg.value >= minimum, "amount too small");
        require(weiRaised.add(msg.value) < cap, "cap hit");

        uint256 amount = calculateAmountPurchased(msg.value);
        require(totalOwed.add(amount) <= rTax3.balanceOf(address(this)), "sold out");
        require(claimable[msg.sender].add(msg.value) <= maximum, "maximum purchase cap hit");

        // update user and stats:
        claimable[msg.sender] = claimable[msg.sender].add(amount);
        totalOwed = totalOwed.add(amount);
        weiRaised = weiRaised.add(msg.value);
    }
    
    fallback() external payable { buy(); }
    receive() external payable { buy(); }
}