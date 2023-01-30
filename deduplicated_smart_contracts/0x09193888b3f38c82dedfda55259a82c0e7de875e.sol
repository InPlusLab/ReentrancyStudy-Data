/**
 *Submitted for verification at Etherscan.io on 2020-12-18
*/

/**
* https://tornado.cash
*
* d888888P                                           dP              a88888b.                   dP
*    88                                              88             d8'   `88                   88
*    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
*    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
*    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
*    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
* ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

library Pairing {
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    /*
     * @return The negation of p, i.e. p.plus(p.negate()) should be zero
     */
    function negate(G1Point memory p) internal pure returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        if (p.X == 0 && p.Y == 0) {
            return G1Point(0, 0);
        } else {
            return G1Point(p.X, PRIME_Q - (p.Y % PRIME_Q));
        }
    }

    /*
     * @return r the sum of two points of G1
     */
    function plus(
        G1Point memory p1,
        G1Point memory p2
    ) internal view returns (G1Point memory r) {
        uint256[4] memory input = [
            p1.X, p1.Y,
            p2.X, p2.Y
        ];
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success, "pairing-add-failed");
    }

    /*
     * @return r the product of a point on G1 and a scalar, i.e.
     *         p == p.scalarMul(1) and p.plus(p) == p.scalarMul(2) for all
     *         points p.
     */
    function scalarMul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {
        uint256[3] memory input = [p.X, p.Y, s];
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success, "pairing-mul-failed");
    }

    /* @return The result of computing the pairing check
     *         e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
     *         For example,
     *         pairing([P1(), P1().negate()], [P2(), P2()]) should return true.
     */
    function pairing(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2,
        G1Point memory d1,
        G2Point memory d2
    ) internal view returns (bool) {
        uint256[24] memory input = [
            a1.X, a1.Y, a2.X[0], a2.X[1], a2.Y[0], a2.Y[1],
            b1.X, b1.Y, b2.X[0], b2.X[1], b2.Y[0], b2.Y[1],
            c1.X, c1.Y, c2.X[0], c2.X[1], c2.Y[0], c2.Y[1],
            d1.X, d1.Y, d2.X[0], d2.X[1], d2.Y[0], d2.Y[1]
        ];
        uint256[1] memory out;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 8, input, mul(24, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success, "pairing-opcode-failed");
        return out[0] != 0;
    }
}

contract WithdrawVerifier {
    uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    using Pairing for *;

    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[8] IC;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(uint256(8003191257131475466332871572552293218053851410737192258998234109174556022307), uint256(3985238886789381197445132520560863079216250367377662287252232673732932469598));
        vk.beta2 = Pairing.G2Point([uint256(9761764439235554326625625306157510890479546648653445898697927151594103249767), uint256(15291887334342321936190920690152242978241756445106371841067398891063016563003)], [uint256(3276588401921358149828146830444994682669968631310129515921610234309100323951), uint256(21453759654473037353413650351257422599525803745872499972193770620265023611146)]);
        vk.gamma2 = Pairing.G2Point([uint256(21437784757841709926483525215263031111190835510089174002450847296894914679571), uint256(14633042729397704382101842169496928278140071581078443512908669024804415179470)], [uint256(21846661153976494232047264549823968857156054359204182571614737710608838050308), uint256(19016430073612127654119594015944105089810951855757623945306573100498262950530)]);
        vk.delta2 = Pairing.G2Point([uint256(12989087773594380352701218080969070737137255023238591515387627903045526551576), uint256(18422521064170995525023530832353180455641410936473320843047252868174656188287)], [uint256(1582843353599041149507309163422983238637957760735999464217682245004035464980), uint256(9834675776153140008342079706185528826990599320364135593694920261188780980245)]);
        vk.IC[0] = Pairing.G1Point(uint256(2018238709384403246832418277863490039734292006123124819472943552929960101608), uint256(19906881758199409019400165150326704020216266606107089415086367868943208181826));
        vk.IC[1] = Pairing.G1Point(uint256(10099083955400060641875040462979459736085518901365922541295062403348638556991), uint256(6042047747015005355358104322469150692693114673776937121173533000229766712043));
        vk.IC[2] = Pairing.G1Point(uint256(18642384784378086543983998291685447214057157988406464804325053504673092317812), uint256(18980968361413722147178276318974922813461202396877512311747491957603620357086));
        vk.IC[3] = Pairing.G1Point(uint256(20987708717888899318373336825162136767216380363407343566633013326952280647154), uint256(104908931723811397542812880522603531301033242887066810851897901081959922779));
        vk.IC[4] = Pairing.G1Point(uint256(3162595513976230784991590390745141465766743252210750274725492652565075572705), uint256(16112294705605943709788936539870722970891977266269610720136188448621403578508));
        vk.IC[5] = Pairing.G1Point(uint256(9983848770537063730360295728129397568886807302741008612287483246495887774221), uint256(16246744176108594465765605925268282288770046146810238223901195837028789903051));
        vk.IC[6] = Pairing.G1Point(uint256(19846979889282629928479250604086913282916037272241605940180327645658195033510), uint256(10557919111633117331029389521021115135297376962895686546486534933571580591540));
        vk.IC[7] = Pairing.G1Point(uint256(7070363800118989192445809582331478863252468333509534650956253651537224897224), uint256(15789832792546432685819337101028064415335311645064701122329861504338928655950));

    }

    /*
     * @returns Whether the proof is valid given the hardcoded verifying key
     *          above and the public inputs
     */
    function verifyProof(
        bytes memory proof,
        uint256[7] memory input
    ) public view returns (bool) {
        uint256[8] memory p = abi.decode(proof, (uint256[8]));
        for (uint8 i = 0; i < p.length; i++) {
            // Make sure that each element in the proof is less than the prime q
            require(p[i] < PRIME_Q, "verifier-proof-element-gte-prime-q");
        }
        Pairing.G1Point memory proofA = Pairing.G1Point(p[0], p[1]);
        Pairing.G2Point memory proofB = Pairing.G2Point([p[2], p[3]], [p[4], p[5]]);
        Pairing.G1Point memory proofC = Pairing.G1Point(p[6], p[7]);

        VerifyingKey memory vk = verifyingKey();
        // Compute the linear combination vkX
        Pairing.G1Point memory vkX = vk.IC[0];
        for (uint256 i = 0; i < input.length; i++) {
            // Make sure that every input is less than the snark scalar field
            require(input[i] < SNARK_SCALAR_FIELD, "verifier-input-gte-snark-scalar-field");
            vkX = Pairing.plus(vkX, Pairing.scalarMul(vk.IC[i + 1], input[i]));
        }

        return Pairing.pairing(
            Pairing.negate(proofA),
            proofB,
            vk.alfa1,
            vk.beta2,
            vkX,
            vk.gamma2,
            proofC,
            vk.delta2
        );
    }
}