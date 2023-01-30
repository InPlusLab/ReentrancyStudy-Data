pragma solidity ^0.5.4;

import "./AuctionityStorage1.sol";

import "./SafeMath.sol";
import "./AuctionityLibrary_V1.sol";
import "./AuctionityLibraryDecodeRawTx_V1.sol";

import "./AuctionityChainId_V1.sol";
import "./AuctionityOracable_V1.sol";
import "./AuctionityPausable_V1.sol";

contract AuctionityDeposit_V1 is AuctionityStorage1, AuctionityLibrary_V1, AuctionityChainId_V1 {
    using SafeMath for uint256;

    struct InfoFromCreateAuction {
        bytes32 tokenHash;
        address tokenContractAddress;
        address auctionSeller;
        uint8 rewardPercent;
        uint256 tokenId;
    }

    struct InfoFromBidding {
        address auctionContractAddress;
        address signer;
        uint256 amount;
    }

    // For previous compatibility
    event LogSentEthToWinner(address auction, address user, uint256 amount);
    event LogSentRewardsDepotEth(address[] user, uint256[] amount);
    event LogDeposed(address user, uint256 amount);
    event LogWithdrawalVoucherSubmitted(address user, uint256 amount, bytes32 withdrawalVoucherHash);
    event LogAuctionEndVoucherSubmitted(
        bytes32 tokenHash,
        address tokenContractAddress,
        uint256 tokenId,
        address indexed seller,
        address indexed winner,
        uint256 amount,
        bytes32 auctionEndVoucherHash
    );

    // events
    event LogWithdrawalVoucherSubmitted_V1(
        address user,
        uint256 amount,
        bytes32 withdrawalVoucherHash
    );

    event LogAddDepot_V1(
        address user,
        address tokenContractAddress,
        uint256 tokenId,
        uint256 amount,
        uint256 totalAmount
    );

    event LogAuctionEndVoucherSubmitted_V1(
        bytes32 tokenHash,
        address tokenContractAddress,
        uint256 tokenId,
        address indexed seller,
        address indexed winner,
        uint256 amount,
        bytes32 auctionEndVoucher_V1Hash
    );
    event LogSentEthToSeller_V1(address auction, address user, uint256 amount);
    event LogSentRewardsDepotEth_V1(address[] user, uint256[] amount);

    /// @notice get amount of user's deposit
    /// @dev Comptability with previous 'AuctionityDeposit_V1'
    /// @param _user address
    /// @return _amount uint256
    function getDepotEth(address _user) public view returns (uint256 _amount) {
        return getBalanceEth_V1(_user);
    }

    /// @notice fallback payable function , with revert if is deactivated
    function() external payable {
        return receiveDepotEth_V1();
    }

    /// @notice deposit Eth
    /// @dev Comptability with previous 'AuctionityDeposit'
    function depositEth() public payable {
        receiveDepotEth_V1();
    }

    /// @notice receive depot Eth
    function receiveDepotEth_V1()  public payable {
        require(!delegatedSendGetPaused_V1(), "CONTRACT_PAUSED");

        address _user = msg.sender;
        uint256 _amount = uint256(msg.value);

        _addDepotEth_V1(_user, _amount);

        // For previous compatibility
        emit LogDeposed(_user, _amount);

        emit LogAddDepot_V1(
            _user,
            address(0),
            uint256(0),
            _amount,
            getBalanceEth_V1(_user)
        );

    }

    /// @notice internal add depot Eth
    /// @param _user address from depot
    /// @param _amount uint256
    /// @return _success
    function _addDepotEth_V1(address _user, uint256 _amount)
        internal
        returns (bool)
    {
        return _addDepot_V1(_user, address(0), uint256(0), _amount);
    }

    /// @notice internal add depot (compatibility ERC1155)
    /// @param _user address from depot
    /// @param _tokenContractAddress address of NFT smart contract
    /// @param _tokenId uint256 of ERC1155
    /// @param _amount uint256 of ERC1155
    /// @return _success
    function _addDepot_V1(
        address _user,
        address _tokenContractAddress,
        uint256 _tokenId,
        uint256 _amount
    ) internal returns (bool) {
        require(_amount > 0, "Amount must be greater than 0");

        tokens[_tokenContractAddress][_tokenId][_user] = tokens[_tokenContractAddress][_tokenId][_user].add(
            _amount
        );

        return true;
    }

    /// @notice internal subtraction depot eth
    /// @param _user address
    /// @param _amount uint256
    /// @return _success
    function _subDepotEth_V1(address _user, uint256 _amount)
        internal
        returns (bool)
    {
        return _subDepot_V1(_user, address(0), uint256(0), _amount);
    }

    /// @notice internal substration depot (compatibility ERC1155)
    /// @param _user address from depot
    /// @param _tokenContractAddress address of NFT smart contract
    /// @param _tokenId uint256 of ERC1155
    /// @param _amount uint256 of ERC1155
    /// @return _success
    function _subDepot_V1(
        address _user,
        address _tokenContractAddress,
        uint256 _tokenId,
        uint256 _amount
    ) internal returns (bool) {
        require(
            tokens[_tokenContractAddress][_tokenId][_user] >= _amount,
            "Amount too low"
        );

        tokens[_tokenContractAddress][_tokenId][_user] = tokens[_tokenContractAddress][_tokenId][_user].sub(
            _amount
        );

        return true;
    }

    /// @notice get balance Eth for a user
    /// @param _user address
    /// @return _balanceOf uint256
    function getBalanceEth_V1(address _user) public view returns (uint256 _balanceOf) {
        return _getBalance_V1(_user, address(0), uint256(0));
    }

    /// @notice get balance for a user (compatibility ERC1155)
    /// @param _user address from depot
    /// @param _tokenContractAddress address of NFT smart contract
    /// @param _tokenId uint256 of ERC1155
    /// @return _balanceOf uint256
    function _getBalance_V1(
        address _user,
        address _tokenContractAddress,
        uint256 _tokenId
    ) internal view returns (uint256 _balanceOf) {
        return tokens[_tokenContractAddress][_tokenId][_user];
    }

    /// @notice withdrawal voucher
    /// @param _withdrawalVoucherData bytes , RSV FROM Oracle, user , amount and key (anti replay)
    /// @param _signedRawTxWithdrawal bytes
    function withdrawalVoucher_V1(
        bytes memory _withdrawalVoucherData,
        bytes memory _signedRawTxWithdrawal
    ) public {
        require(!delegatedSendGetPaused_V1(), "CONTRACT_PAUSED");

        bytes32 _withdrawalVoucherHash = keccak256(_signedRawTxWithdrawal);

        require(
            withdrawalVoucherSubmitted[_withdrawalVoucherHash] != true,
            "Withdrawal voucher is already submited"
        );

        address _withdrawalSigner;
        uint _withdrawalAmount;

        (_withdrawalSigner, _withdrawalAmount) = AuctionityLibraryDecodeRawTx_V1.decodeRawTxGetWithdrawalInfo_V1(
            _signedRawTxWithdrawal,
            getAuctionityChainId_V1()
        );

        require(
            _withdrawalAmount != uint256(0),
            "Withdrawal voucher amount must be greater than zero"
        );
        require(
            _withdrawalSigner != address(0),
            "Withdrawal voucher invalid signature of oracle"
        );

        // if depot is smaller than amount
        require(
            getBalanceEth_V1(_withdrawalSigner) >= _withdrawalAmount,
            "Withdrawal voucher depot amount is too low"
        );

        require(
            withdrawalVoucherOracleSignatureVerification_V1(
                _withdrawalVoucherData,
                _withdrawalSigner,
                _withdrawalAmount,
                _withdrawalVoucherHash
            ),
            "Withdrawal voucher invalid signature of oracle"
        );

        // send amount
        require(
            address(uint160(_withdrawalSigner)).send(_withdrawalAmount),
            "Withdrawal voucher transfer failed"
        );

        _subDepotEth_V1(_withdrawalSigner, _withdrawalAmount);

        withdrawalVoucherList.push(_withdrawalVoucherHash);
        withdrawalVoucherSubmitted[_withdrawalVoucherHash] = true;

        // For previous compatibility
        emit LogWithdrawalVoucherSubmitted(
            _withdrawalSigner,
            _withdrawalAmount,
            _withdrawalVoucherHash
        );

        emit LogWithdrawalVoucherSubmitted_V1(
            _withdrawalSigner,
            _withdrawalAmount,
            _withdrawalVoucherHash
        );
    }

    /// @notice internal withdrawal voucher oracle signature verification
    /// @param _withdrawalVoucherData bytes
    /// @param _withdrawalSigner address
    /// @param _withdrawalAmount uint256
    /// @param _withdrawalVoucherHash bytes32 : hash of _signedRawTxWithdrawal
    /// @return _success
    function withdrawalVoucherOracleSignatureVerification_V1(
        bytes memory _withdrawalVoucherData,
        address _withdrawalSigner,
        uint256 _withdrawalAmount,
        bytes32 _withdrawalVoucherHash
    ) internal returns (bool) {
        /// @dev if oracle is the signer of this withdrawal voucher
        return delegatedSendGetOracle_V1(

        ) == AuctionityLibraryDecodeRawTx_V1.ecrecoverSigner_V1(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    keccak256(
                        abi.encodePacked(
                            address(this),
                            _withdrawalSigner,
                            _withdrawalAmount,
                            _withdrawalVoucherHash
                        )
                    )
                )
            ),
                _withdrawalVoucherData,
            0
        );
    }

    /// @notice auctionEndVoucher_V1
    /// @param _auctionEndVoucherData is a  concatenate of : biddingHashProof, rsv ECDSA signature of oracle validation AEV and transfer token
    /// @param _signedRawTxCreateAuction bytes of signed transaction of create transaction on auction smart contract
    /// @param _signedRawTxBidding bytes of signed transaction of bidding transaction on auction smart contract
    /// @param _send bytes of send external and internal (rewards) amount
    function auctionEndVoucher_V1(
        bytes memory _auctionEndVoucherData,
        bytes memory _signedRawTxCreateAuction,
        bytes memory _signedRawTxBidding,
        bytes memory _send
    ) public {
        require(!delegatedSendGetPaused_V1(), "CONTRACT_PAUSED");

        bytes32 _auctionEndVoucherHash = keccak256(_signedRawTxCreateAuction);
        require(
            auctionEndVoucherSubmitted[_auctionEndVoucherHash] != true,
            "Auction end voucher already submited"
        );

        InfoFromCreateAuction memory _infoFromCreateAuction = getInfoFromCreateAuction_V1(
            _signedRawTxCreateAuction
        );

        address _auctionContractAddress;
        address _winnerSigner;
        uint256 _winnerAmount;

        InfoFromBidding memory _infoFromBidding;

        if (_signedRawTxBidding.length > 1) {
            _infoFromBidding = getInfoFromBidding_V1(
                _signedRawTxBidding,
                _infoFromCreateAuction.tokenHash
            );

            if (!verifyWinnerDepot_V1(_infoFromBidding)) {
                return;
            }
        }

        require(
            auctionEndVoucherOracleSignatureVerification_V1(
                _auctionEndVoucherData,
                keccak256(_send),
                _infoFromCreateAuction,
                _infoFromBidding
            ),
            "Auction end voucher invalid signature of oracle"
        );

        require(
            sendTransfer_V1(
                _infoFromCreateAuction.tokenContractAddress,
                _auctionEndVoucherData,
                97
            ),
            "Auction end voucher transfer failed"
        );

        if (_signedRawTxBidding.length > 1) {
            if (!sendExchange_V1(
                _send,
                _infoFromCreateAuction,
                _infoFromBidding
            )) {
                return;
            }
        }

        auctionEndVoucherList.push(_auctionEndVoucherHash);
        auctionEndVoucherSubmitted[_auctionEndVoucherHash] = true;

        // For previous compatibility
        emit LogAuctionEndVoucherSubmitted(
            _infoFromCreateAuction.tokenHash,
            _infoFromCreateAuction.tokenContractAddress,
            _infoFromCreateAuction.tokenId,
            _infoFromCreateAuction.auctionSeller,
            _infoFromBidding.signer,
            _infoFromBidding.amount,
            _auctionEndVoucherHash
        );

        emit LogAuctionEndVoucherSubmitted_V1(
            _infoFromCreateAuction.tokenHash,
            _infoFromCreateAuction.tokenContractAddress,
            _infoFromCreateAuction.tokenId,
            _infoFromCreateAuction.auctionSeller,
            _infoFromBidding.signer,
            _infoFromBidding.amount,
            _auctionEndVoucherHash
        );
    }

    /// @notice internal get information from create auction signed transaction
    /// @param _signedRawTxCreateAuction bytes
    /// @return InfoFromCreateAuction structure
    function getInfoFromCreateAuction_V1(bytes memory _signedRawTxCreateAuction)
        internal
        view
        returns (InfoFromCreateAuction memory _infoFromCreateAuction)
    {
        (_infoFromCreateAuction.tokenHash, , _infoFromCreateAuction.auctionSeller, _infoFromCreateAuction.tokenContractAddress, _infoFromCreateAuction.tokenId, _infoFromCreateAuction.rewardPercent) = AuctionityLibraryDecodeRawTx_V1.decodeRawTxGetCreateAuctionInfo_V1(
            _signedRawTxCreateAuction,
            getAuctionityChainId_V1()
        );
    }

    /// @notice internal get information from bidding signed transaction
    /// @param _signedRawTxBidding bytes
    /// @param _hashSignedRawTxTokenTransfer bytes32 tokenhash :  hash of _signedRawTxTokenTransfer (include into create auction transaction)
    /// @return InfoFromBidding structure
    function getInfoFromBidding_V1(
        bytes memory _signedRawTxBidding,
        bytes32 _hashSignedRawTxTokenTransfer
    ) internal returns (InfoFromBidding memory _infoFromBidding) {
        bytes32 _hashRawTxTokenTransferFromBid;

        (_hashRawTxTokenTransferFromBid, _infoFromBidding.auctionContractAddress, _infoFromBidding.amount, _infoFromBidding.signer) = AuctionityLibraryDecodeRawTx_V1.decodeRawTxGetBiddingInfo_V1(
            _signedRawTxBidding,
            getAuctionityChainId_V1()
        );

        require(
            _hashRawTxTokenTransferFromBid == _hashSignedRawTxTokenTransfer,
            "Auction end voucher hashRawTxTokenTransfer is invalid"
        );

        require(
            _infoFromBidding.amount != uint256(0),
            "Auction end voucher bidding amount must be greater than zero"
        );

        return _infoFromBidding;

    }

    /// @notice intenral verify winner have enouth depot with bidding information
    /// @param _infoFromBidding InfoFromBidding structure
    /// @return _success
    function verifyWinnerDepot_V1(InfoFromBidding memory _infoFromBidding)
        internal
        returns (bool)
    {
        // depot is greatuer or eqal than amount
        require(
            getBalanceEth_V1(
                _infoFromBidding.signer
            ) >= _infoFromBidding.amount,
            "Auction end voucher depot amount is too low"
        );

        return true;
    }

    /// @notice internal send external and internal deposit amount
    /// @param _send bytes of send external and internal (rewards) amount
    /// @param _infoFromCreateAuction InfoFromCreateAuction structure
    /// @param _infoFromBidding InfoFromBidding structure
    /// @return _success
    function sendExchange_V1(
        bytes memory _send,
        InfoFromCreateAuction memory _infoFromCreateAuction,
        InfoFromBidding memory _infoFromBidding
    ) internal returns (bool) {
        require(
            _subDepotEth_V1(_infoFromBidding.signer, _infoFromBidding.amount),
            "Auction end voucher depot amout is too low"
        );

        uint offset;
        address payable _sendAddress;
        uint256 _sendAmount;
        bytes12 _sendAmountGwei;
        uint256 _sentAmount;

        assembly {
            _sendAddress := mload(add(_send, add(offset, 0x14)))
            _sendAmount := mload(add(_send, add(add(offset, 20), 0x20)))
        }

        require(
            _sendAddress == _infoFromCreateAuction.auctionSeller,
            "Auction end voucher sender address is invalider"
        );

        _sentAmount += _sendAmount;
        offset += 52;

        // send amount to seller
        if (!_sendAddress.send(_sendAmount)) {
            revert("Failed to send funds");
        }

        // emit old event for previous compatibility
        emit LogSentEthToWinner(_infoFromBidding.auctionContractAddress,
            _sendAddress,
            _sendAmount);

        emit LogSentEthToSeller_V1(
            _infoFromBidding.auctionContractAddress,
            _sendAddress,
            _sendAmount
        );

        // if community rewards is informed
        if (_infoFromCreateAuction.rewardPercent > 0) {

            // get number of rewards
            bytes2 _numberOfSendDepositBytes2;
            assembly {
                _numberOfSendDepositBytes2 := mload(
                    add(_send, add(offset, 0x20))
                )
            }

            offset += 2;


            // initiate _rewardsAddress and _rewardsAmount
            address[] memory _rewardsAddress = new address[](
                uint16(_numberOfSendDepositBytes2)
            );
            uint256[] memory _rewardsAmount = new uint256[](
                uint16(_numberOfSendDepositBytes2)
            );


            for (uint16 i = 0; i < uint16(_numberOfSendDepositBytes2); i++) {

                // get address and amount in gwei for reward
                assembly {
                    _sendAddress := mload(add(_send, add(offset, 0x14)))
                    _sendAmountGwei := mload(
                        add(_send, add(add(offset, 20), 0x20))
                    )
                }

                // multiply amount in gwei to wei
                _sendAmount = uint96(_sendAmountGwei) * 1000000000;
                // sum of all reward amount for verification below
                _sentAmount += _sendAmount;
                offset += 32;

                // add internal deposit reward amount for reward address
                if (!_addDepotEth_V1(_sendAddress, _sendAmount)) {
                    revert("Can't add deposit");
                }

                _rewardsAddress[i] = _sendAddress;
                _rewardsAmount[i] = uint256(_sendAmount);
            }

            // For previous compatibility
            emit LogSentRewardsDepotEth(_rewardsAddress, _rewardsAmount);

            emit LogSentRewardsDepotEth_V1(_rewardsAddress, _rewardsAmount);
        }

        // verification if sum of sended amount is equal than bidding amount
        if (uint256(_infoFromBidding.amount) != _sentAmount) {
            revert("Bidding amount is not equal to sent amount");
        }

        return true;
    }

    /// @notice internal get transfert data hash from AEV data (part of transfert token to winner)
    /// @param _auctionEndVoucherData bytes
    /// @return _transferDataHash bytes32
    function getTransferDataHash_V1(bytes memory _auctionEndVoucherData)
        internal
        pure
        returns (bytes32 _transferDataHash)
    {
        bytes memory _transferData = new bytes(_auctionEndVoucherData.length - 97);

        for (uint i = 0; i < (_auctionEndVoucherData.length - 97); i++) {
            _transferData[i] = _auctionEndVoucherData[i + 97];
        }
        return keccak256(_transferData);

    }

    /// @notice internal auctionEndVoucher oracle signature verification
    /// @param _auctionEndVoucherData bytes
    /// @param _sendDataHash bytes32
    /// @param _infoFromCreateAuction InfoFromCreateAuction structure
    /// @param _infoFromBidding InfoFromBidding structure
    /// @return _success
    function auctionEndVoucherOracleSignatureVerification_V1(
        bytes memory _auctionEndVoucherData,
        bytes32 _sendDataHash,
        InfoFromCreateAuction memory _infoFromCreateAuction,
        InfoFromBidding memory _infoFromBidding
    ) internal returns (bool) {
        bytes32 _biddingHashProof;
        assembly {
            _biddingHashProof := mload(add(_auctionEndVoucherData, add(0, 0x20)))
        }

        // get hash of transfert data
        bytes32 _transferDataHash = getTransferDataHash_V1(_auctionEndVoucherData);

        // if oracle is the signer of this auction end voucher
        return delegatedSendGetOracle_V1() == AuctionityLibraryDecodeRawTx_V1.ecrecoverSigner_V1(
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    keccak256(
                        abi.encodePacked(
                            address(this),
                            _infoFromCreateAuction.tokenContractAddress,
                            _infoFromCreateAuction.tokenId,
                            _infoFromCreateAuction.auctionSeller,
                            _infoFromBidding.signer,
                            _infoFromBidding.amount,
                            _biddingHashProof,
                            _infoFromCreateAuction.rewardPercent,
                            _transferDataHash,
                            _sendDataHash
                        )
                    )
                )
            ),
            _auctionEndVoucherData,
            32
        );

    }

    /// @notice send token(s) to winner
    /// @param _tokenContractAddress address
    /// @param _auctionEndVoucherData bytes
    /// @param _offset of begin transfert data
    function sendTransfer_V1(
        address _tokenContractAddress,
        bytes memory _auctionEndVoucherData,
        uint _offset
    ) internal returns (bool) {
        if (!isContract_V1(_tokenContractAddress)) {
            return false;
        }

        uint8 _numberOfTransfer = uint8(_auctionEndVoucherData[_offset]);

        _offset += 1;

        bool _success;
        for (uint8 i = 0; i < _numberOfTransfer; i++) {
            (_offset, _success) = decodeTransferCall_V1(
                _tokenContractAddress,
                _auctionEndVoucherData,
                _offset
            );

            if (!_success) {
                return false;
            }
        }

        return true;

    }

    /// @notice decode transfert and call token smart contract
    /// @param _tokenContractAddress address
    /// @param _auctionEndVoucherData bytes
    /// @param _offset of begin transfert data
    /// @return new offset, and _success
    function decodeTransferCall_V1(
        address _tokenContractAddress,
        bytes memory _auctionEndVoucherData,
        uint _offset
    ) internal returns (uint, bool) {
        bytes memory _sizeOfCallBytes;
        bytes memory _callData;

        uint _sizeOfCallData;

        if (_auctionEndVoucherData[_offset] == 0xb8) {
            _sizeOfCallBytes = new bytes(1);
            _sizeOfCallBytes[0] = bytes1(_auctionEndVoucherData[_offset + 1]);

            _offset += 2;
        }
        if (_auctionEndVoucherData[_offset] == 0xb9) {
            _sizeOfCallBytes = new bytes(2);
            _sizeOfCallBytes[0] = bytes1(_auctionEndVoucherData[_offset + 1]);
            _sizeOfCallBytes[1] = bytes1(_auctionEndVoucherData[_offset + 2]);
            _offset += 3;
        }
        
        _sizeOfCallData = bytesToUint_V1(_sizeOfCallBytes);

        _callData = new bytes(_sizeOfCallData);
        for (uint j = 0; j < _sizeOfCallData; j++) {
            _callData[j] = _auctionEndVoucherData[(j + _offset)];
        }

        _offset += _sizeOfCallData;

        return (_offset, sendCallData_V1(
            _tokenContractAddress,
            _sizeOfCallData,
            _callData
        ));

    }

    /// @notice call token smart contract with call data
    /// @param _tokenContractAddress address
    /// @param _sizeOfCallData uint256 , size of call data
    /// @param _callData bytes
    /// @return _success
    function sendCallData_V1(
        address _tokenContractAddress,
        uint256 _sizeOfCallData,
        bytes memory _callData
    ) internal returns (bool) {
        bool _success;
        bytes4 sig;

        assembly {
            let _ptr := mload(0x40)
            sig := mload(add(_callData, 0x20))

            mstore(_ptr, sig) //Place signature at begining of empty storage
            for {
                let i := 0x04
            } lt(i, _sizeOfCallData) {
                i := add(i, 0x20)
            } {
                mstore(add(_ptr, i), mload(add(_callData, add(0x20, i)))) //Add each param
            }

            // call external smart contract with 10K de gas, return _success
            _success := call(
                //This is the critical change (Pop the top stack value)
                sub(gas, 10000), // gas
                _tokenContractAddress, //To addr
                0, //No value
                _ptr, //Inputs are stored at location _ptr
                _sizeOfCallData, //Inputs _size
                _ptr, //Store output over input (saves space)
                0x20
            ) //Outputs are 32 bytes long

        }

        return _success;
    }

}
