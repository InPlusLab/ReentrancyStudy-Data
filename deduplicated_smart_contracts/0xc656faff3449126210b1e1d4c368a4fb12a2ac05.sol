pragma solidity ^0.5.8;

import "./ERC20Pausable.sol";
import "./ERC20Detailed.sol";
import "./NTSToken.sol";

/**
 * @dev NTS 锁仓合约
 * 在代币上线后需要对25亿发行量中针对股东部分进行合约锁仓。
 * 锁仓规则：
 *   将指定量的代币转换给某账户，将在一个月后解锁 50%，随后分 6 个月解锁。
 */
contract NTSTokenTimeLock {
    address private owner;//合约创建者
    // 代码合约地址
    NTSToken public token;

    // 所有存在锁仓账户的持仓信息
    mapping(address=>Partner) public balances;
    // 锁仓伙伴
    address[] public partners;

    // 锁仓信息
    struct Partner {
        uint  initTokens;//初始 Token 量
        uint balance;//余额
        uint64 nextRelease ;//下次解锁时间timestamp
    }


    constructor(NTSToken _token)public{
        owner = msg.sender;
        token = _token;
    }

    modifier checkTime(uint64 _unlockTimestamp){
        //虽然矿工有能力根据需求调整时间戳， block.timestamp 可以由矿工操纵。
        //但是在我们的锁仓中矿工没有足够的动力来修改，忽略此风险。
        require(_unlockTimestamp > block.timestamp, "_onceUnlockTime must less at block.timestamp");
        _;
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"you are not contract owner");
        _;
    }

    /**
        @dev 设置锁仓条件，将资产锁定在指定账户。在锁仓前需要在 Token 合约上调用approve来允许 Token 转移。
        @param _unlockTimestamp 第一次解锁时间，不能晚于当前区块时间戳，注意时间是秒级的 UTC 时间戳。
        @param _partner 锁仓账户，不能为空地址
        @param _amount 锁仓金额，不能为 0，且不能超过 msg.sender 的余额
     */
    function lock(uint64 _unlockTimestamp,address _partner,uint _amount)
        public  onlyOwner() checkTime(_unlockTimestamp) returns (bool){
        addLock(_unlockTimestamp,_partner,_amount);
        return true;
    }

    /**
     * @dev 批量给多个账号锁仓，在锁仓前需要在 Token 合约上调用approve来允许 Token 转移。
        @param _unlockTimestamp 第一次解锁时间，不能晚于当前区块时间戳，注意时间是秒级的 UTC 时间戳。
        @param _partners 锁仓账户集合，不能为空地址
        @param _amounts  锁仓账户对应的锁仓金额，不能为 0
     */
    function lockBath(uint64 _unlockTimestamp,
    address[] memory _partners,
    uint[] memory _amounts) public onlyOwner() checkTime(_unlockTimestamp) returns(bool){
       require(_partners.length==_amounts.length,"items mismatch");
       for (uint i = 0; i < _partners.length; i++){
            addLock(_unlockTimestamp,_partners[i],_amounts[i]);
       }
       return true;
    }

    // 给单账户锁仓
    function addLock(uint64 _unlockTimestamp,address _partner,uint _amount) internal{
        require(_amount > 0, "no tokens to lock");
        require(_partner!=address(0),"the zero address");
        require(balances[_partner].initTokens==0, "already set partner position");

        //从发送者中转移 Token 到本合约
        bool ok = token.transferFrom(msg.sender,address(this),_amount);
        // 如果转账失败，则说明该账号没有足够的余额供使用，因此不需要额外检查是否足额。
        require(ok,"transfer token failed");
        balances[_partner] = Partner({
            initTokens: _amount,
            balance: _amount,
            nextRelease: _unlockTimestamp
        });
        partners.push(_partner);
    }

    /**
        @dev 释放已解锁 Token
     */
    function release() public {
        address to = msg.sender;
        Partner storage p = balances[to];
        require(p.balance > 0,"no tokens can release");
        //是有到了解锁时间，才能取
        require(p.nextRelease <= block.timestamp, "no yet time");

        uint  amount = 0;
        //如果是第一次解锁，则允许解锁 50%
        if (p.balance==p.initTokens){
           amount = p.initTokens/2;
        }else{
            //否则，每次只能解锁总量的 6 分之一
            // 第一次解锁一半后，剩余   p.initTokens/2
            // 而后续分6 给月解锁完毕，则每次解锁 6 分之一 等于 p.initTokens/2/6
            // 即 p.initTokens/12
            amount = p.initTokens/12;
        }
        // 安全检查与释放
        if(amount>p.balance){
            amount = p.balance;
        }
        bool ok = token.transfer(to, amount);
        require(ok,"transfer token failed");
        // 更新余额
        p.balance -= amount;
        // 更新下一次解锁时间
        // 1个月=31天x86400秒=2678400秒
        p.nextRelease += 2678400;
        //即使余额为 0，也不清理数据。
    }
}