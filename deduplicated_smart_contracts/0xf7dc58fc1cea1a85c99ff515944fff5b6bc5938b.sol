/**
 *Submitted for verification at Etherscan.io on 2019-09-03
*/

pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract LAIToken {
	// Setting constant
	uint256 constant public TOTAL_TOKEN = 10 ** 9;
	uint256 constant public TOKEN_FOR_ICO = 550 * 10 ** 6;
	uint256 constant public TOKEN_FOR_BONUS = 50 * 10 ** 6;
	uint256 constant public TOKEN_FOR_COMPANY = 300 * 10 ** 6;
	uint256 constant public TOKEN_FOR_INDIVIDUAL = 100 * 10 ** 6;
	
	uint256 public tokenForCompany;
	uint public period = 1;

	uint public startTime;
	
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 8;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function LAIToken(
    ) public {
        totalSupply = TOTAL_TOKEN * 10 ** uint256(decimals); // Update total supply with the decimal amount
        name = "LAI Token";                                 // Set the name for display purposes
        symbol = "LAI";                               		// Set the symbol for display purposes
		
		// Initializes
		startTime = 1512997200; // need to update start time
		
		// INDIVIDUAL 
		// 1.TECH TEAM
		balanceOf[0xE0C6d444C475A89e50eD6C05314263D1B280d8D8] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xc53a01d0711C433b37EA85A08B6CDcad5977c6EE] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x710a332d19FC37eE9FFBb52F4F6e4d08db10f769] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xA24fab2B636e238F4581F881D9a76a5C38207bf4] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x151dB6D9e1e6E3599d5eeeD7E0Ad8Cf2cEb42D09] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x30626Fa60154f9102e3b977CAb66E4424Ed14fe6] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		// 2.XDMT - TGTX
		balanceOf[0xc3e359019bCc6888250916361f4b8c6c719474c3] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x769ef98835685cD5B569443cd8ea8C35420ba3dD] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x67fd37B157843B5750aB35E96C98d5720e827c17] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x54A5C24000f22338587B59E8F04227E60bbFd4cD] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x3E56DcCd10b7965d1C314ac1D60A0dA3ED09a8f7] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xd462B827A1fDAE6B34C020ca86Ed1312a11A1676] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x4451d98b978e3A3D738A087dFf15cfe294fb5b1D] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		// 3.HTD
		balanceOf[0x382f5304782C146243259f1ADD021aDD8D50D719] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x4451d98b978e3A3D738A087dFf15cfe294fb5b1D] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xa239BBF3F85a8aEFA4a7ab7C6C9AC75879903C65] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x9a02aE27Af9771622D8D6Bf39BE2e1c3976F89d0] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x9dD2155921Fc27229EE57dd4F1F95B5014Fd1F91] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x86c0e8353E0b5c2c998D8dD09c16A0F0d75813d9] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xc31fdD93B26Ba08c11614914bc035cde5565D005] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x52D639E2254591d8ba938f316019d860bD104fbe] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x0099a03937543720Fd9050bBF3DF4f0BB7d3A6F3] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x3C59022Fa73A9D521AD9C8C4843FDe858EE1d536] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x1587134f21156C55b153EC73F5A90AA3d029cA75] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xAdb5566880D8b0463DfCcC31804a727E419d9D19] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		// 4.Butta		
		balanceOf[0x3CB617913C6Ab9b4bc0CF17C2fAEBe3149E58dC6] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x39535CfC26F74F73C2508922140c5859B733ec67] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x7906A41853dA81E0e1bC122687C47fc4fb02e1e8] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x1C30f6dCe6a955f68a644cd08058A71C0b5211BC] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		// 5.Du phong
		balanceOf[0x2d55C27207F47A2B06dC164f30Bd477C174AfA22] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xCD9c24061A8BF99Afce291B98eEa8C6D384AF20a] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x360A12310E7Ea8FBc4f13b372eeF4Faf9Ee6F18b] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x0271869e03b8F03A3Cd2E6cd2992322BdF017A63] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x08E2500116eeCfFC597daC6750f6c4B80A52810E] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x696c7Fc8d746c9Fd9E0c365de795601aa494e9bD] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x7b65D808d1d5a2CfB217385Bd225AF541Cf64E06] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		// 6.Private investor
		balanceOf[0x28826530DC2b4bee050F946236c4De1846523209] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xe5E7Ba0df9c1321F28FD330722705C6504525f78] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xb57ACF012d41D95CABb91C1CBf4461605Edc5a47] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xf6e5E30338C2f11ED30c96Cb68d820beF837cd61] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x379e136247864468B80c158643BDa3101d22e252] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x39cb2246d335c33a52831e7a1913208bb755B506] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xbE218E067A2Cc86222c904cFF7e7e4e04a010a87] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xCc3985704019E39c526438CAEd107bfC32403fDa] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xCB79a26d969bb1FCe352407F42f46bc22a861624] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xeA68D5BD9E63c3795D81Ffae7D20423Ebe924D05] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		// 7.Advisor
		balanceOf[0x3252c8451f295f078654A68Af4a1363F5Dc9137b] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x8E50B7cC390a3EADCffbB2880f02Ff66d7F648e7] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0xB6A8F95E2E87045c512be48766ef20a5EF349d20] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x3f62c536A29db068c30B637880D61e1Cf27F24F8] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		balanceOf[0x86C942186C3C09E7856488821497B713058563fb] = TOKEN_FOR_INDIVIDUAL * 10 ** uint256(decimals) * 2 / 100;
		
		// COMPANY, ICO, BONUS
		balanceOf[0x966F2884524858326DfF216394a61b9894166c68] = TOKEN_FOR_ICO * 10 ** uint256(decimals);
		tokenForCompany = TOKEN_FOR_COMPANY * 10 ** uint256(decimals);
		balanceOf[0xf28edB52E808cd9DCe18A87fD94D373D6B9f65ae] = tokenForCompany * 10 / 100;// 10% in the beginning
		tokenForCompany = tokenForCompany * 90 / 100;
		balanceOf[0x919afCd5bDf9e8a6cff95cB5016F9DD5FeDbdEC5] = TOKEN_FOR_BONUS * 10 ** uint256(decimals);
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
	
	function companyPeriodFund() public {
		// Second period after 1 year
		if (now >= startTime + 365 days && period == 1) {
			period = 2;
			balanceOf[0xf28edB52E808cd9DCe18A87fD94D373D6B9f65ae] += TOKEN_FOR_COMPANY * 10 ** uint256(decimals) * 4 / 10;
			tokenForCompany -= TOKEN_FOR_COMPANY * 10 ** uint256(decimals) * 4 / 10;
		}
		
		// Third period after 2 years
		if (now >= startTime + 730 days && period == 2) {
			period = 3;
			balanceOf[0xf28edB52E808cd9DCe18A87fD94D373D6B9f65ae] += TOKEN_FOR_COMPANY * 10 ** uint256(decimals) * 5 / 10;
			tokenForCompany -= TOKEN_FOR_COMPANY * 10 ** uint256(decimals) * 5 / 10;		
		}
    }
}