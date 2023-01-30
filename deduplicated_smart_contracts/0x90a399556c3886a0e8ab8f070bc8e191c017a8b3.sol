/**
 *Submitted for verification at Etherscan.io on 2019-07-14
*/

pragma solidity >=0.4.22 <0.6.0;

contract owned {
    address public owner; //Crea una variable publica tipo 'address'

    constructor() public {
        owner = msg.sender; //la variable owner obtiene el valor 'address' de quien despliega el contrato
    }

//Esta funcion define al master.
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

//Esta funcion es usada para transferir la propiedad de tu contrato.
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }

//## En esta parte personalizamos nuestro Token. Cuando hagamos Deploy nos va a pedir definir estas variables
contract TokenERC20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;


    // Crea un Array con todos los balances.
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    //Se ejecuta cada vez que alguien use la funcion Transfer.Se genera un evento publico en la Blockchain, para notificar a los clientes.
    event Transfer(address indexed from, address indexed to, uint256 value);

    //Se ejecuta cada vez que alguien use la funcion Approval.Se genera un evento publico en la Blockchain, para notificar a los clientes.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    //Se ejecuta cada vez que alguien use la funcion Burn. Lanza una notificacion de los Token quemados.
    event Burn(address indexed from, uint256 value);

    /**
     * Contructor. Se ejecuta una sola vez. Al de desplegar el contrato.
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Actualiza el total supply con la cantidad de decimales
        balanceOf[msg.sender] = totalSupply;                    // Entrega al creador todos los token
        name = tokenName;                                       // Establece el nombre del token, con el proposito de mostrarlo.
        symbol = tokenSymbol;                                   // Establece el simbolo del token. Por lo general son 3 letras.
    }

    /**
     * Transferencia interna, solo puede ser convocada por este contrato.
     */

    function _transfer(address _from, address _to, uint _value) internal {
        // Evitar la transferencia a la dirección 0x0. Use burn() en su lugar
        require(_to != address(0x0));
        //Comprueba si el enviador tiene fondos suficientes
        require(balanceOf[_from] >= _value);
        // Comprobacion para overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Guarda esto para una afirmación en el futuro
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Retira los fondos del enviador
        balanceOf[_from] -= _value;
        // Agrega los fondos a la direccion del receptor
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Las afirmaciones se utilizan para utilizar el análisis estático para encontrar errores en su código. Nunca deben fallar
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transferir Token
     *
     * Enviar `_value` tokens a `_to` desde tu cuenta
     *
     * El parametro _to es la direccion del receptor
     * El parametro _value es la cantidad de tokens
     */

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transferir token de otras direcciones
     *
     * Envia `_value` tokens a `_to` in behalf of `_from`
     *
     * El parametro _from es la direccion de donde saldran los token
     * El parametro _to es la direccion del receptor
     * El parametro _value es la cantidad de tokens
     */

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Comprueba lo asignado
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Establecer asignación para otra dirección
     *
     * Permitir a `_spender` gastar no más que `_value` de mis tokens en su favor
     *
     * El parametro _spender es la direccion autorizada para gastar
     * El parametro _value es la cantidad maxima que puede gastar
     */

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Establecer asignación para otra dirección y notificar
     *
     * Permitir a `_spender` gastar no más de `_value` de mis tokens en su favor, y luego hacer ping al contrato al respecto
     *
     * El parametro _spender es la direccion autorizada para gastar
     * El parametro _value es la cantidad maxima que puede gastar
     * El parametro _extraData Alguna información extra para enviar al contrato aprobado.
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    /**
     * Destruir tokens
     *
     *Remueve `_value` tokens del sistema de manera irreversible
     *
     * El parametro _value es la cantidad a destruir
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Revisa si el enviador tiene suficientes
        balanceOf[msg.sender] -= _value;            // Resta los token del enviador
        totalSupply -= _value;                      // Actualiza el total totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destruir los token de otra direccion
     *
     * Remover `_value` tokens del sistema de manera irreversible para la direccion `_from`.
     *
     * El parametro _from es la direccion del sender
     * El parametro _value es la cantidad de tokens a destruir
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Revisa si la direccion objetivo tiene el balance suficiente
        require(_value <= allowance[_from][msg.sender]);    // Comprueba lo asignado
        balanceOf[_from] -= _value;                         // Resta los token de la direccion objetivo
        allowance[_from][msg.sender] -= _value;             // Resta el valor asignado
        totalSupply -= _value;                              // Actualiza el total supply
        emit Burn(_from, _value);
        return true;
    }
}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract ThursdayNinja is owned, TokenERC20 {

    uint256 public sellPrice;
    uint256 public buyPrice;

    mapping (address => bool) public frozenAccount;

    /* Esto genera un evento público en la cadena de bloques que notificará a los clientes. */
    event FrozenFunds(address target, bool frozen);

    /* Inicializa el contrato con los tokens de suministro iniciales al creador del contrato. */
    constructor(
        uint256 initialSupply,
        string memory tokenName,
        string memory tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

    /* Transferencia interna, solo puede ser convocada por este contrato. */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != address(0x0));                          // Evitar la transferencia a la dirección 0x0. Use burn() en su lugar
        require (balanceOf[_from] >= _value);                   // Comprueba que el enviador tenga tokens suficientes
        require (balanceOf[_to] + _value >= balanceOf[_to]);    // Comprobacion para overflows
        require(!frozenAccount[_from]);                         // Comprueba si el enviador esta congelado
        require(!frozenAccount[_to]);                           // Compruebasi el receptor esta congelado
        balanceOf[_from] -= _value;                             // Resta los token al enviador
        balanceOf[_to] += _value;                               // Añade los token al receptor
        emit Transfer(_from, _to, _value);
    }

    /// @notice Crear `mintedAmount` tokens y enviarlos al `target`
    /// El parametro target es la direccion que recibira los token
    /// El parametro mintedAmount es la cantidad de tokens que recibira
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(address(0), address(this), mintedAmount);
        emit Transfer(address(this), target, mintedAmount);
    }

    /// @notice `freeze? Previene | Permite a `target` enviar y recibir token
    /// El parametro target es la direccion a congelar
    /// El parametro freeze usado ya sea para congelar o no
    /// solo puede ser ejecutada por el master
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }

    /// @notice Permitir que los usuarios compren tokens por 'newBuyPrice` eth y vender tokens por 'newSellPrice` eth
    /// El parametro newSellPrice Precio al que los usuarios pueden vender al contrato.
    /// El parametro newBuyPrice Precio que los usuarios pueden comprar al contrato.

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    /// @notice Compre fichas del contrato enviando éter.
    function buy() payable public {
        uint amount = msg.value / buyPrice;                 // Calcular el monto
        _transfer(address(this), msg.sender, amount);       // Hacer la transferencia
    }

    /// @notice venta de `amount` tokens para el contrato
    /// El parametro amount es la cantidad de tokens vendidos
    function sell(uint256 amount) public {
        address myAddress = address(this);
        require(myAddress.balance >= amount * sellPrice);   // Comprueba si el contrato tiene el suficiente ether para comprar
        _transfer(msg.sender, address(this), amount);       // Hace la transferencia
        msg.sender.transfer(amount * sellPrice);            // Envia ether al vendedor.Es importante hacer esto último para evitar ataques de recursión.
    }
}