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
        predictions.push(Prediction('QmfYfkqemPPuUsfXZhSNEL9449H1fRHVMf9zTU8myCKfkJ', '���٧ѧ� ���ѧ�ѧ���'));
        predictions.push(Prediction('QmavxbA6E7ptj6A41BxrCTE7WPDEmWquZCZJyKocniAVw9', '����ڧ� ����ߧէѧ��'));
        predictions.push(Prediction('QmXmtQeHJZDT5iNBJ82QnaJNUTo2Aw8bQX9juQwziymqAP', '���ѧ�ѧݧ�� ���ѧݧ��'));
        predictions.push(Prediction('QmXvM7d4zz8WxUJiC1ZVzc6BkH6ZLfDtCsEiDkua7PpiHG', '���ӧ֧�ݧѧߧ� ����ӧ�'));
        predictions.push(Prediction('QmQ8UBqhGxTh8thVVxFrvhMSrRbuepP3i9XJt5jsbaowf4', '���ѧӧڧ� ����'));
    }
}