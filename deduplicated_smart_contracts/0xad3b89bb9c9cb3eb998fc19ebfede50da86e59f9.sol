/**

 *Submitted for verification at Etherscan.io on 2019-01-28

*/



/**

 * 

 *  MIT License

 *  

 *  Copyright (c) 2018 Vladimir Khramov

 *  

 *  Permission is hereby granted, free of charge, to any person obtaining a copy

 *  of this software and associated documentation files (the "Software"), to deal

 *  in the Software without restriction, including without limitation the rights

 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

 *  copies of the Software, and to permit persons to whom the Software is

 *  furnished to do so, subject to the following conditions:

 *  

 *  The above copyright notice and this permission notice shall be included in all

 *  copies or substantial portions of the Software.

 *  

 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE

 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

 *  SOFTWARE.

 */



pragma solidity ^0.4.17;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {

      return 0;

    }

    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



contract AtomicSwapRegistry {

    function initiate(address _initiator, uint _refundTime, bytes32 _hashedSecret, address _participant) public payable;

}



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  function Ownable() public {

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

    OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }



}







contract Exchange is Ownable {

    using SafeMath for uint256;



    function Exchange(address _swapRegistry) public {

        swapRegistry = AtomicSwapRegistry(_swapRegistry);

    }



    /**

     * Blockchains to swap with (one of them with be useless, since exchange contract will be deployed to it)

     */

    uint8 constant ETH = 1;

    uint8 constant ETH_KOVAN = 2;

    uint8 constant ETH_RINKEBY = 3;

    uint8 constant EOS = 4;

    uint8 constant BITCOIN = 5;



    enum OpType {BUY, SELL}



    struct Order {

        address initiator;



        uint currencyCount;

        uint priceInWei;



        OpType opType;

        bool isFilled;

        bytes32 hash;

    }



    /*****************************************************************/



    mapping(uint8 => Order[]) public orders;



    mapping(address => bytes32[]) hashes;



    mapping (address => uint) public deposits;



    AtomicSwapRegistry public swapRegistry;



    /*****************************************************************/



    function buy(uint8 _secondBlockchain, uint _currencyCount, uint _priceInWeiForOneUnit) public {

        //todo hardcoded only ether like decimals (18)

        uint totalEther = _priceInWeiForOneUnit.mul(_currencyCount).div(1 ether);



        require(totalEther <= deposits[msg.sender]);

        deposits[msg.sender] = deposits[msg.sender].sub(totalEther);



        uint restCurrencyCount = _currencyCount;

        // todo optimization :(

        for(uint i=0; i<orders[_secondBlockchain].length; i++) {

            if (restCurrencyCount==0) {

                continue;

            }

            require(hashes[msg.sender].length>0);//todo more than orders



            Order storage order = orders[_secondBlockchain][i];

            if (order.opType==OpType.BUY) {

                continue;

            }



            //todo minimum price, since not we get first suitable price

            if (order.priceInWei > _priceInWeiForOneUnit) {

                continue;

            }



            if (order.isFilled) {

                continue;

            }



            if (order.currencyCount <= restCurrencyCount) {

                uint weiCount = order.priceInWei.mul(order.currencyCount).div(1 ether);



                bytes32 currentHash = getNextHash(msg.sender);

                swapRegistry.initiate.value(weiCount)(msg.sender, 7200, currentHash, order.initiator);

                order.isFilled = true;

                order.hash = currentHash;

                restCurrencyCount = restCurrencyCount.sub(order.currencyCount);



                uint spread = _priceInWeiForOneUnit.sub(order.priceInWei).mul(order.currencyCount).div(1 ether);

                owner.transfer(spread);

            }

        }



        if (restCurrencyCount > 0) {

            orders[_secondBlockchain].push(

                Order(

                    msg.sender,

                    restCurrencyCount,

                    _priceInWeiForOneUnit,

                    OpType.BUY,

                    false,

                    0

                )

            );

        }

    }





    function sell(uint8 _secondBlockchain, uint _currencyCount, uint _priceInWeiForOneUnit) public {

        require(_currencyCount > 0);

        require(_priceInWeiForOneUnit > 0);



        uint restCurrencyCount = _currencyCount;

        // todo optimization :(

        for(uint i=0; i<orders[_secondBlockchain].length; i++) {

            if (restCurrencyCount==0) {

                continue;

            }

            Order storage order = orders[_secondBlockchain][i];

            if (order.opType==OpType.SELL) {

                continue;

            }



            //todo minimum price, since not we get first suitable price

            if (order.priceInWei < _priceInWeiForOneUnit) {

                continue;

            }



            if (hashes[order.initiator].length==0) {

                continue;

            }



            if (order.isFilled) {

                continue;

            }



            if (order.currencyCount <= restCurrencyCount) {



                uint weiCount = _priceInWeiForOneUnit.mul(order.currencyCount).div(1 ether);



                bytes32 currentHash = getNextHash(order.initiator);

                swapRegistry.initiate.value(weiCount)(order.initiator, 7200, currentHash, msg.sender);

                order.isFilled = true;

                order.hash = currentHash;

                restCurrencyCount = restCurrencyCount.sub(order.currencyCount);



                uint spread = order.priceInWei.sub(_priceInWeiForOneUnit).mul(order.currencyCount).div(1 ether);

                owner.transfer(spread);

                //todo how to do better?

            }

        }



        if (restCurrencyCount > 0) {

            orders[_secondBlockchain].push(

                Order(

                    msg.sender,

                    restCurrencyCount,

                    _priceInWeiForOneUnit,

                    OpType.SELL,

                    false,

                    0

                )

            );

        }

    }



    /*****************************************************************/

    function myHashesCount() view public returns (uint) {

        return hashes[msg.sender].length;

    }



    function addHashes(bytes32 _hash1, bytes32 _hash2, bytes32 _hash3, bytes32 _hash4, bytes32 _hash5) public {

        // for front in smartz params in this way

        bytes32[5] memory newHashes = [_hash1, _hash2, _hash3, _hash4, _hash5];

        for (uint i = 0; i < newHashes.length; i++) {

            if (newHashes[i] != 0) {

                //todo check that hash has been never used

                hashes[msg.sender].push(newHashes[i]);

            }

        }



    }



    function getNextHash(address _addr) internal returns (bytes32 result) {

        assert(hashes[_addr].length > 0);



        result = hashes[_addr][ hashes[_addr].length-1 ];

        hashes[_addr].length -= 1;

    }



    /*****************************************************************/



    function myDeposit() view public returns (uint) {

        return deposits[msg.sender];

    }



    function deposit() public payable {

        deposits[msg.sender] += msg.value;

    }



    function withdraw(uint _amount) public {

        //todo check orders

        require(deposits[msg.sender] >= _amount);



        deposits[msg.sender] -= _amount;



        msg.sender.transfer(_amount);

    }

}





contract ExchangeConstructed is Exchange {

    function ExchangeConstructed(address _swapRegistry) 

        public payable 

        Exchange(0x76ACF33951b1D58c0dF0388194926Eb5f22e520D)

    {

        

    }

}