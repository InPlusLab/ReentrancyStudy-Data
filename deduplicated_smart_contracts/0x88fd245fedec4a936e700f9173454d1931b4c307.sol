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

contract RewardVerifier {
    uint256 constant SNARK_SCALAR_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    using Pairing for *;

    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[13] IC;
    }

    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(uint256(4553325557779972549638085524729520109606974412790145636375195877897165216886), uint256(4565141803779308879478376883020155522080283243481641587848132552194011457072));
        vk.beta2 = Pairing.G2Point([uint256(21795043833158849315149822154703943190773888990789209572393217927874997233659), uint256(9615422013179423608802778137712723115287334517418332915037870133668489688426)], [uint256(11396906238363855568648033437869606181086174437666638187380697381691821736516), uint256(21037063051003766616135543879849442507547875476870425189552527497432564332212)]);
        vk.gamma2 = Pairing.G2Point([uint256(7897617957999673035799789355924936566094200042468389367289322993064642840432), uint256(19463087544215100433813799701170870746179128711738065221641284489355381288731)], [uint256(58428999331624262715765618678790212923533090177577710407545099890344901696), uint256(14699444274472253614650581997793263191127501025785560508155332237963676597243)]);
        vk.delta2 = Pairing.G2Point([uint256(6407260744615577253013273448670194267447326711790730923817563354209855187074), uint256(12602533981865761589016385150283329940681632535316295028389294423195275109849)], [uint256(21837290307680520538108368182839140442005581975111322692696846161833297300603), uint256(20480098371958932078081909162754900378918077956581547550208277048325758212340)]);
        vk.IC[0] = Pairing.G1Point(uint256(9056076546161075347166548970907008701734604665913838301067499903383113956445), uint256(18091340235754904503753420435552454028015977980747911843770207510030182936012));
        vk.IC[1] = Pairing.G1Point(uint256(6681438949395956520917327622263249539412039091387156741453534809339020135910), uint256(1340958998784938980995616579018897822284916882535450299280291172228690734785));
        vk.IC[2] = Pairing.G1Point(uint256(13721153540292832547465731745196759234656617630780310688322491862212848547376), uint256(13363320111049903674452086890312413184243161058502179598656179780619772458694));
        vk.IC[3] = Pairing.G1Point(uint256(3947539524660075952352833336050751102960910584366219908864344807665005387881), uint256(5294467160112437621707498299669708039892670197037014095410014311139995248229));
        vk.IC[4] = Pairing.G1Point(uint256(7077587025310054030193357832716270269250430755809333108365732575092218788355), uint256(20408356258800341963326551664354901814296197159253435028842468214163089104361));
        vk.IC[5] = Pairing.G1Point(uint256(18054387723555555996790083907154866220385980435327582076418943650470854331519), uint256(8799962658993895354624389497858052615707186345602672578895149164056775889727));
        vk.IC[6] = Pairing.G1Point(uint256(21377038878160605027683129665314526547485676187054306522335257385974528927831), uint256(10882837078278830115600319485476502490060770549128822573370259485992296981482));
        vk.IC[7] = Pairing.G1Point(uint256(20942312410047293785720152899299458461135756113589362698268600238532678374237), uint256(5857164022407541162893158106376785667807060754157295039657399796122351210523));
        vk.IC[8] = Pairing.G1Point(uint256(12673742463344061699927863980969981283012056109327725502697371523935062608675), uint256(16052864217724030939862680095107248838213648618452863627753558357913695369152));
        vk.IC[9] = Pairing.G1Point(uint256(2367963805563200759391143443496600646345573390209267553258281553419200351627), uint256(13537910469027724695463700821189197899269679775558309729818311085021850548494));
        vk.IC[10] = Pairing.G1Point(uint256(10425027035798488340765632713230081375263983094092100225324756523152460367667), uint256(13579817268424669677540588784132407231682927560248859539634692695555741320973));
        vk.IC[11] = Pairing.G1Point(uint256(12924832128545372328233083705303231769607023817607236436720126794211844310733), uint256(6665070279895487624101555009565693557628389349007526873122823248540198667409));
        vk.IC[12] = Pairing.G1Point(uint256(7251847029011483783651651560962158546305886865520516646384597057701803813578), uint256(12225818222075046279997517934018271636586087932625938280382792436395600261252));

    }

    /*
     * @returns Whether the proof is valid given the hardcoded verifying key
     *          above and the public inputs
     */
    function verifyProof(
        bytes memory proof,
        uint256[12] memory input
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