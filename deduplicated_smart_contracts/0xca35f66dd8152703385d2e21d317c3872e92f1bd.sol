/**
 *Submitted for verification at Etherscan.io on 2019-11-06
*/

pragma solidity ^0.5.12;

contract Capsule {
    struct Prediction {
        string cid;
        string name;
    }

    Prediction[] public predictions;

    constructor() public {
        predictions.push(Prediction('QmfYfkqemPPuUsfXZhSNEL9449H1fRHVMf9zTU8myCKfkJ', '§¡§Ù§Ñ§ä §¤§Ñ§æ§Ñ§â§à§Ó'));
        predictions.push(Prediction('QmavxbA6E7ptj6A41BxrCTE7WPDEmWquZCZJyKocniAVw9', '§À§â§Ú§Û §¢§à§ß§Õ§Ñ§â§î'));
        predictions.push(Prediction('QmXmtQeHJZDT5iNBJ82QnaJNUTo2Aw8bQX9juQwziymqAP', '§¯§Ñ§ä§Ñ§Ý§î§ñ §¤§Ñ§Ý§ñ§ß'));
        predictions.push(Prediction('QmXvM7d4zz8WxUJiC1ZVzc6BkH6ZLfDtCsEiDkua7PpiHG', '§³§Ó§Ö§ä§Ý§Ñ§ß§Ñ §¢§à§Ó§Ñ'));
        predictions.push(Prediction('QmQ8UBqhGxTh8thVVxFrvhMSrRbuepP3i9XJt5jsbaowf4', '§¥§Ñ§Ó§Ú§Õ §Á§ß'));
    }
}