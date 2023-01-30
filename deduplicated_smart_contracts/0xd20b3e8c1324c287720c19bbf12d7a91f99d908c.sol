/**
 *Submitted for verification at Etherscan.io on 2019-07-27
*/

pragma solidity ^ 0.5 .1;

interface tokenRecipient {
	function receiveApproval(address from, uint256 value, address token, bytes calldata extraData) external;
}


contract ERC20Token {
	string private _name;

	function name() public view returns(string memory) {
		return _name;
	}
	string private _symbol;

	function symbol() public view returns(string memory) {
		return _symbol;
	}
	uint8 private _decimals = 18;

	function decimals() public view returns(uint8) {
		return _decimals;
	}
	// 18 decimals is the strongly suggested default, avoid changing it
	uint256 public _totalSupply;

	function totalSupply() public view returns(uint256) {
		return _totalSupply;
	}
	//�˻������������ӳ��
	// This creates an array with all balances
	mapping(address => uint256) public _balanceOf;

	function balanceOf(address _owner) public view returns(uint256 balance) {
		return _balanceOf[_owner];
	}

	//��Ȩ
	mapping(address => mapping(address => uint256)) public _allowance;

	//�����¼� ת���¼�
	// This generates a public event on the blockchain that will notify clients
	event Transfer(address indexed from, address indexed to, uint256 value);
	//�����¼� ��Ȩ�¼�
	// This generates a public event on the blockchain that will notify clients
	event Approval(address indexed owner, address indexed spender, uint256 value);
	//�����¼� 
	// This notifies clients about the amount burnt
	event Burn(address indexed from, uint256 value);

	/**
	 * Constructor function
	 *
	 * Initializes contract with initial supply tokens to the creator of the contract
	 */
	constructor(
		uint256 initialSupply,
		string memory tokenName,
		string memory tokenSymbol
	) public {
		_totalSupply = initialSupply * 10 ** uint256(_decimals); // Update total supply with the decimal amount
		//һ��ʼ�����Ҷ��ں�Լӵ��������
		_balanceOf[msg.sender] = _totalSupply; // Give the creator all initial tokens
		_name = tokenName; // Set the name for display purposes
		_symbol = tokenSymbol; // Set the symbol for display purposes
	}

	//�ڲ�����
	function _transfer(address from, address to, uint value) internal {
		// Prevent transfer to 0x0 address. Use burn() instead
		require(to != address(0x0)); //���ԣ����ܸ�һ���յ�ַת����
		// Check if the sender has enough
		require(_balanceOf[from] >= value); //ת���߱���ӵ�еĴ�������������ڵ���ת��������
		// Check for overflows
		require(_balanceOf[to] + value >= _balanceOf[to]); //����ļ������ڿ��ǵ������ݵ����
		// Save this for an assertion in the future
		uint previousBalances = _balanceOf[from] + _balanceOf[to]; //ת���ߺ�ת���ߵ�����
		// Subtract from the sender
		_balanceOf[from] -= value; //ת��
		// Add the same to the recipient
		_balanceOf[to] += value; //ת��
		//�ύ�¼�
		emit Transfer(from, to, value);
		// Asserts are used to use static analysis to find bugs in your code. They should never fail
		assert(_balanceOf[from] + _balanceOf[to] == previousBalances); //����֮��ת���Ժ������϶��ǲ����
	}


	//��������
	function transfer(address to, uint256 value) public returns(bool success) {
		_transfer(msg.sender, to, value);
		return true;
	}


	function transferFrom(address from, address to, uint256 value) public returns(bool success) {
		//���ܳ���ת��
		require(value <= _allowance[from][msg.sender]); // Check allowance
		//��ȥ��Ȩ�Ķ��
		_allowance[from][msg.sender] -= value;
		//ת��
		_transfer(from, to, value);
		return true;
	}


	function approve(address spender, uint256 value) public
	returns(bool success) {
		//��Ȩ��ȣ���������û����ô��ȣ������ܣ���Ϊת�˵�ʱ����������жϣ����ﲻ�ù���
		_allowance[msg.sender][spender] = value;
		//�ύ��Ȩ�¼�
		emit Approval(msg.sender, spender, value);
		return true;
	}

	function approveAndCall(address spender, uint256 value, bytes memory extraData) public returns(bool success) {
		tokenRecipient _spender = tokenRecipient(spender);
		if (approve(spender, value)) {
			_spender.receiveApproval(msg.sender, value, address(this), extraData);
			return true;
		}
	}

	function burn(uint256 value) public returns(bool success) {
		require(_balanceOf[msg.sender] >= value); // Check if the sender has enough
		_balanceOf[msg.sender] -= value; // Subtract from the sender
		_totalSupply -= value; // Updates totalSupply
		//�ύ�¼�
		emit Burn(msg.sender, value);
		return true;
	}

	function burnFrom(address from, uint256 value) public returns(bool success) {
		require(_balanceOf[from] >= value); // Check if the targeted balance is enough
		require(value <= _allowance[from][msg.sender]); // Check allowance
		_balanceOf[from] -= value; // Subtract from the targeted balance
		_allowance[from][msg.sender] -= value; // Subtract from the sender's allowance
		_totalSupply -= value; // Update totalSupply
		//�ύ�¼�
		emit Burn(from, value);
		return true;
	}

}