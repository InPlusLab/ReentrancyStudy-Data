pragma solidity ^0.5.0;

import "./EtheleToken.sol";

/**
 * Generator of all 7 Etherem Elements (Ethele) ERC20 Token Contracts.
 * There are 5 Ethele Elements Tokens: Fire, Earth, Metal, Water, Wood.
 * There are 2 Ethele YinYang Tokens: Yin, Yang.
 */
contract EtheleGenerator {
    address private _fire;
    address private _earth;
    address private _metal;
    address private _water;
    address private _wood;
    address private _yin;
    address private _yang;

    uint256 private _step; // The deploy process has to be completed in steps, because the gas needed is too large.

    uint256 private constant LAUNCH_TIME = 1565438400; // Ethele Token address will only be able to be created after mainnet launch.

    // Set step to 0. Step function can be called after launch time for creation of all 7 Ethele Tokens
    // and assignment of Ethele token transmuteSources and allowBurnsFrom for interaction between the contracts.
    constructor() public {
        _step = 0;
    }

    function getLaunchTime() public pure returns (uint256) {
        return LAUNCH_TIME;
    }

    function step() public {
        require(_step <= 3 && LAUNCH_TIME < block.timestamp);

        if (_step == 0) {
            _fire = address(new EtheleToken("Ethele Fire", "EEFI"));
            _earth = address(new EtheleToken("Ethele Earth", "EEEA"));
        } else if (_step == 1) {
            _metal = address(new EtheleToken("Ethele Metal", "EEME"));
            _water = address(new EtheleToken("Ethele Water", "EEWA"));
        } else if (_step == 2) {
            _wood = address(new EtheleToken("Ethele Wood", "EEWO"));
            _yin = address(new EtheleToken("Ethele Yin", "EEYI"));
        } else if (_step == 3) {
            _yang = address(new EtheleToken("Ethele Yang", "EEYA"));
            // Each of the 5 elements has 2 elements which create it. 
            EtheleToken(_fire).setTransmuteSources12(_metal, _wood);
            EtheleToken(_earth).setTransmuteSources12(_water, _fire);
            EtheleToken(_metal).setTransmuteSources12(_wood, _earth);
            EtheleToken(_water).setTransmuteSources12(_fire, _metal);
            EtheleToken(_wood).setTransmuteSources12(_earth, _water);
            
            // 1 Yin and 1 Yang creates 1 of any element of choice.
            EtheleToken(_fire).setTransmuteSources34(_yin, _yang);
            EtheleToken(_earth).setTransmuteSources34(_yin, _yang);
            EtheleToken(_metal).setTransmuteSources34(_yin, _yang);
            EtheleToken(_water).setTransmuteSources34(_yin, _yang);
            EtheleToken(_wood).setTransmuteSources34(_yin, _yang);

            // Allow each element to burn the components that are transmuted to it.
            EtheleToken(_metal).allowBurnsFrom(_fire);
            EtheleToken(_wood).allowBurnsFrom(_fire);
            EtheleToken(_water).allowBurnsFrom(_earth);
            EtheleToken(_fire).allowBurnsFrom(_earth);
            EtheleToken(_wood).allowBurnsFrom(_metal);
            EtheleToken(_earth).allowBurnsFrom(_metal);
            EtheleToken(_fire).allowBurnsFrom(_water);
            EtheleToken(_metal).allowBurnsFrom(_water);
            EtheleToken(_earth).allowBurnsFrom(_wood);
            EtheleToken(_water).allowBurnsFrom(_wood);

            // All 5 elements are allowed to burn yin and yang.
            // Because Yin + Yang can transmute to any of the 5 elements. 
            EtheleToken(_yin).allowBurnsFrom(_fire);
            EtheleToken(_yin).allowBurnsFrom(_earth);
            EtheleToken(_yin).allowBurnsFrom(_metal);
            EtheleToken(_yin).allowBurnsFrom(_water);
            EtheleToken(_yin).allowBurnsFrom(_wood);
            EtheleToken(_yang).allowBurnsFrom(_fire);
            EtheleToken(_yang).allowBurnsFrom(_earth);
            EtheleToken(_yang).allowBurnsFrom(_metal);
            EtheleToken(_yang).allowBurnsFrom(_water);
            EtheleToken(_yang).allowBurnsFrom(_wood);
        }

        _step += 1;
    }

    function getStep() public view returns (uint256) {
        return _step;
    }
    function fire() public view returns (address) {
        return _fire;
    }
    function earth() public view returns (address) {
        return _earth;
    }
    function metal() public view returns (address) {
        return _metal;
    }
    function water() public view returns (address) {
        return _water;
    }
    function wood() public view returns (address) {
        return _wood;
    }
    function yin() public view returns (address) {
        return _yin;
    }
    function yang() public view returns (address) {
        return _yang;
    }
}
