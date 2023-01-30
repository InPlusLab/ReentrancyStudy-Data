pragma solidity ^0.6.3;

import "./ZeneKa.sol";

// Based on ZoKrates Verifier @ https://github.com/Zokrates/ZoKrates

contract ZeneKaG16 is ZeneKa {
    using Pairing for *;

    struct VerifyingKeyG16 {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }

    struct ProofG16 {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }

    struct ParamsG16 {
        bytes32[2] a;
        bytes32[2][2] b;
        bytes32[2][2] gamma;
        bytes32[2][2] delta;
        uint256 gamma_abc_len;
        bytes32[2][] gamma_abc;
        bool registered;
    }

    mapping(bytes32 => ParamsG16) private _idToVkParamsG16;

    function _verifyingKeyG16(bytes32 _id)
        internal
        view
        returns (VerifyingKeyG16 memory vk)
    {
        ParamsG16 memory params = _idToVkParamsG16[_id];

        vk.a = Pairing.G1Point(uint256(params.a[0]), uint256(params.a[1]));
        vk.b = Pairing.G2Point(
            [uint256(params.b[0][0]), uint256(params.b[0][1])],
            [uint256(params.b[1][0]), uint256(params.b[1][1])]
        );
        vk.gamma = Pairing.G2Point(
            [uint256(params.gamma[0][0]), uint256(params.gamma[0][1])],
            [uint256(params.gamma[1][0]), uint256(params.gamma[1][1])]
        );
        vk.delta = Pairing.G2Point(
            [uint256(params.delta[0][0]), uint256(params.delta[0][1])],
            [uint256(params.delta[1][0]), uint256(params.delta[1][1])]
        );
        vk.gamma_abc = new Pairing.G1Point[](params.gamma_abc_len);
        for (uint256 i = 0; i < params.gamma_abc_len; i++) {
            vk.gamma_abc[i] = Pairing.G1Point(
                uint256(params.gamma_abc[i][0]),
                uint256(params.gamma_abc[i][1])
            );
        }
    }

    function registerG16(
        bytes32[2] memory _a,
        bytes32[2][2] memory _b,
        bytes32[2][2] memory _gamma,
        bytes32[2][2] memory _delta,
        uint256 _gamma_abc_len,
        bytes32[2][] memory _gamma_abc
    ) public returns (bool isRegistered) {
        bytes32 id = keccak256(
            abi.encodePacked(_a, _b, _gamma, _delta, _gamma_abc_len, _gamma_abc)
        );

        if (_idToVkParamsG16[id].registered) return true;

        _idToVkParamsG16[id] = ParamsG16({
            a: _a,
            b: _b,
            gamma: _gamma,
            delta: _delta,
            gamma_abc_len: _gamma_abc_len,
            gamma_abc: _gamma_abc,
            registered: true
        });

        emit Register(id, msg.sender);
        return true;
    }

    function commitG16(bytes32 _id, bytes32 _proofHash)
        public
        returns (bool didCommit)
    {
        // Stores a proof hash (throws if pre-existing value)
        if (
            !_idToVkParamsG16[_id].registered ||
            _proofHashToProver[_proofHash] != address(0)
        ) return false;
        _proofHashToProver[_proofHash] = msg.sender;
        _proofHashToBlock[_proofHash] = block.number;
        emit Commit(_id, _proofHash, msg.sender);
        return true;
    }

    function proveG16(
        bytes32 _id,
        uint256[2] memory _a,
        uint256[2][2] memory _b,
        uint256[2] memory _c,
        uint256[] memory _input
    ) public returns (bool isValid) {
        bytes32 proofHash = keccak256(abi.encodePacked(_a, _b, _c, _input));
        if (_proofHashToProven[proofHash]) return true;
        if (
            !_idToVkParamsG16[_id].registered ||
            _proofHashToProver[proofHash] != msg.sender ||
            block.number <= _proofHashToBlock[proofHash]
        ) return false;

        VerifyingKeyG16 memory vk = _verifyingKeyG16(_id);
        if (_input.length + 1 != _idToVkParamsG16[_id].gamma_abc_len)
            return false;
        ProofG16 memory proof;
        proof.a = Pairing.G1Point(_a[0], _a[1]);
        proof.b = Pairing.G2Point([_b[0][0], _b[0][1]], [_b[1][0], _b[1][1]]);
        proof.c = Pairing.G1Point(_c[0], _c[1]);
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint256 i = 0; i < _input.length; i++) {
            if (_input[i] >= SNARK_SCALAR_FIELD) return false;
            vk_x = Pairing.addition(
                vk_x,
                Pairing.scalar_mul(vk.gamma_abc[i + 1], _input[i])
            );
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if (
            !Pairing.pairingProd4(
                proof.a,
                proof.b,
                Pairing.negate(vk_x),
                vk.gamma,
                Pairing.negate(proof.c),
                vk.delta,
                Pairing.negate(vk.a),
                vk.b
            )
        ) return false;

        _verified(_id, proofHash, _input);
        return true;
    }
}
