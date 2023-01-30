/**

 *Submitted for verification at Etherscan.io on 2018-12-03

*/



pragma solidity ^0.4.24;



// https://github.com/ethereum/EIPs/issues/20

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



interface KyberProxy {

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty)

        external view

        returns(uint expectedRate, uint slippageRate);

}



contract PTToDaiConversionRate {

    function recordImbalance(

        ERC20 token,

        int buyAmount,

        uint rateUpdateBlock,

        uint currentBlock

    )

        public {

            // do nothing

        }



    function getRate(ERC20 token, uint currentBlockNumber, bool buy, uint qty) public view returns(uint) {

        if(token != 0x094c875704c14783049DDF8136E298B3a099c446) return 0;

        if(buy) return 0;

        



        uint slippageRate;

        uint expectedRate;

        (expectedRate,slippageRate) = KyberProxy(0x818E6FECD516Ecc3849DAf6845e3EC868087B755).

                getExpectedRate(ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE),

                                ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359),

                                (10**17 * qty) / 10**18);

        return 1005 * (10**18 * 10**18/ expectedRate) / 1000;

    }    

}