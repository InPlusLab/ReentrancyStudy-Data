/**
 *Submitted for verification at Etherscan.io on 2019-12-05
*/

/*
* d888888P                                           dP              a88888b.                   dP
*    88                                              88             d8'   `88                   88
*    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
*    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
*    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
*    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
* ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*/

// Please check https://twitter.com/TornadoCash for instructions for the contest

pragma solidity 0.5.13;
pragma experimental ABIEncoderV2;

contract RelayersContest {
    mapping(string => bool) public participants;
    string[] public participantsArray;
    uint256 endRegistration;
    uint256 endContest;
    address public owner;
    string[] public winners;
    bool isWinnersSet = false;
    
    event Register(string participant);
    event Winners(string[] winners);
    
    constructor(uint256 _endRegistration, uint256 _endContest) public {
        require(_endRegistration > now);
        require(_endContest >= _endRegistration + 3 days);
        endRegistration = _endRegistration;
        owner = msg.sender;
        endContest = _endContest;
    }
    
    function register(string memory _ensDomain) public {
        require(now <= endRegistration, 'registration is over');
        require(!participants[_ensDomain], 'already registred');
        participants[_ensDomain] = true;
        participantsArray.push(_ensDomain);
        emit Register(_ensDomain);
    }
    
    function setWinners(string[] memory _winners) public {
        require(msg.sender == owner);
        require(now > endContest, 'too early');
        require(!isWinnersSet);
        for(uint i = 0; i < _winners.length; i++) {
            require(participants[_winners[i]], 'not participant');
            winners.push(_winners[i]);
        }
        isWinnersSet = true;
        emit Winners(_winners);
    }
}