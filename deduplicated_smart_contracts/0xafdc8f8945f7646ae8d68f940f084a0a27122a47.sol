/**
 *Submitted for verification at Etherscan.io on 2020-02-25
*/

pragma solidity ^0.5.0;

library StringUtil {
    /*
     * 字符串连接
     */
    function concat(string memory self, string memory str) pure public returns(string memory) {
        bytes memory selfBytes = bytes(self);
        bytes memory strBytes = bytes(str);
        
        uint selfLen = selfBytes.length;
        uint strLen = strBytes.length;
        
        if (selfLen == 0 && strLen == 0) {
            return self;
        } else if (selfLen == 0) {
            return str;
        } else if (strLen == 0) {
            return self;
        }
        
        uint length = selfLen + strLen;
        bytes memory temp = new bytes(length);
        uint index = 0;
        for (uint i = 0 ; i < selfLen ; i++) {
            temp[index++] = selfBytes[i];
        }
        for (uint i = 0 ; i < strLen ; i++) {
            temp[index++] = strBytes[i];
        }
        
        return string(temp);
    }
    
    /*
     * 字符串比较，self>str => 1，self<str => -1，self=str => 0
     */
    function compare(string memory self, string memory str) pure public returns(int) {
        bytes memory selfBytes = bytes(self);
        bytes memory strBytes = bytes(str);
        
        uint selfLen = selfBytes.length;
        uint strLen = strBytes.length;
        
        uint minLen = selfLen;
        if (selfLen > strLen) {
            minLen = strLen;
        }
        
        for (uint i = 0 ; i < minLen ; i++) {
            if (selfBytes[i] < strBytes[i]) {
                return -1;
            } else if (selfBytes[i] > strBytes[i]) {
                return 1;
            }
        }
        
        if (selfLen < strLen) {
            return -1;
        } else if (selfLen > strLen) {
            return 1;
        }
        
        return 0;
    }
    
    /*
     * 字符串是否相同  
     */
    function equals(string memory self, string memory str) pure public returns(bool) {
        return compare(self, str) == 0;
    }

    /*
     *  获取子字符串第一次出现的位置下标
     */
    function indexOf(string memory self, string memory str) pure public returns(int) {
        bytes memory selfBytes = bytes(self);
        bytes memory strBytes = bytes(str);
        
        uint selfLen = selfBytes.length;
        uint strLen = strBytes.length;
        
        if (selfLen < 1 || strLen < 1 || selfLen < strLen) {
            return -1;
        }
        
        if (selfLen > 2 ** 128 - 1) {
            return -1;
        }
        
        uint index = 0;
        for (uint i = 0 ; i < selfLen ; i++) {
            if (selfBytes[i] == strBytes[0]) {
                index = 1;
                while (index < strLen && (i + index) < selfLen && selfBytes[i + index] == strBytes[index]) {
                    index++;
                }
                
                if (index == strLen) {
                    return int(i);
                }
            }
        }
        
        return -1;
    }
    
    /*
     *   将uint256转成字符串 
     */
    function fromUint256(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = byte(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}


contract TestDiary {
    using StringUtil for string;
    
    struct Diary {
        uint id;
        uint time;
        uint star;
        string phone;
        string content;
    }
    
    uint private index = 0;
    
    mapping(uint=>Diary) private diaries;
    mapping(string=>uint[]) private phoneDiaries;
    
    function getTotal() view public returns(uint) {
        return index;
    }
    
    function star(uint id) public {
        require(diaries[id].time > 0, "日记不存在!");
        diaries[id].star++;
    }
    
    function getStar(uint id) view public returns(uint) {
        require(diaries[id].time > 0, "日记不存在!");
        return diaries[id].star;
    }
    
    function publish(string memory phone, string memory content) public {
        require(keccak256(bytes(phone)) != keccak256(""), "Phone 不能为空");
        require(keccak256(bytes(content)) != keccak256(""), "Content 不能为空");
        
        uint _id = index++;
        Diary memory diary = Diary({
            id : _id,
            phone : phone,
            content : content,
            time : now,
            star : 0
        });

        diaries[_id] = diary;
        if (phoneDiaries[phone].length > 0) {
            phoneDiaries[phone].push(_id);
        } else {
            phoneDiaries[phone]=[_id];
        }
    }
    
    function getIdsByPhone(string memory phone) view public returns(uint[] memory) {
        return phoneDiaries[phone];
    }
    
    function getByContentId(uint id) view public returns(string memory) {
        require(diaries[id].time > 0, "日记不存在!");
        return diaries[id].content;
    }
    
    function getById(uint id) view public returns(uint, uint, uint, string memory, string memory) {
        require(diaries[id].time > 0, "日记不存在!");
        Diary memory diary = diaries[id];
        return (diary.id, diary.time, diary.star, diary.phone, diary.content);
    }
    
    function diaryToJsonString(Diary memory diary) pure private returns(string memory) {
        string memory temp = "{id:";
        temp = temp.concat(StringUtil.fromUint256(diary.id));
        temp = temp.concat(",phone:'");
        temp = temp.concat(diary.phone);
        temp = temp.concat("',content:'");
        temp = temp.concat(diary.content);
        temp = temp.concat("',time:");
        temp = temp.concat(StringUtil.fromUint256(diary.time));
        temp = temp.concat(",star:");
        temp = temp.concat(StringUtil.fromUint256(diary.star));
        temp = temp.concat("}");
        
        return temp;
    }
}