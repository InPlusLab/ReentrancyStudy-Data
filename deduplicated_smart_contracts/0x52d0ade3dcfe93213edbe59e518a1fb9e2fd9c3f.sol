/**

 *Submitted for verification at Etherscan.io on 2018-12-08

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

  function totalSupply() external view returns (uint256);



  function balanceOf(address who) external view returns (uint256);



  function allowance(address owner, address spender)

    external view returns (uint256);



  function transfer(address to, uint256 value) external returns (bool);



  function approve(address spender, uint256 value)

    external returns (bool);



  function transferFrom(address from, address to, uint256 value)

    external returns (bool);



  event Transfer(

    address indexed from,

    address indexed to,

    uint256 value

  );



  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

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



// File: contracts/ExternalCall.sol



library ExternalCall {

    // Source: https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol

    // call has been separated into its own function in order to take advantage

    // of the Solidity's code generator to produce a loop that copies tx.data into memory.

    function externalCall(address destination, uint value, bytes data, uint dataOffset, uint dataLength) internal returns(bool result) {

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)

            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that

            result := call(

                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting

                                   // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +

                                   // callNewAccountGas (25000, in case the destination address does not exist and needs creating)

                destination,

                value,

                add(d, dataOffset),

                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem

                x,

                0                  // Output is ignored, therefore the output size is zero

            )

        }

    }

}



// File: contracts/ISetToken.sol



/*

    Copyright 2018 Set Labs Inc.



    Licensed under the Apache License, Version 2.0 (the "License");

    you may not use this file except in compliance with the License.

    You may obtain a copy of the License at



    http://www.apache.org/licenses/LICENSE-2.0



    Unless required by applicable law or agreed to in writing, software

    distributed under the License is distributed on an "AS IS" BASIS,

    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

    See the License for the specific language governing permissions and

    limitations under the License.

*/



pragma solidity ^0.4.24;



/**

 * @title ISetToken

 * @author Set Protocol

 *

 * The ISetToken interface provides a light-weight, structured way to interact with the

 * SetToken contract from another contract.

 */

interface ISetToken {



    /* ============ External Functions ============ */



    /*

     * Get natural unit of Set

     *

     * @return  uint256       Natural unit of Set

     */

    function naturalUnit()

        external

        view

        returns (uint256);



    /*

     * Get addresses of all components in the Set

     *

     * @return  componentAddresses       Array of component tokens

     */

    function getComponents()

        external

        view

        returns(address[]);



    /*

     * Get units of all tokens in Set

     *

     * @return  units       Array of component units

     */

    function getUnits()

        external

        view

        returns(uint256[]);



    /*

     * Checks to make sure token is component of Set

     *

     * @param  _tokenAddress     Address of token being checked

     * @return  bool             True if token is component of Set

     */

    function tokenIsComponent(

        address _tokenAddress

    )

        external

        view

        returns (bool);



    /*

     * Mint set token for given address.

     * Can only be called by authorized contracts.

     *

     * @param  _issuer      The address of the issuing account

     * @param  _quantity    The number of sets to attribute to issuer

     */

    function mint(

        address _issuer,

        uint256 _quantity

    )

        external;



    /*

     * Burn set token for given address

     * Can only be called by authorized contracts

     *

     * @param  _from        The address of the redeeming account

     * @param  _quantity    The number of sets to burn from redeemer

     */

    function burn(

        address _from,

        uint256 _quantity

    )

        external;



    /**

    * Transfer token for a specified address

    *

    * @param to The address to transfer to.

    * @param value The amount to be transferred.

    */

    function transfer(

        address to,

        uint256 value

    )

        external;

}



// File: contracts/SetBuyer.sol



contract IKyberNetworkProxy {

    function trade(

        address src,

        uint srcAmount,

        address dest,

        address destAddress,

        uint maxDestAmount,

        uint minConversionRate,

        address walletId

    )

        public

        payable

        returns(uint);

}





contract SetBuyer {

    using SafeMath for uint256;

    using ExternalCall for address;



    function buy(

        ISetToken set,

        bytes callDatas,

        uint[] starts // including 0 and LENGTH values

    )

        public

        payable

    {

        change(callDatas, starts);



        address[] memory components = set.getComponents();

        uint256[] memory units = set.getUnits();



        uint256 fitAmount = uint(-1);

        for (uint i = 0; i < components.length; i++) {

            IERC20 token = IERC20(components[i]);

            if (token.allowance(this, set) == 0) {

                require(token.approve(set, uint256(-1)), "Approve failed");

            }



            uint256 amount = token.balanceOf(this).div(units[i]);

            if (amount < fitAmount) {

                fitAmount = amount;

            }

        }



        set.mint(msg.sender, fitAmount);



        if (address(this).balance > 0) {

            msg.sender.transfer(address(this).balance);

        }

        for (i = 0; i < components.length; i++) {

            token = IERC20(components[i]);

            if (token.balanceOf(this) > 0) {

                require(token.transfer(msg.sender, token.balanceOf(this)), "transfer failed");

            }

        }

    }



    function() public payable {

        require(tx.origin != msg.sender);

    }



    function sell(

        ISetToken set,

        uint256 amount,

        bytes callDatas,

        uint[] starts // including 0 and LENGTH values

    )

        public

    {

        set.burn(msg.sender, amount);



        change(callDatas, starts);



        address[] memory components = set.getComponents();



        if (address(this).balance > 0) {

            msg.sender.transfer(address(this).balance);

        }

        for (uint i = 0; i < components.length; i++) {

            IERC20 token = IERC20(components[i]);

            if (token.balanceOf(this) > 0) {

                require(token.transfer(msg.sender, token.balanceOf(this)), "transfer failed");

            }

        }

    }



    function change(bytes callDatas, uint[] starts) public payable { // starts should include 0 and callDatas.length

        for (uint i = 0; i < starts.length - 1; i++) {

            require(address(this).externalCall(0, callDatas, starts[i], starts[i + 1] - starts[i]));

        }

    }



    function sendEthValue(address target, bytes data, uint256 value) external {

        // solium-disable-next-line security/no-call-value

        require(target.call.value(value)(data));

    }



    function sendEthProportion(address target, bytes data, uint256 mul, uint256 div) external {

        uint256 value = address(this).balance.mul(mul).div(div);

        // solium-disable-next-line security/no-call-value

        require(target.call.value(value)(data));

    }



    function approveTokenAmount(address target, bytes data, IERC20 fromToken, uint256 amount) external {

        if (fromToken.allowance(this, target) != 0) {

             fromToken.approve(target, 0);

        }

        fromToken.approve(target, amount);

        require(target.call(data));

    }



    function approveTokenProportion(address target, bytes data, IERC20 fromToken, uint256 mul, uint256 div) external {

        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);

        if (fromToken.allowance(this, target) != 0) {

            fromToken.approve(target, 0);

        }

        fromToken.approve(target, amount);

        require(target.call(data));

    }



    function transferTokenAmount(address target, bytes data, IERC20 fromToken, uint256 amount) external {

        require(fromToken.transfer(target, amount));

        if (data.length != 0) {

            require(target.call(data));

        }

    }



    function transferTokenProportion(address target, bytes data, IERC20 fromToken, uint256 mul, uint256 div) external {

        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);

        require(fromToken.transfer(target, amount));

        if (data.length != 0) {

            // solium-disable-next-line security/no-low-level-calls

            require(target.call(data));

        }

    }



    function transferTokenProportionToOrigin(IERC20 token, uint256 mul, uint256 div) external {

        uint256 amount = token.balanceOf(this).mul(mul).div(div);

        // solium-disable-next-line security/no-tx-origin

        require(token.transfer(tx.origin, amount));

    }



    // Kyber Network



    function kyberSendEthProportion(IKyberNetworkProxy kyber, IERC20 fromToken, address toToken, uint256 mul, uint256 div) external {

        uint256 value = address(this).balance.mul(mul).div(div);

        kyber.trade.value(value)(

            fromToken,

            value,

            toToken,

            this,

            1 << 255,

            0,

            0

        );

    }



    function kyberApproveTokenAmount(IKyberNetworkProxy kyber, IERC20 fromToken, address toToken, uint256 amount) external {

        if (fromToken.allowance(this, kyber) == 0) {

            fromToken.approve(kyber, uint256(-1));

        }

        kyber.trade(

            fromToken,

            amount,

            toToken,

            this,

            1 << 255,

            0,

            0

        );

    }



    function kyberApproveTokenProportion(IKyberNetworkProxy kyber, IERC20 fromToken, address toToken, uint256 mul, uint256 div) external {

        uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);

        this.kyberApproveTokenAmount(kyber, fromToken, toToken, amount);

    }

}