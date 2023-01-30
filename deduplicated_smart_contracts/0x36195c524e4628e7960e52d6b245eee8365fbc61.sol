pragma solidity ^0.5.0;

/// @title Plan Austral 1985 - 2019 - CriptoAustral ₳
/// @author Daniel Fernando Perosio (http://danielperosio.com) e-mail daniel@perosio.com - dperosio@gmail.com
/// @notice CriptoAustral es la recuperación de la moneda Austral con respaldo digital en la cadena de bloques Ethereum, reemisión, recirculación y puesta en valor. 
/// Cada token ERC-721 corresponde en paridad a un billete físico de Australes sellado con el hash de este contrato y su identificador. 
/// El austral fue la moneda de curso legal de la República Argentina desde el 15 de junio de 1985 hasta el 31 de diciembre de 1991. 
/// En 1989 el Austral se depreció 5000% anual, padeciendo un periodo hiperinflacionario entre 1989 y 1990. 
/// Con la devaluación del Austral, miles de personas pasaron hacia la pobreza: la hiperinflación devoró salarios, generó revueltas, saqueos y llevó al adelantamiento del traspaso del poder. 
/// El CriptoAustral es una obra artística que plantea la idea del tiempo perdido, su recuperación, la del trabajo y de la vida que está representado en la moneda como valor de intercambio entre las personas.  
/// @dev Compatible con la implementación de OpenZeppelin de la especificación ERC-721 Cripto Coleccionables

import "./ownable.sol";
import "./ERC721Full.sol";
import "./SafeMath.sol";
import "./Pausable.sol";
import './Strings.sol';

contract CriptoAustral is Ownable, ERC721Full, Pausable {
   
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;
    using Strings for string;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    address payable private _autor;  
    address payable private _seller;
    
    constructor(string memory _name, string memory _symbol, string memory _uriBase) ERC721Full(_name, _symbol) public onlyOwner {
        _nombre = _name;
        _simbolo = _symbol;
        __uriBase = bytes(_uriBase);
        _autor = msg.sender;
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    struct Austral {
        uint32 valor;
        string valorLetras;
        string numeroSerie;
        uint16 emision;            
    }

    Austral[] public monedas;

    mapping (uint => address) private _idPropietario; 

    mapping (address => uint) private _numTokens; 

    mapping(address => uint256[]) private _propiedadTokens; 

    mapping(uint256 => uint256) private _propiedadTokensIndice; 

    uint256[] private _totalTokens;

    mapping(uint256 => uint256) private _totalTokensIndice; 

    mapping (address => mapping (address => bool)) private _operadorAprobado;

    mapping(uint256 => string) private _tokenUri;

    mapping (uint => address) private _tokenAprobado;   

    mapping(uint256 => uint256) private _tokensForSale;  

    mapping (uint => address payable) private _paymentAddress; 

    string private _nombre;
    string private _simbolo;
    bytes private __uriBase;  

    event nuevaMoneda(uint monedaId, uint32 _valor, string _valorLetras, string _numeroSerie, uint16 _anio); 
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);  
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function actualizarUrl(string calldata _nuevaUrl ) external onlyOwner {
        __uriBase = bytes(_nuevaUrl);        
    }

    function withdraw() onlyOwner public returns(bool success)  {
        uint256 amount = address(this).balance;
        _autor.transfer(amount);
        return true;
    }    

    function  _mintCirculante(uint32 _valor, string memory _valorLetras, string memory  _numeroSerie, uint16 _anio) internal {
        uint id = monedas.push(Austral(_valor, _valorLetras, _numeroSerie, _anio)) - 1;
        _idPropietario[id] = msg.sender;        
        _numTokens[msg.sender] = _numTokens[msg.sender].add(1);        
        _addTokenToOwnerEnumeration(msg.sender, id);       
        _totalTokens.push(id);
        _tokenUri[id] = Strings.strConcat(baseTokenURI(), Strings.uint2str(id));       
        emit nuevaMoneda(id, _valor, _valorLetras, _numeroSerie, _anio); 
    }    

    function emitirMoneda(uint32 _valor, string calldata _valorLetras, string calldata _numeroSerie, uint16 _emision) external onlyOwner { 
        uint32  __valor =  _valor; 
        string memory __valorLetras  = string(abi.encodePacked(_valorLetras));      
        string memory __numeroSerie  = string(abi.encodePacked(_numeroSerie));
        uint16  _anio =  _emision;
        _mintCirculante(__valor, __valorLetras, __numeroSerie, _anio);
    }

    modifier onlyOwnerOf(uint _tokenId) {
        address owner = _idPropietario[_tokenId];
        require(msg.sender == _idPropietario[_tokenId] || msg.sender == owner || msg.sender == _tokenAprobado[_tokenId] || _operadorAprobado[owner][msg.sender]);
        _;
    }

    modifier validDestination( address _to ) {
        require(_to != address(0x0));
        require(_to != address(this));
        _;
    }

    function _exists(uint256 _tokenId) internal view returns (bool) {
        address owner = _idPropietario[_tokenId];
        return owner != address(0);
    }
    
    function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
        require(_exists(_tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(_tokenId);
        return (_spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender));
    }

    function setApprovalForAll(address _to, bool _approved) public onlyOwner {
        require(_to != _msgSender(), "ERC721: approve to caller");
        _operadorAprobado[_msgSender()][_to] = _approved;
        emit ApprovalForAll(_msgSender(), _to, _approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operadorAprobado[owner][operator];
    }
    
    function _clearApproval(uint256 _tokenId) private {
        if (_tokenAprobado[_tokenId] != address(0)) {
            _tokenAprobado[_tokenId] = address(0);
        }
    }

    // ERC721
    
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0), "ERC721: balance query for the zero address");
        return _numTokens[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        address owner = _idPropietario[_tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }    

    function _transfer(address _from, address _to, uint256 _tokenId) private validDestination(_to) {
        _numTokens[_to] = _numTokens[_to].add(1);
        _numTokens[_from] = _numTokens[_from].sub(1);
        _clearApproval(_tokenId);
        _idPropietario[_tokenId] = _to;
        _removeTokenFromOwnerEnumeration(_from, _tokenId);
        _addTokenToOwnerEnumeration(_to, _tokenId);       
    }

    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) validDestination(_to) {
        _transfer(msg.sender, _to, _tokenId);
         emit Transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) validDestination(_to) {
        _tokenAprobado[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }
        
    function getApproved(uint256 _tokenId) public view returns (address) {
        require(_exists(_tokenId), "ERC721: approved query for nonexistent token");
        return _tokenAprobado[_tokenId];
    }

    function takeOwnership(uint256 _tokenId) public {
        require(_tokenAprobado[_tokenId] == msg.sender);
        address  owner = ownerOf(_tokenId);
        _transfer(owner, msg.sender, _tokenId);
    }   

    function transferFrom(address _from, address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) validDestination(_to) {
         _transfer(_from, _to, _tokenId);
          emit Transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public onlyOwnerOf(tokenId) validDestination(to) {
        safeTransferFrom(from, to, tokenId, "");
       
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public onlyOwnerOf(tokenId) validDestination(to) {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {
        _transfer(from, to, tokenId);
        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }
        bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }
     
    // ENUMERABLE

   function totalSupply() public view returns (uint256) {
        return _totalTokens.length;
    }
   
    function tokenByIndex(uint256 _index) public view returns (uint256) {
        require(_index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _totalTokens[_index];
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
        require(_index < balanceOf(_owner), "ERC721Enumerable: owner index out of bounds");
        return _propiedadTokens[_owner][_index];
    }
  
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _propiedadTokens[owner];
    }
    
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _propiedadTokensIndice[tokenId] = _propiedadTokens[to].length;
        _propiedadTokens[to].push(tokenId);
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _totalTokensIndice[tokenId] = _totalTokens.length;
        _totalTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = _propiedadTokens[from].length.sub(1);
        uint256 tokenIndex = _propiedadTokensIndice[tokenId];
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _propiedadTokens[from][lastTokenIndex];
            _propiedadTokens[from][tokenIndex] = lastTokenId; 
            _propiedadTokensIndice[lastTokenId] = tokenIndex; 
        }
        _propiedadTokens[from].length--;
    }
   
    function listaTokensDe(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](_numTokens[_owner]);
        uint counter = 0;
        for (uint i = 0; i < monedas.length; i++) {
          if (_idPropietario[i] == _owner) {
            result[counter] = i;
            counter++;
          }
        }
        return result;
    }

    // METADATA

    function baseTokenURI() public view returns (string memory) {
        return string(__uriBase);
    }

    function name() external view returns (string memory _name){
        _name = _nombre;
    }
    
    function symbol() external view returns (string memory _symbol){
        _symbol = _simbolo;
    }

    function tokenURI(uint256 _tokenId) external view returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenUri[_tokenId];
    }

    function setTokenURI(uint256 _tokenId, string calldata _uri) external onlyOwnerOf(_tokenId) {
        require(_exists(_tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenUri[_tokenId] = _uri;
    } 

    // VENTA

    function setForSale(uint256 _tokenId, uint _feeWei) external onlyOwnerOf(_tokenId) whenNotPaused {
        address owner = ownerOf(_tokenId);
        _seller = msg.sender;
        require(_exists(_tokenId));  
        _tokenAprobado[_tokenId] = address(this);
        _tokensForSale[_tokenId] = _feeWei;
        _paymentAddress[_tokenId] = _seller;
        emit Approval(owner, address(this), _tokenId);
    }

    function removeSale(uint256 _tokenId) external onlyOwnerOf(_tokenId) whenNotPaused {       
        require(_exists(_tokenId));  
        _clearApproval(_tokenId);
        _tokensForSale[_tokenId] = 0;
        _paymentAddress[_tokenId] =  address(0);      
    }

    function tokenSales(uint256 _tokenId) external view whenNotPaused returns (uint256) {
        require(_exists(_tokenId), "Nonexistent token");
        return _tokensForSale[_tokenId];
    }

    function buy(uint256 _tokenId) external payable whenNotPaused {
        address buyer = msg.sender;
        uint256 payedPrice = _tokensForSale[_tokenId];
        require(msg.value >= payedPrice); 
        require(_exists(_tokenId));
        require(getApproved(_tokenId) == address(this));
        _seller = _paymentAddress[_tokenId];
        require(_seller != address(0x0));
            if (payedPrice > 0) {
                _seller.transfer(payedPrice);
            }
        _tokensForSale[_tokenId] = 0;
        _paymentAddress[_tokenId] =  address(0);  
        _transfer(ownerOf(_tokenId), buyer, _tokenId);
    }
}