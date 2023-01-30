pragma solidity ^0.6.3;

import "./ZeneKa.sol";

// Based on ZoKrates Verifier @ https://github.com/Zokrates/ZoKrates

contract ZeneKaPGHR13 is ZeneKa {
    struct VerifyingKeyPGHR13 {
        Pairing.G2Point a;
        Pairing.G1Point b;
        Pairing.G2Point c;
        Pairing.G2Point gamma;
        Pairing.G1Point gamma_beta_1;
        Pairing.G2Point gamma_beta_2;
        Pairing.G2Point z;
        Pairing.G1Point[] ic;
    }

    struct ProofPGHR13 {
        Pairing.G1Point a;
        Pairing.G1Point a_p;
        Pairing.G2Point b;
        Pairing.G1Point b_p;
        Pairing.G1Point c;
        Pairing.G1Point c_p;
        Pairing.G1Point k;
        Pairing.G1Point h;
    }

    struct ParamsPGHR13 {
        bytes32[2][2] a;
        bytes32[2] b;
        bytes32[2][2] c;
        bytes32[2][2] gamma;
        bytes32[2] gamma_beta_1;
        bytes32[2][2] gamma_beta_2;
        bytes32[2][2] z;
        uint256 ic_len;
        bytes32[2][] ic;
        bool registered;
    }

    mapping(bytes32 => ParamsPGHR13) private _idToVkParamsPGHR13;

    function _verifyingKeyPGHR13(bytes32 _id)
        internal
        view
        returns (VerifyingKeyPGHR13 memory vk)
    {
        ParamsPGHR13 memory params = _idToVkParamsPGHR13[_id];

        vk.a = Pairing.G2Point(
            [uint256(params.a[0][0]), uint256(params.a[0][1])],
            [uint256(params.a[1][0]), uint256(params.a[1][1])]
        );
        vk.b = Pairing.G1Point(uint256(params.b[0]), uint256(params.b[1]));
        vk.c = Pairing.G2Point(
            [uint256(params.c[0][0]), uint256(params.c[0][1])],
            [uint256(params.c[1][0]), uint256(params.c[1][1])]
        );
        vk.gamma = Pairing.G2Point(
            [uint256(params.gamma[0][0]), uint256(params.gamma[0][1])],
            [uint256(params.gamma[1][0]), uint256(params.gamma[1][1])]
        );
        vk.gamma_beta_1 = Pairing.G1Point(
            uint256(params.gamma_beta_1[0]),
            uint256(params.gamma_beta_1[1])
        );
        vk.gamma_beta_2 = Pairing.G2Point(
            [
                uint256(params.gamma_beta_2[0][0]),
                uint256(params.gamma_beta_2[0][1])
            ],
            [
                uint256(params.gamma_beta_2[1][0]),
                uint256(params.gamma_beta_2[1][1])
            ]
        );
        vk.z = Pairing.G2Point(
            [uint256(params.z[0][0]), uint256(params.z[0][1])],
            [uint256(params.z[1][0]), uint256(params.z[1][1])]
        );
        vk.ic = new Pairing.G1Point[](params.ic_len);
        for (uint256 i = 0; i < params.ic_len; i++) {
            vk.ic[i] = Pairing.G1Point(
                uint256(params.ic[i][0]),
                uint256(params.ic[i][1])
            );
        }
    }

    function registerPGHR13(
        bytes32[2][2] memory _a,
        bytes32[2] memory _b,
        bytes32[2][2] memory _c,
        bytes32[2][2] memory _gamma,
        bytes32[2] memory _gamma_beta_1,
        bytes32[2][2] memory _gamma_beta_2,
        bytes32[2][2] memory _z,
        uint256 _ic_len,
        bytes32[2][] memory _ic
    ) public returns (bool isRegistered) {
        bytes32 id = keccak256(
            abi.encodePacked(
                _a,
                _b,
                _c,
                _gamma,
                _gamma_beta_1,
                _gamma_beta_2,
                _z,
                _ic_len,
                _ic
            )
        );

        if (_idToVkParamsPGHR13[id].registered) return true;

        _idToVkParamsPGHR13[id] = ParamsPGHR13({
            a: _a,
            b: _b,
            c: _c,
            gamma: _gamma,
            gamma_beta_1: _gamma_beta_1,
            gamma_beta_2: _gamma_beta_2,
            z: _z,
            ic_len: _ic_len,
            ic: _ic,
            registered: true
        });

        emit Register(id, msg.sender);
        return true;
    }

    function commitPGHR13(bytes32 _id, bytes32 _proofHash)
        public
        returns (bool didCommit)
    {
        // Stores a proof hash (throws if pre-existing value)
        if (
            !_idToVkParamsPGHR13[_id].registered ||
            _proofHashToProver[_proofHash] != address(0)
        ) return false;
        _proofHashToProver[_proofHash] = msg.sender;
        _proofHashToBlock[_proofHash] = block.number;
        emit Commit(_id, _proofHash, msg.sender);
        return true;
    }

    function provePGHR13(
        bytes32 _id,
        uint256[2] memory _a,
        uint256[2] memory _a_p,
        uint256[2][2] memory _b,
        uint256[2] memory _b_p,
        uint256[2] memory _c,
        uint256[2] memory _c_p,
        uint256[2] memory _h,
        uint256[2] memory _k,
        uint256[] memory _input
    ) public returns (bool isValid) {
        bytes32 proofHash = keccak256(
            abi.encodePacked(_a, _a_p, _b, _b_p, _c, _c_p, _h, _k, _input)
        );
        if (_proofHashToProven[proofHash]) return true;
        if (
            !_idToVkParamsPGHR13[_id].registered ||
            _proofHashToProver[proofHash] != msg.sender ||
            block.number <= _proofHashToBlock[proofHash]
        ) return false;

        VerifyingKeyPGHR13 memory vk = _verifyingKeyPGHR13(_id);
        if (_input.length + 1 != _idToVkParamsPGHR13[_id].ic_len) return false;
        ProofPGHR13 memory proof;
        proof.a = Pairing.G1Point(_a[0], _a[1]);
        proof.a_p = Pairing.G1Point(_a_p[0], _a_p[1]);
        proof.b = Pairing.G2Point([_b[0][0], _b[0][1]], [_b[1][0], _b[1][1]]);
        proof.b_p = Pairing.G1Point(_b_p[0], _b_p[1]);
        proof.c = Pairing.G1Point(_c[0], _c[1]);
        proof.c_p = Pairing.G1Point(_c_p[0], _c_p[1]);
        proof.h = Pairing.G1Point(_h[0], _h[1]);
        proof.k = Pairing.G1Point(_k[0], _k[1]);

        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint256 i = 0; i < _input.length; i++) {
            if (_input[i] >= SNARK_SCALAR_FIELD) return false;
            vk_x = Pairing.addition(
                vk_x,
                Pairing.scalar_mul(vk.ic[i + 1], _input[i])
            );
        }
        vk_x = Pairing.addition(vk_x, vk.ic[0]);
        if (
            !Pairing.pairingProd2(
                proof.a,
                vk.a,
                Pairing.negate(proof.a_p),
                Pairing.P2()
            ) ||
            !Pairing.pairingProd2(
                vk.b,
                proof.b,
                Pairing.negate(proof.b_p),
                Pairing.P2()
            ) ||
            !Pairing.pairingProd2(
                proof.c,
                vk.c,
                Pairing.negate(proof.c_p),
                Pairing.P2()
            ) ||
            !Pairing.pairingProd3(
                proof.k,
                vk.gamma,
                Pairing.negate(
                    Pairing.addition(vk_x, Pairing.addition(proof.a, proof.c))
                ),
                vk.gamma_beta_2,
                Pairing.negate(vk.gamma_beta_1),
                proof.b
            ) ||
            !Pairing.pairingProd3(
                Pairing.addition(vk_x, proof.a),
                proof.b,
                Pairing.negate(proof.h),
                vk.z,
                Pairing.negate(proof.c),
                Pairing.P2()
            )
        ) return false;

        _verified(_id, proofHash, _input);
        return true;
    }
}
