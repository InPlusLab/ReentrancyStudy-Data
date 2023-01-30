/**

 *Submitted for verification at Etherscan.io on 2019-04-16

*/



//    Copyright (C) 2018 LikeCoin Foundation Limited

//

//    This file is part of LikeCoin Smart Contract.

//

//    LikeCoin Smart Contract is free software: you can redistribute it and/or modify

//    it under the terms of the GNU General Public License as published by

//    the Free Software Foundation, either version 3 of the License, or

//    (at your option) any later version.

//

//    LikeCoin Smart Contract is distributed in the hope that it will be useful,

//    but WITHOUT ANY WARRANTY; without even the implied warranty of

//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

//    GNU General Public License for more details.

//

//    You should have received a copy of the GNU General Public License

//    along with LikeCoin Smart Contract.  If not, see <http://www.gnu.org/licenses/>.



pragma solidity ^0.4.25;



// Source: https://github.com/OpenZeppelin/openzeppelin-solidity/blob/5471fc808a17342d738853d7bf3e9e5ef3108074/contracts/token/ERC20/IERC20.sol

// Copied here to avoid incompatibility with Solidity v0.5.x in latest master branch



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

    function totalSupply() external view returns (uint256);



    function balanceOf(address who) external view returns (uint256);



    function allowance(address owner, address spender) external view returns (uint256);



    function transfer(address to, uint256 value) external returns (bool);



    function approve(address spender, uint256 value) external returns (bool);



    function transferFrom(address from, address to, uint256 value) external returns (bool);



    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed owner, address indexed spender, uint256 value);

}





contract LikeChainRelayLogicInterface {

    function commitWithdrawHash(uint64 height, uint64 round, bytes _payload) public;

    function updateValidator(address[] _newValidators, bytes _proof) public;

    function withdraw(bytes _withdrawInfo, bytes _proof) public;

    function upgradeLogicContract(address _newLogicContract, bytes _proof) public;

    event Upgraded(uint256 _newLogicContractIndex, address _newLogicContract);

}



contract LikeChainRelayState {

    uint256 public logicContractIndex;

    address public logicContract;



    IERC20 public tokenContract;



    address[] public validators;

    

    struct ValidatorInfo {

        uint8 index;

        uint32 power;

    }

    

    mapping(address => ValidatorInfo) public validatorInfo;

    uint256 public totalVotingPower;

    uint public lastValidatorUpdateTime;



    uint public latestBlockHeight;

    bytes32 public latestWithdrawHash;



    mapping(bytes32 => bool) public consumedIds;

    mapping(bytes32 => bytes32) public reserved;

}



contract LikeChainRelayMain is LikeChainRelayState, LikeChainRelayLogicInterface {

    constructor(

        address _logicContract,

        address _tokenContract,

        address[] _validators,

        uint32[] _votingPowers

    ) public {

        uint len = _validators.length;

        require(len > 0);

        require(len < 256);

        require(_votingPowers.length == len);

        

        logicContract = _logicContract;

        logicContractIndex = 0;



        for (uint8 i = 0; i < len; i += 1) {

            address v = _validators[i];

            require(validatorInfo[v].power == 0);

            uint32 power = _votingPowers[i];

            require(power > 0);

            validators.push(v);

            validatorInfo[v] = ValidatorInfo({

                index: i,

                power: power

            });

            totalVotingPower += power;

        }

        

        tokenContract = IERC20(_tokenContract);

    }



    function commitWithdrawHash(uint64 /* height */, uint64 /* round */, bytes /* _payload */) public {

        require(logicContract.delegatecall(msg.data));

    }



    function updateValidator(address[] /* _newValidators */, bytes /* _proof */) public {

        require(logicContract.delegatecall(msg.data));

    }



    function withdraw(bytes /* _withdrawInfo */, bytes /* _proof */) public {

        require(logicContract.delegatecall(msg.data));

    }



    function upgradeLogicContract(address /* _newLogicContract */, bytes /* _proof */) public {

        require(logicContract.delegatecall(msg.data));

    }

}