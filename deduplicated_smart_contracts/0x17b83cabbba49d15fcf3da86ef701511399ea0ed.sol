/**

 *Submitted for verification at Etherscan.io on 2019-05-15

*/



pragma solidity ^0.4.13;

contract FranklinStorage {

    // For tree depth 24
    bytes32 constant EMPTY_TREE_ROOT = 0x003f7e15e4de3453fe13e11fb4b007f1fce6a5b0f0353b3b8208910143aaa2f7;

    uint256 public constant DEADLINE = 3600;

    event BlockCommitted(uint32 indexed blockNumber);
    event BlockVerified(uint32 indexed blockNumber);

    enum Circuit {
        DEPOSIT,
        TRANSFER,
        EXIT
    }

    enum AccountState {
        NOT_REGISTERED,
        REGISTERED,
        PENDING_EXIT,
        UNCONFIRMED_EXIT
    }

    struct Block {
        uint8 circuit;
        uint64  deadline;
        uint128 totalFees;
        bytes32 newRoot;
        bytes32 publicDataCommitment;
        address prover;
    }

    // Key is block number
    mapping (uint32 => Block) public blocks;
    // Only some addresses can send proofs
    mapping (address => bool) public operators;
    // Fee collection accounting
    mapping (address => uint256) public balances;

    struct Account {
        uint8 state;
        uint32 exitBatchNumber;
        address owner;
        uint256 publicKey;
        uint32 exitListHead;
        uint32 exitListTail;
    }

    // one Ethereum address should have one account
    mapping (address => uint24) public ethereumAddressToAccountID;

    // Plasma account => general information
    mapping (uint24 => Account) public accounts;

    // Public information for users
    bool public stopped;
    uint32 public lastCommittedBlockNumber;
    uint32 public lastVerifiedBlockNumber;
    bytes32 public lastVerifiedRoot;
    uint64 public constant MAX_DELAY = 1 days;
    uint256 public constant DENOMINATOR = 1000000000000;

    // deposits

    uint256 public constant DEPOSIT_BATCH_SIZE = 1;
    uint256 public totalDepositRequests; // enumerates total number of deposit, starting from 0
    uint256 public lastCommittedDepositBatch;
    uint256 public lastVerifiedDepositBatch;
    uint128 public currentDepositBatchFee; // deposit request fee scaled units

    uint24 public constant SPECIAL_ACCOUNT_DEPOSITS = 1;

    uint24 public nextAccountToRegister;

    // some ideas for optimization of the deposit request information storage:
    // store in a mapping: 20k gas to add, 5k to update a record + 5k to update the global counter per batch
    // store in an array: 20k + 5k gas to add, 5k to update + up to DEPOSIT_BATCH_SIZE * SLOAD

    // batch number => (plasma address => deposit information)
    mapping (uint256 => mapping (uint24 => DepositRequest)) public depositRequests;
    mapping (uint256 => DepositBatch) public depositBatches;

    struct DepositRequest {
        uint128 amount;
    }

    enum DepositBatchState {
        CREATED,
        COMMITTED,
        VERIFIED
    }

    struct DepositBatch {
        uint8 state;
        uint24 numRequests;
        uint32 blockNumber;
        uint64 timestamp;
        uint128 batchFee;
    }

    event LogDepositRequest(uint256 indexed batchNumber, uint24 indexed accountID, uint256 indexed publicKey, uint128 amount);
    event LogCancelDepositRequest(uint256 indexed batchNumber, uint24 indexed accountID);

    // Exits 

    uint256 constant EXIT_BATCH_SIZE = 1;
    uint256 public totalExitRequests; 
    uint256 public lastCommittedExitBatch;
    uint256 public lastVerifiedExitBatch;
    uint128 public currentExitBatchFee; 

    uint24 public constant SPECIAL_ACCOUNT_EXITS = 0;

    // batches for complete exits
    mapping (uint256 => ExitBatch) public exitBatches;

    enum ExitBatchState {
        CREATED,
        COMMITTED,
        VERIFIED
    }

    struct ExitBatch {
        uint8 state;
        uint32 blockNumber;
        uint64 timestamp;
        uint128 batchFee;
    }

    event LogExitRequest(uint256 indexed batchNumber, uint24 indexed accountID);
    event LogCancelExitRequest(uint256 indexed batchNumber, uint24 indexed accountID);

    event LogExit(address indexed ethereumAddress, uint32 indexed blockNumber);
    event LogCompleteExit(address indexed ethereumAddress, uint32 indexed blockNumber, uint24 accountID);

    struct ExitLeaf {
        uint32 nextID;
        uint128 amount;
    }

    mapping (address => mapping (uint32 => ExitLeaf)) public exitLeafs;

    // mapping ethereum address => block number => balance
    // mapping (address => mapping (uint32 => uint128)) public exitAmounts;
    // Delegates chain
    address public depositor;
    address public transactor;
    address public exitor;
}

library TwistedEdwards {
    // EdwardsPoint public generator;

    struct EdwardsPoint {
        uint256 x;
        uint256 y;
    }

    // constructor (
    //     uint256[2] memory _generator
    // ) public {
    //     require(_generator[0] < getPrimeFieldSize(), "Generator X is not in the field");
    //     require(_generator[1] < getPrimeFieldSize(), "Generator Y is not in the field");
    //     // TODO: Check generator order
    //     generator = EdwardsPoint (_generator[0], _generator[1]);
    // }

    function getA()
    internal
    pure 
    returns (uint256) {
        return 21888242871839275222246405745257275088548364400416034343698204186575808495616;
    }

    function getD()
    internal
    pure 
    returns (uint256) {
        return 12181644023421730124874158521699555681764249180949974110617291017600649128846;
    }

    function getCofactor()
    internal
    pure 
    returns (uint256) {
        return 8;
    }

    function getMainGroupOrder()
    internal
    pure 
    returns (uint256) {
        return 2736030358979909402780800718157159386076813972158567259200215660948447373041;
    }

    function getPrimeFieldSize()
    internal
    pure 
    returns (uint256) {
        return 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    }

    function fieldNegate(uint256 _x)
    internal
    pure
    returns (uint256) {
        return getPrimeFieldSize() - _x;
    }

    function negate(EdwardsPoint memory P)
    internal
    pure
    returns (EdwardsPoint memory S)
    {
        S = EdwardsPoint(fieldNegate(P.x), P.y);
    }

    function fieldInv(uint256 x) 
    internal 
    pure returns (uint256) {
        uint256 p = getPrimeFieldSize();
        uint256 a = x;
        if (a == 0)
            return 0;
        if (a > p)
            a = a % p;
        int256 t1;
        int256 t2 = 1;
        uint256 r1 = p;
        uint256 r2 = a;
        uint256 q;
        while (r2 != 0) {
            q = r1 / r2;
            (t1, t2, r1, r2) = (t2, t1 - int256(q) * t2, r2, r1 - q * r2);
        }
        if (t1 < 0)
            return (p - uint256(-t1));
        return uint256(t1);
    }

    // Infinity point is encoded as (0, 1)
    function isInfinity(EdwardsPoint memory P)
    internal
    pure
    returns (bool)
    {  
        return P.x == 0 && P.y == 1;
    }

    // group addition law
    // x3 = (x1*y2+y1*x2)/(1+d*x1*x2*y1*y2)
    // y3 = (y1*y2-a*x1*x2)/(1-d*x1*x2*y1*y2)

    // IMPORTANT! Take no assumption about a == -1 for now
    function add(EdwardsPoint memory P, EdwardsPoint memory Q)
    internal
    pure
    returns (EdwardsPoint memory S)
    {
        uint256 p = getPrimeFieldSize();
        uint256 a = getA();
        uint256 d = getD();

        // precompute and save x1*y2. x2*y1
        uint256 x1y2 = mulmod(P.x, Q.y, p);
        uint256 x2y1 = mulmod(Q.x, P.y, p);
        // calculate x1*x2 and y1*y2 for shortness
        uint256 x1x2 = mulmod(P.x, Q.x, p);
        uint256 y1y2 = mulmod(P.y, Q.y, p);

        uint256 x3_t = addmod(x1y2, x2y1, p);
        uint256 x3_b = fieldInv(addmod(1, mulmod( mulmod(d, x1y2, p), x2y1, p), p) );

        // manual negations here
        uint256 y3_t = addmod(y1y2, p - mulmod(a, x1x2, p), p);
        uint256 y3_b = fieldInv(addmod(1, p - mulmod( mulmod(d, x1y2, p), x2y1, p), p) );
        
        S = EdwardsPoint(mulmod(x3_t, x3_b, p), mulmod(y3_t, y3_b, p));
    }

    // group doubling law
    // x3 = (x1*y1+y1*x1)/(1+d*x1*x1*y1*y1)
    // y3 = (y1*y1-a*x1*x1)/(1-d*x1*x1*y1*y1)

    // IMPORTANT! Take no assumption about a == -1 for now
    function double(EdwardsPoint memory P)
    internal
    pure
    returns (EdwardsPoint memory S)
    {
        uint256 p = getPrimeFieldSize();
        uint256 a = getA();
        uint256 d = getD();

        // precompute and save x1*y2. x2*y1
        uint256 xx = mulmod(P.x, P.x, p);
        uint256 yy = mulmod(P.y, P.y, p);
        uint256 xy = mulmod(P.x, P.y, p);

        uint256 x3_t = addmod(xy, xy, p);
        uint256 x3_b = fieldInv(addmod(1, mulmod( mulmod(d, xy, p), xy, p), p) );

        // manual negations here
        uint256 y3_t = addmod(yy, p - mulmod(a, xx, p), p);
        uint256 y3_b = fieldInv(addmod(1, p - mulmod( mulmod(d, xx, p), yy, p), p) );
        
        S = EdwardsPoint(mulmod(x3_t, x3_b, p), mulmod(y3_t, y3_b, p));
    }

    
    function multiplyByScalar(
        uint256 d, 
        EdwardsPoint memory P
    ) 
    internal 
    pure
    returns (EdwardsPoint memory S)
    {
        
        S = EdwardsPoint(0,1);
        if (d == 0) {
            return S;
        }

        EdwardsPoint memory base = EdwardsPoint(P.x, P.y);

        // double and add
        uint256 remaining = d;
        while (remaining != 0) {
            if ((remaining & 1) != 0) {
                S = add(S, base);
            }
            remaining = remaining >> 1;
            base = double(base);
        }

    }

    // Check that a * x^2 + y^2 = 1 + d * x^2 * y^2
    function isOnCurve(
        EdwardsPoint memory P
    )
    internal
    pure
    returns (bool)
    {
        uint256 p = getPrimeFieldSize();
        uint256 a = getA();
        uint256 d = getD();

        uint256 xx = mulmod(P.x, P.x, p);
        uint256 yy = mulmod(P.y, P.y, p);

        uint256 lhs = addmod(mulmod(a, xx,p), yy, p);
        uint256 rhs = addmod(1, mulmod(d, mulmod(xx, yy, p), p), p);

        return lhs == rhs;
    }

    function isInCorrectGroup(
        EdwardsPoint memory P
    ) 
    internal 
    pure
    returns (bool)
    {
        uint256 order = getMainGroupOrder();
        return isInfinity(multiplyByScalar(order, P));
    }

    function isCorrectGroup(
        uint256[2] memory point
    )
    internal
    pure
    returns (bool)
    {
        EdwardsPoint memory P = EdwardsPoint(point[0], point[1]);
        return isInCorrectGroup(P);
    }

    function multiply(
        uint256 d,
        uint256[2] memory point
    )
    internal
    pure
    returns (uint256[2] memory result)
    {
        EdwardsPoint memory P = EdwardsPoint(point[0], point[1]);
        EdwardsPoint memory S = multiplyByScalar(d, P);
        result[0] = S.x;
        result[1] = S.y;
    }

    function checkOnCurve(
        uint256[2] memory point
    )
    internal
    pure
    returns (bool) {
        EdwardsPoint memory P = EdwardsPoint(point[0], point[1]);
        return isOnCurve(P);
    }

    // // Multiplication dP. P affine, wNAF: w=5
    // // Params: d, Px, Py
    // // Output: Jacobian Q
    // function _wnafMul(
    //     uint256 d, 
    //     EdwardsPoint memory P
    // ) 
    // internal 
    // pure 
    // returns (EdwardsPoint memory S)
    // {
    //     uint p = getPrimeFieldSize();
    //     if (d == 0) {
    //         return pointOfInfinity;
    //     }
    //     uint dwPtr; // points to array of NAF coefficients.
    //     uint i;

    //     // wNAF
    //     assembly
    //     {
    //         let dm := 0
    //         dwPtr := mload(0x40)
    //         mstore(0x40, add(dwPtr, 512)) // Should lower this.
    //     loop:
    //         jumpi(loop_end, iszero(d))
    //         jumpi(even, iszero(and(d, 1)))
    //         dm := mod(d, 32)
    //         mstore8(add(dwPtr, i), dm) // Don't store as signed - convert when reading.
    //         d := add(sub(d, dm), mul(gt(dm, 16), 32))
    //     even:
    //         d := div(d, 2)
    //         i := add(i, 1)
    //         jump(loop)
    //     loop_end:
    //     }

    //     // Pre calculation
    //     uint[3][8] memory PREC; // P, 3P, 5P, 7P, 9P, 11P, 13P, 15P
    //     PREC[0] = [P[0], P[1], 1];
    //     uint[3] memory X = _double(PREC[0]);
    //     PREC[1] = _addMixed(X, P);
    //     PREC[2] = _add(X, PREC[1]);
    //     PREC[3] = _add(X, PREC[2]);
    //     PREC[4] = _add(X, PREC[3]);
    //     PREC[5] = _add(X, PREC[4]);
    //     PREC[6] = _add(X, PREC[5]);
    //     PREC[7] = _add(X, PREC[6]);

    //     // Mult loop
    //     while(i > 0) {
    //         uint dj;
    //         uint pIdx;
    //         i--;
    //         assembly {
    //             dj := byte(0, mload(add(dwPtr, i)))
    //         }
    //         Q = _double(Q);
    //         if (dj > 16) {
    //             pIdx = (31 - dj) / 2; // These are the "negative ones", so invert y.
    //             Q = _add(Q, [PREC[pIdx][0], p - PREC[pIdx][1], PREC[pIdx][2] ]);
    //         }
    //         else if (dj > 0) {
    //             pIdx = (dj - 1) / 2;
    //             Q = _add(Q, [PREC[pIdx][0], PREC[pIdx][1], PREC[pIdx][2] ]);
    //         }
    //         if (Q[0] == pointOfInfinity[0] && Q[1] == pointOfInfinity[1] && Q[2] == pointOfInfinity[2]) {
    //             return Q;
    //         }
    //     }
    //     return Q;
    // }







}

contract Verifier {

    function NegateY( uint256 Y )
        internal pure returns (uint256)
    {
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        return q - (Y % q);
    }

    function Verify ( uint256[14] in_vk, uint256[] vk_gammaABC, uint256[8] in_proof, uint256[] proof_inputs )
        internal 
        view 
        returns (bool)
    {
        require( ((vk_gammaABC.length / 2) - 1) == proof_inputs.length, "Invalid number of public inputs" );

        // Compute the linear combination vk_x
        uint256[3] memory mul_input;
        uint256[4] memory add_input;
        bool success;
        uint m = 2;

        // First two fields are used as the sum
        add_input[0] = vk_gammaABC[0];
        add_input[1] = vk_gammaABC[1];

        // Performs a sum of gammaABC[0] + sum[ gammaABC[i+1]^proof_inputs[i] ]
        for (uint i = 0; i < proof_inputs.length; i++) {
            mul_input[0] = vk_gammaABC[m++];
            mul_input[1] = vk_gammaABC[m++];
            mul_input[2] = proof_inputs[i];

            assembly {
                // ECMUL, output to last 2 elements of `add_input`
                success := staticcall(sub(gas, 2000), 7, mul_input, 0x60, add(add_input, 0x40), 0x40)
            }
            require( success, "Failed to call ECMUL precompile" );

            assembly {
                // ECADD
                success := staticcall(sub(gas, 2000), 6, add_input, 0x80, add_input, 0x40)
            }
            require( success, "Failed to call ECADD precompile" );
        }

        uint[24] memory input = [
            // (proof.A, proof.B)
            in_proof[0], in_proof[1],                           // proof.A   (G1)
            in_proof[2], in_proof[3], in_proof[4], in_proof[5], // proof.B   (G2)

            // (-vk.alpha, vk.beta)
            in_vk[0], NegateY(in_vk[1]),                        // -vk.alpha (G1)
            in_vk[2], in_vk[3], in_vk[4], in_vk[5],             // vk.beta   (G2)

            // (-vk_x, vk.gamma)
            add_input[0], NegateY(add_input[1]),                // -vk_x     (G1)
            in_vk[6], in_vk[7], in_vk[8], in_vk[9],             // vk.gamma  (G2)

            // (-proof.C, vk.delta)
            in_proof[6], NegateY(in_proof[7]),                  // -proof.C  (G1)
            in_vk[10], in_vk[11], in_vk[12], in_vk[13]          // vk.delta  (G2)
        ];

        uint[1] memory out;
        assembly {
            success := staticcall(sub(gas, 2000), 8, input, 768, out, 0x20)
        }
        require(success, "Failed to call pairing precompile");
        return out[0] == 1;
    }
}

contract DepositVerificationKey {

    function getVkDepositCircuit() internal pure returns (uint256[14] memory vk, uint256[] memory gammaABC) {

        
        vk[0] = 0x02834523b73cb0630d49fc3e2054522563fb6471012d3f1e6fe31cb946240774;
        vk[1] = 0x0ba99f12ab5e9c80db6c85f62fb7a0df5d0dcb1088eb4b48d36156d816489128;
        vk[2] = 0x0f19b305cee59f6dc3c054880068b4a13768e5b901d0479271c20f8b79243965;
        vk[3] = 0x11e32a8c382c7fb28b177d02e354607f7c33abc7f5636e71cd0fb4cd77eb1d74;
        vk[4] = 0x2bee5b6bb3fda73e29152d399f1bd211961f048eeb0d5a7d752ad9ffb649dff1;
        vk[5] = 0x15ec0d94cdfe1fdcc23a58995e2af0b788fffae99691676fa943d608226b8682;
        vk[6] = 0x03f6ee67c8871c54c6f20e77376eb305e5b4964f1019bce1ad9ce22b2bec622c;
        vk[7] = 0x21b45fc68e2059b1eab7eee045ab7be7ed45a2d3f6e3515ac1ec28f7b490b1dd;
        vk[8] = 0x0c9b53ea69e19134e41340bb6c0d1795661381291bf630c24396f8e866528002;
        vk[9] = 0x2e24ea773c3f54e3e7fc82249e7de02be3932e8b156800d9e4d19a5047f85cbb;
        vk[10] = 0x215e8c48ee50bad165d2420f9220145fa4cc98d7dcb52cc2a6e9010fd6214411;
        vk[11] = 0x1917a1144eb6f1c16ebf2673f2eb0fe275ae8bf518ae36553354580cd191293f;
        vk[12] = 0x1d636227f8db452d07a36077ffb1f0723947ae4cae746721445d3d249438ee57;
        vk[13] = 0x13c4be40874508b0fa8b895657084e1a8e1bb7002d7a8cc05f0973763cb20755;

        gammaABC = new uint256[](8);
        gammaABC[0] = 0x017474e8efdf8775559844f978a7d23602c51508c42055cba41da71d8c184662;
        gammaABC[1] = 0x0479fb6bc0d7c11f5a734f450f6a47ec94bd59014f8398b248f59dc058b76b64;
        gammaABC[2] = 0x06cef07cba4570717e5a1389b1425ed2f9d3de870c651254f557b82187eda82c;
        gammaABC[3] = 0x1ba4b300e354352533d910452a340d16d2205ab18698cc5158bbb89a4d6340e9;
        gammaABC[4] = 0x16901a82f58d7d091cb47c0b8daa365e9c8dea97ff33d461044ce0c8f03cae71;
        gammaABC[5] = 0x0902ea2f0d929f53465faab02d6e6c475868b5004b6ccdf29ec17fdcf1f4bf50;
        gammaABC[6] = 0x113c4aa77bfc12e18d3d0f64e840c2f912406ee9e61e476aaa67f8c743baa7c2;
        gammaABC[7] = 0x176aa258bd76a01a4f744c71483afbc1ec4cd0529a6842b8a14c7feb75821e90;


    }

}

contract ExitVerificationKey {

    function getVkExitCircuit() internal pure returns (uint256[14] memory vk, uint256[] memory gammaABC) {

        
        vk[0] = 0x2655d0f184451488c9c86edaa0f36a7d4f7a2fc3825e7d030af5660d3681ace6;
        vk[1] = 0x30062c29546c272a712d301884a3deef21716e671c5da66cac7f5d263714a2a6;
        vk[2] = 0x1e6c69a1d12135996fa27fb9f435d1876b34629e574671ba77826b8733d93b65;
        vk[3] = 0x0bb271e151e34c9bfe2abaaf66c5888ccfa6c2272a29ab8f5f572d1177fbdf1e;
        vk[4] = 0x05ff0ddaeb5d75296cac71fd305db5a3395759a926cb6c8701f84d35710f78ee;
        vk[5] = 0x20272b96093e40001583fead3bd6e8c6453f346bdf92d5779bed7ab884d0aa2e;
        vk[6] = 0x0950cc975d157dd4e80dc8d162caa4e506186f7adbe9cf69867a18e56b7a167b;
        vk[7] = 0x0a58c1bf8b3a41a9d53c66509de333ac6e110de78d270f6f4c7a32acac5d65bf;
        vk[8] = 0x152ff1340ad2dcf6eb3b2373263f3e3d48c58e4f3c8035d994d690efb89105cd;
        vk[9] = 0x1a7a1d4994c386d270238d45dcf938bfae17753560be434e4c98950d9a150d9c;
        vk[10] = 0x0ea995b343d372ae0f5cad6a29ea289172d127085b8ebb9a8a46d8c359728dcb;
        vk[11] = 0x256fd00e2102e55b0e0882a8fc9297d9e2eb66b1f368dea21c3b4fea52ff1b77;
        vk[12] = 0x024e59df7dad7374d09caa273089b9d27057c131db4d645cbe2b780ed8dca72b;
        vk[13] = 0x1aea3eea3d14b2240eabd4c12fa0cc60a3431e6f55132cf7809eb80b5c696c7d;

        gammaABC = new uint256[](8);
        gammaABC[0] = 0x02e10a3d18c9ddc8a7faf5e20d6cd56ae82426e802596b8e424c8d24a2d8cc91;
        gammaABC[1] = 0x0fcf4f982b4c051fe7d7e25d73c174f709e1a116a39573f5ebcce86a694086ac;
        gammaABC[2] = 0x0647167a8df2f9de6e1dbd6e6e52e8bcf6b64d7fb9a6405f3efca93f250cac14;
        gammaABC[3] = 0x2045113ec018db92050dba997d86b3b440c420d55819887fee065a17ef897897;
        gammaABC[4] = 0x253baaed4e84773d8b85c1ac4d0b64d15d5652b318c3a72daf96a6d26a6d1481;
        gammaABC[5] = 0x170034f174be16fd996aeb4ac97653a3f0e344ed8b5dbe947d952208a938edba;
        gammaABC[6] = 0x23967a7baa217743b308217c7db86912a130a668bce7c9ac030d5ed42472347c;
        gammaABC[7] = 0x2bfd3180a31b3fef9328b1225755ea2e7ca8d1e832cb4729930e15b5f842300d;


    }

}

contract TransferVerificationKey {

    function getVkTransferCircuit() internal pure returns (uint256[14] memory vk, uint256[] memory gammaABC) {

        
        vk[0] = 0x10c2409dca4fa02e16250e08e4cbf8eae90c8fba1e91115f065f88f73d0ec0ba;
        vk[1] = 0x0aa6ecb84f58760a6a01d0f31bb8776582c893f66562b623d9082e50b9147015;
        vk[2] = 0x10296458aa3bcd5ad37ae95f63f55e90b8830fe1449dc21aee05ebdf7e29ef14;
        vk[3] = 0x0f51783ae1ca492c229a5d04bc2de03ff6ff9a4f877a2bc80bb60eb1f70cc84b;
        vk[4] = 0x0f874f1341d40fe04cebe4668c968c74d2d09aa07e4685889c90f6d4ec4345de;
        vk[5] = 0x1652c73a52779311ca7ffdcd9749e40592780259a9c9e738b63199dad11d7f17;
        vk[6] = 0x086d1b9a535ffcebe71f045e022967f0c113114c04a1bf944a395c14cce50f49;
        vk[7] = 0x2b2166f750b92453a4bc000425e93c3c412d911961dcd9050c61368f07673262;
        vk[8] = 0x12ba168ac5544a1b8c1bd3c47b6d9a1391db76a608e4556b639e0032e2deffbe;
        vk[9] = 0x2b32a828faf0bb870f693cc8031c166b0063d854c435ea1b516e67ba5a6d8907;
        vk[10] = 0x100f54919b2e2f9ddaacfae446be3614441bb0e451380ec96658979748613433;
        vk[11] = 0x066bcceed5d7a04466af77a2af1e9ca005a12f19bc4d7cc8e231354885b82607;
        vk[12] = 0x28782e5b286bda594b1ad6320c62df3dbfcf4db5043430d19204f46a34fd4119;
        vk[13] = 0x11b16528236d3aba305c2f3b051b0d88902465da7969d8b6719fbf9dd35dcf2a;

        gammaABC = new uint256[](8);
        gammaABC[0] = 0x0f33cb3065f68e121317d06f1424955c5a7e2ec8edebc909aac08a3f17069886;
        gammaABC[1] = 0x037f77f317232115d1e59c5d751cdfc7cb71860def1eac9c26601ca608818d82;
        gammaABC[2] = 0x160621974534ddb69577555fb5add3b219fc3d7940d6af98fd0b4d1323e98a02;
        gammaABC[3] = 0x0f99ebad244805d05f610d8a9e2fb9395fe4159ed19ff545c1663395faf2e54e;
        gammaABC[4] = 0x252887d8a49ac0d88d097657230f297137e590d836a958c33f6e86737a7b6d5d;
        gammaABC[5] = 0x303d4a352e156b053325cd397e875076f30a41b8b5cb919c284f76021c95d506;
        gammaABC[6] = 0x12373b5d89c0ded59c6cff32b0ff93b98a46b0fabc01be54748fbe072c34721e;
        gammaABC[7] = 0x00c29f8e6d126eff674bede612ba90717ef37c8fa3431309d2bb81dac30871e5;


    }

}

contract VerificationKeys is TransferVerificationKey, DepositVerificationKey, ExitVerificationKey {
}

contract FranklinCommon is VerificationKeys, FranklinStorage, Verifier {

    modifier active_only() {
        require(!stopped, "contract should not be globally stopped");
        _;
    }

    modifier operator_only() {
        require(operators[msg.sender] == true, "sender should be one of the operators");
        _;
    }

    // unit normalization functions
    function scaleIntoPlasmaUnitsFromWei(uint256 value)
    public
    pure
    returns (uint128) {
        uint256 den = DENOMINATOR;
        require(value % den == 0, "amount has higher precision than possible");
        uint256 scaled = value / den;
        require(scaled < uint256(1) << 128, "deposit amount is too high");
        return uint128(scaled);
    }

    function scaleFromPlasmaUnitsIntoWei(uint128 value)
    public
    pure
    returns (uint256) {
        return uint256(value) * DENOMINATOR;
    }

    function verifyProof(Circuit circuitType, uint256[8] memory proof, bytes32 oldRoot, bytes32 newRoot, bytes32 finalHash)
        internal view returns (bool valid)
    {
        uint256 mask = (~uint256(0)) >> 3;
        uint256[14] memory vk;
        uint256[] memory gammaABC;
        if (circuitType == Circuit.DEPOSIT) {
            (vk, gammaABC) = getVkDepositCircuit();
        } else if (circuitType == Circuit.TRANSFER) {
            (vk, gammaABC) = getVkTransferCircuit();
        } else if (circuitType == Circuit.EXIT) {
            (vk, gammaABC) = getVkExitCircuit();
        } else {
            return false;
        }
        uint256[] memory inputs = new uint256[](3);
        inputs[0] = uint256(oldRoot);
        inputs[1] = uint256(newRoot);
        inputs[2] = uint256(finalHash) & mask;
        return Verify(vk, gammaABC, proof, inputs);
    }

}

contract Exitor is FranklinCommon {

    function exit() 
    public 
    payable
    {
        uint128 userFee = scaleIntoPlasmaUnitsFromWei(msg.value);
        require(userFee >= currentExitBatchFee, "exit fee should be more than required by the operator");
        uint24 accountID = ethereumAddressToAccountID[msg.sender];
        require(accountID != 0, "empty accounts can not exit");

        uint256 currentBatch = totalExitRequests/EXIT_BATCH_SIZE;
        // write aux info about the batch
        ExitBatch storage batch = exitBatches[currentBatch];
        // batch countdown start from the first request
        if (batch.timestamp == 0) {
            batch.state = uint8(ExitBatchState.CREATED);
            batch.timestamp = uint64(block.timestamp);
            batch.batchFee = currentExitBatchFee;
        }

        Account storage account = accounts[accountID];
        require(account.state == uint8(AccountState.REGISTERED), "only accounts that are registered and not pending exit can exit");
        account.state = uint8(AccountState.PENDING_EXIT);
        account.exitBatchNumber = uint32(currentBatch);

        totalExitRequests++;

        emit LogExitRequest(currentBatch, accountID);
    }

    // allow users to cancel an exit if the work on the next proof is not yet started
    function cancelExit()
    public
    {
        uint24 accountID = ethereumAddressToAccountID[msg.sender];
        require(accountID != 0, "trying to cancel a deposit for non-existing account");
        uint256 currentBatch = totalExitRequests/EXIT_BATCH_SIZE;
        uint256 requestsInThisBatch = totalExitRequests % EXIT_BATCH_SIZE;

        // if the first request in a batch is canceled - clear it to stop the countdown
        if (requestsInThisBatch == 0) {
            delete exitBatches[currentBatch];
        }

        Account storage account = accounts[accountID];
        require(account.state == uint8(AccountState.PENDING_EXIT), "can only cancel exits for accounts that are pending exit");
        require(account.exitBatchNumber == uint32(currentBatch), "can not cancel an exit in the batch that was already accepted");
        account.state = uint8(AccountState.REGISTERED);
        account.exitBatchNumber = 0;

        emit LogCancelExitRequest(currentBatch, accountID);

        totalExitRequests--;

        // TODO may be return an fee that was collected
    }

    // this does not work in multi-operator mode
    function startNextExitBatch()
    public
    operator_only()
    {
        uint256 currentBatch = totalExitRequests/EXIT_BATCH_SIZE;
        uint256 inTheCurrentBatch = totalExitRequests % EXIT_BATCH_SIZE;
        if (inTheCurrentBatch != 0) {
            totalExitRequests = (currentBatch + 1) * EXIT_BATCH_SIZE;
        } else {
            revert("it's not necessary to bump the batch number");
        }
    }

    // this does not work in multi-operator mode
    function changeExitBatchFee(uint128 newBatchFee)
    public
    operator_only()
    {
        if (currentExitBatchFee == 0) {
            revert("fee is already at minimum");
        }
        if (newBatchFee < currentExitBatchFee) {
            currentExitBatchFee = newBatchFee;
        } else {
            revert("can not increase an exit fee");
        }
    }

    // pure function to calculate commitment formats
    function createPublicDataCommitmentForExit(uint32 blockNumber, bytes memory txDataPacked)
    public 
    pure
    returns (bytes32 h) {

        bytes32 initialHash = sha256(abi.encodePacked(uint256(blockNumber)));
        bytes32 finalHash = sha256(abi.encodePacked(initialHash, txDataPacked));
        
        return finalHash;
    }

    // on commitment to some block we just commit to SOME public data, that will be parsed 
    // ONLY when proof is presented
    
    function commitExitBlock(
        uint256 batchNumber,
        uint24[EXIT_BATCH_SIZE] memory accoundIDs, 
        uint32 blockNumber, 
        bytes memory txDataPacked, 
        bytes32 newRoot
    ) 
    public 
    operator_only 
    {
        require(blockNumber == lastCommittedBlockNumber + 1, "may only commit next block");
        require(batchNumber == lastCommittedExitBatch, "trying to commit batch out of order");
        
        ExitBatch storage batch = exitBatches[batchNumber];
        batch.state = uint8(ExitBatchState.COMMITTED);
        batch.blockNumber = blockNumber;
        batch.timestamp = uint64(block.timestamp);
                
        bytes32 publicDataCommitment = createPublicDataCommitmentForExit(blockNumber, txDataPacked);

        blocks[blockNumber] = Block(
            uint8(Circuit.EXIT), 
            uint64(block.timestamp + MAX_DELAY), 
            0, 
            newRoot, 
            publicDataCommitment, 
            msg.sender
        );
        emit BlockCommitted(blockNumber);
        lastCommittedBlockNumber++;
        lastCommittedExitBatch++;

        // process the block information
        processExitBlockData(batchNumber, blockNumber, accoundIDs, txDataPacked);
    }

    // exit block is special - to avoid storge writes an exit data is sent on verification,
    // but not on commitment
    function verifyExitBlock(
        uint256 batchNumber, 
        uint32 blockNumber, 
        uint256[8] memory proof
    ) 
    public 
    operator_only 
    {
        require(lastVerifiedBlockNumber < lastCommittedBlockNumber, "no committed block to verify");
        require(blockNumber == lastVerifiedBlockNumber + 1, "may only verify next block");
        require(batchNumber == lastVerifiedExitBatch, "trying to prove batch out of order");

        Block storage committed = blocks[blockNumber];
        require(committed.circuit == uint8(Circuit.EXIT), "trying to prove the invalid circuit for this block number");

        ExitBatch storage batch = exitBatches[batchNumber];
        require(batch.blockNumber == blockNumber, "block number in referencing invalid batch number");
        batch.state = uint8(ExitBatchState.VERIFIED);
        batch.timestamp = uint64(block.timestamp);
        // do actual verification

        bool verification_success = verifyProof(
            Circuit.EXIT, 
            proof, 
            lastVerifiedRoot, 
            committed.newRoot, 
            committed.publicDataCommitment
        );
        require(verification_success, "invalid proof");

        emit BlockVerified(blockNumber);
        lastVerifiedBlockNumber++;
        lastVerifiedExitBatch++;
        lastVerifiedRoot = committed.newRoot;
    }

    // transaction data is trivial: 3 bytes of in-plasma address, 16 bytes of amount
    // same a for partial exits - write to storage, so users can pull the balances later
    function processExitBlockData(
        uint256 batchNumber, 
        uint32 blockNumber,
        uint24[EXIT_BATCH_SIZE] memory accountIDs, 
        bytes memory txData
    ) 
    internal 
    {
        uint256 chunk;
        uint256 pointer = 32;
        address accountOwner;
        uint128 scaledAmount;
        uint32 tail;
        for (uint256 i = 0; i < EXIT_BATCH_SIZE; i++) { 
            // this is a cheap way to ensure that all requests are unique, without O(n) MSTORE
            // it also automatically guarantees that all requests requests from the batch have been executed
            if (accountIDs[i] == 0) {
                continue;
            }
            require(i == 0 || accountIDs[i] > accountIDs[i-1], "accountIDs are not properly ordered");
            assembly {
                chunk := mload(add(txData, pointer))
            }
            pointer += 19;
            
            require(accountIDs[i] == chunk >> 232, "invalid account ID in commitment");
            Account storage account = accounts[accountIDs[i]];
            require(account.state == uint8(AccountState.PENDING_EXIT), "there was no such exit request");
            require(account.exitBatchNumber == uint32(batchNumber), "account was registered for exit in another batch");

            // accountOwner = accounts[accountIDs[i]].owner;
            scaledAmount = uint128(chunk << 24 >> 128);
   
            ExitLeaf memory newLeaf;
            tail = account.exitListTail;
            if (tail == 0) {
                // create a fresh list that is both head and tail
                newLeaf = ExitLeaf(0, scaledAmount);
                exitLeafs[account.owner][blockNumber] = newLeaf;
                account.exitListTail = blockNumber;
            } else {
                // previous tail is somewhere in the past
                ExitLeaf storage previousExitLeaf = exitLeafs[account.owner][tail];

                newLeaf = ExitLeaf(0, scaledAmount);
                previousExitLeaf.nextID = blockNumber;

                exitLeafs[account.owner][blockNumber] = newLeaf;
                account.exitListTail = blockNumber;
            }

            // if there was no head - point to here
            if (account.exitListHead == 0) {
                account.exitListHead = blockNumber;
            }

            // exitAmounts[accountOwner][blockNumber] = scaledAmount;
            account.state = uint8(AccountState.UNCONFIRMED_EXIT);

            emit LogCompleteExit(accountOwner, blockNumber, accountIDs[i]);
        }
    }

    // function withdrawUserBalance(
    //     uint32[] blockNumbers
    // )
    // public
    // {
    //     require(blockNumbers.length > 0, "requires non-empty set");
    //     uint256 totalAmountInWei;
    //     uint32 blockNumber;
    //     for (uint256 i = 0; i < blockNumbers.length; i++) {
    //         blockNumber = blockNumbers[i]; 

    //         require(blockNumber <= lastVerifiedBlockNumber, "can only process exits from verified blocks");
    //         uint24 accountID = ethereumAddressToAccountID[msg.sender];
    //         uint128 balance;
    //         uint256 amountInWei;
    //         if (accountID != 0) {
    //             // user either didn't fully exit or didn't take full exit balance yet
    //             Account storage account = accounts[accountID];
    //             if (account.state == uint8(AccountState.UNCONFIRMED_EXIT)) {
    //                 uint256 batchNumber = account.exitBatchNumber;
    //                 ExitBatch storage batch = exitBatches[batchNumber];
    //                 if (blockNumber == batch.blockNumber) {
    //                     balance = exitAmounts[msg.sender][blockNumber];

    //                     delete accounts[accountID];
    //                     delete ethereumAddressToAccountID[msg.sender];
    //                     delete exitAmounts[msg.sender][blockNumber];

    //                     amountInWei = scaleFromPlasmaUnitsIntoWei(balance);
    //                     totalAmountInWei += amountInWei;
    //                     continue;
    //                 }
    //             }
    //         }
    //         // user account information is already deleted or it's not the block number where a full exit has happened
    //         // we require a non-zero balance in this case cause chain cleanup is not required
    //         balance = exitAmounts[msg.sender][blockNumber];

    //         require(balance != 0, "nothing to exit");
    //         delete exitAmounts[msg.sender][blockNumber];

    //         amountInWei = scaleFromPlasmaUnitsIntoWei(balance);
    //         totalAmountInWei += amountInWei;
    //     }
    //     msg.sender.transfer(totalAmountInWei);
    // }

    function withdrawUserBalance(
        uint256 iterationsLimit
    )
    public
    {
        require(iterationsLimit > 0, "must iterate");
        uint256 totalAmountInWei;
        uint256 amountInWei;
        uint24 accountID = ethereumAddressToAccountID[msg.sender];
        require(accountID != 0, "this should not happen as exiting happens one by one until the complete one");
        Account storage account = accounts[accountID];

        uint32 currentHead = account.exitListHead;
        uint32 nextHead = currentHead;

        for (uint256 i = 0; i < iterationsLimit; i++) {
            if (currentHead > lastVerifiedBlockNumber) {
                if (i == 0) {
                    revert("nothing to process");
                } else {
                    return;
                }
            }
            ExitLeaf storage leaf = exitLeafs[msg.sender][currentHead];

            amountInWei = scaleFromPlasmaUnitsIntoWei(leaf.amount);
            totalAmountInWei += amountInWei;

            // no matter if the next leafID is empty or not we can assign it

            nextHead = leaf.nextID;
            delete exitLeafs[msg.sender][currentHead];

            if (nextHead == 0 && account.state == uint8(AccountState.UNCONFIRMED_EXIT)) {
                // there is no next element AND account is exiting, so it must be the complete exit leaf
                uint256 batchNumber = account.exitBatchNumber;
                ExitBatch storage batch = exitBatches[batchNumber];
                require(currentHead == batch.blockNumber, "last item in the list should match the complete exit block");
                delete accounts[accountID];
                delete ethereumAddressToAccountID[msg.sender];
            }

            if (nextHead == 0) {
                // this is an end of the list
                break;
            } else {
                currentHead = nextHead;
            }

        }

        account.exitListHead = nextHead;
        if (nextHead == 0) {
            account.exitListTail = 0;
        }

        msg.sender.transfer(totalAmountInWei);
    }

}