/**
 *Submitted for verification at Etherscan.io on 2020-11-19
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract CompositeVaultMaster {
    address public governance;

    address public valueToken = address(0x49E833337ECe7aFE375e44F4E3e8481029218E5c);

    address public govVault = address(0xceC03a960Ea678A2B6EA350fe0DbD1807B22D875); // 14.0% profit from Value Vaults
    address public insuranceFund = 0xb7b2Ea8A1198368f950834875047aA7294A2bDAa; // set to Governance Multisig at start
    address public performanceReward = 0x7Be4D5A99c903C437EC77A20CB6d0688cBB73c7f; // set to deploy wallet at start

    uint256 public govVaultProfitShareFee = 1400; // 14.0% | VIP-7 (https://yfv.finance/vip-vote/vip_7)
    uint256 public gasFee = 50; // 0.5% at start and can be set by governance decision
    uint256 public insuranceFee = 0; // 6% | VIP-10 (to compensate who lost during the exploit on Nov 14 2020)
    uint256 public withdrawalProtectionFee = 0; // % of withdrawal go back to vault (for auto-compounding) to protect withdrawals

    mapping(address => address) public bank;
    mapping(address => bool) public isVault;
    mapping(address => bool) public isController;
    mapping(address => bool) public isStrategy;

    mapping(address => uint) public slippage; // over 10000

    constructor(address _valueToken) public {
        if (_valueToken != address(0)) valueToken = _valueToken;
        governance = msg.sender;
    }

    function setGovernance(address _governance) external {
        require(msg.sender == governance, "!governance");
        governance = _governance;
    }

    function setBank(address _vault, address _bank) external {
        require(msg.sender == governance, "!governance");
        bank[_vault] = _bank;
    }

    function addVault(address _vault) external {
        require(msg.sender == governance, "!governance");
        isVault[_vault] = true;
    }

    function removeVault(address _vault) external {
        require(msg.sender == governance, "!governance");
        isVault[_vault] = false;
    }

    function addController(address _controller) external {
        require(msg.sender == governance, "!governance");
        isController[_controller] = true;
    }

    function removeController(address _controller) external {
        require(msg.sender == governance, "!governance");
        isController[_controller] = true;
    }

    function addStrategy(address _strategy) external {
        require(msg.sender == governance, "!governance");
        isStrategy[_strategy] = true;
    }

    function removeStrategy(address _strategy) external {
        require(msg.sender == governance, "!governance");
        isStrategy[_strategy] = false;
    }

    function setGovVault(address _govVault) public {
        require(msg.sender == governance, "!governance");
        govVault = _govVault;
    }

    function setInsuranceFund(address _insuranceFund) public {
        require(msg.sender == governance, "!governance");
        insuranceFund = _insuranceFund;
    }

    function setPerformanceReward(address _performanceReward) public{
        require(msg.sender == governance, "!governance");
        performanceReward = _performanceReward;
    }

    function setGovVaultProfitShareFee(uint256 _govVaultProfitShareFee) public {
        require(msg.sender == governance, "!governance");
        require(_govVaultProfitShareFee <= 3000, "_govVaultProfitShareFee over 30%");
        govVaultProfitShareFee = _govVaultProfitShareFee;
    }

    function setGasFee(uint256 _gasFee) public {
        require(msg.sender == governance, "!governance");
        require(_gasFee <= 500, "_gasFee over 5%");
        gasFee = _gasFee;
    }

    function setInsuranceFee(uint256 _insuranceFee) public {
        require(msg.sender == governance, "!governance");
        require(_insuranceFee <= 2000, "_insuranceFee over 20%");
        insuranceFee = _insuranceFee;
    }

    function setWithdrawalProtectionFee(uint256 _withdrawalProtectionFee) public {
        require(msg.sender == governance, "!governance");
        require(_withdrawalProtectionFee <= 100, "_withdrawalProtectionFee over 1%");
        withdrawalProtectionFee = _withdrawalProtectionFee;
    }

    function setSlippage(address _token, uint _slippage) external {
        require(msg.sender == governance, "!governance");
        require(_slippage <= 1000, ">10%");
        slippage[_token] = _slippage;
    }

    function convertSlippage(address _input, address _output) view external returns (uint) {
        uint _is = slippage[_input];
        uint _os = slippage[_output];
        return (_is > _os) ? _is : _os;
    }

    /**
     * This function allows governance to take unsupported tokens out of the contract. This is in an effort to make someone whole, should they seriously mess up.
     * There is no guarantee governance will vote to return these. It also allows for removal of airdropped tokens.
     */
    function governanceRecoverUnsupported(IERC20 _token, uint256 amount, address to) external {
        require(msg.sender == governance, "!governance");
        _token.transfer(to, amount);
    }
}