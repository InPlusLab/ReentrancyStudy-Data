/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity ^0.4.24;



contract Forwarder {

    using SafeMath for *;



    string public name = "Forwarder";

    address private currentCorpBank1_ = 0xc95EFA676762BE92F70405B25214cd10616d0089;

    address private currentCorpBank2_ = 0xF29527437Eb2AE5Da10db32d49E27Cb22F04b875;

    address private currentCorpBank3_ = 0x19306Bfa01cB57A3F1E3CB80d2ACE2057661F41C;

    

    constructor() 

        public

    {

        //constructor does nothing.

    }

    

    function()

        public

        payable

    {

        // done so that if any one tries to dump eth into this contract, we can

        // just forward it to corp bank.

        if (currentCorpBank1_ != address(0) && currentCorpBank2_ != address(0) && currentCorpBank3_ != address(0))

            uint total = msg.value;

            uint div2 = (total/10).mul(3);

            uint div3 = (total/10).mul(4);

            uint div1 = (total.sub(div2)).sub(div3);

            currentCorpBank1_.transfer(div1);

            currentCorpBank2_.transfer(div2);

            currentCorpBank3_.transfer(div3);

    }

    

    function deposit()

        public 

        payable

        returns(bool)

    {

        require(msg.value > 0, "Forwarder Deposit failed - zero deposits not allowed");

        uint total = msg.value;

        uint div2 = (total/10).mul(3);

        uint div3 = (total/10).mul(4);

        uint div1 = (total.sub(div2)).sub(div3);

        currentCorpBank1_.transfer(div1);

        currentCorpBank2_.transfer(div2);

        currentCorpBank3_.transfer(div3);

        return(true);

    }



    function withdraw()

        public

        payable

    {

        require(msg.sender == currentCorpBank1_|| msg.sender == currentCorpBank2_ || msg.sender == currentCorpBank3_);

        uint total = address(this).balance;

        uint div2 = (total/10).mul(3);

        uint div3 = (total/10).mul(4);

        uint div1 = (total.sub(div2)).sub(div3);

        currentCorpBank1_.transfer(div1);

        currentCorpBank2_.transfer(div2);

        currentCorpBank3_.transfer(div3);

    }

}



library SafeMath {



    /**

    * @dev Multiplies two numbers, throws on overflow.

    */

    function mul(uint256 a, uint256 b)

        internal

        pure

        returns (uint256 c)

    {

        if (a == 0) {

            return 0;

        }

        c = a * b;

        require(c / a == b, "SafeMath mul failed");

        return c;

    }



    /**

    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b)

        internal

        pure

        returns (uint256)

    {

        require(b <= a, "SafeMath sub failed");

        return a - b;

    }



    /**

    * @dev Adds two numbers, throws on overflow.

    */

    function add(uint256 a, uint256 b)

        internal

        pure

        returns (uint256 c)

    {

        c = a + b;

        require(c >= a, "SafeMath add failed");

        return c;

    }



    /**

     * @dev gives square root of given x.

     */

    function sqrt(uint256 x)

        internal

        pure

        returns (uint256 y)

    {

        uint256 z = ((add(x,1)) / 2);

        y = x;

        while (z < y)

        {

            y = z;

            z = ((add((x / z),z)) / 2);

        }

    }



    /**

     * @dev gives square. multiplies x by x

     */

    function sq(uint256 x)

        internal

        pure

        returns (uint256)

    {

        return (mul(x,x));

    }



    /**

     * @dev x to the power of y

     */

    function pwr(uint256 x, uint256 y)

        internal

        pure

        returns (uint256)

    {

        if (x==0)

            return (0);

        else if (y==0)

            return (1);

        else

        {

            uint256 z = x;

            for (uint256 i=1; i < y; i++)

                z = mul(z,x);

            return (z);

        }

    }

}