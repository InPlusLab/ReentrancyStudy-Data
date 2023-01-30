/**
 *Submitted for verification at Etherscan.io on 2020-01-16
*/

pragma solidity ^0.5.12;


contract ConditionalTokens {
    function reportPayouts(bytes32 questionId, uint256[] calldata payouts) external;
}

contract Realitio {
    function resultFor(bytes32 questionId) external view returns (bytes32);
}

contract RealitioProxy {
  ConditionalTokens public conditionalTokens;
  Realitio public realitio;

  constructor(ConditionalTokens _conditionalTokens, Realitio _realitio) public {
    conditionalTokens = _conditionalTokens;
    realitio = _realitio;
  }

  function resolveSingleSelectCondition(bytes32 questionId, uint256 numOutcomes) public {
    uint256 answer = uint256(realitio.resultFor(questionId));

    require(answer < numOutcomes, "Answer must be between 0 and numOutcomes");

    uint256[] memory payouts = new uint256[](numOutcomes);

    payouts[answer] = 1;

    conditionalTokens.reportPayouts(questionId, payouts);
  }
}