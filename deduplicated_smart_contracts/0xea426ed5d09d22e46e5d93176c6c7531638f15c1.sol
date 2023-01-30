/**
 *Submitted for verification at Etherscan.io on 2021-03-17
*/

pragma solidity ^0.6.10;
pragma experimental ABIEncoderV2;

interface TokenInterface {
    function balanceOf(address) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint256);
    function decimals() external view returns (uint);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);

}

contract Resolver {
    struct TokenData {
        bool isToken;
        string name;
        string symbol;
        uint256 decimals;
    }

    function getTokenDetails(address[] memory tknAddress) public view returns (TokenData[] memory) {
        TokenData[] memory tokenDatas = new TokenData[](tknAddress.length);
        for (uint i = 0; i < tknAddress.length; i++) {
            if (tknAddress[i] == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
                tokenDatas[i] = TokenData(
                    true,
                    "ETHER",
                    "ETH",
                    18
                );
            } else {
                TokenInterface token = TokenInterface(tknAddress[i]);
                bool isToken = true;
                
                try token.symbol() {
                } catch {
                    isToken = false;
                    continue;
                }
                
                try token.name() {
                } catch {
                    isToken = false;
                    continue;
                }
                
                try token.decimals() {
                } catch {
                    isToken = false;
                    continue;
                }
                
                tokenDatas[i] = TokenData(
                        true,
                        token.name(),
                        token.symbol(),
                        token.decimals()
                );
            }
        }
        return tokenDatas;
    }

    function getBalances(address owner, address[] memory tknAddress) public view returns (uint[] memory) {
        uint[] memory tokensBal = new uint[](tknAddress.length);
        for (uint i = 0; i < tknAddress.length; i++) {
            if (tknAddress[i] == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
                tokensBal[i] = owner.balance;
            } else {
                TokenInterface token = TokenInterface(tknAddress[i]);
                tokensBal[i] = token.balanceOf(owner);
            }
        }
        return tokensBal;
    }

    function getAllowances(address owner, address spender, address[] memory tknAddress) public view returns (uint[] memory) {
        uint[] memory tokenAllowances = new uint[](tknAddress.length);
        for (uint i = 0; i < tknAddress.length; i++) {
            if (tknAddress[i] == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
                tokenAllowances[i] = 0;
            } else {
                TokenInterface token = TokenInterface(tknAddress[i]);
                tokenAllowances[i] = token.allowance(owner, spender);
            }
        }
        return tokenAllowances;
    }

}


contract InstaERC20Resolver is Resolver {

    string public constant name = "ERC20-Resolver-v1.1";

}