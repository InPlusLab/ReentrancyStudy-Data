/**

 *Submitted for verification at Etherscan.io on 2018-11-24

*/



pragma solidity ^0.4.24;



/* MZT1_userpic is part of Mizhen family that players can design their own user icon.

 */

contract MZBoss {

    uint256 constant internal magnitude = 1e18; // related to payoutsTo_, profitPershare_, profitPerSharePot_, profitPerShareNew_

    mapping(address => int256) internal payoutsTo_;

    uint256 public tokenSupply_ = 0; // total sold tokens 

    uint256 public profitPerShare_ = 0 ;

    uint256 public _totalProfitPot = 0;

    address constant internal _communityAddress = 0x43e8587aCcE957629C9FD2185dD700dcDdE1dD1E;

    /**

     * profit distribution from game pot

     */

    function potDistribution()

        public

        payable

    {

        //

        uint256 _incomingEthereum = msg.value;

        if(tokenSupply_ > 0){

            

            // profit per share 

            uint256 profitPerSharePot_ = SafeMath.mul(_incomingEthereum, magnitude) / (tokenSupply_);

            

            // update profitPerShare_, adding profit from game pot

            profitPerShare_ = SafeMath.add(profitPerShare_, profitPerSharePot_);

            

        } else {

            // send to community

            payoutsTo_[_communityAddress] -=  (int256) (_incomingEthereum);

            

        }

        

        //update _totalProfitPot

        _totalProfitPot = SafeMath.add(_incomingEthereum, _totalProfitPot); 

    }

} 



contract MZT1_userpic {



    mapping (address => mapping (uint256 => uint256)) public blockColor_; 

    address constant public _MZBossAddress = 0x16d29707a5F507f9252Ae5b7fc5E86399725C663;

    address constant public _communityAddress = 0x43e8587aCcE957629C9FD2185dD700dcDdE1dD1E;



    uint256 constant public designFee_ = 3e17; // 0.3 ether to design

    mapping (address => bool) public design_;



	modifier designFeeCheck(){ 

        uint256 _incomingEthereum = msg.value;

        address _customerAddress = msg.sender;

        require((_incomingEthereum >= designFee_) || (designRight(_customerAddress)));

        _;

    }

    

    // fired whenever a player set color

    event onSetColor

    (

        address indexed playerAddress,

        uint256[] ColorSetID,

        uint256[] ColorSetColor

    );

	



	function setPicColor(uint256[] blockIDArray_, uint256[] blockColorArray_) 

	    designFeeCheck()

        public

        payable

    {

        address _customerAddress = msg.sender;

        uint256 _incomingEthereum =msg.value;

        

        if(_incomingEthereum > 0){

            uint256 toCommunity = _incomingEthereum/2;

            uint256 toMZBoss = _incomingEthereum/2;

            

            // sent to MZBoss and community address

            sendPotProfit(toMZBoss);

            _communityAddress.transfer(toCommunity); 

        }



        for (uint i = 0; i < blockIDArray_.length; i++) {

        blockColor_[_customerAddress][blockIDArray_[i]] = blockColorArray_[i];

        }

        

        design_[_customerAddress] = true;

        

        emit onSetColor(_customerAddress, blockIDArray_, blockColorArray_);

    }

    

    function designRight(address _customerAddress)

        public

        view

        returns(bool)

    {

        return design_[_customerAddress];

    }

    

    function display(address _customerAddress)

        public

        view

        returns(uint256[], uint256[])

    {

        uint256[] memory IDArray_ = new uint256[](64);

        uint256[] memory colorArray_ = new uint256[](64);

        

        for (uint i = 0; i < 64; i++) {

            IDArray_[i] = i;

            colorArray_[i] = blockColor_[_customerAddress][i];

            

        }

        return (IDArray_, colorArray_);

    }

    

    /* send eth to MZBoss

	 *

	 */

	function sendPotProfit(uint256 valueToSend)

	    internal

	{

		

		MZBoss m = MZBoss(_MZBossAddress);

		m.potDistribution.value(valueToSend)();

	}

   

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



    /**

    * @dev Multiplies two numbers, throws on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    /**

    * @dev Integer division of two numbers, truncating the quotient.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;

    }



    /**

    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    /**

    * @dev Adds two numbers, throws on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}