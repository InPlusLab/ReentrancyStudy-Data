/**

 *Submitted for verification at Etherscan.io on 2019-04-08

*/



// File: @digix/solidity-collections/contracts/abstract/AddressIteratorInteractive.sol



pragma solidity ^0.4.19;

/**

  @title Address Iterator Interactive

  @author DigixGlobal Pte Ltd

*/

contract AddressIteratorInteractive {



  /**

    @notice Lists a Address collection from start or end

    @param _count Total number of Address items to return

    @param _function_first Function that returns the First Address item in the list

    @param _function_last Function that returns the last Address item in the list

    @param _function_next Function that returns the Next Address item in the list

    @param _function_previous Function that returns previous Address item in the list

    @param _from_start whether to read from start (or end) of the list

    @return {"_address_items" : "Collection of reversed Address list"}

  */

  function list_addresses(uint256 _count,

                                 function () external constant returns (address) _function_first,

                                 function () external constant returns (address) _function_last,

                                 function (address) external constant returns (address) _function_next,

                                 function (address) external constant returns (address) _function_previous,

                                 bool _from_start)

           internal

           constant

           returns (address[] _address_items)

  {

    if (_from_start) {

      _address_items = private_list_addresses_from_address(_function_first(), _count, true, _function_last, _function_next);

    } else {

      _address_items = private_list_addresses_from_address(_function_last(), _count, true, _function_first, _function_previous);

    }

  }







  /**

    @notice Lists a Address collection from some `_current_item`, going forwards or backwards depending on `_from_start`

    @param _current_item The current Item

    @param _count Total number of Address items to return

    @param _function_first Function that returns the First Address item in the list

    @param _function_last Function that returns the last Address item in the list

    @param _function_next Function that returns the Next Address item in the list

    @param _function_previous Function that returns previous Address item in the list

    @param _from_start whether to read in the forwards ( or backwards) direction

    @return {"_address_items" :"Collection/list of Address"}

  */

  function list_addresses_from(address _current_item, uint256 _count,

                                function () external constant returns (address) _function_first,

                                function () external constant returns (address) _function_last,

                                function (address) external constant returns (address) _function_next,

                                function (address) external constant returns (address) _function_previous,

                                bool _from_start)

           internal

           constant

           returns (address[] _address_items)

  {

    if (_from_start) {

      _address_items = private_list_addresses_from_address(_current_item, _count, false, _function_last, _function_next);

    } else {

      _address_items = private_list_addresses_from_address(_current_item, _count, false, _function_first, _function_previous);

    }

  }





  /**

    @notice a private function to lists a Address collection starting from some `_current_item` (which could be included or excluded), in the forwards or backwards direction

    @param _current_item The current Item

    @param _count Total number of Address items to return

    @param _including_current Whether the `_current_item` should be included in the result

    @param _function_last Function that returns the address where we stop reading more address

    @param _function_next Function that returns the next address to read after some address (could be backwards or forwards in the physical collection)

    @return {"_address_items" :"Collection/list of Address"}

  */

  function private_list_addresses_from_address(address _current_item, uint256 _count, bool _including_current,

                                 function () external constant returns (address) _function_last,

                                 function (address) external constant returns (address) _function_next)

           private

           constant

           returns (address[] _address_items)

  {

    uint256 _i;

    uint256 _real_count = 0;

    address _last_item;



    _last_item = _function_last();

    if (_count == 0 || _last_item == address(0x0)) {

      _address_items = new address[](0);

    } else {

      address[] memory _items_temp = new address[](_count);

      address _this_item;

      if (_including_current == true) {

        _items_temp[0] = _current_item;

        _real_count = 1;

      }

      _this_item = _current_item;

      for (_i = _real_count; (_i < _count) && (_this_item != _last_item);_i++) {

        _this_item = _function_next(_this_item);

        if (_this_item != address(0x0)) {

          _real_count++;

          _items_temp[_i] = _this_item;

        }

      }



      _address_items = new address[](_real_count);

      for(_i = 0;_i < _real_count;_i++) {

        _address_items[_i] = _items_temp[_i];

      }

    }

  }





  /** DEPRECATED

    @notice private function to list a Address collection starting from the start or end of the list

    @param _count Total number of Address item to return

    @param _function_total Function that returns the Total number of Address item in the list

    @param _function_first Function that returns the First Address item in the list

    @param _function_next Function that returns the Next Address item in the list

    @return {"_address_items" :"Collection/list of Address"}

  */

  /*function list_addresses_from_start_or_end(uint256 _count,

                                 function () external constant returns (uint256) _function_total,

                                 function () external constant returns (address) _function_first,

                                 function (address) external constant returns (address) _function_next)



           private

           constant

           returns (address[] _address_items)

  {

    uint256 _i;

    address _current_item;

    uint256 _real_count = _function_total();



    if (_count > _real_count) {

      _count = _real_count;

    }



    address[] memory _items_tmp = new address[](_count);



    if (_count > 0) {

      _current_item = _function_first();

      _items_tmp[0] = _current_item;



      for(_i = 1;_i <= (_count - 1);_i++) {

        _current_item = _function_next(_current_item);

        if (_current_item != address(0x0)) {

          _items_tmp[_i] = _current_item;

        }

      }

      _address_items = _items_tmp;

    } else {

      _address_items = new address[](0);

    }

  }*/



  /** DEPRECATED

    @notice a private function to lists a Address collection starting from some `_current_item`, could be forwards or backwards

    @param _current_item The current Item

    @param _count Total number of Address items to return

    @param _function_last Function that returns the bytes where we stop reading more bytes

    @param _function_next Function that returns the next bytes to read after some bytes (could be backwards or forwards in the physical collection)

    @return {"_address_items" :"Collection/list of Address"}

  */

  /*function list_addresses_from_byte(address _current_item, uint256 _count,

                                 function () external constant returns (address) _function_last,

                                 function (address) external constant returns (address) _function_next)

           private

           constant

           returns (address[] _address_items)

  {

    uint256 _i;

    uint256 _real_count = 0;



    if (_count == 0) {

      _address_items = new address[](0);

    } else {

      address[] memory _items_temp = new address[](_count);



      address _start_item;

      address _last_item;



      _last_item = _function_last();



      if (_last_item != _current_item) {

        _start_item = _function_next(_current_item);

        if (_start_item != address(0x0)) {

          _items_temp[0] = _start_item;

          _real_count = 1;

          for(_i = 1;(_i <= (_count - 1)) && (_start_item != _last_item);_i++) {

            _start_item = _function_next(_start_item);

            if (_start_item != address(0x0)) {

              _real_count++;

              _items_temp[_i] = _start_item;

            }

          }

          _address_items = new address[](_real_count);

          for(_i = 0;_i <= (_real_count - 1);_i++) {

            _address_items[_i] = _items_temp[_i];

          }

        } else {

          _address_items = new address[](0);

        }

      } else {

        _address_items = new address[](0);

      }

    }

  }*/

}



// File: @digix/solidity-collections/contracts/abstract/BytesIteratorInteractive.sol

/**

  @title Bytes Iterator Interactive

  @author DigixGlobal Pte Ltd

*/

contract BytesIteratorInteractive {



  /**

    @notice Lists a Bytes collection from start or end

    @param _count Total number of Bytes items to return

    @param _function_first Function that returns the First Bytes item in the list

    @param _function_last Function that returns the last Bytes item in the list

    @param _function_next Function that returns the Next Bytes item in the list

    @param _function_previous Function that returns previous Bytes item in the list

    @param _from_start whether to read from start (or end) of the list

    @return {"_bytes_items" : "Collection of reversed Bytes list"}

  */

  function list_bytesarray(uint256 _count,

                                 function () external constant returns (bytes32) _function_first,

                                 function () external constant returns (bytes32) _function_last,

                                 function (bytes32) external constant returns (bytes32) _function_next,

                                 function (bytes32) external constant returns (bytes32) _function_previous,

                                 bool _from_start)

           internal

           constant

           returns (bytes32[] _bytes_items)

  {

    if (_from_start) {

      _bytes_items = private_list_bytes_from_bytes(_function_first(), _count, true, _function_last, _function_next);

    } else {

      _bytes_items = private_list_bytes_from_bytes(_function_last(), _count, true, _function_first, _function_previous);

    }

  }



  /**

    @notice Lists a Bytes collection from some `_current_item`, going forwards or backwards depending on `_from_start`

    @param _current_item The current Item

    @param _count Total number of Bytes items to return

    @param _function_first Function that returns the First Bytes item in the list

    @param _function_last Function that returns the last Bytes item in the list

    @param _function_next Function that returns the Next Bytes item in the list

    @param _function_previous Function that returns previous Bytes item in the list

    @param _from_start whether to read in the forwards ( or backwards) direction

    @return {"_bytes_items" :"Collection/list of Bytes"}

  */

  function list_bytesarray_from(bytes32 _current_item, uint256 _count,

                                function () external constant returns (bytes32) _function_first,

                                function () external constant returns (bytes32) _function_last,

                                function (bytes32) external constant returns (bytes32) _function_next,

                                function (bytes32) external constant returns (bytes32) _function_previous,

                                bool _from_start)

           internal

           constant

           returns (bytes32[] _bytes_items)

  {

    if (_from_start) {

      _bytes_items = private_list_bytes_from_bytes(_current_item, _count, false, _function_last, _function_next);

    } else {

      _bytes_items = private_list_bytes_from_bytes(_current_item, _count, false, _function_first, _function_previous);

    }

  }



  /**

    @notice A private function to lists a Bytes collection starting from some `_current_item` (which could be included or excluded), in the forwards or backwards direction

    @param _current_item The current Item

    @param _count Total number of Bytes items to return

    @param _including_current Whether the `_current_item` should be included in the result

    @param _function_last Function that returns the bytes where we stop reading more bytes

    @param _function_next Function that returns the next bytes to read after some bytes (could be backwards or forwards in the physical collection)

    @return {"_address_items" :"Collection/list of Bytes"}

  */

  function private_list_bytes_from_bytes(bytes32 _current_item, uint256 _count, bool _including_current,

                                 function () external constant returns (bytes32) _function_last,

                                 function (bytes32) external constant returns (bytes32) _function_next)

           private

           constant

           returns (bytes32[] _bytes32_items)

  {

    uint256 _i;

    uint256 _real_count = 0;

    bytes32 _last_item;



    _last_item = _function_last();

    if (_count == 0 || _last_item == bytes32(0x0)) {

      _bytes32_items = new bytes32[](0);

    } else {

      bytes32[] memory _items_temp = new bytes32[](_count);

      bytes32 _this_item;

      if (_including_current == true) {

        _items_temp[0] = _current_item;

        _real_count = 1;

      }

      _this_item = _current_item;

      for (_i = _real_count; (_i < _count) && (_this_item != _last_item);_i++) {

        _this_item = _function_next(_this_item);

        if (_this_item != bytes32(0x0)) {

          _real_count++;

          _items_temp[_i] = _this_item;

        }

      }



      _bytes32_items = new bytes32[](_real_count);

      for(_i = 0;_i < _real_count;_i++) {

        _bytes32_items[_i] = _items_temp[_i];

      }

    }

  }









  ////// DEPRECATED FUNCTIONS (old versions)



  /**

    @notice a private function to lists a Bytes collection starting from some `_current_item`, could be forwards or backwards

    @param _current_item The current Item

    @param _count Total number of Bytes items to return

    @param _function_last Function that returns the bytes where we stop reading more bytes

    @param _function_next Function that returns the next bytes to read after some bytes (could be backwards or forwards in the physical collection)

    @return {"_bytes_items" :"Collection/list of Bytes"}

  */

  /*function list_bytes_from_bytes(bytes32 _current_item, uint256 _count,

                                 function () external constant returns (bytes32) _function_last,

                                 function (bytes32) external constant returns (bytes32) _function_next)

           private

           constant

           returns (bytes32[] _bytes_items)

  {

    uint256 _i;

    uint256 _real_count = 0;



    if (_count == 0) {

      _bytes_items = new bytes32[](0);

    } else {

      bytes32[] memory _items_temp = new bytes32[](_count);



      bytes32 _start_item;

      bytes32 _last_item;



      _last_item = _function_last();



      if (_last_item != _current_item) {

        _start_item = _function_next(_current_item);

        if (_start_item != bytes32(0x0)) {

          _items_temp[0] = _start_item;

          _real_count = 1;

          for(_i = 1;(_i <= (_count - 1)) && (_start_item != _last_item);_i++) {

            _start_item = _function_next(_start_item);

            if (_start_item != bytes32(0x0)) {

              _real_count++;

              _items_temp[_i] = _start_item;

            }

          }

          _bytes_items = new bytes32[](_real_count);

          for(_i = 0;_i <= (_real_count - 1);_i++) {

            _bytes_items[_i] = _items_temp[_i];

          }

        } else {

          _bytes_items = new bytes32[](0);

        }

      } else {

        _bytes_items = new bytes32[](0);

      }

    }

  }*/



  /**

    @notice private function to list a Bytes collection starting from the start or end of the list

    @param _count Total number of Bytes item to return

    @param _function_total Function that returns the Total number of Bytes item in the list

    @param _function_first Function that returns the First Bytes item in the list

    @param _function_next Function that returns the Next Bytes item in the list

    @return {"_bytes_items" :"Collection/list of Bytes"}

  */

  /*function list_bytes_from_start_or_end(uint256 _count,

                                 function () external constant returns (uint256) _function_total,

                                 function () external constant returns (bytes32) _function_first,

                                 function (bytes32) external constant returns (bytes32) _function_next)



           private

           constant

           returns (bytes32[] _bytes_items)

  {

    uint256 _i;

    bytes32 _current_item;

    uint256 _real_count = _function_total();



    if (_count > _real_count) {

      _count = _real_count;

    }



    bytes32[] memory _items_tmp = new bytes32[](_count);



    if (_count > 0) {

      _current_item = _function_first();

      _items_tmp[0] = _current_item;



      for(_i = 1;_i <= (_count - 1);_i++) {

        _current_item = _function_next(_current_item);

        if (_current_item != bytes32(0x0)) {

          _items_tmp[_i] = _current_item;

        }

      }

      _bytes_items = _items_tmp;

    } else {

      _bytes_items = new bytes32[](0);

    }

  }*/

}



// File: @digix/solidity-collections/contracts/abstract/IndexedBytesIteratorInteractive.sol

/**

  @title Indexed Bytes Iterator Interactive

  @author DigixGlobal Pte Ltd

*/

contract IndexedBytesIteratorInteractive {



  /**

    @notice Lists an indexed Bytes collection from start or end

    @param _collection_index Index of the Collection to list

    @param _count Total number of Bytes items to return

    @param _function_first Function that returns the First Bytes item in the list

    @param _function_last Function that returns the last Bytes item in the list

    @param _function_next Function that returns the Next Bytes item in the list

    @param _function_previous Function that returns previous Bytes item in the list

    @param _from_start whether to read from start (or end) of the list

    @return {"_bytes_items" : "Collection of reversed Bytes list"}

  */

  function list_indexed_bytesarray(bytes32 _collection_index, uint256 _count,

                              function (bytes32) external constant returns (bytes32) _function_first,

                              function (bytes32) external constant returns (bytes32) _function_last,

                              function (bytes32, bytes32) external constant returns (bytes32) _function_next,

                              function (bytes32, bytes32) external constant returns (bytes32) _function_previous,

                              bool _from_start)

           internal

           constant

           returns (bytes32[] _indexed_bytes_items)

  {

    if (_from_start) {

      _indexed_bytes_items = private_list_indexed_bytes_from_bytes(_collection_index, _function_first(_collection_index), _count, true, _function_last, _function_next);

    } else {

      _indexed_bytes_items = private_list_indexed_bytes_from_bytes(_collection_index, _function_last(_collection_index), _count, true, _function_first, _function_previous);

    }

  }



  /**

    @notice Lists an indexed Bytes collection from some `_current_item`, going forwards or backwards depending on `_from_start`

    @param _collection_index Index of the Collection to list

    @param _current_item The current Item

    @param _count Total number of Bytes items to return

    @param _function_first Function that returns the First Bytes item in the list

    @param _function_last Function that returns the last Bytes item in the list

    @param _function_next Function that returns the Next Bytes item in the list

    @param _function_previous Function that returns previous Bytes item in the list

    @param _from_start whether to read in the forwards ( or backwards) direction

    @return {"_bytes_items" :"Collection/list of Bytes"}

  */

  function list_indexed_bytesarray_from(bytes32 _collection_index, bytes32 _current_item, uint256 _count,

                                function (bytes32) external constant returns (bytes32) _function_first,

                                function (bytes32) external constant returns (bytes32) _function_last,

                                function (bytes32, bytes32) external constant returns (bytes32) _function_next,

                                function (bytes32, bytes32) external constant returns (bytes32) _function_previous,

                                bool _from_start)

           internal

           constant

           returns (bytes32[] _indexed_bytes_items)

  {

    if (_from_start) {

      _indexed_bytes_items = private_list_indexed_bytes_from_bytes(_collection_index, _current_item, _count, false, _function_last, _function_next);

    } else {

      _indexed_bytes_items = private_list_indexed_bytes_from_bytes(_collection_index, _current_item, _count, false, _function_first, _function_previous);

    }

  }



  /**

    @notice a private function to lists an indexed Bytes collection starting from some `_current_item` (which could be included or excluded), in the forwards or backwards direction

    @param _collection_index Index of the Collection to list

    @param _current_item The item where we start reading from the list

    @param _count Total number of Bytes items to return

    @param _including_current Whether the `_current_item` should be included in the result

    @param _function_last Function that returns the bytes where we stop reading more bytes

    @param _function_next Function that returns the next bytes to read after another bytes (could be backwards or forwards in the physical collection)

    @return {"_bytes_items" :"Collection/list of Bytes"}

  */

  function private_list_indexed_bytes_from_bytes(bytes32 _collection_index, bytes32 _current_item, uint256 _count, bool _including_current,

                                         function (bytes32) external constant returns (bytes32) _function_last,

                                         function (bytes32, bytes32) external constant returns (bytes32) _function_next)

           private

           constant

           returns (bytes32[] _indexed_bytes_items)

  {

    uint256 _i;

    uint256 _real_count = 0;

    bytes32 _last_item;



    _last_item = _function_last(_collection_index);

    if (_count == 0 || _last_item == bytes32(0x0)) {  // if count is 0 or the collection is empty, returns empty array

      _indexed_bytes_items = new bytes32[](0);

    } else {

      bytes32[] memory _items_temp = new bytes32[](_count);

      bytes32 _this_item;

      if (_including_current) {

        _items_temp[0] = _current_item;

        _real_count = 1;

      }

      _this_item = _current_item;

      for (_i = _real_count; (_i < _count) && (_this_item != _last_item);_i++) {

        _this_item = _function_next(_collection_index, _this_item);

        if (_this_item != bytes32(0x0)) {

          _real_count++;

          _items_temp[_i] = _this_item;

        }

      }



      _indexed_bytes_items = new bytes32[](_real_count);

      for(_i = 0;_i < _real_count;_i++) {

        _indexed_bytes_items[_i] = _items_temp[_i];

      }

    }

  }





  // old function, DEPRECATED

  /*function list_indexed_bytes_from_bytes(bytes32 _collection_index, bytes32 _current_item, uint256 _count,

                                         function (bytes32) external constant returns (bytes32) _function_last,

                                         function (bytes32, bytes32) external constant returns (bytes32) _function_next)

           private

           constant

           returns (bytes32[] _indexed_bytes_items)

  {

    uint256 _i;

    uint256 _real_count = 0;

    if (_count == 0) {

      _indexed_bytes_items = new bytes32[](0);

    } else {

      bytes32[] memory _items_temp = new bytes32[](_count);



      bytes32 _start_item;

      bytes32 _last_item;



      _last_item = _function_last(_collection_index);



      if (_last_item != _current_item) {

        _start_item = _function_next(_collection_index, _current_item);

        if (_start_item != bytes32(0x0)) {

          _items_temp[0] = _start_item;

          _real_count = 1;

          for(_i = 1;(_i <= (_count - 1)) && (_start_item != _last_item);_i++) {

            _start_item = _function_next(_collection_index, _start_item);

            if (_start_item != bytes32(0x0)) {

              _real_count++;

              _items_temp[_i] = _start_item;

            }

          }

          _indexed_bytes_items = new bytes32[](_real_count);

          for(_i = 0;_i <= (_real_count - 1);_i++) {

            _indexed_bytes_items[_i] = _items_temp[_i];

          }

        } else {

          _indexed_bytes_items = new bytes32[](0);

        }

      } else {

        _indexed_bytes_items = new bytes32[](0);

      }

    }

  }*/

}



// File: @digix/solidity-collections/contracts/lib/DoublyLinkedList.sol

library DoublyLinkedList {



  struct Item {

    bytes32 item;

    uint256 previous_index;

    uint256 next_index;

  }



  struct Data {

    uint256 first_index;

    uint256 last_index;

    uint256 count;

    mapping(bytes32 => uint256) item_index;

    mapping(uint256 => bool) valid_indexes;

    Item[] collection;

  }



  struct IndexedUint {

    mapping(bytes32 => Data) data;

  }



  struct IndexedAddress {

    mapping(bytes32 => Data) data;

  }



  struct IndexedBytes {

    mapping(bytes32 => Data) data;

  }



  struct Address {

    Data data;

  }



  struct Bytes {

    Data data;

  }



  struct Uint {

    Data data;

  }



  uint256 constant NONE = uint256(0);

  bytes32 constant EMPTY_BYTES = bytes32(0x0);

  address constant NULL_ADDRESS = address(0x0);



  function find(Data storage self, bytes32 _item)

           public

           constant

           returns (uint256 _item_index)

  {

    if ((self.item_index[_item] == NONE) && (self.count == NONE)) {

      _item_index = NONE;

    } else {

      _item_index = self.item_index[_item];

    }

  }



  function get(Data storage self, uint256 _item_index)

           public

           constant

           returns (bytes32 _item)

  {

    if (self.valid_indexes[_item_index] == true) {

      _item = self.collection[_item_index - 1].item;

    } else {

      _item = EMPTY_BYTES;

    }

  }



  function append(Data storage self, bytes32 _data)

           internal

           returns (bool _success)

  {

    if (find(self, _data) != NONE || _data == bytes32("")) { // rejects addition of empty values

      _success = false;

    } else {

      uint256 _index = uint256(self.collection.push(Item({item: _data, previous_index: self.last_index, next_index: NONE})));

      if (self.last_index == NONE) {

        if ((self.first_index != NONE) || (self.count != NONE)) {

          revert();

        } else {

          self.first_index = self.last_index = _index;

          self.count = 1;

        }

      } else {

        self.collection[self.last_index - 1].next_index = _index;

        self.last_index = _index;

        self.count++;

      }

      self.valid_indexes[_index] = true;

      self.item_index[_data] = _index;

      _success = true;

    }

  }



  function remove(Data storage self, uint256 _index)

           internal

           returns (bool _success)

  {

    if (self.valid_indexes[_index] == true) {

      Item memory item = self.collection[_index - 1];

      if (item.previous_index == NONE) {

        self.first_index = item.next_index;

      } else {

        self.collection[item.previous_index - 1].next_index = item.next_index;

      }



      if (item.next_index == NONE) {

        self.last_index = item.previous_index;

      } else {

        self.collection[item.next_index - 1].previous_index = item.previous_index;

      }

      delete self.collection[_index - 1];

      self.valid_indexes[_index] = false;

      delete self.item_index[item.item];

      self.count--;

      _success = true;

    } else {

      _success = false;

    }

  }



  function remove_item(Data storage self, bytes32 _item)

           internal

           returns (bool _success)

  {

    uint256 _item_index = find(self, _item);

    if (_item_index != NONE) {

      require(remove(self, _item_index));

      _success = true;

    } else {

      _success = false;

    }

    return _success;

  }



  function total(Data storage self)

           public

           constant

           returns (uint256 _total_count)

  {

    _total_count = self.count;

  }



  function start(Data storage self)

           public

           constant

           returns (uint256 _item_index)

  {

    _item_index = self.first_index;

    return _item_index;

  }



  function start_item(Data storage self)

           public

           constant

           returns (bytes32 _item)

  {

    uint256 _item_index = start(self);

    if (_item_index != NONE) {

      _item = get(self, _item_index);

    } else {

      _item = EMPTY_BYTES;

    }

  }



  function end(Data storage self)

           public

           constant

           returns (uint256 _item_index)

  {

    _item_index = self.last_index;

    return _item_index;

  }



  function end_item(Data storage self)

           public

           constant

           returns (bytes32 _item)

  {

    uint256 _item_index = end(self);

    if (_item_index != NONE) {

      _item = get(self, _item_index);

    } else {

      _item = EMPTY_BYTES;

    }

  }



  function valid(Data storage self, uint256 _item_index)

           public

           constant

           returns (bool _yes)

  {

    _yes = self.valid_indexes[_item_index];

    //_yes = ((_item_index - 1) < self.collection.length);

  }



  function valid_item(Data storage self, bytes32 _item)

           public

           constant

           returns (bool _yes)

  {

    uint256 _item_index = self.item_index[_item];

    _yes = self.valid_indexes[_item_index];

  }



  function previous(Data storage self, uint256 _current_index)

           public

           constant

           returns (uint256 _previous_index)

  {

    if (self.valid_indexes[_current_index] == true) {

      _previous_index = self.collection[_current_index - 1].previous_index;

    } else {

      _previous_index = NONE;

    }

  }



  function previous_item(Data storage self, bytes32 _current_item)

           public

           constant

           returns (bytes32 _previous_item)

  {

    uint256 _current_index = find(self, _current_item);

    if (_current_index != NONE) {

      uint256 _previous_index = previous(self, _current_index);

      _previous_item = get(self, _previous_index);

    } else {

      _previous_item = EMPTY_BYTES;

    }

  }



  function next(Data storage self, uint256 _current_index)

           public

           constant

           returns (uint256 _next_index)

  {

    if (self.valid_indexes[_current_index] == true) {

      _next_index = self.collection[_current_index - 1].next_index;

    } else {

      _next_index = NONE;

    }

  }



  function next_item(Data storage self, bytes32 _current_item)

           public

           constant

           returns (bytes32 _next_item)

  {

    uint256 _current_index = find(self, _current_item);

    if (_current_index != NONE) {

      uint256 _next_index = next(self, _current_index);

      _next_item = get(self, _next_index);

    } else {

      _next_item = EMPTY_BYTES;

    }

  }



  function find(Uint storage self, uint256 _item)

           public

           constant

           returns (uint256 _item_index)

  {

    _item_index = find(self.data, bytes32(_item));

  }



  function get(Uint storage self, uint256 _item_index)

           public

           constant

           returns (uint256 _item)

  {

    _item = uint256(get(self.data, _item_index));

  }





  function append(Uint storage self, uint256 _data)

           public

           returns (bool _success)

  {

    _success = append(self.data, bytes32(_data));

  }



  function remove(Uint storage self, uint256 _index)

           internal

           returns (bool _success)

  {

    _success = remove(self.data, _index);

  }



  function remove_item(Uint storage self, uint256 _item)

           public

           returns (bool _success)

  {

    _success = remove_item(self.data, bytes32(_item));

  }



  function total(Uint storage self)

           public

           constant

           returns (uint256 _total_count)

  {

    _total_count = total(self.data);

  }



  function start(Uint storage self)

           public

           constant

           returns (uint256 _index)

  {

    _index = start(self.data);

  }



  function start_item(Uint storage self)

           public

           constant

           returns (uint256 _start_item)

  {

    _start_item = uint256(start_item(self.data));

  }





  function end(Uint storage self)

           public

           constant

           returns (uint256 _index)

  {

    _index = end(self.data);

  }



  function end_item(Uint storage self)

           public

           constant

           returns (uint256 _end_item)

  {

    _end_item = uint256(end_item(self.data));

  }



  function valid(Uint storage self, uint256 _item_index)

           public

           constant

           returns (bool _yes)

  {

    _yes = valid(self.data, _item_index);

  }



  function valid_item(Uint storage self, uint256 _item)

           public

           constant

           returns (bool _yes)

  {

    _yes = valid_item(self.data, bytes32(_item));

  }



  function previous(Uint storage self, uint256 _current_index)

           public

           constant

           returns (uint256 _previous_index)

  {

    _previous_index = previous(self.data, _current_index);

  }



  function previous_item(Uint storage self, uint256 _current_item)

           public

           constant

           returns (uint256 _previous_item)

  {

    _previous_item = uint256(previous_item(self.data, bytes32(_current_item)));

  }



  function next(Uint storage self, uint256 _current_index)

           public

           constant

           returns (uint256 _next_index)

  {

    _next_index = next(self.data, _current_index);

  }



  function next_item(Uint storage self, uint256 _current_item)

           public

           constant

           returns (uint256 _next_item)

  {

    _next_item = uint256(next_item(self.data, bytes32(_current_item)));

  }



  function find(Address storage self, address _item)

           public

           constant

           returns (uint256 _item_index)

  {

    _item_index = find(self.data, bytes32(_item));

  }



  function get(Address storage self, uint256 _item_index)

           public

           constant

           returns (address _item)

  {

    _item = address(get(self.data, _item_index));

  }





  function find(IndexedUint storage self, bytes32 _collection_index, uint256 _item)

           public

           constant

           returns (uint256 _item_index)

  {

    _item_index = find(self.data[_collection_index], bytes32(_item));

  }



  function get(IndexedUint storage self, bytes32 _collection_index, uint256 _item_index)

           public

           constant

           returns (uint256 _item)

  {

    _item = uint256(get(self.data[_collection_index], _item_index));

  }





  function append(IndexedUint storage self, bytes32 _collection_index, uint256 _data)

           public

           returns (bool _success)

  {

    _success = append(self.data[_collection_index], bytes32(_data));

  }



  function remove(IndexedUint storage self, bytes32 _collection_index, uint256 _index)

           internal

           returns (bool _success)

  {

    _success = remove(self.data[_collection_index], _index);

  }



  function remove_item(IndexedUint storage self, bytes32 _collection_index, uint256 _item)

           public

           returns (bool _success)

  {

    _success = remove_item(self.data[_collection_index], bytes32(_item));

  }



  function total(IndexedUint storage self, bytes32 _collection_index)

           public

           constant

           returns (uint256 _total_count)

  {

    _total_count = total(self.data[_collection_index]);

  }



  function start(IndexedUint storage self, bytes32 _collection_index)

           public

           constant

           returns (uint256 _index)

  {

    _index = start(self.data[_collection_index]);

  }



  function start_item(IndexedUint storage self, bytes32 _collection_index)

           public

           constant

           returns (uint256 _start_item)

  {

    _start_item = uint256(start_item(self.data[_collection_index]));

  }





  function end(IndexedUint storage self, bytes32 _collection_index)

           public

           constant

           returns (uint256 _index)

  {

    _index = end(self.data[_collection_index]);

  }



  function end_item(IndexedUint storage self, bytes32 _collection_index)

           public

           constant

           returns (uint256 _end_item)

  {

    _end_item = uint256(end_item(self.data[_collection_index]));

  }



  function valid(IndexedUint storage self, bytes32 _collection_index, uint256 _item_index)

           public

           constant

           returns (bool _yes)

  {

    _yes = valid(self.data[_collection_index], _item_index);

  }



  function valid_item(IndexedUint storage self, bytes32 _collection_index, uint256 _item)

           public

           constant

           returns (bool _yes)

  {

    _yes = valid_item(self.data[_collection_index], bytes32(_item));

  }



  function previous(IndexedUint storage self, bytes32 _collection_index, uint256 _current_index)

           public

           constant

           returns (uint256 _previous_index)

  {

    _previous_index = previous(self.data[_collection_index], _current_index);

  }



  function previous_item(IndexedUint storage self, bytes32 _collection_index, uint256 _current_item)

           public

           constant

           returns (uint256 _previous_item)

  {

    _previous_item = uint256(previous_item(self.data[_collection_index], bytes32(_current_item)));

  }



  function next(IndexedUint storage self, bytes32 _collection_index, uint256 _current_index)

           public

           constant

           returns (uint256 _next_index)

  {

    _next_index = next(self.data[_collection_index], _current_index);

  }



  function next_item(IndexedUint storage self, bytes32 _collection_index, uint256 _current_item)

           public

           constant

           returns (uint256 _next_item)

  {

    _next_item = uint256(next_item(self.data[_collection_index], bytes32(_current_item)));

  }



  function append(Address storage self, address _data)

           public

           returns (bool _success)

  {

    _success = append(self.data, bytes32(_data));

  }



  function remove(Address storage self, uint256 _index)

           internal

           returns (bool _success)

  {

    _success = remove(self.data, _index);

  }





  function remove_item(Address storage self, address _item)

           public

           returns (bool _success)

  {

    _success = remove_item(self.data, bytes32(_item));

  }



  function total(Address storage self)

           public

           constant

           returns (uint256 _total_count)

  {

    _total_count = total(self.data);

  }



  function start(Address storage self)

           public

           constant

           returns (uint256 _index)

  {

    _index = start(self.data);

  }



  function start_item(Address storage self)

           public

           constant

           returns (address _start_item)

  {

    _start_item = address(start_item(self.data));

  }





  function end(Address storage self)

           public

           constant

           returns (uint256 _index)

  {

    _index = end(self.data);

  }



  function end_item(Address storage self)

           public

           constant

           returns (address _end_item)

  {

    _end_item = address(end_item(self.data));

  }



  function valid(Address storage self, uint256 _item_index)

           public

           constant

           returns (bool _yes)

  {

    _yes = valid(self.data, _item_index);

  }



  function valid_item(Address storage self, address _item)

           public

           constant

           returns (bool _yes)

  {

    _yes = valid_item(self.data, bytes32(_item));

  }



  function previous(Address storage self, uint256 _current_index)

           public

           constant

           returns (uint256 _previous_index)

  {

    _previous_index = previous(self.data, _current_index);

  }



  function previous_item(Address storage self, address _current_item)

           public

           constant

           returns (address _previous_item)

  {

    _previous_item = address(previous_item(self.data, bytes32(_current_item)));

  }



  function next(Address storage self, uint256 _current_index)

           public

           constant

           returns (uint256 _next_index)

  {

    _next_index = next(self.data, _current_index);

  }



  function next_item(Address storage self, address _current_item)

           public

           constant

           returns (address _next_item)

  {

    _next_item = address(next_item(self.data, bytes32(_current_item)));

  }



  function append(IndexedAddress storage self, bytes32 _collection_index, address _data)

           public

           returns (bool _success)

  {

    _success = append(self.data[_collection_index], bytes32(_data));

  }



  function remove(IndexedAddress storage self, bytes32 _collection_index, uint256 _index)

           internal

           returns (bool _success)

  {

    _success = remove(self.data[_collection_index], _index);

  }





  function remove_item(IndexedAddress storage self, bytes32 _collection_index, address _item)

           public

           returns (bool _success)

  {

    _success = remove_item(self.data[_collection_index], bytes32(_item));

  }



  function total(IndexedAddress storage self, bytes32 _collection_index)

           public

           constant

           returns (uint256 _total_count)

  {

    _total_count = total(self.data[_collection_index]);

  }



  function start(IndexedAddress storage self, bytes32 _collection_index)

           public

           constant

           returns (uint256 _index)

  {

    _index = start(self.data[_collection_index]);

  }



  function start_item(IndexedAddress storage self, bytes32 _collection_index)

           public

           constant

           returns (address _start_item)

  {

    _start_item = address(start_item(self.data[_collection_index]));

  }





  function end(IndexedAddress storage self, bytes32 _collection_index)

           public

           constant

           returns (uint256 _index)

  {

    _index = end(self.data[_collection_index]);

  }



  function end_item(IndexedAddress storage self, bytes32 _collection_index)

           public

           constant

           returns (address _end_item)

  {

    _end_item = address(end_item(self.data[_collection_index]));

  }



  function valid(IndexedAddress storage self, bytes32 _collection_index, uint256 _item_index)

           public

           constant

           returns (bool _yes)

  {

    _yes = valid(self.data[_collection_index], _item_index);

  }



  function valid_item(IndexedAddress storage self, bytes32 _collection_index, address _item)

           public

           constant

           returns (bool _yes)

  {

    _yes = valid_item(self.data[_collection_index], bytes32(_item));

  }



  function previous(IndexedAddress storage self, bytes32 _collection_index, uint256 _current_index)

           public

           constant

           returns (uint256 _previous_index)

  {

    _previous_index = previous(self.data[_collection_index], _current_index);

  }



  function previous_item(IndexedAddress storage self, bytes32 _collection_index, address _current_item)

           public

           constant

           returns (address _previous_item)

  {

    _previous_item = address(previous_item(self.data[_collection_index], bytes32(_current_item)));

  }



  function next(IndexedAddress storage self, bytes32 _collection_index, uint256 _current_index)

           public

           constant

           returns (uint256 _next_index)

  {

    _next_index = next(self.data[_collection_index], _current_index);

  }



  function next_item(IndexedAddress storage self, bytes32 _collection_index, address _current_item)

           public

           constant

           returns (address _next_item)

  {

    _next_item = address(next_item(self.data[_collection_index], bytes32(_current_item)));

  }





  function find(Bytes storage self, bytes32 _item)

           public

           constant

           returns (uint256 _item_index)

  {

    _item_index = find(self.data, _item);

  }



  function get(Bytes storage self, uint256 _item_index)

           public

           constant

           returns (bytes32 _item)

  {

    _item = get(self.data, _item_index);

  }





  function append(Bytes storage self, bytes32 _data)

           public

           returns (bool _success)

  {

    _success = append(self.data, _data);

  }



  function remove(Bytes storage self, uint256 _index)

           internal

           returns (bool _success)

  {

    _success = remove(self.data, _index);

  }





  function remove_item(Bytes storage self, bytes32 _item)

           public

           returns (bool _success)

  {

    _success = remove_item(self.data, _item);

  }



  function total(Bytes storage self)

           public

           constant

           returns (uint256 _total_count)

  {

    _total_count = total(self.data);

  }



  function start(Bytes storage self)

           public

           constant

           returns (uint256 _index)

  {

    _index = start(self.data);

  }



  function start_item(Bytes storage self)

           public

           constant

           returns (bytes32 _start_item)

  {

    _start_item = start_item(self.data);

  }





  function end(Bytes storage self)

           public

           constant

           returns (uint256 _index)

  {

    _index = end(self.data);

  }



  function end_item(Bytes storage self)

           public

           constant

           returns (bytes32 _end_item)

  {

    _end_item = end_item(self.data);

  }



  function valid(Bytes storage self, uint256 _item_index)

           public

           constant

           returns (bool _yes)

  {

    _yes = valid(self.data, _item_index);

  }



  function valid_item(Bytes storage self, bytes32 _item)

           public

           constant

           returns (bool _yes)

  {

    _yes = valid_item(self.data, _item);

  }



  function previous(Bytes storage self, uint256 _current_index)

           public

           constant

           returns (uint256 _previous_index)

  {

    _previous_index = previous(self.data, _current_index);

  }



  function previous_item(Bytes storage self, bytes32 _current_item)

           public

           constant

           returns (bytes32 _previous_item)

  {

    _previous_item = previous_item(self.data, _current_item);

  }



  function next(Bytes storage self, uint256 _current_index)

           public

           constant

           returns (uint256 _next_index)

  {

    _next_index = next(self.data, _current_index);

  }



  function next_item(Bytes storage self, bytes32 _current_item)

           public

           constant

           returns (bytes32 _next_item)

  {

    _next_item = next_item(self.data, _current_item);

  }



  function append(IndexedBytes storage self, bytes32 _collection_index, bytes32 _data)

           public

           returns (bool _success)

  {

    _success = append(self.data[_collection_index], bytes32(_data));

  }



  function remove(IndexedBytes storage self, bytes32 _collection_index, uint256 _index)

           internal

           returns (bool _success)

  {

    _success = remove(self.data[_collection_index], _index);

  }





  function remove_item(IndexedBytes storage self, bytes32 _collection_index, bytes32 _item)

           public

           returns (bool _success)

  {

    _success = remove_item(self.data[_collection_index], bytes32(_item));

  }



  function total(IndexedBytes storage self, bytes32 _collection_index)

           public

           constant

           returns (uint256 _total_count)

  {

    _total_count = total(self.data[_collection_index]);

  }



  function start(IndexedBytes storage self, bytes32 _collection_index)

           public

           constant

           returns (uint256 _index)

  {

    _index = start(self.data[_collection_index]);

  }



  function start_item(IndexedBytes storage self, bytes32 _collection_index)

           public

           constant

           returns (bytes32 _start_item)

  {

    _start_item = bytes32(start_item(self.data[_collection_index]));

  }





  function end(IndexedBytes storage self, bytes32 _collection_index)

           public

           constant

           returns (uint256 _index)

  {

    _index = end(self.data[_collection_index]);

  }



  function end_item(IndexedBytes storage self, bytes32 _collection_index)

           public

           constant

           returns (bytes32 _end_item)

  {

    _end_item = bytes32(end_item(self.data[_collection_index]));

  }



  function valid(IndexedBytes storage self, bytes32 _collection_index, uint256 _item_index)

           public

           constant

           returns (bool _yes)

  {

    _yes = valid(self.data[_collection_index], _item_index);

  }



  function valid_item(IndexedBytes storage self, bytes32 _collection_index, bytes32 _item)

           public

           constant

           returns (bool _yes)

  {

    _yes = valid_item(self.data[_collection_index], bytes32(_item));

  }



  function previous(IndexedBytes storage self, bytes32 _collection_index, uint256 _current_index)

           public

           constant

           returns (uint256 _previous_index)

  {

    _previous_index = previous(self.data[_collection_index], _current_index);

  }



  function previous_item(IndexedBytes storage self, bytes32 _collection_index, bytes32 _current_item)

           public

           constant

           returns (bytes32 _previous_item)

  {

    _previous_item = bytes32(previous_item(self.data[_collection_index], bytes32(_current_item)));

  }



  function next(IndexedBytes storage self, bytes32 _collection_index, uint256 _current_index)

           public

           constant

           returns (uint256 _next_index)

  {

    _next_index = next(self.data[_collection_index], _current_index);

  }



  function next_item(IndexedBytes storage self, bytes32 _collection_index, bytes32 _current_item)

           public

           constant

           returns (bytes32 _next_item)

  {

    _next_item = bytes32(next_item(self.data[_collection_index], bytes32(_current_item)));

  }

}



// File: @digix/solidity-collections/contracts/abstract/BytesIteratorStorage.sol

/**

  @title Bytes Iterator Storage

  @author DigixGlobal Pte Ltd

*/

contract BytesIteratorStorage {



  // Initialize Doubly Linked List of Bytes

  using DoublyLinkedList for DoublyLinkedList.Bytes;



  /**

    @notice Reads the first item from the list of Bytes

    @param _list The source list

    @return {"_item": "The first item from the list"}

  */

  function read_first_from_bytesarray(DoublyLinkedList.Bytes storage _list)

           internal

           constant

           returns (bytes32 _item)

  {

    _item = _list.start_item();

  }



  /**

    @notice Reads the last item from the list of Bytes

    @param _list The source list

    @return {"_item": "The last item from the list"}

  */

  function read_last_from_bytesarray(DoublyLinkedList.Bytes storage _list)

           internal

           constant

           returns (bytes32 _item)

  {

    _item = _list.end_item();

  }



  /**

    @notice Reads the next item on the list of Bytes

    @param _list The source list

    @param _current_item The current item to be used as base line

    @return {"_item": "The next item from the list based on the specieid `_current_item`"}

    TODO: Need to verify what happens if the specified `_current_item` is the last item from the list

  */

  function read_next_from_bytesarray(DoublyLinkedList.Bytes storage _list, bytes32 _current_item)

           internal

           constant

           returns (bytes32 _item)

  {

    _item = _list.next_item(_current_item);

  }



  /**

    @notice Reads the previous item on the list of Bytes

    @param _list The source list

    @param _current_item The current item to be used as base line

    @return {"_item": "The previous item from the list based on the spcified `_current_item`"}

    TODO: Need to verify what happens if the specified `_current_item` is the first item from the list

  */

  function read_previous_from_bytesarray(DoublyLinkedList.Bytes storage _list, bytes32 _current_item)

           internal

           constant

           returns (bytes32 _item)

  {

    _item = _list.previous_item(_current_item);

  }



  /**

    @notice Reads the list of Bytes and returns the length of the list

    @param _list The source list

    @return {"count": "`uint256` The lenght of the list"}



  */

  function read_total_bytesarray(DoublyLinkedList.Bytes storage _list)

           internal

           constant

           returns (uint256 _count)

  {

    _count = _list.total();

  }

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    c = _a * _b;

    assert(c / _a == _b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // assert(_b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return _a / _b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);

    return _a - _b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;

    assert(c >= _a);

    return c;

  }

}



// File: contracts/common/DaoConstants.sol

contract DaoConstants {

    using SafeMath for uint256;

    bytes32 EMPTY_BYTES = bytes32(0x0);

    address EMPTY_ADDRESS = address(0x0);





    bytes32 PROPOSAL_STATE_PREPROPOSAL = "proposal_state_preproposal";

    bytes32 PROPOSAL_STATE_DRAFT = "proposal_state_draft";

    bytes32 PROPOSAL_STATE_MODERATED = "proposal_state_moderated";

    bytes32 PROPOSAL_STATE_ONGOING = "proposal_state_ongoing";

    bytes32 PROPOSAL_STATE_CLOSED = "proposal_state_closed";

    bytes32 PROPOSAL_STATE_ARCHIVED = "proposal_state_archived";



    uint256 PRL_ACTION_STOP = 1;

    uint256 PRL_ACTION_PAUSE = 2;

    uint256 PRL_ACTION_UNPAUSE = 3;



    uint256 COLLATERAL_STATUS_UNLOCKED = 1;

    uint256 COLLATERAL_STATUS_LOCKED = 2;

    uint256 COLLATERAL_STATUS_CLAIMED = 3;



    bytes32 INTERMEDIATE_DGD_IDENTIFIER = "inter_dgd_id";

    bytes32 INTERMEDIATE_MODERATOR_DGD_IDENTIFIER = "inter_mod_dgd_id";

    bytes32 INTERMEDIATE_BONUS_CALCULATION_IDENTIFIER = "inter_bonus_calculation_id";



    // interactive contracts

    bytes32 CONTRACT_DAO = "dao";

    bytes32 CONTRACT_DAO_SPECIAL_PROPOSAL = "dao:special:proposal";

    bytes32 CONTRACT_DAO_STAKE_LOCKING = "dao:stake-locking";

    bytes32 CONTRACT_DAO_VOTING = "dao:voting";

    bytes32 CONTRACT_DAO_VOTING_CLAIMS = "dao:voting:claims";

    bytes32 CONTRACT_DAO_SPECIAL_VOTING_CLAIMS = "dao:svoting:claims";

    bytes32 CONTRACT_DAO_IDENTITY = "dao:identity";

    bytes32 CONTRACT_DAO_REWARDS_MANAGER = "dao:rewards-manager";

    bytes32 CONTRACT_DAO_REWARDS_MANAGER_EXTRAS = "dao:rewards-extras";

    bytes32 CONTRACT_DAO_ROLES = "dao:roles";

    bytes32 CONTRACT_DAO_FUNDING_MANAGER = "dao:funding-manager";

    bytes32 CONTRACT_DAO_WHITELISTING = "dao:whitelisting";

    bytes32 CONTRACT_DAO_INFORMATION = "dao:information";



    // service contracts

    bytes32 CONTRACT_SERVICE_ROLE = "service:role";

    bytes32 CONTRACT_SERVICE_DAO_INFO = "service:dao:info";

    bytes32 CONTRACT_SERVICE_DAO_LISTING = "service:dao:listing";

    bytes32 CONTRACT_SERVICE_DAO_CALCULATOR = "service:dao:calculator";



    // storage contracts

    bytes32 CONTRACT_STORAGE_DAO = "storage:dao";

    bytes32 CONTRACT_STORAGE_DAO_COUNTER = "storage:dao:counter";

    bytes32 CONTRACT_STORAGE_DAO_UPGRADE = "storage:dao:upgrade";

    bytes32 CONTRACT_STORAGE_DAO_IDENTITY = "storage:dao:identity";

    bytes32 CONTRACT_STORAGE_DAO_POINTS = "storage:dao:points";

    bytes32 CONTRACT_STORAGE_DAO_SPECIAL = "storage:dao:special";

    bytes32 CONTRACT_STORAGE_DAO_CONFIG = "storage:dao:config";

    bytes32 CONTRACT_STORAGE_DAO_STAKE = "storage:dao:stake";

    bytes32 CONTRACT_STORAGE_DAO_REWARDS = "storage:dao:rewards";

    bytes32 CONTRACT_STORAGE_DAO_WHITELISTING = "storage:dao:whitelisting";

    bytes32 CONTRACT_STORAGE_INTERMEDIATE_RESULTS = "storage:intermediate:results";



    bytes32 CONTRACT_DGD_TOKEN = "t:dgd";

    bytes32 CONTRACT_DGX_TOKEN = "t:dgx";

    bytes32 CONTRACT_BADGE_TOKEN = "t:badge";



    uint8 ROLES_ROOT = 1;

    uint8 ROLES_FOUNDERS = 2;

    uint8 ROLES_PRLS = 3;

    uint8 ROLES_KYC_ADMINS = 4;



    uint256 QUARTER_DURATION = 90 days;



    bytes32 CONFIG_MINIMUM_LOCKED_DGD = "min_dgd_participant";

    bytes32 CONFIG_MINIMUM_DGD_FOR_MODERATOR = "min_dgd_moderator";

    bytes32 CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR = "min_reputation_moderator";



    bytes32 CONFIG_LOCKING_PHASE_DURATION = "locking_phase_duration";

    bytes32 CONFIG_QUARTER_DURATION = "quarter_duration";

    bytes32 CONFIG_VOTING_COMMIT_PHASE = "voting_commit_phase";

    bytes32 CONFIG_VOTING_PHASE_TOTAL = "voting_phase_total";

    bytes32 CONFIG_INTERIM_COMMIT_PHASE = "interim_voting_commit_phase";

    bytes32 CONFIG_INTERIM_PHASE_TOTAL = "interim_voting_phase_total";



    bytes32 CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR = "draft_quorum_fixed_numerator";

    bytes32 CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR = "draft_quorum_fixed_denominator";

    bytes32 CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR = "draft_quorum_sfactor_numerator";

    bytes32 CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR = "draft_quorum_sfactor_denominator";

    bytes32 CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR = "vote_quorum_fixed_numerator";

    bytes32 CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR = "vote_quorum_fixed_denominator";

    bytes32 CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR = "vote_quorum_sfactor_numerator";

    bytes32 CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR = "vote_quorum_sfactor_denominator";

    bytes32 CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR = "final_reward_sfactor_numerator";

    bytes32 CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR = "final_reward_sfactor_denominator";



    bytes32 CONFIG_DRAFT_QUOTA_NUMERATOR = "draft_quota_numerator";

    bytes32 CONFIG_DRAFT_QUOTA_DENOMINATOR = "draft_quota_denominator";

    bytes32 CONFIG_VOTING_QUOTA_NUMERATOR = "voting_quota_numerator";

    bytes32 CONFIG_VOTING_QUOTA_DENOMINATOR = "voting_quota_denominator";



    bytes32 CONFIG_MINIMAL_QUARTER_POINT = "minimal_qp";

    bytes32 CONFIG_QUARTER_POINT_SCALING_FACTOR = "quarter_point_scaling_factor";

    bytes32 CONFIG_REPUTATION_POINT_SCALING_FACTOR = "rep_point_scaling_factor";



    bytes32 CONFIG_MODERATOR_MINIMAL_QUARTER_POINT = "minimal_mod_qp";

    bytes32 CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR = "mod_qp_scaling_factor";

    bytes32 CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR = "mod_rep_point_scaling_factor";



    bytes32 CONFIG_QUARTER_POINT_DRAFT_VOTE = "quarter_point_draft_vote";

    bytes32 CONFIG_QUARTER_POINT_VOTE = "quarter_point_vote";

    bytes32 CONFIG_QUARTER_POINT_INTERIM_VOTE = "quarter_point_interim_vote";



    /// this is per 10000 ETHs

    bytes32 CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH = "q_p_milestone_completion";



    bytes32 CONFIG_BONUS_REPUTATION_NUMERATOR = "bonus_reputation_numerator";

    bytes32 CONFIG_BONUS_REPUTATION_DENOMINATOR = "bonus_reputation_denominator";



    bytes32 CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE = "special_proposal_commit_phase";

    bytes32 CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL = "special_proposal_phase_total";



    bytes32 CONFIG_SPECIAL_QUOTA_NUMERATOR = "config_special_quota_numerator";

    bytes32 CONFIG_SPECIAL_QUOTA_DENOMINATOR = "config_special_quota_denominator";



    bytes32 CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR = "special_quorum_numerator";

    bytes32 CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR = "special_quorum_denominator";



    bytes32 CONFIG_MAXIMUM_REPUTATION_DEDUCTION = "config_max_reputation_deduction";

    bytes32 CONFIG_PUNISHMENT_FOR_NOT_LOCKING = "config_punishment_not_locking";



    bytes32 CONFIG_REPUTATION_PER_EXTRA_QP_NUM = "config_rep_per_extra_qp_num";

    bytes32 CONFIG_REPUTATION_PER_EXTRA_QP_DEN = "config_rep_per_extra_qp_den";



    bytes32 CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION = "config_max_m_rp_deduction";

    bytes32 CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM = "config_rep_per_extra_m_qp_num";

    bytes32 CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN = "config_rep_per_extra_m_qp_den";



    bytes32 CONFIG_PORTION_TO_MODERATORS_NUM = "config_mod_portion_num";

    bytes32 CONFIG_PORTION_TO_MODERATORS_DEN = "config_mod_portion_den";



    bytes32 CONFIG_DRAFT_VOTING_PHASE = "config_draft_voting_phase";



    bytes32 CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE = "config_rp_boost_per_badge";



    bytes32 CONFIG_VOTE_CLAIMING_DEADLINE = "config_claiming_deadline";



    bytes32 CONFIG_PREPROPOSAL_COLLATERAL = "config_preproposal_collateral";



    bytes32 CONFIG_MAX_FUNDING_FOR_NON_DIGIX = "config_max_funding_nonDigix";

    bytes32 CONFIG_MAX_MILESTONES_FOR_NON_DIGIX = "config_max_milestones_nonDigix";

    bytes32 CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER = "config_nonDigix_proposal_cap";



    bytes32 CONFIG_PROPOSAL_DEAD_DURATION = "config_dead_duration";

    bytes32 CONFIG_CARBON_VOTE_REPUTATION_BONUS = "config_cv_reputation";

}



// File: @digix/cacp-contracts-dao/contracts/ACOwned.sol

/// @title Owner based access control

/// @author DigixGlobal

contract ACOwned {



  address public owner;

  address public new_owner;

  bool is_ac_owned_init;



  /// @dev Modifier to check if msg.sender is the contract owner

  modifier if_owner() {

    require(is_owner());

    _;

  }



  function init_ac_owned()

           internal

           returns (bool _success)

  {

    if (is_ac_owned_init == false) {

      owner = msg.sender;

      is_ac_owned_init = true;

    }

    _success = true;

  }



  function is_owner()

           private

           constant

           returns (bool _is_owner)

  {

    _is_owner = (msg.sender == owner);

  }



  function change_owner(address _new_owner)

           if_owner()

           public

           returns (bool _success)

  {

    new_owner = _new_owner;

    _success = true;

  }



  function claim_ownership()

           public

           returns (bool _success)

  {

    require(msg.sender == new_owner);

    owner = new_owner;

    _success = true;

  }

}



// File: @digix/cacp-contracts-dao/contracts/Constants.sol

/// @title Some useful constants

/// @author DigixGlobal

contract Constants {

  address constant NULL_ADDRESS = address(0x0);

  uint256 constant ZERO = uint256(0);

  bytes32 constant EMPTY = bytes32(0x0);

}



// File: @digix/cacp-contracts-dao/contracts/ContractResolver.sol

/// @title Contract Name Registry

/// @author DigixGlobal

contract ContractResolver is ACOwned, Constants {



  mapping (bytes32 => address) contracts;

  bool public locked_forever;



  modifier unless_registered(bytes32 _key) {

    require(contracts[_key] == NULL_ADDRESS);

    _;

  }



  modifier if_owner_origin() {

    require(tx.origin == owner);

    _;

  }



  /// Function modifier to check if msg.sender corresponds to the resolved address of a given key

  /// @param _contract The resolver key

  modifier if_sender_is(bytes32 _contract) {

    require(msg.sender == get_contract(_contract));

    _;

  }



  modifier if_not_locked() {

    require(locked_forever == false);

    _;

  }



  /// @dev ContractResolver constructor will perform the following: 1. Set msg.sender as the contract owner.

  constructor() public

  {

    require(init_ac_owned());

    locked_forever = false;

  }



  /// @dev Called at contract initialization

  /// @param _key bytestring for CACP name

  /// @param _contract_address The address of the contract to be registered

  /// @return _success if the operation is successful

  function init_register_contract(bytes32 _key, address _contract_address)

           if_owner_origin()

           if_not_locked()

           unless_registered(_key)

           public

           returns (bool _success)

  {

    require(_contract_address != NULL_ADDRESS);

    contracts[_key] = _contract_address;

    _success = true;

  }



  /// @dev Lock the resolver from any further modifications.  This can only be called from the owner

  /// @return _success if the operation is successful

  function lock_resolver_forever()

           if_owner

           public

           returns (bool _success)

  {

    locked_forever = true;

    _success = true;

  }



  /// @dev Get address of a contract

  /// @param _key the bytestring name of the contract to look up

  /// @return _contract the address of the contract

  function get_contract(bytes32 _key)

           public

           view

           returns (address _contract)

  {

    require(contracts[_key] != NULL_ADDRESS);

    _contract = contracts[_key];

  }

}



// File: @digix/cacp-contracts-dao/contracts/ResolverClient.sol

/// @title Contract Resolver Interface

/// @author DigixGlobal

contract ResolverClient {



  /// The address of the resolver contract for this project

  address public resolver;

  bytes32 public key;



  /// Make our own address available to us as a constant

  address public CONTRACT_ADDRESS;



  /// Function modifier to check if msg.sender corresponds to the resolved address of a given key

  /// @param _contract The resolver key

  modifier if_sender_is(bytes32 _contract) {

    require(sender_is(_contract));

    _;

  }



  function sender_is(bytes32 _contract) internal view returns (bool _isFrom) {

    _isFrom = msg.sender == ContractResolver(resolver).get_contract(_contract);

  }



  modifier if_sender_is_from(bytes32[3] _contracts) {

    require(sender_is_from(_contracts));

    _;

  }



  function sender_is_from(bytes32[3] _contracts) internal view returns (bool _isFrom) {

    uint256 _n = _contracts.length;

    for (uint256 i = 0; i < _n; i++) {

      if (_contracts[i] == bytes32(0x0)) continue;

      if (msg.sender == ContractResolver(resolver).get_contract(_contracts[i])) {

        _isFrom = true;

        break;

      }

    }

  }



  /// Function modifier to check resolver's locking status.

  modifier unless_resolver_is_locked() {

    require(is_locked() == false);

    _;

  }



  /// @dev Initialize new contract

  /// @param _key the resolver key for this contract

  /// @return _success if the initialization is successful

  function init(bytes32 _key, address _resolver)

           internal

           returns (bool _success)

  {

    bool _is_locked = ContractResolver(_resolver).locked_forever();

    if (_is_locked == false) {

      CONTRACT_ADDRESS = address(this);

      resolver = _resolver;

      key = _key;

      require(ContractResolver(resolver).init_register_contract(key, CONTRACT_ADDRESS));

      _success = true;

    }  else {

      _success = false;

    }

  }



  /// @dev Check if resolver is locked

  /// @return _locked if the resolver is currently locked

  function is_locked()

           private

           view

           returns (bool _locked)

  {

    _locked = ContractResolver(resolver).locked_forever();

  }



  /// @dev Get the address of a contract

  /// @param _key the resolver key to look up

  /// @return _contract the address of the contract

  function get_contract(bytes32 _key)

           public

           view

           returns (address _contract)

  {

    _contract = ContractResolver(resolver).get_contract(_key);

  }

}



// File: contracts/storage/DaoWhitelistingStorage.sol

// This contract is basically created to restrict read access to

// ethereum accounts, and whitelisted contracts

contract DaoWhitelistingStorage is ResolverClient, DaoConstants {



    // we want to avoid the scenario in which an on-chain bribing contract

    // can be deployed to distribute funds in a trustless way by verifying

    // on-chain votes. This mapping marks whether a contract address is whitelisted

    // to read from the read functions in DaoStorage, DaoSpecialStorage, etc.

    mapping (address => bool) public whitelist;



    constructor(address _resolver)

        public

    {

        require(init(CONTRACT_STORAGE_DAO_WHITELISTING, _resolver));

    }



    function setWhitelisted(address _contractAddress, bool _senderIsAllowedToRead)

        public

    {

        require(sender_is(CONTRACT_DAO_WHITELISTING));

        whitelist[_contractAddress] = _senderIsAllowedToRead;

    }

}



// File: contracts/common/DaoWhitelistingCommon.sol

contract DaoWhitelistingCommon is ResolverClient, DaoConstants {



    function daoWhitelistingStorage()

        internal

        view

        returns (DaoWhitelistingStorage _contract)

    {

        _contract = DaoWhitelistingStorage(get_contract(CONTRACT_STORAGE_DAO_WHITELISTING));

    }



    /**

    @notice Check if a certain address is whitelisted to read sensitive information in the storage layer

    @dev if the address is an account, it is allowed to read. If the address is a contract, it has to be in the whitelist

    */

    function senderIsAllowedToRead()

        internal

        view

        returns (bool _senderIsAllowedToRead)

    {

        // msg.sender is allowed to read only if its an EOA or a whitelisted contract

        _senderIsAllowedToRead = (msg.sender == tx.origin) || daoWhitelistingStorage().whitelist(msg.sender);

    }

}



// File: contracts/lib/DaoStructs.sol

library DaoStructs {

    using DoublyLinkedList for DoublyLinkedList.Bytes;

    using SafeMath for uint256;

    bytes32 constant EMPTY_BYTES = bytes32(0x0);



    struct PrlAction {

        // UTC timestamp at which the PRL action was done

        uint256 at;



        // IPFS hash of the document summarizing the action

        bytes32 doc;



        // Type of action

        // check PRL_ACTION_* in "./../common/DaoConstants.sol"

        uint256 actionId;

    }



    struct Voting {

        // UTC timestamp at which the voting round starts

        uint256 startTime;



        // Mapping of whether a commit was used in this voting round

        mapping (bytes32 => bool) usedCommits;



        // Mapping of commits by address. These are the commits during the commit phase in a voting round

        // This only stores the most recent commit in the voting round

        // In case a vote is edited, the previous commit is overwritten by the new commit

        // Only this new commit is verified at the reveal phase

        mapping (address => bytes32) commits;



        // This mapping is updated after the reveal phase, when votes are revealed

        // It is a mapping of address to weight of vote

        // Weight implies the lockedDGDStake of the address, at the time of revealing

        // If the address voted "NO", or didn't vote, this would be 0

        mapping (address => uint256) yesVotes;



        // This mapping is updated after the reveal phase, when votes are revealed

        // It is a mapping of address to weight of vote

        // Weight implies the lockedDGDStake of the address, at the time of revealing

        // If the address voted "YES", or didn't vote, this would be 0

        mapping (address => uint256) noVotes;



        // Boolean whether the voting round passed or not

        bool passed;



        // Boolean whether the voting round results were claimed or not

        // refer the claimProposalVotingResult function in "./../interative/DaoVotingClaims.sol"

        bool claimed;



        // Boolean whether the milestone following this voting round was funded or not

        // The milestone is funded when the proposer calls claimFunding in "./../interactive/DaoFundingManager.sol"

        bool funded;

    }



    struct ProposalVersion {

        // IPFS doc hash of this version of the proposal

        bytes32 docIpfsHash;



        // UTC timestamp at which this version was created

        uint256 created;



        // The number of milestones in the proposal as per this version

        uint256 milestoneCount;



        // The final reward asked by the proposer for completion of the entire proposal

        uint256 finalReward;



        // List of fundings required by the proposal as per this version

        // The numbers are in wei

        uint256[] milestoneFundings;



        // When a proposal is finalized (calling Dao.finalizeProposal), the proposer can no longer add proposal versions

        // However, they can still add more details to this final proposal version, in the form of IPFS docs.

        // These IPFS docs are stored in this array

        bytes32[] moreDocs;

    }



    struct Proposal {

        // ID of the proposal. Also the IPFS hash of the first ProposalVersion

        bytes32 proposalId;



        // current state of the proposal

        // refer PROPOSAL_STATE_* in "./../common/DaoConstants.sol"

        bytes32 currentState;



        // UTC timestamp at which the proposal was created

        uint256 timeCreated;



        // DoublyLinkedList of IPFS doc hashes of the various versions of the proposal

        DoublyLinkedList.Bytes proposalVersionDocs;



        // Mapping of version (IPFS doc hash) to ProposalVersion struct

        mapping (bytes32 => ProposalVersion) proposalVersions;



        // Voting struct for the draft voting round

        Voting draftVoting;



        // Mapping of voting round index (starts from 0) to Voting struct

        // votingRounds[0] is the Voting round of the proposal, which lasts for get_uint_config(CONFIG_VOTING_PHASE_TOTAL)

        // votingRounds[i] for i>0 are the Interim Voting rounds of the proposal, which lasts for get_uint_config(CONFIG_INTERIM_PHASE_TOTAL)

        mapping (uint256 => Voting) votingRounds;



        // Every proposal has a collateral tied to it with a value of

        // get_uint_config(CONFIG_PREPROPOSAL_COLLATERAL) (refer "./../storage/DaoConfigsStorage.sol")

        // Collateral can be in different states

        // refer COLLATERAL_STATUS_* in "./../common/DaoConstants.sol"

        uint256 collateralStatus;

        uint256 collateralAmount;



        // The final version of the proposal

        // Every proposal needs to be finalized before it can be voted on

        // This is the IPFS doc hash of the final version

        bytes32 finalVersion;



        // List of PrlAction structs

        // These are all the actions done by the PRL on the proposal

        PrlAction[] prlActions;



        // Address of the user who created the proposal

        address proposer;



        // Address of the moderator who endorsed the proposal

        address endorser;



        // Boolean whether the proposal is paused/stopped at the moment

        bool isPausedOrStopped;



        // Boolean whether the proposal was created by a founder role

        bool isDigix;

    }



    function countVotes(Voting storage _voting, address[] _allUsers)

        external

        view

        returns (uint256 _for, uint256 _against)

    {

        uint256 _n = _allUsers.length;

        for (uint256 i = 0; i < _n; i++) {

            if (_voting.yesVotes[_allUsers[i]] > 0) {

                _for = _for.add(_voting.yesVotes[_allUsers[i]]);

            } else if (_voting.noVotes[_allUsers[i]] > 0) {

                _against = _against.add(_voting.noVotes[_allUsers[i]]);

            }

        }

    }



    // get the list of voters who voted _vote (true-yes/false-no)

    function listVotes(Voting storage _voting, address[] _allUsers, bool _vote)

        external

        view

        returns (address[] memory _voters, uint256 _length)

    {

        uint256 _n = _allUsers.length;

        uint256 i;

        _length = 0;

        _voters = new address[](_n);

        if (_vote == true) {

            for (i = 0; i < _n; i++) {

                if (_voting.yesVotes[_allUsers[i]] > 0) {

                    _voters[_length] = _allUsers[i];

                    _length++;

                }

            }

        } else {

            for (i = 0; i < _n; i++) {

                if (_voting.noVotes[_allUsers[i]] > 0) {

                    _voters[_length] = _allUsers[i];

                    _length++;

                }

            }

        }

    }



    function readVote(Voting storage _voting, address _voter)

        public

        view

        returns (bool _vote, uint256 _weight)

    {

        if (_voting.yesVotes[_voter] > 0) {

            _weight = _voting.yesVotes[_voter];

            _vote = true;

        } else {

            _weight = _voting.noVotes[_voter]; // if _voter didnt vote at all, the weight will be 0 anyway

            _vote = false;

        }

    }



    function revealVote(

        Voting storage _voting,

        address _voter,

        bool _vote,

        uint256 _weight

    )

        public

    {

        if (_vote) {

            _voting.yesVotes[_voter] = _weight;

        } else {

            _voting.noVotes[_voter] = _weight;

        }

    }



    function readVersion(ProposalVersion storage _version)

        public

        view

        returns (

            bytes32 _doc,

            uint256 _created,

            uint256[] _milestoneFundings,

            uint256 _finalReward

        )

    {

        _doc = _version.docIpfsHash;

        _created = _version.created;

        _milestoneFundings = _version.milestoneFundings;

        _finalReward = _version.finalReward;

    }



    // read the funding for a particular milestone of a finalized proposal

    // if _milestoneId is the same as _milestoneCount, it returns the final reward

    function readProposalMilestone(Proposal storage _proposal, uint256 _milestoneIndex)

        public

        view

        returns (uint256 _funding)

    {

        bytes32 _finalVersion = _proposal.finalVersion;

        uint256 _milestoneCount = _proposal.proposalVersions[_finalVersion].milestoneFundings.length;

        require(_milestoneIndex <= _milestoneCount);

        require(_finalVersion != EMPTY_BYTES); // the proposal must have been finalized



        if (_milestoneIndex < _milestoneCount) {

            _funding = _proposal.proposalVersions[_finalVersion].milestoneFundings[_milestoneIndex];

        } else {

            _funding = _proposal.proposalVersions[_finalVersion].finalReward;

        }

    }



    function addProposalVersion(

        Proposal storage _proposal,

        bytes32 _newDoc,

        uint256[] _newMilestoneFundings,

        uint256 _finalReward

    )

        public

    {

        _proposal.proposalVersionDocs.append(_newDoc);

        _proposal.proposalVersions[_newDoc].docIpfsHash = _newDoc;

        _proposal.proposalVersions[_newDoc].created = now;

        _proposal.proposalVersions[_newDoc].milestoneCount = _newMilestoneFundings.length;

        _proposal.proposalVersions[_newDoc].milestoneFundings = _newMilestoneFundings;

        _proposal.proposalVersions[_newDoc].finalReward = _finalReward;

    }



    struct SpecialProposal {

        // ID of the special proposal

        // This is the IPFS doc hash of the proposal

        bytes32 proposalId;



        // UTC timestamp at which the proposal was created

        uint256 timeCreated;



        // Voting struct for the special proposal

        Voting voting;



        // List of the new uint256 configs as per the special proposal

        uint256[] uintConfigs;



        // List of the new address configs as per the special proposal

        address[] addressConfigs;



        // List of the new bytes32 configs as per the special proposal

        bytes32[] bytesConfigs;



        // Address of the user who created the special proposal

        // This address should also be in the ROLES_FOUNDERS group

        // refer "./../storage/DaoIdentityStorage.sol"

        address proposer;

    }



    // All configs are as per the DaoConfigsStorage values at the time when

    // calculateGlobalRewardsBeforeNewQuarter is called by founder in that quarter

    struct DaoQuarterInfo {

        // The minimum quarter points required

        // below this, reputation will be deducted

        uint256 minimalParticipationPoint;



        // The scaling factor for quarter point

        uint256 quarterPointScalingFactor;



        // The scaling factor for reputation point

        uint256 reputationPointScalingFactor;



        // The summation of effectiveDGDs in the previous quarter

        // The effectiveDGDs represents the effective participation in DigixDAO in a quarter

        // Which depends on lockedDGDStake, quarter point and reputation point

        // This value is the summation of all participant effectiveDGDs

        // It will be used to calculate the fraction of effectiveDGD a user has,

        // which will determine his portion of DGX rewards for that quarter

        uint256 totalEffectiveDGDPreviousQuarter;



        // The minimum moderator quarter point required

        // below this, reputation will be deducted for moderators

        uint256 moderatorMinimalParticipationPoint;



        // the scaling factor for moderator quarter point

        uint256 moderatorQuarterPointScalingFactor;



        // the scaling factor for moderator reputation point

        uint256 moderatorReputationPointScalingFactor;



        // The summation of effectiveDGDs (only specific to moderators)

        uint256 totalEffectiveModeratorDGDLastQuarter;



        // UTC timestamp from which the DGX rewards for the previous quarter are distributable to Holders

        uint256 dgxDistributionDay;



        // This is the rewards pool for the previous quarter. This is the sum of the DGX fees coming in from the collector, and the demurrage that has incurred

        // when user call claimRewards() in the previous quarter.

        // more graphical explanation: https://ipfs.io/ipfs/QmZDgFFMbyF3dvuuDfoXv5F6orq4kaDPo7m3QvnseUguzo

        uint256 dgxRewardsPoolLastQuarter;



        // The summation of all dgxRewardsPoolLastQuarter up until this quarter

        uint256 sumRewardsFromBeginning;

    }



    // There are many function calls where all calculations/summations cannot be done in one transaction

    // and require multiple transactions.

    // This struct stores the intermediate results in between the calculating transactions

    // These intermediate results are stored in IntermediateResultsStorage

    struct IntermediateResults {

        // weight of "FOR" votes counted up until the current calculation step

        uint256 currentForCount;



        // weight of "AGAINST" votes counted up until the current calculation step

        uint256 currentAgainstCount;



        // summation of effectiveDGDs up until the iteration of calculation

        uint256 currentSumOfEffectiveBalance;



        // Address of user until which the calculation has been done

        address countedUntil;

    }

}



// File: contracts/storage/DaoStorage.sol

contract DaoStorage is DaoWhitelistingCommon, BytesIteratorStorage {

    using DoublyLinkedList for DoublyLinkedList.Bytes;

    using DaoStructs for DaoStructs.Voting;

    using DaoStructs for DaoStructs.Proposal;

    using DaoStructs for DaoStructs.ProposalVersion;



    // List of all the proposals ever created in DigixDAO

    DoublyLinkedList.Bytes allProposals;



    // mapping of Proposal struct by its ID

    // ID is also the IPFS doc hash of the first ever version of this proposal

    mapping (bytes32 => DaoStructs.Proposal) proposalsById;



    // mapping from state of a proposal to list of all proposals in that state

    // proposals are added/removed from the state's list as their states change

    // eg. when proposal is endorsed, when proposal is funded, etc

    mapping (bytes32 => DoublyLinkedList.Bytes) proposalsByState;



    constructor(address _resolver) public {

        require(init(CONTRACT_STORAGE_DAO, _resolver));

    }



    /////////////////////////////// READ FUNCTIONS //////////////////////////////



    /// @notice read all information and details of proposal

    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc Proposal ID, i.e. hash of IPFS doc

    /// return {

    ///   "_doc": "Original IPFS doc of proposal, also ID of proposal",

    ///   "_proposer": "Address of the proposer",

    ///   "_endorser": "Address of the moderator that endorsed the proposal",

    ///   "_state": "Current state of the proposal",

    ///   "_timeCreated": "UTC timestamp at which proposal was created",

    ///   "_nVersions": "Number of versions of the proposal",

    ///   "_latestVersionDoc": "IPFS doc hash of the latest version of this proposal",

    ///   "_finalVersion": "If finalized, the version of the final proposal",

    ///   "_pausedOrStopped": "If the proposal is paused/stopped at the moment",

    ///   "_isDigixProposal": "If the proposal has been created by founder or not"

    /// }

    function readProposal(bytes32 _proposalId)

        public

        view

        returns (

            bytes32 _doc,

            address _proposer,

            address _endorser,

            bytes32 _state,

            uint256 _timeCreated,

            uint256 _nVersions,

            bytes32 _latestVersionDoc,

            bytes32 _finalVersion,

            bool _pausedOrStopped,

            bool _isDigixProposal

        )

    {

        require(senderIsAllowedToRead());

        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];

        _doc = _proposal.proposalId;

        _proposer = _proposal.proposer;

        _endorser = _proposal.endorser;

        _state = _proposal.currentState;

        _timeCreated = _proposal.timeCreated;

        _nVersions = read_total_bytesarray(_proposal.proposalVersionDocs);

        _latestVersionDoc = read_last_from_bytesarray(_proposal.proposalVersionDocs);

        _finalVersion = _proposal.finalVersion;

        _pausedOrStopped = _proposal.isPausedOrStopped;

        _isDigixProposal = _proposal.isDigix;

    }



    function readProposalProposer(bytes32 _proposalId)

        public

        view

        returns (address _proposer)

    {

        _proposer = proposalsById[_proposalId].proposer;

    }



    function readTotalPrlActions(bytes32 _proposalId)

        public

        view

        returns (uint256 _length)

    {

        _length = proposalsById[_proposalId].prlActions.length;

    }



    function readPrlAction(bytes32 _proposalId, uint256 _index)

        public

        view

        returns (uint256 _actionId, uint256 _time, bytes32 _doc)

    {

        DaoStructs.PrlAction[] memory _actions = proposalsById[_proposalId].prlActions;

        require(_index < _actions.length);

        _actionId = _actions[_index].actionId;

        _time = _actions[_index].at;

        _doc = _actions[_index].doc;

    }



    function readProposalDraftVotingResult(bytes32 _proposalId)

        public

        view

        returns (bool _result)

    {

        require(senderIsAllowedToRead());

        _result = proposalsById[_proposalId].draftVoting.passed;

    }



    function readProposalVotingResult(bytes32 _proposalId, uint256 _index)

        public

        view

        returns (bool _result)

    {

        require(senderIsAllowedToRead());

        _result = proposalsById[_proposalId].votingRounds[_index].passed;

    }



    function readProposalDraftVotingTime(bytes32 _proposalId)

        public

        view

        returns (uint256 _start)

    {

        require(senderIsAllowedToRead());

        _start = proposalsById[_proposalId].draftVoting.startTime;

    }



    function readProposalVotingTime(bytes32 _proposalId, uint256 _index)

        public

        view

        returns (uint256 _start)

    {

        require(senderIsAllowedToRead());

        _start = proposalsById[_proposalId].votingRounds[_index].startTime;

    }



    function readDraftVotingCount(bytes32 _proposalId, address[] _allUsers)

        external

        view

        returns (uint256 _for, uint256 _against)

    {

        require(senderIsAllowedToRead());

        return proposalsById[_proposalId].draftVoting.countVotes(_allUsers);

    }



    function readVotingCount(bytes32 _proposalId, uint256 _index, address[] _allUsers)

        external

        view

        returns (uint256 _for, uint256 _against)

    {

        require(senderIsAllowedToRead());

        return proposalsById[_proposalId].votingRounds[_index].countVotes(_allUsers);

    }



    function readVotingRoundVotes(bytes32 _proposalId, uint256 _index, address[] _allUsers, bool _vote)

        external

        view

        returns (address[] memory _voters, uint256 _length)

    {

        require(senderIsAllowedToRead());

        return proposalsById[_proposalId].votingRounds[_index].listVotes(_allUsers, _vote);

    }



    function readDraftVote(bytes32 _proposalId, address _voter)

        public

        view

        returns (bool _vote, uint256 _weight)

    {

        require(senderIsAllowedToRead());

        return proposalsById[_proposalId].draftVoting.readVote(_voter);

    }



    /// @notice returns the latest committed vote by a voter on a proposal

    /// @param _proposalId proposal ID

    /// @param _voter address of the voter

    /// @return {

    ///   "_commitHash": ""

    /// }

    function readComittedVote(bytes32 _proposalId, uint256 _index, address _voter)

        public

        view

        returns (bytes32 _commitHash)

    {

        require(senderIsAllowedToRead());

        _commitHash = proposalsById[_proposalId].votingRounds[_index].commits[_voter];

    }



    function readVote(bytes32 _proposalId, uint256 _index, address _voter)

        public

        view

        returns (bool _vote, uint256 _weight)

    {

        require(senderIsAllowedToRead());

        return proposalsById[_proposalId].votingRounds[_index].readVote(_voter);

    }



    /// @notice get all information and details of the first proposal

    /// return {

    ///   "_id": ""

    /// }

    function getFirstProposal()

        public

        view

        returns (bytes32 _id)

    {

        _id = read_first_from_bytesarray(allProposals);

    }



    /// @notice get all information and details of the last proposal

    /// return {

    ///   "_id": ""

    /// }

    function getLastProposal()

        public

        view

        returns (bytes32 _id)

    {

        _id = read_last_from_bytesarray(allProposals);

    }



    /// @notice get all information and details of proposal next to _proposalId

    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc

    /// return {

    ///   "_id": ""

    /// }

    function getNextProposal(bytes32 _proposalId)

        public

        view

        returns (bytes32 _id)

    {

        _id = read_next_from_bytesarray(

            allProposals,

            _proposalId

        );

    }



    /// @notice get all information and details of proposal previous to _proposalId

    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc

    /// return {

    ///   "_id": ""

    /// }

    function getPreviousProposal(bytes32 _proposalId)

        public

        view

        returns (bytes32 _id)

    {

        _id = read_previous_from_bytesarray(

            allProposals,

            _proposalId

        );

    }



    /// @notice get all information and details of the first proposal in state _stateId

    /// @param _stateId State ID of the proposal

    /// return {

    ///   "_id": ""

    /// }

    function getFirstProposalInState(bytes32 _stateId)

        public

        view

        returns (bytes32 _id)

    {

        require(senderIsAllowedToRead());

        _id = read_first_from_bytesarray(proposalsByState[_stateId]);

    }



    /// @notice get all information and details of the last proposal in state _stateId

    /// @param _stateId State ID of the proposal

    /// return {

    ///   "_id": ""

    /// }

    function getLastProposalInState(bytes32 _stateId)

        public

        view

        returns (bytes32 _id)

    {

        require(senderIsAllowedToRead());

        _id = read_last_from_bytesarray(proposalsByState[_stateId]);

    }



    /// @notice get all information and details of the next proposal to _proposalId in state _stateId

    /// @param _stateId State ID of the proposal

    /// return {

    ///   "_id": ""

    /// }

    function getNextProposalInState(bytes32 _stateId, bytes32 _proposalId)

        public

        view

        returns (bytes32 _id)

    {

        require(senderIsAllowedToRead());

        _id = read_next_from_bytesarray(

            proposalsByState[_stateId],

            _proposalId

        );

    }



    /// @notice get all information and details of the previous proposal to _proposalId in state _stateId

    /// @param _stateId State ID of the proposal

    /// return {

    ///   "_id": ""

    /// }

    function getPreviousProposalInState(bytes32 _stateId, bytes32 _proposalId)

        public

        view

        returns (bytes32 _id)

    {

        require(senderIsAllowedToRead());

        _id = read_previous_from_bytesarray(

            proposalsByState[_stateId],

            _proposalId

        );

    }



    /// @notice read proposal version details for a specific version

    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc

    /// @param _version Version of proposal, i.e. hash of IPFS doc for specific version

    /// return {

    ///   "_doc": "",

    ///   "_created": "",

    ///   "_milestoneFundings": ""

    /// }

    function readProposalVersion(bytes32 _proposalId, bytes32 _version)

        public

        view

        returns (

            bytes32 _doc,

            uint256 _created,

            uint256[] _milestoneFundings,

            uint256 _finalReward

        )

    {

        return proposalsById[_proposalId].proposalVersions[_version].readVersion();

    }



    /**

    @notice Read the fundings of a finalized proposal

    @return {

        "_fundings": "fundings for the milestones",

        "_finalReward": "the final reward"

    }

    */

    function readProposalFunding(bytes32 _proposalId)

        public

        view

        returns (uint256[] memory _fundings, uint256 _finalReward)

    {

        require(senderIsAllowedToRead());

        bytes32 _finalVersion = proposalsById[_proposalId].finalVersion;

        require(_finalVersion != EMPTY_BYTES);

        _fundings = proposalsById[_proposalId].proposalVersions[_finalVersion].milestoneFundings;

        _finalReward = proposalsById[_proposalId].proposalVersions[_finalVersion].finalReward;

    }



    function readProposalMilestone(bytes32 _proposalId, uint256 _index)

        public

        view

        returns (uint256 _funding)

    {

        require(senderIsAllowedToRead());

        _funding = proposalsById[_proposalId].readProposalMilestone(_index);

    }



    /// @notice get proposal version details for the first version

    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc

    /// return {

    ///   "_version": ""

    /// }

    function getFirstProposalVersion(bytes32 _proposalId)

        public

        view

        returns (bytes32 _version)

    {

        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];

        _version = read_first_from_bytesarray(_proposal.proposalVersionDocs);

    }



    /// @notice get proposal version details for the last version

    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc

    /// return {

    ///   "_version": ""

    /// }

    function getLastProposalVersion(bytes32 _proposalId)

        public

        view

        returns (bytes32 _version)

    {

        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];

        _version = read_last_from_bytesarray(_proposal.proposalVersionDocs);

    }



    /// @notice get proposal version details for the next version to _version

    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc

    /// @param _version Version of proposal

    /// return {

    ///   "_nextVersion": ""

    /// }

    function getNextProposalVersion(bytes32 _proposalId, bytes32 _version)

        public

        view

        returns (bytes32 _nextVersion)

    {

        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];

        _nextVersion = read_next_from_bytesarray(

            _proposal.proposalVersionDocs,

            _version

        );

    }



    /// @notice get proposal version details for the previous version to _version

    /// @param _proposalId Proposal ID, i.e. hash of IPFS doc

    /// @param _version Version of proposal

    /// return {

    ///   "_previousVersion": ""

    /// }

    function getPreviousProposalVersion(bytes32 _proposalId, bytes32 _version)

        public

        view

        returns (bytes32 _previousVersion)

    {

        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];

        _previousVersion = read_previous_from_bytesarray(

            _proposal.proposalVersionDocs,

            _version

        );

    }



    function isDraftClaimed(bytes32 _proposalId)

        public

        view

        returns (bool _claimed)

    {

        _claimed = proposalsById[_proposalId].draftVoting.claimed;

    }



    function isClaimed(bytes32 _proposalId, uint256 _index)

        public

        view

        returns (bool _claimed)

    {

        _claimed = proposalsById[_proposalId].votingRounds[_index].claimed;

    }



    function readProposalCollateralStatus(bytes32 _proposalId)

        public

        view

        returns (uint256 _status)

    {

        require(senderIsAllowedToRead());

        _status = proposalsById[_proposalId].collateralStatus;

    }



    function readProposalCollateralAmount(bytes32 _proposalId)

        public

        view

        returns (uint256 _amount)

    {

        _amount = proposalsById[_proposalId].collateralAmount;

    }



    /// @notice Read the additional docs that are added after the proposal is finalized

    /// @dev Will throw if the propsal is not finalized yet

    function readProposalDocs(bytes32 _proposalId)

        public

        view

        returns (bytes32[] _moreDocs)

    {

        bytes32 _finalVersion = proposalsById[_proposalId].finalVersion;

        require(_finalVersion != EMPTY_BYTES);

        _moreDocs = proposalsById[_proposalId].proposalVersions[_finalVersion].moreDocs;

    }



    function readIfMilestoneFunded(bytes32 _proposalId, uint256 _milestoneId)

        public

        view

        returns (bool _funded)

    {

        require(senderIsAllowedToRead());

        _funded = proposalsById[_proposalId].votingRounds[_milestoneId].funded;

    }



    ////////////////////////////// WRITE FUNCTIONS //////////////////////////////



    function addProposal(

        bytes32 _doc,

        address _proposer,

        uint256[] _milestoneFundings,

        uint256 _finalReward,

        bool _isFounder

    )

        external

    {

        require(sender_is(CONTRACT_DAO));

        require(

          (proposalsById[_doc].proposalId == EMPTY_BYTES) &&

          (_doc != EMPTY_BYTES)

        );



        allProposals.append(_doc);

        proposalsByState[PROPOSAL_STATE_PREPROPOSAL].append(_doc);

        proposalsById[_doc].proposalId = _doc;

        proposalsById[_doc].proposer = _proposer;

        proposalsById[_doc].currentState = PROPOSAL_STATE_PREPROPOSAL;

        proposalsById[_doc].timeCreated = now;

        proposalsById[_doc].isDigix = _isFounder;

        proposalsById[_doc].addProposalVersion(_doc, _milestoneFundings, _finalReward);

    }



    function editProposal(

        bytes32 _proposalId,

        bytes32 _newDoc,

        uint256[] _newMilestoneFundings,

        uint256 _finalReward

    )

        external

    {

        require(sender_is(CONTRACT_DAO));



        proposalsById[_proposalId].addProposalVersion(_newDoc, _newMilestoneFundings, _finalReward);

    }



    /// @notice change fundings of a proposal

    /// @dev Will throw if the proposal is not finalized yet

    function changeFundings(bytes32 _proposalId, uint256[] _newMilestoneFundings, uint256 _finalReward)

        external

    {

        require(sender_is(CONTRACT_DAO));



        bytes32 _finalVersion = proposalsById[_proposalId].finalVersion;

        require(_finalVersion != EMPTY_BYTES);

        proposalsById[_proposalId].proposalVersions[_finalVersion].milestoneFundings = _newMilestoneFundings;

        proposalsById[_proposalId].proposalVersions[_finalVersion].finalReward = _finalReward;

    }



    /// @dev Will throw if the proposal is not finalized yet

    function addProposalDoc(bytes32 _proposalId, bytes32 _newDoc)

        public

    {

        require(sender_is(CONTRACT_DAO));



        bytes32 _finalVersion = proposalsById[_proposalId].finalVersion;

        require(_finalVersion != EMPTY_BYTES); //already checked in interactive layer, but why not

        proposalsById[_proposalId].proposalVersions[_finalVersion].moreDocs.push(_newDoc);

    }



    function finalizeProposal(bytes32 _proposalId)

        public

    {

        require(sender_is(CONTRACT_DAO));



        proposalsById[_proposalId].finalVersion = getLastProposalVersion(_proposalId);

    }



    function updateProposalEndorse(

        bytes32 _proposalId,

        address _endorser

    )

        public

    {

        require(sender_is(CONTRACT_DAO));



        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];

        _proposal.endorser = _endorser;

        _proposal.currentState = PROPOSAL_STATE_DRAFT;

        proposalsByState[PROPOSAL_STATE_PREPROPOSAL].remove_item(_proposalId);

        proposalsByState[PROPOSAL_STATE_DRAFT].append(_proposalId);

    }



    function setProposalDraftPass(bytes32 _proposalId, bool _result)

        public

    {

        require(sender_is(CONTRACT_DAO_VOTING_CLAIMS));



        proposalsById[_proposalId].draftVoting.passed = _result;

        if (_result) {

            proposalsByState[PROPOSAL_STATE_DRAFT].remove_item(_proposalId);

            proposalsByState[PROPOSAL_STATE_MODERATED].append(_proposalId);

            proposalsById[_proposalId].currentState = PROPOSAL_STATE_MODERATED;

        } else {

            closeProposalInternal(_proposalId);

        }

    }



    function setProposalPass(bytes32 _proposalId, uint256 _index, bool _result)

        public

    {

        require(sender_is(CONTRACT_DAO_VOTING_CLAIMS));



        if (!_result) {

            closeProposalInternal(_proposalId);

        } else if (_index == 0) {

            proposalsByState[PROPOSAL_STATE_MODERATED].remove_item(_proposalId);

            proposalsByState[PROPOSAL_STATE_ONGOING].append(_proposalId);

            proposalsById[_proposalId].currentState = PROPOSAL_STATE_ONGOING;

        }

        proposalsById[_proposalId].votingRounds[_index].passed = _result;

    }



    function setProposalDraftVotingTime(

        bytes32 _proposalId,

        uint256 _time

    )

        public

    {

        require(sender_is(CONTRACT_DAO));



        proposalsById[_proposalId].draftVoting.startTime = _time;

    }



    function setProposalVotingTime(

        bytes32 _proposalId,

        uint256 _index,

        uint256 _time

    )

        public

    {

        require(sender_is_from([CONTRACT_DAO, CONTRACT_DAO_VOTING_CLAIMS, EMPTY_BYTES]));



        proposalsById[_proposalId].votingRounds[_index].startTime = _time;

    }



    function setDraftVotingClaim(bytes32 _proposalId, bool _claimed)

        public

    {

        require(sender_is(CONTRACT_DAO_VOTING_CLAIMS));

        proposalsById[_proposalId].draftVoting.claimed = _claimed;

    }



    function setVotingClaim(bytes32 _proposalId, uint256 _index, bool _claimed)

        public

    {

        require(sender_is(CONTRACT_DAO_VOTING_CLAIMS));

        proposalsById[_proposalId].votingRounds[_index].claimed = _claimed;

    }



    function setProposalCollateralStatus(bytes32 _proposalId, uint256 _status)

        public

    {

        require(sender_is_from([CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_FUNDING_MANAGER, CONTRACT_DAO]));

        proposalsById[_proposalId].collateralStatus = _status;

    }



    function setProposalCollateralAmount(bytes32 _proposalId, uint256 _amount)

        public

    {

        require(sender_is(CONTRACT_DAO));

        proposalsById[_proposalId].collateralAmount = _amount;

    }



    function updateProposalPRL(

        bytes32 _proposalId,

        uint256 _action,

        bytes32 _doc,

        uint256 _time

    )

        public

    {

        require(sender_is(CONTRACT_DAO));

        require(proposalsById[_proposalId].currentState != PROPOSAL_STATE_CLOSED);



        DaoStructs.PrlAction memory prlAction;

        prlAction.at = _time;

        prlAction.doc = _doc;

        prlAction.actionId = _action;

        proposalsById[_proposalId].prlActions.push(prlAction);



        if (_action == PRL_ACTION_PAUSE) {

          proposalsById[_proposalId].isPausedOrStopped = true;

        } else if (_action == PRL_ACTION_UNPAUSE) {

          proposalsById[_proposalId].isPausedOrStopped = false;

        } else { // STOP

          proposalsById[_proposalId].isPausedOrStopped = true;

          closeProposalInternal(_proposalId);

        }

    }



    function closeProposalInternal(bytes32 _proposalId)

        internal

    {

        bytes32 _currentState = proposalsById[_proposalId].currentState;

        proposalsByState[_currentState].remove_item(_proposalId);

        proposalsByState[PROPOSAL_STATE_CLOSED].append(_proposalId);

        proposalsById[_proposalId].currentState = PROPOSAL_STATE_CLOSED;

    }



    function addDraftVote(

        bytes32 _proposalId,

        address _voter,

        bool _vote,

        uint256 _weight

    )

        public

    {

        require(sender_is(CONTRACT_DAO_VOTING));



        DaoStructs.Proposal storage _proposal = proposalsById[_proposalId];

        if (_vote) {

            _proposal.draftVoting.yesVotes[_voter] = _weight;

            if (_proposal.draftVoting.noVotes[_voter] > 0) { // minimize number of writes to storage, since EIP-1087 is not implemented yet

                _proposal.draftVoting.noVotes[_voter] = 0;

            }

        } else {

            _proposal.draftVoting.noVotes[_voter] = _weight;

            if (_proposal.draftVoting.yesVotes[_voter] > 0) {

                _proposal.draftVoting.yesVotes[_voter] = 0;

            }

        }

    }



    function commitVote(

        bytes32 _proposalId,

        bytes32 _hash,

        address _voter,

        uint256 _index

    )

        public

    {

        require(sender_is(CONTRACT_DAO_VOTING));



        proposalsById[_proposalId].votingRounds[_index].commits[_voter] = _hash;

    }



    function revealVote(

        bytes32 _proposalId,

        address _voter,

        bool _vote,

        uint256 _weight,

        uint256 _index

    )

        public

    {

        require(sender_is(CONTRACT_DAO_VOTING));



        proposalsById[_proposalId].votingRounds[_index].revealVote(_voter, _vote, _weight);

    }



    function closeProposal(bytes32 _proposalId)

        public

    {

        require(sender_is(CONTRACT_DAO));

        closeProposalInternal(_proposalId);

    }



    function archiveProposal(bytes32 _proposalId)

        public

    {

        require(sender_is(CONTRACT_DAO_VOTING_CLAIMS));

        bytes32 _currentState = proposalsById[_proposalId].currentState;

        proposalsByState[_currentState].remove_item(_proposalId);

        proposalsByState[PROPOSAL_STATE_ARCHIVED].append(_proposalId);

        proposalsById[_proposalId].currentState = PROPOSAL_STATE_ARCHIVED;

    }



    function setMilestoneFunded(bytes32 _proposalId, uint256 _milestoneId)

        public

    {

        require(sender_is(CONTRACT_DAO_FUNDING_MANAGER));

        proposalsById[_proposalId].votingRounds[_milestoneId].funded = true;

    }

}



// File: @digix/solidity-collections/contracts/abstract/AddressIteratorStorage.sol

/**

  @title Address Iterator Storage

  @author DigixGlobal Pte Ltd

  @notice See: [Doubly Linked List](/DoublyLinkedList)

*/

contract AddressIteratorStorage {



  // Initialize Doubly Linked List of Address

  using DoublyLinkedList for DoublyLinkedList.Address;



  /**

    @notice Reads the first item from the list of Address

    @param _list The source list

    @return {"_item" : "The first item from the list"}

  */

  function read_first_from_addresses(DoublyLinkedList.Address storage _list)

           internal

           constant

           returns (address _item)

  {

    _item = _list.start_item();

  }





  /**

    @notice Reads the last item from the list of Address

    @param _list The source list

    @return {"_item" : "The last item from the list"}

  */

  function read_last_from_addresses(DoublyLinkedList.Address storage _list)

           internal

           constant

           returns (address _item)

  {

    _item = _list.end_item();

  }



  /**

    @notice Reads the next item on the list of Address

    @param _list The source list

    @param _current_item The current item to be used as base line

    @return {"_item" : "The next item from the list based on the specieid `_current_item`"}

  */

  function read_next_from_addresses(DoublyLinkedList.Address storage _list, address _current_item)

           internal

           constant

           returns (address _item)

  {

    _item = _list.next_item(_current_item);

  }



  /**

    @notice Reads the previous item on the list of Address

    @param _list The source list

    @param _current_item The current item to be used as base line

    @return {"_item" : "The previous item from the list based on the spcified `_current_item`"}

  */

  function read_previous_from_addresses(DoublyLinkedList.Address storage _list, address _current_item)

           internal

           constant

           returns (address _item)

  {

    _item = _list.previous_item(_current_item);

  }



  /**

    @notice Reads the list of Address and returns the length of the list

    @param _list The source list

    @return {"_count": "The lenght of the list"}

  */

  function read_total_addresses(DoublyLinkedList.Address storage _list)

           internal

           constant

           returns (uint256 _count)

  {

    _count = _list.total();

  }

}



// File: contracts/storage/DaoStakeStorage.sol

contract DaoStakeStorage is ResolverClient, DaoConstants, AddressIteratorStorage {

    using DoublyLinkedList for DoublyLinkedList.Address;



    // This is the DGD stake of a user (one that is considered in the DAO)

    mapping (address => uint256) public lockedDGDStake;



    // This is the actual number of DGDs locked by user

    // may be more than the lockedDGDStake

    // in case they locked during the main phase

    mapping (address => uint256) public actualLockedDGD;



    // The total locked DGDs in the DAO (summation of lockedDGDStake)

    uint256 public totalLockedDGDStake;



    // The total locked DGDs by moderators

    uint256 public totalModeratorLockedDGDStake;



    // The list of participants in DAO

    // actual participants will be subset of this list

    DoublyLinkedList.Address allParticipants;



    // The list of moderators in DAO

    // actual moderators will be subset of this list

    DoublyLinkedList.Address allModerators;



    // Boolean to mark if an address has redeemed

    // reputation points for their DGD Badge

    mapping (address => bool) public redeemedBadge;



    // mapping to note whether an address has claimed their

    // reputation bonus for carbon vote participation

    mapping (address => bool) public carbonVoteBonusClaimed;



    constructor(address _resolver) public {

        require(init(CONTRACT_STORAGE_DAO_STAKE, _resolver));

    }



    function redeemBadge(address _user)

        public

    {

        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));

        redeemedBadge[_user] = true;

    }



    function setCarbonVoteBonusClaimed(address _user)

        public

    {

        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));

        carbonVoteBonusClaimed[_user] = true;

    }



    function updateTotalLockedDGDStake(uint256 _totalLockedDGDStake)

        public

    {

        require(sender_is_from([CONTRACT_DAO_STAKE_LOCKING, CONTRACT_DAO_REWARDS_MANAGER, EMPTY_BYTES]));

        totalLockedDGDStake = _totalLockedDGDStake;

    }



    function updateTotalModeratorLockedDGDs(uint256 _totalLockedDGDStake)

        public

    {

        require(sender_is_from([CONTRACT_DAO_STAKE_LOCKING, CONTRACT_DAO_REWARDS_MANAGER, EMPTY_BYTES]));

        totalModeratorLockedDGDStake = _totalLockedDGDStake;

    }



    function updateUserDGDStake(address _user, uint256 _actualLockedDGD, uint256 _lockedDGDStake)

        public

    {

        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));

        actualLockedDGD[_user] = _actualLockedDGD;

        lockedDGDStake[_user] = _lockedDGDStake;

    }



    function readUserDGDStake(address _user)

        public

        view

        returns (

            uint256 _actualLockedDGD,

            uint256 _lockedDGDStake

        )

    {

        _actualLockedDGD = actualLockedDGD[_user];

        _lockedDGDStake = lockedDGDStake[_user];

    }



    function addToParticipantList(address _user)

        public

        returns (bool _success)

    {

        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));

        _success = allParticipants.append(_user);

    }



    function removeFromParticipantList(address _user)

        public

        returns (bool _success)

    {

        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));

        _success = allParticipants.remove_item(_user);

    }



    function addToModeratorList(address _user)

        public

        returns (bool _success)

    {

        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));

        _success = allModerators.append(_user);

    }



    function removeFromModeratorList(address _user)

        public

        returns (bool _success)

    {

        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));

        _success = allModerators.remove_item(_user);

    }



    function isInParticipantList(address _user)

        public

        view

        returns (bool _is)

    {

        _is = allParticipants.find(_user) != 0;

    }



    function isInModeratorsList(address _user)

        public

        view

        returns (bool _is)

    {

        _is = allModerators.find(_user) != 0;

    }



    function readFirstModerator()

        public

        view

        returns (address _item)

    {

        _item = read_first_from_addresses(allModerators);

    }



    function readLastModerator()

        public

        view

        returns (address _item)

    {

        _item = read_last_from_addresses(allModerators);

    }



    function readNextModerator(address _current_item)

        public

        view

        returns (address _item)

    {

        _item = read_next_from_addresses(allModerators, _current_item);

    }



    function readPreviousModerator(address _current_item)

        public

        view

        returns (address _item)

    {

        _item = read_previous_from_addresses(allModerators, _current_item);

    }



    function readTotalModerators()

        public

        view

        returns (uint256 _total_count)

    {

        _total_count = read_total_addresses(allModerators);

    }



    function readFirstParticipant()

        public

        view

        returns (address _item)

    {

        _item = read_first_from_addresses(allParticipants);

    }



    function readLastParticipant()

        public

        view

        returns (address _item)

    {

        _item = read_last_from_addresses(allParticipants);

    }



    function readNextParticipant(address _current_item)

        public

        view

        returns (address _item)

    {

        _item = read_next_from_addresses(allParticipants, _current_item);

    }



    function readPreviousParticipant(address _current_item)

        public

        view

        returns (address _item)

    {

        _item = read_previous_from_addresses(allParticipants, _current_item);

    }



    function readTotalParticipant()

        public

        view

        returns (uint256 _total_count)

    {

        _total_count = read_total_addresses(allParticipants);

    }

}



// File: contracts/service/DaoListingService.sol

/**

@title Contract to list various storage states from DigixDAO

@author Digix Holdings

*/

contract DaoListingService is

    AddressIteratorInteractive,

    BytesIteratorInteractive,

    IndexedBytesIteratorInteractive,

    DaoWhitelistingCommon

{



    /**

    @notice Constructor

    @param _resolver address of contract resolver

    */

    constructor(address _resolver) public {

        require(init(CONTRACT_SERVICE_DAO_LISTING, _resolver));

    }



    function daoStakeStorage()

        internal

        view

        returns (DaoStakeStorage _contract)

    {

        _contract = DaoStakeStorage(get_contract(CONTRACT_STORAGE_DAO_STAKE));

    }



    function daoStorage()

        internal

        view

        returns (DaoStorage _contract)

    {

        _contract = DaoStorage(get_contract(CONTRACT_STORAGE_DAO));

    }



    /**

    @notice function to list moderators

    @dev note that this list may include some additional entries that are

         not moderators in the current quarter. This may happen if they

         were moderators in the previous quarter, but have not confirmed

         their participation in the current quarter. For a single address,

         a better way to know if moderator or not is:

         Dao.isModerator(_user)

    @param _count number of addresses to list

    @param _from_start boolean, whether to list from start or end

    @return {

      "_moderators": "list of moderator addresses"

    }

    */

    function listModerators(uint256 _count, bool _from_start)

        public

        view

        returns (address[] _moderators)

    {

        _moderators = list_addresses(

            _count,

            daoStakeStorage().readFirstModerator,

            daoStakeStorage().readLastModerator,

            daoStakeStorage().readNextModerator,

            daoStakeStorage().readPreviousModerator,

            _from_start

        );

    }



    /**

    @notice function to list moderators from a particular moderator

    @dev note that this list may include some additional entries that are

         not moderators in the current quarter. This may happen if they

         were moderators in the previous quarter, but have not confirmed

         their participation in the current quarter. For a single address,

         a better way to know if moderator or not is:

         Dao.isModerator(_user)



         Another note: this function will start listing AFTER the _currentModerator

         For example: we have [address1, address2, address3, address4]. listModeratorsFrom(address1, 2, true) = [address2, address3]

    @param _currentModerator start the list after this moderator address

    @param _count number of addresses to list

    @param _from_start boolean, whether to list from start or end

    @return {

      "_moderators": "list of moderator addresses"

    }

    */

    function listModeratorsFrom(

        address _currentModerator,

        uint256 _count,

        bool _from_start

    )

        public

        view

        returns (address[] _moderators)

    {

        _moderators = list_addresses_from(

            _currentModerator,

            _count,

            daoStakeStorage().readFirstModerator,

            daoStakeStorage().readLastModerator,

            daoStakeStorage().readNextModerator,

            daoStakeStorage().readPreviousModerator,

            _from_start

        );

    }



    /**

    @notice function to list participants

    @dev note that this list may include some additional entries that are

         not participants in the current quarter. This may happen if they

         were participants in the previous quarter, but have not confirmed

         their participation in the current quarter. For a single address,

         a better way to know if participant or not is:

         Dao.isParticipant(_user)

    @param _count number of addresses to list

    @param _from_start boolean, whether to list from start or end

    @return {

      "_participants": "list of participant addresses"

    }

    */

    function listParticipants(uint256 _count, bool _from_start)

        public

        view

        returns (address[] _participants)

    {

        _participants = list_addresses(

            _count,

            daoStakeStorage().readFirstParticipant,

            daoStakeStorage().readLastParticipant,

            daoStakeStorage().readNextParticipant,

            daoStakeStorage().readPreviousParticipant,

            _from_start

        );

    }



    /**

    @notice function to list participants from a particular participant

    @dev note that this list may include some additional entries that are

         not participants in the current quarter. This may happen if they

         were participants in the previous quarter, but have not confirmed

         their participation in the current quarter. For a single address,

         a better way to know if participant or not is:

         contracts.dao.isParticipant(_user)



         Another note: this function will start listing AFTER the _currentParticipant

         For example: we have [address1, address2, address3, address4]. listParticipantsFrom(address1, 2, true) = [address2, address3]

    @param _currentParticipant list from AFTER this participant address

    @param _count number of addresses to list

    @param _from_start boolean, whether to list from start or end

    @return {

      "_participants": "list of participant addresses"

    }

    */

    function listParticipantsFrom(

        address _currentParticipant,

        uint256 _count,

        bool _from_start

    )

        public

        view

        returns (address[] _participants)

    {

        _participants = list_addresses_from(

            _currentParticipant,

            _count,

            daoStakeStorage().readFirstParticipant,

            daoStakeStorage().readLastParticipant,

            daoStakeStorage().readNextParticipant,

            daoStakeStorage().readPreviousParticipant,

            _from_start

        );

    }



    /**

    @notice function to list _count no. of proposals

    @param _count number of proposals to list

    @param _from_start boolean value, true if count from start, false if count from end

    @return {

      "_proposals": "the list of proposal IDs"

    }

    */

    function listProposals(

        uint256 _count,

        bool _from_start

    )

        public

        view

        returns (bytes32[] _proposals)

    {

        _proposals = list_bytesarray(

            _count,

            daoStorage().getFirstProposal,

            daoStorage().getLastProposal,

            daoStorage().getNextProposal,

            daoStorage().getPreviousProposal,

            _from_start

        );

    }



    /**

    @notice function to list _count no. of proposals from AFTER _currentProposal

    @param _currentProposal ID of proposal to list proposals from

    @param _count number of proposals to list

    @param _from_start boolean value, true if count forwards, false if count backwards

    @return {

      "_proposals": "the list of proposal IDs"

    }

    */

    function listProposalsFrom(

        bytes32 _currentProposal,

        uint256 _count,

        bool _from_start

    )

        public

        view

        returns (bytes32[] _proposals)

    {

        _proposals = list_bytesarray_from(

            _currentProposal,

            _count,

            daoStorage().getFirstProposal,

            daoStorage().getLastProposal,

            daoStorage().getNextProposal,

            daoStorage().getPreviousProposal,

            _from_start

        );

    }



    /**

    @notice function to list _count no. of proposals in state _stateId

    @param _stateId state of proposal

    @param _count number of proposals to list

    @param _from_start boolean value, true if count from start, false if count from end

    @return {

      "_proposals": "the list of proposal IDs"

    }

    */

    function listProposalsInState(

        bytes32 _stateId,

        uint256 _count,

        bool _from_start

    )

        public

        view

        returns (bytes32[] _proposals)

    {

        require(senderIsAllowedToRead());

        _proposals = list_indexed_bytesarray(

            _stateId,

            _count,

            daoStorage().getFirstProposalInState,

            daoStorage().getLastProposalInState,

            daoStorage().getNextProposalInState,

            daoStorage().getPreviousProposalInState,

            _from_start

        );

    }



    /**

    @notice function to list _count no. of proposals in state _stateId from AFTER _currentProposal

    @param _stateId state of proposal

    @param _currentProposal ID of proposal to list proposals from

    @param _count number of proposals to list

    @param _from_start boolean value, true if count forwards, false if count backwards

    @return {

      "_proposals": "the list of proposal IDs"

    }

    */

    function listProposalsInStateFrom(

        bytes32 _stateId,

        bytes32 _currentProposal,

        uint256 _count,

        bool _from_start

    )

        public

        view

        returns (bytes32[] _proposals)

    {

        require(senderIsAllowedToRead());

        _proposals = list_indexed_bytesarray_from(

            _stateId,

            _currentProposal,

            _count,

            daoStorage().getFirstProposalInState,

            daoStorage().getLastProposalInState,

            daoStorage().getNextProposalInState,

            daoStorage().getPreviousProposalInState,

            _from_start

        );

    }



    /**

    @notice function to list proposal versions

    @param _proposalId ID of the proposal

    @param _count number of proposal versions to list

    @param _from_start boolean, true to list from start, false to list from end

    @return {

      "_versions": "list of proposal versions"

    }

    */

    function listProposalVersions(

        bytes32 _proposalId,

        uint256 _count,

        bool _from_start

    )

        public

        view

        returns (bytes32[] _versions)

    {

        _versions = list_indexed_bytesarray(

            _proposalId,

            _count,

            daoStorage().getFirstProposalVersion,

            daoStorage().getLastProposalVersion,

            daoStorage().getNextProposalVersion,

            daoStorage().getPreviousProposalVersion,

            _from_start

        );

    }



    /**

    @notice function to list proposal versions from AFTER a particular version

    @param _proposalId ID of the proposal

    @param _currentVersion version to list _count versions from

    @param _count number of proposal versions to list

    @param _from_start boolean, true to list from start, false to list from end

    @return {

      "_versions": "list of proposal versions"

    }

    */

    function listProposalVersionsFrom(

        bytes32 _proposalId,

        bytes32 _currentVersion,

        uint256 _count,

        bool _from_start

    )

        public

        view

        returns (bytes32[] _versions)

    {

        _versions = list_indexed_bytesarray_from(

            _proposalId,

            _currentVersion,

            _count,

            daoStorage().getFirstProposalVersion,

            daoStorage().getLastProposalVersion,

            daoStorage().getNextProposalVersion,

            daoStorage().getPreviousProposalVersion,

            _from_start

        );

    }

}



// File: @digix/solidity-collections/contracts/abstract/IndexedAddressIteratorStorage.sol

/**

  @title Indexed Address IteratorStorage

  @author DigixGlobal Pte Ltd

  @notice This contract utilizes: [Doubly Linked List](/DoublyLinkedList)

*/

contract IndexedAddressIteratorStorage {



  using DoublyLinkedList for DoublyLinkedList.IndexedAddress;

  /**

    @notice Reads the first item from an Indexed Address Doubly Linked List

    @param _list The source list

    @param _collection_index Index of the Collection to evaluate

    @return {"_item" : "First item on the list"}

  */

  function read_first_from_indexed_addresses(DoublyLinkedList.IndexedAddress storage _list, bytes32 _collection_index)

           internal

           constant

           returns (address _item)

  {

    _item = _list.start_item(_collection_index);

  }



  /**

    @notice Reads the last item from an Indexed Address Doubly Linked list

    @param _list The source list

    @param _collection_index Index of the Collection to evaluate

    @return {"_item" : "First item on the list"}

  */

  function read_last_from_indexed_addresses(DoublyLinkedList.IndexedAddress storage _list, bytes32 _collection_index)

           internal

           constant

           returns (address _item)

  {

    _item = _list.end_item(_collection_index);

  }



  /**

    @notice Reads the next item from an Indexed Address Doubly Linked List based on the specified `_current_item`

    @param _list The source list

    @param _collection_index Index of the Collection to evaluate

    @param _current_item The current item to use as base line

    @return {"_item": "The next item on the list"}

  */

  function read_next_from_indexed_addresses(DoublyLinkedList.IndexedAddress storage _list, bytes32 _collection_index, address _current_item)

           internal

           constant

           returns (address _item)

  {

    _item = _list.next_item(_collection_index, _current_item);

  }



  /**

    @notice Reads the previous item from an Index Address Doubly Linked List based on the specified `_current_item`

    @param _list The source list

    @param _collection_index Index of the Collection to evaluate

    @param _current_item The current item to use as base line

    @return {"_item" : "The previous item on the list"}

  */

  function read_previous_from_indexed_addresses(DoublyLinkedList.IndexedAddress storage _list, bytes32 _collection_index, address _current_item)

           internal

           constant

           returns (address _item)

  {

    _item = _list.previous_item(_collection_index, _current_item);

  }





  /**

    @notice Reads the total number of items in an Indexed Address Doubly Linked List

    @param _list  The source list

    @param _collection_index Index of the Collection to evaluate

    @return {"_count": "Length of the Doubly Linked list"}

  */

  function read_total_indexed_addresses(DoublyLinkedList.IndexedAddress storage _list, bytes32 _collection_index)

           internal

           constant

           returns (uint256 _count)

  {

    _count = _list.total(_collection_index);

  }

}



// File: @digix/solidity-collections/contracts/abstract/UintIteratorStorage.sol

/**

  @title Uint Iterator Storage

  @author DigixGlobal Pte Ltd

*/

contract UintIteratorStorage {



  using DoublyLinkedList for DoublyLinkedList.Uint;



  /**

    @notice Returns the first item from a `DoublyLinkedList.Uint` list

    @param _list The DoublyLinkedList.Uint list

    @return {"_item": "The first item"}

  */

  function read_first_from_uints(DoublyLinkedList.Uint storage _list)

           internal

           constant

           returns (uint256 _item)

  {

    _item = _list.start_item();

  }



  /**

    @notice Returns the last item from a `DoublyLinkedList.Uint` list

    @param _list The DoublyLinkedList.Uint list

    @return {"_item": "The last item"}

  */

  function read_last_from_uints(DoublyLinkedList.Uint storage _list)

           internal

           constant

           returns (uint256 _item)

  {

    _item = _list.end_item();

  }



  /**

    @notice Returns the next item from a `DoublyLinkedList.Uint` list based on the specified `_current_item`

    @param _list The DoublyLinkedList.Uint list

    @param _current_item The current item

    @return {"_item": "The next item"}

  */

  function read_next_from_uints(DoublyLinkedList.Uint storage _list, uint256 _current_item)

           internal

           constant

           returns (uint256 _item)

  {

    _item = _list.next_item(_current_item);

  }



  /**

    @notice Returns the previous item from a `DoublyLinkedList.Uint` list based on the specified `_current_item`

    @param _list The DoublyLinkedList.Uint list

    @param _current_item The current item

    @return {"_item": "The previous item"}

  */

  function read_previous_from_uints(DoublyLinkedList.Uint storage _list, uint256 _current_item)

           internal

           constant

           returns (uint256 _item)

  {

    _item = _list.previous_item(_current_item);

  }



  /**

    @notice Returns the total count of itemsfrom a `DoublyLinkedList.Uint` list

    @param _list The DoublyLinkedList.Uint list

    @return {"_count": "The total count of items"}

  */

  function read_total_uints(DoublyLinkedList.Uint storage _list)

           internal

           constant

           returns (uint256 _count)

  {

    _count = _list.total();

  }

}



// File: @digix/cdap/contracts/storage/DirectoryStorage.sol

/**

@title Directory Storage contains information of a directory

@author DigixGlobal

*/

contract DirectoryStorage is IndexedAddressIteratorStorage, UintIteratorStorage {



  using DoublyLinkedList for DoublyLinkedList.IndexedAddress;

  using DoublyLinkedList for DoublyLinkedList.Uint;



  struct User {

    bytes32 document;

    bool active;

  }



  struct Group {

    bytes32 name;

    bytes32 document;

    uint256 role_id;

    mapping(address => User) members_by_address;

  }



  struct System {

    DoublyLinkedList.Uint groups;

    DoublyLinkedList.IndexedAddress groups_collection;

    mapping (uint256 => Group) groups_by_id;

    mapping (address => uint256) group_ids_by_address;

    mapping (uint256 => bytes32) roles_by_id;

    bool initialized;

    uint256 total_groups;

  }



  System system;



  /**

  @notice Initializes directory settings

  @return _success If directory initialization is successful

  */

  function initialize_directory()

           internal

           returns (bool _success)

  {

    require(system.initialized == false);

    system.total_groups = 0;

    system.initialized = true;

    internal_create_role(1, "root");

    internal_create_group(1, "root", "");

    _success = internal_update_add_user_to_group(1, tx.origin, "");

  }



  /**

  @notice Creates a new role with the given information

  @param _role_id Id of the new role

  @param _name Name of the new role

  @return {"_success": "If creation of new role is successful"}

  */

  function internal_create_role(uint256 _role_id, bytes32 _name)

           internal

           returns (bool _success)

  {

    require(_role_id > 0);

    require(_name != bytes32(0x0));

    system.roles_by_id[_role_id] = _name;

    _success = true;

  }



  /**

  @notice Returns the role's name of a role id

  @param _role_id Id of the role

  @return {"_name": "Name of the role"}

  */

  function read_role(uint256 _role_id)

           public

           constant

           returns (bytes32 _name)

  {

    _name = system.roles_by_id[_role_id];

  }



  /**

  @notice Creates a new group with the given information

  @param _role_id Role id of the new group

  @param _name Name of the new group

  @param _document Document of the new group

  @return {

    "_success": "If creation of the new group is successful",

    "_group_id: "Id of the new group"

  }

  */

  function internal_create_group(uint256 _role_id, bytes32 _name, bytes32 _document)

           internal

           returns (bool _success, uint256 _group_id)

  {

    require(_role_id > 0);

    require(read_role(_role_id) != bytes32(0x0));

    _group_id = ++system.total_groups;

    system.groups.append(_group_id);

    system.groups_by_id[_group_id].role_id = _role_id;

    system.groups_by_id[_group_id].name = _name;

    system.groups_by_id[_group_id].document = _document;

    _success = true;

  }



  /**

  @notice Returns the group's information

  @param _group_id Id of the group

  @return {

    "_role_id": "Role id of the group",

    "_name: "Name of the group",

    "_document: "Document of the group"

  }

  */

  function read_group(uint256 _group_id)

           public

           constant

           returns (uint256 _role_id, bytes32 _name, bytes32 _document, uint256 _members_count)

  {

    if (system.groups.valid_item(_group_id)) {

      _role_id = system.groups_by_id[_group_id].role_id;

      _name = system.groups_by_id[_group_id].name;

      _document = system.groups_by_id[_group_id].document;

      _members_count = read_total_indexed_addresses(system.groups_collection, bytes32(_group_id));

    } else {

      _role_id = 0;

      _name = "invalid";

      _document = "";

      _members_count = 0;

    }

  }



  /**

  @notice Adds new user with the given information to a group

  @param _group_id Id of the group

  @param _user Address of the new user

  @param _document Information of the new user

  @return {"_success": "If adding new user to a group is successful"}

  */

  function internal_update_add_user_to_group(uint256 _group_id, address _user, bytes32 _document)

           internal

           returns (bool _success)

  {

    if (system.groups_by_id[_group_id].members_by_address[_user].active == false && system.group_ids_by_address[_user] == 0 && system.groups_by_id[_group_id].role_id != 0) {



      system.groups_by_id[_group_id].members_by_address[_user].active = true;

      system.group_ids_by_address[_user] = _group_id;

      system.groups_collection.append(bytes32(_group_id), _user);

      system.groups_by_id[_group_id].members_by_address[_user].document = _document;

      _success = true;

    } else {

      _success = false;

    }

  }



  /**

  @notice Removes user from its group

  @param _user Address of the user

  @return {"_success": "If removing of user is successful"}

  */

  function internal_destroy_group_user(address _user)

           internal

           returns (bool _success)

  {

    uint256 _group_id = system.group_ids_by_address[_user];

    if ((_group_id == 1) && (system.groups_collection.total(bytes32(_group_id)) == 1)) {

      _success = false;

    } else {

      system.groups_by_id[_group_id].members_by_address[_user].active = false;

      system.group_ids_by_address[_user] = 0;

      delete system.groups_by_id[_group_id].members_by_address[_user];

      _success = system.groups_collection.remove_item(bytes32(_group_id), _user);

    }

  }



  /**

  @notice Returns the role id of a user

  @param _user Address of a user

  @return {"_role_id": "Role id of the user"}

  */

  function read_user_role_id(address _user)

           constant

           public

           returns (uint256 _role_id)

  {

    uint256 _group_id = system.group_ids_by_address[_user];

    _role_id = system.groups_by_id[_group_id].role_id;

  }



  /**

  @notice Returns the user's information

  @param _user Address of the user

  @return {

    "_group_id": "Group id of the user",

    "_role_id": "Role id of the user",

    "_document": "Information of the user"

  }

  */

  function read_user(address _user)

           public

           constant

           returns (uint256 _group_id, uint256 _role_id, bytes32 _document)

  {

    _group_id = system.group_ids_by_address[_user];

    _role_id = system.groups_by_id[_group_id].role_id;

    _document = system.groups_by_id[_group_id].members_by_address[_user].document;

  }



  /**

  @notice Returns the id of the first group

  @return {"_group_id": "Id of the first group"}

  */

  function read_first_group()

           view

           external

           returns (uint256 _group_id)

  {

    _group_id = read_first_from_uints(system.groups);

  }



  /**

  @notice Returns the id of the last group

  @return {"_group_id": "Id of the last group"}

  */

  function read_last_group()

           view

           external

           returns (uint256 _group_id)

  {

    _group_id = read_last_from_uints(system.groups);

  }



  /**

  @notice Returns the id of the previous group depending on the given current group

  @param _current_group_id Id of the current group

  @return {"_group_id": "Id of the previous group"}

  */

  function read_previous_group_from_group(uint256 _current_group_id)

           view

           external

           returns (uint256 _group_id)

  {

    _group_id = read_previous_from_uints(system.groups, _current_group_id);

  }



  /**

  @notice Returns the id of the next group depending on the given current group

  @param _current_group_id Id of the current group

  @return {"_group_id": "Id of the next group"}

  */

  function read_next_group_from_group(uint256 _current_group_id)

           view

           external

           returns (uint256 _group_id)

  {

    _group_id = read_next_from_uints(system.groups, _current_group_id);

  }



  /**

  @notice Returns the total number of groups

  @return {"_total_groups": "Total number of groups"}

  */

  function read_total_groups()

           view

           external

           returns (uint256 _total_groups)

  {

    _total_groups = read_total_uints(system.groups);

  }



  /**

  @notice Returns the first user of a group

  @param _group_id Id of the group

  @return {"_user": "Address of the user"}

  */

  function read_first_user_in_group(bytes32 _group_id)

           view

           external

           returns (address _user)

  {

    _user = read_first_from_indexed_addresses(system.groups_collection, bytes32(_group_id));

  }



  /**

  @notice Returns the last user of a group

  @param _group_id Id of the group

  @return {"_user": "Address of the user"}

  */

  function read_last_user_in_group(bytes32 _group_id)

           view

           external

           returns (address _user)

  {

    _user = read_last_from_indexed_addresses(system.groups_collection, bytes32(_group_id));

  }



  /**

  @notice Returns the next user of a group depending on the given current user

  @param _group_id Id of the group

  @param _current_user Address of the current user

  @return {"_user": "Address of the next user"}

  */

  function read_next_user_in_group(bytes32 _group_id, address _current_user)

           view

           external

           returns (address _user)

  {

    _user = read_next_from_indexed_addresses(system.groups_collection, bytes32(_group_id), _current_user);

  }



  /**

  @notice Returns the previous user of a group depending on the given current user

  @param _group_id Id of the group

  @param _current_user Address of the current user

  @return {"_user": "Address of the last user"}

  */

  function read_previous_user_in_group(bytes32 _group_id, address _current_user)

           view

           external

           returns (address _user)

  {

    _user = read_previous_from_indexed_addresses(system.groups_collection, bytes32(_group_id), _current_user);

  }



  /**

  @notice Returns the total number of users of a group

  @param _group_id Id of the group

  @return {"_total_users": "Total number of users"}

  */

  function read_total_users_in_group(bytes32 _group_id)

           view

           external

           returns (uint256 _total_users)

  {

    _total_users = read_total_indexed_addresses(system.groups_collection, bytes32(_group_id));

  }

}



// File: contracts/storage/DaoIdentityStorage.sol

contract DaoIdentityStorage is ResolverClient, DaoConstants, DirectoryStorage {



    // struct for KYC details

    // doc is the IPFS doc hash for any information regarding this KYC

    // id_expiration is the UTC timestamp at which this KYC will expire

    // at any time after this, the user's KYC is invalid, and that user

    // MUST re-KYC before doing any proposer related operation in DigixDAO

    struct KycDetails {

        bytes32 doc;

        uint256 id_expiration;

    }



    // a mapping of address to the KYC details

    mapping (address => KycDetails) kycInfo;



    constructor(address _resolver)

        public

    {

        require(init(CONTRACT_STORAGE_DAO_IDENTITY, _resolver));

        require(initialize_directory());

    }



    function create_group(uint256 _role_id, bytes32 _name, bytes32 _document)

        public

        returns (bool _success, uint256 _group_id)

    {

        require(sender_is(CONTRACT_DAO_IDENTITY));

        (_success, _group_id) = internal_create_group(_role_id, _name, _document);

        require(_success);

    }



    function create_role(uint256 _role_id, bytes32 _name)

        public

        returns (bool _success)

    {

        require(sender_is(CONTRACT_DAO_IDENTITY));

        _success = internal_create_role(_role_id, _name);

        require(_success);

    }



    function update_add_user_to_group(uint256 _group_id, address _user, bytes32 _document)

        public

        returns (bool _success)

    {

        require(sender_is(CONTRACT_DAO_IDENTITY));

        _success = internal_update_add_user_to_group(_group_id, _user, _document);

        require(_success);

    }



    function update_remove_group_user(address _user)

        public

        returns (bool _success)

    {

        require(sender_is(CONTRACT_DAO_IDENTITY));

        _success = internal_destroy_group_user(_user);

        require(_success);

    }



    function update_kyc(address _user, bytes32 _doc, uint256 _id_expiration)

        public

    {

        require(sender_is(CONTRACT_DAO_IDENTITY));

        kycInfo[_user].doc = _doc;

        kycInfo[_user].id_expiration = _id_expiration;

    }



    function read_kyc_info(address _user)

        public

        view

        returns (bytes32 _doc, uint256 _id_expiration)

    {

        _doc = kycInfo[_user].doc;

        _id_expiration = kycInfo[_user].id_expiration;

    }



    function is_kyc_approved(address _user)

        public

        view

        returns (bool _approved)

    {

        uint256 _id_expiration;

        (,_id_expiration) = read_kyc_info(_user);

        _approved = _id_expiration > now;

    }

}



// File: contracts/common/IdentityCommon.sol

contract IdentityCommon is DaoWhitelistingCommon {



    modifier if_root() {

        require(identity_storage().read_user_role_id(msg.sender) == ROLES_ROOT);

        _;

    }



    modifier if_founder() {

        require(is_founder());

        _;

    }



    function is_founder()

        internal

        view

        returns (bool _isFounder)

    {

        _isFounder = identity_storage().read_user_role_id(msg.sender) == ROLES_FOUNDERS;

    }



    modifier if_prl() {

        require(identity_storage().read_user_role_id(msg.sender) == ROLES_PRLS);

        _;

    }



    modifier if_kyc_admin() {

        require(identity_storage().read_user_role_id(msg.sender) == ROLES_KYC_ADMINS);

        _;

    }



    function identity_storage()

        internal

        view

        returns (DaoIdentityStorage _contract)

    {

        _contract = DaoIdentityStorage(get_contract(CONTRACT_STORAGE_DAO_IDENTITY));

    }

}



// File: contracts/storage/DaoConfigsStorage.sol

contract DaoConfigsStorage is ResolverClient, DaoConstants {



    // mapping of config name to config value

    // config names can be found in DaoConstants contract

    mapping (bytes32 => uint256) public uintConfigs;



    // mapping of config name to config value

    // config names can be found in DaoConstants contract

    mapping (bytes32 => address) public addressConfigs;



    // mapping of config name to config value

    // config names can be found in DaoConstants contract

    mapping (bytes32 => bytes32) public bytesConfigs;



    uint256 ONE_BILLION = 1000000000;

    uint256 ONE_MILLION = 1000000;



    constructor(address _resolver)

        public

    {

        require(init(CONTRACT_STORAGE_DAO_CONFIG, _resolver));



        uintConfigs[CONFIG_LOCKING_PHASE_DURATION] = 10 days;

        uintConfigs[CONFIG_QUARTER_DURATION] = QUARTER_DURATION;

        uintConfigs[CONFIG_VOTING_COMMIT_PHASE] = 14 days;

        uintConfigs[CONFIG_VOTING_PHASE_TOTAL] = 21 days;

        uintConfigs[CONFIG_INTERIM_COMMIT_PHASE] = 7 days;

        uintConfigs[CONFIG_INTERIM_PHASE_TOTAL] = 14 days;







        uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR] = 5; // 5%

        uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR] = 100; // 5%

        uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR] = 35; // 35%

        uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR] = 100; // 35%





        uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR] = 5; // 5%

        uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR] = 100; // 5%

        uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR] = 25; // 25%

        uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR] = 100; // 25%



        uintConfigs[CONFIG_DRAFT_QUOTA_NUMERATOR] = 1; // >50%

        uintConfigs[CONFIG_DRAFT_QUOTA_DENOMINATOR] = 2; // >50%

        uintConfigs[CONFIG_VOTING_QUOTA_NUMERATOR] = 1; // >50%

        uintConfigs[CONFIG_VOTING_QUOTA_DENOMINATOR] = 2; // >50%





        uintConfigs[CONFIG_QUARTER_POINT_DRAFT_VOTE] = ONE_BILLION;

        uintConfigs[CONFIG_QUARTER_POINT_VOTE] = ONE_BILLION;

        uintConfigs[CONFIG_QUARTER_POINT_INTERIM_VOTE] = ONE_BILLION;



        uintConfigs[CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH] = 20000 * ONE_BILLION;



        uintConfigs[CONFIG_BONUS_REPUTATION_NUMERATOR] = 15; // 15% bonus for consistent votes

        uintConfigs[CONFIG_BONUS_REPUTATION_DENOMINATOR] = 100; // 15% bonus for consistent votes



        uintConfigs[CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE] = 28 days;

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL] = 35 days;







        uintConfigs[CONFIG_SPECIAL_QUOTA_NUMERATOR] = 1; // >50%

        uintConfigs[CONFIG_SPECIAL_QUOTA_DENOMINATOR] = 2; // >50%



        uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR] = 40; // 40%

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR] = 100; // 40%



        uintConfigs[CONFIG_MAXIMUM_REPUTATION_DEDUCTION] = 8334 * ONE_MILLION;



        uintConfigs[CONFIG_PUNISHMENT_FOR_NOT_LOCKING] = 1666 * ONE_MILLION;

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_NUM] = 1; // 1 extra QP gains 1/1 RP

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_DEN] = 1;





        uintConfigs[CONFIG_MINIMAL_QUARTER_POINT] = 2 * ONE_BILLION;

        uintConfigs[CONFIG_QUARTER_POINT_SCALING_FACTOR] = 400 * ONE_BILLION;

        uintConfigs[CONFIG_REPUTATION_POINT_SCALING_FACTOR] = 2000 * ONE_BILLION;



        uintConfigs[CONFIG_MODERATOR_MINIMAL_QUARTER_POINT] = 4 * ONE_BILLION;

        uintConfigs[CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR] = 400 * ONE_BILLION;

        uintConfigs[CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR] = 2000 * ONE_BILLION;



        uintConfigs[CONFIG_PORTION_TO_MODERATORS_NUM] = 42; //4.2% of DGX to moderator voting activity

        uintConfigs[CONFIG_PORTION_TO_MODERATORS_DEN] = 1000;



        uintConfigs[CONFIG_DRAFT_VOTING_PHASE] = 10 days;



        uintConfigs[CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE] = 412500 * ONE_MILLION;



        uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR] = 7; // 7%

        uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR] = 100; // 7%



        uintConfigs[CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION] = 12500 * ONE_MILLION;

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM] = 1;

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN] = 1;



        uintConfigs[CONFIG_VOTE_CLAIMING_DEADLINE] = 10 days;



        uintConfigs[CONFIG_MINIMUM_LOCKED_DGD] = 10 * ONE_BILLION;

        uintConfigs[CONFIG_MINIMUM_DGD_FOR_MODERATOR] = 842 * ONE_BILLION;

        uintConfigs[CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR] = 400 * ONE_BILLION;



        uintConfigs[CONFIG_PREPROPOSAL_COLLATERAL] = 2 ether;



        uintConfigs[CONFIG_MAX_FUNDING_FOR_NON_DIGIX] = 100 ether;

        uintConfigs[CONFIG_MAX_MILESTONES_FOR_NON_DIGIX] = 5;

        uintConfigs[CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER] = 80;



        uintConfigs[CONFIG_PROPOSAL_DEAD_DURATION] = 90 days;

        uintConfigs[CONFIG_CARBON_VOTE_REPUTATION_BONUS] = 10 * ONE_BILLION;

    }



    function updateUintConfigs(uint256[] _uintConfigs)

        external

    {

        require(sender_is(CONTRACT_DAO_SPECIAL_VOTING_CLAIMS));

        uintConfigs[CONFIG_LOCKING_PHASE_DURATION] = _uintConfigs[0];

        /*

        This used to be a config that can be changed. Now, _uintConfigs[1] is just a dummy config that doesnt do anything

        uintConfigs[CONFIG_QUARTER_DURATION] = _uintConfigs[1];

        */

        uintConfigs[CONFIG_VOTING_COMMIT_PHASE] = _uintConfigs[2];

        uintConfigs[CONFIG_VOTING_PHASE_TOTAL] = _uintConfigs[3];

        uintConfigs[CONFIG_INTERIM_COMMIT_PHASE] = _uintConfigs[4];

        uintConfigs[CONFIG_INTERIM_PHASE_TOTAL] = _uintConfigs[5];

        uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR] = _uintConfigs[6];

        uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR] = _uintConfigs[7];

        uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR] = _uintConfigs[8];

        uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR] = _uintConfigs[9];

        uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR] = _uintConfigs[10];

        uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR] = _uintConfigs[11];

        uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR] = _uintConfigs[12];

        uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR] = _uintConfigs[13];

        uintConfigs[CONFIG_DRAFT_QUOTA_NUMERATOR] = _uintConfigs[14];

        uintConfigs[CONFIG_DRAFT_QUOTA_DENOMINATOR] = _uintConfigs[15];

        uintConfigs[CONFIG_VOTING_QUOTA_NUMERATOR] = _uintConfigs[16];

        uintConfigs[CONFIG_VOTING_QUOTA_DENOMINATOR] = _uintConfigs[17];

        uintConfigs[CONFIG_QUARTER_POINT_DRAFT_VOTE] = _uintConfigs[18];

        uintConfigs[CONFIG_QUARTER_POINT_VOTE] = _uintConfigs[19];

        uintConfigs[CONFIG_QUARTER_POINT_INTERIM_VOTE] = _uintConfigs[20];

        uintConfigs[CONFIG_MINIMAL_QUARTER_POINT] = _uintConfigs[21];

        uintConfigs[CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH] = _uintConfigs[22];

        uintConfigs[CONFIG_BONUS_REPUTATION_NUMERATOR] = _uintConfigs[23];

        uintConfigs[CONFIG_BONUS_REPUTATION_DENOMINATOR] = _uintConfigs[24];

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE] = _uintConfigs[25];

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL] = _uintConfigs[26];

        uintConfigs[CONFIG_SPECIAL_QUOTA_NUMERATOR] = _uintConfigs[27];

        uintConfigs[CONFIG_SPECIAL_QUOTA_DENOMINATOR] = _uintConfigs[28];

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR] = _uintConfigs[29];

        uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR] = _uintConfigs[30];

        uintConfigs[CONFIG_MAXIMUM_REPUTATION_DEDUCTION] = _uintConfigs[31];

        uintConfigs[CONFIG_PUNISHMENT_FOR_NOT_LOCKING] = _uintConfigs[32];

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_NUM] = _uintConfigs[33];

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_DEN] = _uintConfigs[34];

        uintConfigs[CONFIG_QUARTER_POINT_SCALING_FACTOR] = _uintConfigs[35];

        uintConfigs[CONFIG_REPUTATION_POINT_SCALING_FACTOR] = _uintConfigs[36];

        uintConfigs[CONFIG_MODERATOR_MINIMAL_QUARTER_POINT] = _uintConfigs[37];

        uintConfigs[CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR] = _uintConfigs[38];

        uintConfigs[CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR] = _uintConfigs[39];

        uintConfigs[CONFIG_PORTION_TO_MODERATORS_NUM] = _uintConfigs[40];

        uintConfigs[CONFIG_PORTION_TO_MODERATORS_DEN] = _uintConfigs[41];

        uintConfigs[CONFIG_DRAFT_VOTING_PHASE] = _uintConfigs[42];

        uintConfigs[CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE] = _uintConfigs[43];

        uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR] = _uintConfigs[44];

        uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR] = _uintConfigs[45];

        uintConfigs[CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION] = _uintConfigs[46];

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM] = _uintConfigs[47];

        uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN] = _uintConfigs[48];

        uintConfigs[CONFIG_VOTE_CLAIMING_DEADLINE] = _uintConfigs[49];

        uintConfigs[CONFIG_MINIMUM_LOCKED_DGD] = _uintConfigs[50];

        uintConfigs[CONFIG_MINIMUM_DGD_FOR_MODERATOR] = _uintConfigs[51];

        uintConfigs[CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR] = _uintConfigs[52];

        uintConfigs[CONFIG_PREPROPOSAL_COLLATERAL] = _uintConfigs[53];

        uintConfigs[CONFIG_MAX_FUNDING_FOR_NON_DIGIX] = _uintConfigs[54];

        uintConfigs[CONFIG_MAX_MILESTONES_FOR_NON_DIGIX] = _uintConfigs[55];

        uintConfigs[CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER] = _uintConfigs[56];

        uintConfigs[CONFIG_PROPOSAL_DEAD_DURATION] = _uintConfigs[57];

        uintConfigs[CONFIG_CARBON_VOTE_REPUTATION_BONUS] = _uintConfigs[58];

    }



    function readUintConfigs()

        public

        view

        returns (uint256[])

    {

        uint256[] memory _uintConfigs = new uint256[](59);

        _uintConfigs[0] = uintConfigs[CONFIG_LOCKING_PHASE_DURATION];

        _uintConfigs[1] = uintConfigs[CONFIG_QUARTER_DURATION];

        _uintConfigs[2] = uintConfigs[CONFIG_VOTING_COMMIT_PHASE];

        _uintConfigs[3] = uintConfigs[CONFIG_VOTING_PHASE_TOTAL];

        _uintConfigs[4] = uintConfigs[CONFIG_INTERIM_COMMIT_PHASE];

        _uintConfigs[5] = uintConfigs[CONFIG_INTERIM_PHASE_TOTAL];

        _uintConfigs[6] = uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_NUMERATOR];

        _uintConfigs[7] = uintConfigs[CONFIG_DRAFT_QUORUM_FIXED_PORTION_DENOMINATOR];

        _uintConfigs[8] = uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_NUMERATOR];

        _uintConfigs[9] = uintConfigs[CONFIG_DRAFT_QUORUM_SCALING_FACTOR_DENOMINATOR];

        _uintConfigs[10] = uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_NUMERATOR];

        _uintConfigs[11] = uintConfigs[CONFIG_VOTING_QUORUM_FIXED_PORTION_DENOMINATOR];

        _uintConfigs[12] = uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_NUMERATOR];

        _uintConfigs[13] = uintConfigs[CONFIG_VOTING_QUORUM_SCALING_FACTOR_DENOMINATOR];

        _uintConfigs[14] = uintConfigs[CONFIG_DRAFT_QUOTA_NUMERATOR];

        _uintConfigs[15] = uintConfigs[CONFIG_DRAFT_QUOTA_DENOMINATOR];

        _uintConfigs[16] = uintConfigs[CONFIG_VOTING_QUOTA_NUMERATOR];

        _uintConfigs[17] = uintConfigs[CONFIG_VOTING_QUOTA_DENOMINATOR];

        _uintConfigs[18] = uintConfigs[CONFIG_QUARTER_POINT_DRAFT_VOTE];

        _uintConfigs[19] = uintConfigs[CONFIG_QUARTER_POINT_VOTE];

        _uintConfigs[20] = uintConfigs[CONFIG_QUARTER_POINT_INTERIM_VOTE];

        _uintConfigs[21] = uintConfigs[CONFIG_MINIMAL_QUARTER_POINT];

        _uintConfigs[22] = uintConfigs[CONFIG_QUARTER_POINT_MILESTONE_COMPLETION_PER_10000ETH];

        _uintConfigs[23] = uintConfigs[CONFIG_BONUS_REPUTATION_NUMERATOR];

        _uintConfigs[24] = uintConfigs[CONFIG_BONUS_REPUTATION_DENOMINATOR];

        _uintConfigs[25] = uintConfigs[CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE];

        _uintConfigs[26] = uintConfigs[CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL];

        _uintConfigs[27] = uintConfigs[CONFIG_SPECIAL_QUOTA_NUMERATOR];

        _uintConfigs[28] = uintConfigs[CONFIG_SPECIAL_QUOTA_DENOMINATOR];

        _uintConfigs[29] = uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_NUMERATOR];

        _uintConfigs[30] = uintConfigs[CONFIG_SPECIAL_PROPOSAL_QUORUM_DENOMINATOR];

        _uintConfigs[31] = uintConfigs[CONFIG_MAXIMUM_REPUTATION_DEDUCTION];

        _uintConfigs[32] = uintConfigs[CONFIG_PUNISHMENT_FOR_NOT_LOCKING];

        _uintConfigs[33] = uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_NUM];

        _uintConfigs[34] = uintConfigs[CONFIG_REPUTATION_PER_EXTRA_QP_DEN];

        _uintConfigs[35] = uintConfigs[CONFIG_QUARTER_POINT_SCALING_FACTOR];

        _uintConfigs[36] = uintConfigs[CONFIG_REPUTATION_POINT_SCALING_FACTOR];

        _uintConfigs[37] = uintConfigs[CONFIG_MODERATOR_MINIMAL_QUARTER_POINT];

        _uintConfigs[38] = uintConfigs[CONFIG_MODERATOR_QUARTER_POINT_SCALING_FACTOR];

        _uintConfigs[39] = uintConfigs[CONFIG_MODERATOR_REPUTATION_POINT_SCALING_FACTOR];

        _uintConfigs[40] = uintConfigs[CONFIG_PORTION_TO_MODERATORS_NUM];

        _uintConfigs[41] = uintConfigs[CONFIG_PORTION_TO_MODERATORS_DEN];

        _uintConfigs[42] = uintConfigs[CONFIG_DRAFT_VOTING_PHASE];

        _uintConfigs[43] = uintConfigs[CONFIG_REPUTATION_POINT_BOOST_FOR_BADGE];

        _uintConfigs[44] = uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_NUMERATOR];

        _uintConfigs[45] = uintConfigs[CONFIG_FINAL_REWARD_SCALING_FACTOR_DENOMINATOR];

        _uintConfigs[46] = uintConfigs[CONFIG_MAXIMUM_MODERATOR_REPUTATION_DEDUCTION];

        _uintConfigs[47] = uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_NUM];

        _uintConfigs[48] = uintConfigs[CONFIG_REPUTATION_PER_EXTRA_MODERATOR_QP_DEN];

        _uintConfigs[49] = uintConfigs[CONFIG_VOTE_CLAIMING_DEADLINE];

        _uintConfigs[50] = uintConfigs[CONFIG_MINIMUM_LOCKED_DGD];

        _uintConfigs[51] = uintConfigs[CONFIG_MINIMUM_DGD_FOR_MODERATOR];

        _uintConfigs[52] = uintConfigs[CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR];

        _uintConfigs[53] = uintConfigs[CONFIG_PREPROPOSAL_COLLATERAL];

        _uintConfigs[54] = uintConfigs[CONFIG_MAX_FUNDING_FOR_NON_DIGIX];

        _uintConfigs[55] = uintConfigs[CONFIG_MAX_MILESTONES_FOR_NON_DIGIX];

        _uintConfigs[56] = uintConfigs[CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER];

        _uintConfigs[57] = uintConfigs[CONFIG_PROPOSAL_DEAD_DURATION];

        _uintConfigs[58] = uintConfigs[CONFIG_CARBON_VOTE_REPUTATION_BONUS];

        return _uintConfigs;

    }

}



// File: contracts/storage/DaoProposalCounterStorage.sol

contract DaoProposalCounterStorage is ResolverClient, DaoConstants {



    constructor(address _resolver) public {

        require(init(CONTRACT_STORAGE_DAO_COUNTER, _resolver));

    }



    // This is to mark the number of proposals that have been funded in a specific quarter

    // this is to take care of the cap on the number of funded proposals in a quarter

    mapping (uint256 => uint256) public proposalCountByQuarter;



    function addNonDigixProposalCountInQuarter(uint256 _quarterNumber)

        public

    {

        require(sender_is(CONTRACT_DAO_VOTING_CLAIMS));

        proposalCountByQuarter[_quarterNumber] = proposalCountByQuarter[_quarterNumber].add(1);

    }

}



// File: contracts/storage/DaoUpgradeStorage.sol

contract DaoUpgradeStorage is ResolverClient, DaoConstants {



    // this UTC timestamp marks the start of the first quarter

    // of DigixDAO. All time related calculations in DaoCommon

    // depend on this value

    uint256 public startOfFirstQuarter;



    // this boolean marks whether the DAO contracts have been replaced

    // by newer versions or not. The process of migration is done by deploying

    // a new set of contracts, transferring funds from these contracts to the new ones

    // migrating some state variables, and finally setting this boolean to true

    // All operations in these contracts that may transfer tokens, claim ether,

    // boost one's reputation, etc. SHOULD fail if this is true

    bool public isReplacedByNewDao;



    // this is the address of the new Dao contract

    address public newDaoContract;



    // this is the address of the new DaoFundingManager contract

    // ether funds will be moved from the current version's contract to this

    // new contract

    address public newDaoFundingManager;



    // this is the address of the new DaoRewardsManager contract

    // DGX funds will be moved from the current version of contract to this

    // new contract

    address public newDaoRewardsManager;



    constructor(address _resolver) public {

        require(init(CONTRACT_STORAGE_DAO_UPGRADE, _resolver));

    }



    function setStartOfFirstQuarter(uint256 _start)

        public

    {

        require(sender_is(CONTRACT_DAO));

        startOfFirstQuarter = _start;

    }





    function setNewContractAddresses(

        address _newDaoContract,

        address _newDaoFundingManager,

        address _newDaoRewardsManager

    )

        public

    {

        require(sender_is(CONTRACT_DAO));

        newDaoContract = _newDaoContract;

        newDaoFundingManager = _newDaoFundingManager;

        newDaoRewardsManager = _newDaoRewardsManager;

    }





    function updateForDaoMigration()

        public

    {

        require(sender_is(CONTRACT_DAO));

        isReplacedByNewDao = true;

    }

}



// File: contracts/storage/DaoSpecialStorage.sol

contract DaoSpecialStorage is DaoWhitelistingCommon {

    using DoublyLinkedList for DoublyLinkedList.Bytes;

    using DaoStructs for DaoStructs.SpecialProposal;

    using DaoStructs for DaoStructs.Voting;



    // List of all the special proposals ever created in DigixDAO

    DoublyLinkedList.Bytes proposals;



    // mapping of the SpecialProposal struct by its ID

    // ID is also the IPFS doc hash of the proposal

    mapping (bytes32 => DaoStructs.SpecialProposal) proposalsById;



    constructor(address _resolver) public {

        require(init(CONTRACT_STORAGE_DAO_SPECIAL, _resolver));

    }



    function addSpecialProposal(

        bytes32 _proposalId,

        address _proposer,

        uint256[] _uintConfigs,

        address[] _addressConfigs,

        bytes32[] _bytesConfigs

    )

        public

    {

        require(sender_is(CONTRACT_DAO_SPECIAL_PROPOSAL));

        require(

          (proposalsById[_proposalId].proposalId == EMPTY_BYTES) &&

          (_proposalId != EMPTY_BYTES)

        );

        proposals.append(_proposalId);

        proposalsById[_proposalId].proposalId = _proposalId;

        proposalsById[_proposalId].proposer = _proposer;

        proposalsById[_proposalId].timeCreated = now;

        proposalsById[_proposalId].uintConfigs = _uintConfigs;

        proposalsById[_proposalId].addressConfigs = _addressConfigs;

        proposalsById[_proposalId].bytesConfigs = _bytesConfigs;

    }



    function readProposal(bytes32 _proposalId)

        public

        view

        returns (

            bytes32 _id,

            address _proposer,

            uint256 _timeCreated,

            uint256 _timeVotingStarted

        )

    {

        _id = proposalsById[_proposalId].proposalId;

        _proposer = proposalsById[_proposalId].proposer;

        _timeCreated = proposalsById[_proposalId].timeCreated;

        _timeVotingStarted = proposalsById[_proposalId].voting.startTime;

    }



    function readProposalProposer(bytes32 _proposalId)

        public

        view

        returns (address _proposer)

    {

        _proposer = proposalsById[_proposalId].proposer;

    }



    function readConfigs(bytes32 _proposalId)

        public

        view

        returns (

            uint256[] memory _uintConfigs,

            address[] memory _addressConfigs,

            bytes32[] memory _bytesConfigs

        )

    {

        _uintConfigs = proposalsById[_proposalId].uintConfigs;

        _addressConfigs = proposalsById[_proposalId].addressConfigs;

        _bytesConfigs = proposalsById[_proposalId].bytesConfigs;

    }



    function readVotingCount(bytes32 _proposalId, address[] _allUsers)

        external

        view

        returns (uint256 _for, uint256 _against)

    {

        require(senderIsAllowedToRead());

        return proposalsById[_proposalId].voting.countVotes(_allUsers);

    }



    function readVotingTime(bytes32 _proposalId)

        public

        view

        returns (uint256 _start)

    {

        require(senderIsAllowedToRead());

        _start = proposalsById[_proposalId].voting.startTime;

    }



    function commitVote(

        bytes32 _proposalId,

        bytes32 _hash,

        address _voter

    )

        public

    {

        require(sender_is(CONTRACT_DAO_VOTING));

        proposalsById[_proposalId].voting.commits[_voter] = _hash;

    }



    function readComittedVote(bytes32 _proposalId, address _voter)

        public

        view

        returns (bytes32 _commitHash)

    {

        require(senderIsAllowedToRead());

        _commitHash = proposalsById[_proposalId].voting.commits[_voter];

    }



    function setVotingTime(bytes32 _proposalId, uint256 _time)

        public

    {

        require(sender_is(CONTRACT_DAO_SPECIAL_PROPOSAL));

        proposalsById[_proposalId].voting.startTime = _time;

    }



    function readVotingResult(bytes32 _proposalId)

        public

        view

        returns (bool _result)

    {

        require(senderIsAllowedToRead());

        _result = proposalsById[_proposalId].voting.passed;

    }



    function setPass(bytes32 _proposalId, bool _result)

        public

    {

        require(sender_is(CONTRACT_DAO_SPECIAL_VOTING_CLAIMS));

        proposalsById[_proposalId].voting.passed = _result;

    }



    function setVotingClaim(bytes32 _proposalId, bool _claimed)

        public

    {

        require(sender_is(CONTRACT_DAO_SPECIAL_VOTING_CLAIMS));

        DaoStructs.SpecialProposal storage _proposal = proposalsById[_proposalId];

        _proposal.voting.claimed = _claimed;

    }



    function isClaimed(bytes32 _proposalId)

        public

        view

        returns (bool _claimed)

    {

        require(senderIsAllowedToRead());

        _claimed = proposalsById[_proposalId].voting.claimed;

    }



    function readVote(bytes32 _proposalId, address _voter)

        public

        view

        returns (bool _vote, uint256 _weight)

    {

        require(senderIsAllowedToRead());

        return proposalsById[_proposalId].voting.readVote(_voter);

    }



    function revealVote(

        bytes32 _proposalId,

        address _voter,

        bool _vote,

        uint256 _weight

    )

        public

    {

        require(sender_is(CONTRACT_DAO_VOTING));

        proposalsById[_proposalId].voting.revealVote(_voter, _vote, _weight);

    }

}



// File: contracts/storage/DaoPointsStorage.sol

contract DaoPointsStorage is ResolverClient, DaoConstants {



    // struct for a non-transferrable token

    struct Token {

        uint256 totalSupply;

        mapping (address => uint256) balance;

    }



    // the reputation point token

    // since reputation is cumulative, we only need to store one value

    Token reputationPoint;



    // since quarter points are specific to quarters, we need a mapping from

    // quarter number to the quarter point token for that quarter

    mapping (uint256 => Token) quarterPoint;



    // the same is the case with quarter moderator points

    // these are specific to quarters

    mapping (uint256 => Token) quarterModeratorPoint;



    constructor(address _resolver)

        public

    {

        require(init(CONTRACT_STORAGE_DAO_POINTS, _resolver));

    }



    /// @notice add quarter points for a _participant for a _quarterNumber

    function addQuarterPoint(address _participant, uint256 _point, uint256 _quarterNumber)

        public

        returns (uint256 _newPoint, uint256 _newTotalPoint)

    {

        require(sender_is_from([CONTRACT_DAO_VOTING, CONTRACT_DAO_VOTING_CLAIMS, EMPTY_BYTES]));

        quarterPoint[_quarterNumber].totalSupply = quarterPoint[_quarterNumber].totalSupply.add(_point);

        quarterPoint[_quarterNumber].balance[_participant] = quarterPoint[_quarterNumber].balance[_participant].add(_point);



        _newPoint = quarterPoint[_quarterNumber].balance[_participant];

        _newTotalPoint = quarterPoint[_quarterNumber].totalSupply;

    }



    function addModeratorQuarterPoint(address _participant, uint256 _point, uint256 _quarterNumber)

        public

        returns (uint256 _newPoint, uint256 _newTotalPoint)

    {

        require(sender_is_from([CONTRACT_DAO_VOTING, CONTRACT_DAO_VOTING_CLAIMS, EMPTY_BYTES]));

        quarterModeratorPoint[_quarterNumber].totalSupply = quarterModeratorPoint[_quarterNumber].totalSupply.add(_point);

        quarterModeratorPoint[_quarterNumber].balance[_participant] = quarterModeratorPoint[_quarterNumber].balance[_participant].add(_point);



        _newPoint = quarterModeratorPoint[_quarterNumber].balance[_participant];

        _newTotalPoint = quarterModeratorPoint[_quarterNumber].totalSupply;

    }



    /// @notice get quarter points for a _participant in a _quarterNumber

    function getQuarterPoint(address _participant, uint256 _quarterNumber)

        public

        view

        returns (uint256 _point)

    {

        _point = quarterPoint[_quarterNumber].balance[_participant];

    }



    function getQuarterModeratorPoint(address _participant, uint256 _quarterNumber)

        public

        view

        returns (uint256 _point)

    {

        _point = quarterModeratorPoint[_quarterNumber].balance[_participant];

    }



    /// @notice get total quarter points for a particular _quarterNumber

    function getTotalQuarterPoint(uint256 _quarterNumber)

        public

        view

        returns (uint256 _totalPoint)

    {

        _totalPoint = quarterPoint[_quarterNumber].totalSupply;

    }



    function getTotalQuarterModeratorPoint(uint256 _quarterNumber)

        public

        view

        returns (uint256 _totalPoint)

    {

        _totalPoint = quarterModeratorPoint[_quarterNumber].totalSupply;

    }



    /// @notice add reputation points for a _participant

    function increaseReputation(address _participant, uint256 _point)

        public

        returns (uint256 _newPoint, uint256 _totalPoint)

    {

        require(sender_is_from([CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_STAKE_LOCKING]));

        reputationPoint.totalSupply = reputationPoint.totalSupply.add(_point);

        reputationPoint.balance[_participant] = reputationPoint.balance[_participant].add(_point);



        _newPoint = reputationPoint.balance[_participant];

        _totalPoint = reputationPoint.totalSupply;

    }



    /// @notice subtract reputation points for a _participant

    function reduceReputation(address _participant, uint256 _point)

        public

        returns (uint256 _newPoint, uint256 _totalPoint)

    {

        require(sender_is_from([CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_REWARDS_MANAGER, EMPTY_BYTES]));

        uint256 _toDeduct = _point;

        if (reputationPoint.balance[_participant] > _point) {

            reputationPoint.balance[_participant] = reputationPoint.balance[_participant].sub(_point);

        } else {

            _toDeduct = reputationPoint.balance[_participant];

            reputationPoint.balance[_participant] = 0;

        }



        reputationPoint.totalSupply = reputationPoint.totalSupply.sub(_toDeduct);



        _newPoint = reputationPoint.balance[_participant];

        _totalPoint = reputationPoint.totalSupply;

    }



  /// @notice get reputation points for a _participant

  function getReputation(address _participant)

      public

      view

      returns (uint256 _point)

  {

      _point = reputationPoint.balance[_participant];

  }



  /// @notice get total reputation points distributed in the dao

  function getTotalReputation()

      public

      view

      returns (uint256 _totalPoint)

  {

      _totalPoint = reputationPoint.totalSupply;

  }

}



// File: contracts/storage/DaoRewardsStorage.sol

// this contract will receive DGXs fees from the DGX fees distributors

contract DaoRewardsStorage is ResolverClient, DaoConstants {

    using DaoStructs for DaoStructs.DaoQuarterInfo;



    // DaoQuarterInfo is a struct that stores the quarter specific information

    // regarding totalEffectiveDGDs, DGX distribution day, etc. pls check

    // docs in lib/DaoStructs

    mapping(uint256 => DaoStructs.DaoQuarterInfo) public allQuartersInfo;



    // Mapping that stores the DGX that can be claimed as rewards by

    // an address (a participant of DigixDAO)

    mapping(address => uint256) public claimableDGXs;



    // This stores the total DGX value that has been claimed by participants

    // this can be done by calling the DaoRewardsManager.claimRewards method

    // Note that this value is the only outgoing DGX from DaoRewardsManager contract

    // Note that this value also takes into account the demurrage that has been paid

    // by participants for simply holding their DGXs in the DaoRewardsManager contract

    uint256 public totalDGXsClaimed;



    // The Quarter ID in which the user last participated in

    // To participate means they had locked more than CONFIG_MINIMUM_LOCKED_DGD

    // DGD tokens. In addition, they should not have withdrawn those tokens in the same

    // quarter. Basically, in the main phase of the quarter, if DaoCommon.isParticipant(_user)

    // was true, they were participants. And that quarter was their lastParticipatedQuarter

    mapping (address => uint256) public lastParticipatedQuarter;



    // This mapping is only used to update the lastParticipatedQuarter to the

    // previousLastParticipatedQuarter in case users lock and withdraw DGDs

    // within the same quarter's locking phase

    mapping (address => uint256) public previousLastParticipatedQuarter;



    // This number marks the Quarter in which the rewards were last updated for that user

    // Since the rewards calculation for a specific quarter is only done once that

    // quarter is completed, we need this value to note the last quarter when the rewards were updated

    // We then start adding the rewards for all quarters after that quarter, until the current quarter

    mapping (address => uint256) public lastQuarterThatRewardsWasUpdated;



    // Similar as the lastQuarterThatRewardsWasUpdated, but this is for reputation updates

    // Note that reputation can also be deducted for no participation (not locking DGDs)

    // This value is used to update the reputation based on all quarters from the lastQuarterThatReputationWasUpdated

    // to the current quarter

    mapping (address => uint256) public lastQuarterThatReputationWasUpdated;



    constructor(address _resolver)

           public

    {

        require(init(CONTRACT_STORAGE_DAO_REWARDS, _resolver));

    }



    function updateQuarterInfo(

        uint256 _quarterNumber,

        uint256 _minimalParticipationPoint,

        uint256 _quarterPointScalingFactor,

        uint256 _reputationPointScalingFactor,

        uint256 _totalEffectiveDGDPreviousQuarter,



        uint256 _moderatorMinimalQuarterPoint,

        uint256 _moderatorQuarterPointScalingFactor,

        uint256 _moderatorReputationPointScalingFactor,

        uint256 _totalEffectiveModeratorDGDLastQuarter,



        uint256 _dgxDistributionDay,

        uint256 _dgxRewardsPoolLastQuarter,

        uint256 _sumRewardsFromBeginning

    )

        public

    {

        require(sender_is(CONTRACT_DAO_REWARDS_MANAGER));

        allQuartersInfo[_quarterNumber].minimalParticipationPoint = _minimalParticipationPoint;

        allQuartersInfo[_quarterNumber].quarterPointScalingFactor = _quarterPointScalingFactor;

        allQuartersInfo[_quarterNumber].reputationPointScalingFactor = _reputationPointScalingFactor;

        allQuartersInfo[_quarterNumber].totalEffectiveDGDPreviousQuarter = _totalEffectiveDGDPreviousQuarter;



        allQuartersInfo[_quarterNumber].moderatorMinimalParticipationPoint = _moderatorMinimalQuarterPoint;

        allQuartersInfo[_quarterNumber].moderatorQuarterPointScalingFactor = _moderatorQuarterPointScalingFactor;

        allQuartersInfo[_quarterNumber].moderatorReputationPointScalingFactor = _moderatorReputationPointScalingFactor;

        allQuartersInfo[_quarterNumber].totalEffectiveModeratorDGDLastQuarter = _totalEffectiveModeratorDGDLastQuarter;



        allQuartersInfo[_quarterNumber].dgxDistributionDay = _dgxDistributionDay;

        allQuartersInfo[_quarterNumber].dgxRewardsPoolLastQuarter = _dgxRewardsPoolLastQuarter;

        allQuartersInfo[_quarterNumber].sumRewardsFromBeginning = _sumRewardsFromBeginning;

    }



    function updateClaimableDGX(address _user, uint256 _newClaimableDGX)

        public

    {

        require(sender_is(CONTRACT_DAO_REWARDS_MANAGER));

        claimableDGXs[_user] = _newClaimableDGX;

    }



    function updateLastParticipatedQuarter(address _user, uint256 _lastQuarter)

        public

    {

        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));

        lastParticipatedQuarter[_user] = _lastQuarter;

    }



    function updatePreviousLastParticipatedQuarter(address _user, uint256 _lastQuarter)

        public

    {

        require(sender_is(CONTRACT_DAO_STAKE_LOCKING));

        previousLastParticipatedQuarter[_user] = _lastQuarter;

    }



    function updateLastQuarterThatRewardsWasUpdated(address _user, uint256 _lastQuarter)

        public

    {

        require(sender_is_from([CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_STAKE_LOCKING, EMPTY_BYTES]));

        lastQuarterThatRewardsWasUpdated[_user] = _lastQuarter;

    }



    function updateLastQuarterThatReputationWasUpdated(address _user, uint256 _lastQuarter)

        public

    {

        require(sender_is_from([CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_STAKE_LOCKING, EMPTY_BYTES]));

        lastQuarterThatReputationWasUpdated[_user] = _lastQuarter;

    }



    function addToTotalDgxClaimed(uint256 _dgxClaimed)

        public

    {

        require(sender_is(CONTRACT_DAO_REWARDS_MANAGER));

        totalDGXsClaimed = totalDGXsClaimed.add(_dgxClaimed);

    }



    function readQuarterInfo(uint256 _quarterNumber)

        public

        view

        returns (

            uint256 _minimalParticipationPoint,

            uint256 _quarterPointScalingFactor,

            uint256 _reputationPointScalingFactor,

            uint256 _totalEffectiveDGDPreviousQuarter,



            uint256 _moderatorMinimalQuarterPoint,

            uint256 _moderatorQuarterPointScalingFactor,

            uint256 _moderatorReputationPointScalingFactor,

            uint256 _totalEffectiveModeratorDGDLastQuarter,



            uint256 _dgxDistributionDay,

            uint256 _dgxRewardsPoolLastQuarter,

            uint256 _sumRewardsFromBeginning

        )

    {

        _minimalParticipationPoint = allQuartersInfo[_quarterNumber].minimalParticipationPoint;

        _quarterPointScalingFactor = allQuartersInfo[_quarterNumber].quarterPointScalingFactor;

        _reputationPointScalingFactor = allQuartersInfo[_quarterNumber].reputationPointScalingFactor;

        _totalEffectiveDGDPreviousQuarter = allQuartersInfo[_quarterNumber].totalEffectiveDGDPreviousQuarter;

        _moderatorMinimalQuarterPoint = allQuartersInfo[_quarterNumber].moderatorMinimalParticipationPoint;

        _moderatorQuarterPointScalingFactor = allQuartersInfo[_quarterNumber].moderatorQuarterPointScalingFactor;

        _moderatorReputationPointScalingFactor = allQuartersInfo[_quarterNumber].moderatorReputationPointScalingFactor;

        _totalEffectiveModeratorDGDLastQuarter = allQuartersInfo[_quarterNumber].totalEffectiveModeratorDGDLastQuarter;

        _dgxDistributionDay = allQuartersInfo[_quarterNumber].dgxDistributionDay;

        _dgxRewardsPoolLastQuarter = allQuartersInfo[_quarterNumber].dgxRewardsPoolLastQuarter;

        _sumRewardsFromBeginning = allQuartersInfo[_quarterNumber].sumRewardsFromBeginning;

    }



    function readQuarterGeneralInfo(uint256 _quarterNumber)

        public

        view

        returns (

            uint256 _dgxDistributionDay,

            uint256 _dgxRewardsPoolLastQuarter,

            uint256 _sumRewardsFromBeginning

        )

    {

        _dgxDistributionDay = allQuartersInfo[_quarterNumber].dgxDistributionDay;

        _dgxRewardsPoolLastQuarter = allQuartersInfo[_quarterNumber].dgxRewardsPoolLastQuarter;

        _sumRewardsFromBeginning = allQuartersInfo[_quarterNumber].sumRewardsFromBeginning;

    }



    function readQuarterModeratorInfo(uint256 _quarterNumber)

        public

        view

        returns (

            uint256 _moderatorMinimalQuarterPoint,

            uint256 _moderatorQuarterPointScalingFactor,

            uint256 _moderatorReputationPointScalingFactor,

            uint256 _totalEffectiveModeratorDGDLastQuarter

        )

    {

        _moderatorMinimalQuarterPoint = allQuartersInfo[_quarterNumber].moderatorMinimalParticipationPoint;

        _moderatorQuarterPointScalingFactor = allQuartersInfo[_quarterNumber].moderatorQuarterPointScalingFactor;

        _moderatorReputationPointScalingFactor = allQuartersInfo[_quarterNumber].moderatorReputationPointScalingFactor;

        _totalEffectiveModeratorDGDLastQuarter = allQuartersInfo[_quarterNumber].totalEffectiveModeratorDGDLastQuarter;

    }



    function readQuarterParticipantInfo(uint256 _quarterNumber)

        public

        view

        returns (

            uint256 _minimalParticipationPoint,

            uint256 _quarterPointScalingFactor,

            uint256 _reputationPointScalingFactor,

            uint256 _totalEffectiveDGDPreviousQuarter

        )

    {

        _minimalParticipationPoint = allQuartersInfo[_quarterNumber].minimalParticipationPoint;

        _quarterPointScalingFactor = allQuartersInfo[_quarterNumber].quarterPointScalingFactor;

        _reputationPointScalingFactor = allQuartersInfo[_quarterNumber].reputationPointScalingFactor;

        _totalEffectiveDGDPreviousQuarter = allQuartersInfo[_quarterNumber].totalEffectiveDGDPreviousQuarter;

    }



    function readDgxDistributionDay(uint256 _quarterNumber)

        public

        view

        returns (uint256 _distributionDay)

    {

        _distributionDay = allQuartersInfo[_quarterNumber].dgxDistributionDay;

    }



    function readTotalEffectiveDGDLastQuarter(uint256 _quarterNumber)

        public

        view

        returns (uint256 _totalEffectiveDGDPreviousQuarter)

    {

        _totalEffectiveDGDPreviousQuarter = allQuartersInfo[_quarterNumber].totalEffectiveDGDPreviousQuarter;

    }



    function readTotalEffectiveModeratorDGDLastQuarter(uint256 _quarterNumber)

        public

        view

        returns (uint256 _totalEffectiveModeratorDGDLastQuarter)

    {

        _totalEffectiveModeratorDGDLastQuarter = allQuartersInfo[_quarterNumber].totalEffectiveModeratorDGDLastQuarter;

    }



    function readRewardsPoolOfLastQuarter(uint256 _quarterNumber)

        public

        view

        returns (uint256 _rewardsPool)

    {

        _rewardsPool = allQuartersInfo[_quarterNumber].dgxRewardsPoolLastQuarter;

    }

}



// File: contracts/storage/IntermediateResultsStorage.sol

contract IntermediateResultsStorage is ResolverClient, DaoConstants {

    using DaoStructs for DaoStructs.IntermediateResults;



    constructor(address _resolver) public {

        require(init(CONTRACT_STORAGE_INTERMEDIATE_RESULTS, _resolver));

    }



    // There are scenarios in which we must loop across all participants/moderators

    // in a function call. For a big number of operations, the function call may be short of gas

    // To tackle this, we use an IntermediateResults struct to store the intermediate results

    // The same function is then called multiple times until all operations are completed

    // If the operations cannot be done in that iteration, the intermediate results are stored

    // else, the final outcome is returned

    // Please check the lib/DaoStructs for docs on this struct

    mapping (bytes32 => DaoStructs.IntermediateResults) allIntermediateResults;



    function getIntermediateResults(bytes32 _key)

        public

        view

        returns (

            address _countedUntil,

            uint256 _currentForCount,

            uint256 _currentAgainstCount,

            uint256 _currentSumOfEffectiveBalance

        )

    {

        _countedUntil = allIntermediateResults[_key].countedUntil;

        _currentForCount = allIntermediateResults[_key].currentForCount;

        _currentAgainstCount = allIntermediateResults[_key].currentAgainstCount;

        _currentSumOfEffectiveBalance = allIntermediateResults[_key].currentSumOfEffectiveBalance;

    }



    function resetIntermediateResults(bytes32 _key)

        public

    {

        require(sender_is_from([CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_SPECIAL_VOTING_CLAIMS]));

        allIntermediateResults[_key].countedUntil = address(0x0);

    }



    function setIntermediateResults(

        bytes32 _key,

        address _countedUntil,

        uint256 _currentForCount,

        uint256 _currentAgainstCount,

        uint256 _currentSumOfEffectiveBalance

    )

        public

    {

        require(sender_is_from([CONTRACT_DAO_REWARDS_MANAGER, CONTRACT_DAO_VOTING_CLAIMS, CONTRACT_DAO_SPECIAL_VOTING_CLAIMS]));

        allIntermediateResults[_key].countedUntil = _countedUntil;

        allIntermediateResults[_key].currentForCount = _currentForCount;

        allIntermediateResults[_key].currentAgainstCount = _currentAgainstCount;

        allIntermediateResults[_key].currentSumOfEffectiveBalance = _currentSumOfEffectiveBalance;

    }

}



// File: contracts/lib/MathHelper.sol

library MathHelper {



  using SafeMath for uint256;



  function max(uint256 a, uint256 b) internal pure returns (uint256 _max){

      _max = b;

      if (a > b) {

          _max = a;

      }

  }



  function min(uint256 a, uint256 b) internal pure returns (uint256 _min){

      _min = b;

      if (a < b) {

          _min = a;

      }

  }



  function sumNumbers(uint256[] _numbers) internal pure returns (uint256 _sum) {

      for (uint256 i=0;i<_numbers.length;i++) {

          _sum = _sum.add(_numbers[i]);

      }

  }

}



// File: contracts/common/DaoCommonMini.sol

contract DaoCommonMini is IdentityCommon {



    using MathHelper for MathHelper;



    /**

    @notice Check if the DAO contracts have been replaced by a new set of contracts

    @return _isNotReplaced true if it is not replaced, false if it has already been replaced

    */

    function isDaoNotReplaced()

        public

        view

        returns (bool _isNotReplaced)

    {

        _isNotReplaced = !daoUpgradeStorage().isReplacedByNewDao();

    }



    /**

    @notice Check if it is currently in the locking phase

    @dev No governance activities can happen in the locking phase. The locking phase is from t=0 to t=CONFIG_LOCKING_PHASE_DURATION-1

    @return _isLockingPhase true if it is in the locking phase

    */

    function isLockingPhase()

        public

        view

        returns (bool _isLockingPhase)

    {

        _isLockingPhase = currentTimeInQuarter() < getUintConfig(CONFIG_LOCKING_PHASE_DURATION);

    }



    /**

    @notice Check if it is currently in a main phase.

    @dev The main phase is where all the governance activities could take plase. If the DAO is replaced, there can never be any more main phase.

    @return _isMainPhase true if it is in a main phase

    */

    function isMainPhase()

        public

        view

        returns (bool _isMainPhase)

    {

        _isMainPhase =

            isDaoNotReplaced() &&

            currentTimeInQuarter() >= getUintConfig(CONFIG_LOCKING_PHASE_DURATION);

    }



    /**

    @notice Check if the calculateGlobalRewardsBeforeNewQuarter function has been done for a certain quarter

    @dev However, there is no need to run calculateGlobalRewardsBeforeNewQuarter for the first quarter

    */

    modifier ifGlobalRewardsSet(uint256 _quarterNumber) {

        if (_quarterNumber > 1) {

            require(daoRewardsStorage().readDgxDistributionDay(_quarterNumber) > 0);

        }

        _;

    }



    /**

    @notice require that it is currently during a phase, which is within _relativePhaseStart and _relativePhaseEnd seconds, after the _startingPoint

    */

    function requireInPhase(uint256 _startingPoint, uint256 _relativePhaseStart, uint256 _relativePhaseEnd)

        internal

        view

    {

        require(_startingPoint > 0);

        require(now < _startingPoint.add(_relativePhaseEnd));

        require(now >= _startingPoint.add(_relativePhaseStart));

    }



    /**

    @notice Get the current quarter index

    @dev Quarter indexes starts from 1

    @return _quarterNumber the current quarter index

    */

    function currentQuarterNumber()

        public

        view

        returns(uint256 _quarterNumber)

    {

        _quarterNumber = getQuarterNumber(now);

    }



    /**

    @notice Get the quarter index of a timestamp

    @dev Quarter indexes starts from 1

    @return _index the quarter index

    */

    function getQuarterNumber(uint256 _time)

        internal

        view

        returns (uint256 _index)

    {

        require(startOfFirstQuarterIsSet());

        _index =

            _time.sub(daoUpgradeStorage().startOfFirstQuarter())

            .div(getUintConfig(CONFIG_QUARTER_DURATION))

            .add(1);

    }



    /**

    @notice Get the relative time in quarter of a timestamp

    @dev For example, the timeInQuarter of the first second of any quarter n-th is always 1

    */

    function timeInQuarter(uint256 _time)

        internal

        view

        returns (uint256 _timeInQuarter)

    {

        require(startOfFirstQuarterIsSet()); // must be already set

        _timeInQuarter =

            _time.sub(daoUpgradeStorage().startOfFirstQuarter())

            % getUintConfig(CONFIG_QUARTER_DURATION);

    }



    /**

    @notice Check if the start of first quarter is already set

    @return _isSet true if start of first quarter is already set

    */

    function startOfFirstQuarterIsSet()

        internal

        view

        returns (bool _isSet)

    {

        _isSet = daoUpgradeStorage().startOfFirstQuarter() != 0;

    }



    /**

    @notice Get the current relative time in the quarter

    @dev For example: the currentTimeInQuarter of the first second of any quarter is 1

    @return _currentT the current relative time in the quarter

    */

    function currentTimeInQuarter()

        public

        view

        returns (uint256 _currentT)

    {

        _currentT = timeInQuarter(now);

    }



    /**

    @notice Get the time remaining in the quarter

    */

    function getTimeLeftInQuarter(uint256 _time)

        internal

        view

        returns (uint256 _timeLeftInQuarter)

    {

        _timeLeftInQuarter = getUintConfig(CONFIG_QUARTER_DURATION).sub(timeInQuarter(_time));

    }



    function daoListingService()

        internal

        view

        returns (DaoListingService _contract)

    {

        _contract = DaoListingService(get_contract(CONTRACT_SERVICE_DAO_LISTING));

    }



    function daoConfigsStorage()

        internal

        view

        returns (DaoConfigsStorage _contract)

    {

        _contract = DaoConfigsStorage(get_contract(CONTRACT_STORAGE_DAO_CONFIG));

    }



    function daoStakeStorage()

        internal

        view

        returns (DaoStakeStorage _contract)

    {

        _contract = DaoStakeStorage(get_contract(CONTRACT_STORAGE_DAO_STAKE));

    }



    function daoStorage()

        internal

        view

        returns (DaoStorage _contract)

    {

        _contract = DaoStorage(get_contract(CONTRACT_STORAGE_DAO));

    }



    function daoProposalCounterStorage()

        internal

        view

        returns (DaoProposalCounterStorage _contract)

    {

        _contract = DaoProposalCounterStorage(get_contract(CONTRACT_STORAGE_DAO_COUNTER));

    }



    function daoUpgradeStorage()

        internal

        view

        returns (DaoUpgradeStorage _contract)

    {

        _contract = DaoUpgradeStorage(get_contract(CONTRACT_STORAGE_DAO_UPGRADE));

    }



    function daoSpecialStorage()

        internal

        view

        returns (DaoSpecialStorage _contract)

    {

        _contract = DaoSpecialStorage(get_contract(CONTRACT_STORAGE_DAO_SPECIAL));

    }



    function daoPointsStorage()

        internal

        view

        returns (DaoPointsStorage _contract)

    {

        _contract = DaoPointsStorage(get_contract(CONTRACT_STORAGE_DAO_POINTS));

    }



    function daoRewardsStorage()

        internal

        view

        returns (DaoRewardsStorage _contract)

    {

        _contract = DaoRewardsStorage(get_contract(CONTRACT_STORAGE_DAO_REWARDS));

    }



    function intermediateResultsStorage()

        internal

        view

        returns (IntermediateResultsStorage _contract)

    {

        _contract = IntermediateResultsStorage(get_contract(CONTRACT_STORAGE_INTERMEDIATE_RESULTS));

    }



    function getUintConfig(bytes32 _configKey)

        public

        view

        returns (uint256 _configValue)

    {

        _configValue = daoConfigsStorage().uintConfigs(_configKey);

    }

}



// File: contracts/common/DaoCommon.sol

contract DaoCommon is DaoCommonMini {



    using MathHelper for MathHelper;



    /**

    @notice Check if the transaction is called by the proposer of a proposal

    @return _isFromProposer true if the caller is the proposer

    */

    function isFromProposer(bytes32 _proposalId)

        internal

        view

        returns (bool _isFromProposer)

    {

        _isFromProposer = msg.sender == daoStorage().readProposalProposer(_proposalId);

    }



    /**

    @notice Check if the proposal can still be "editted", or in other words, added more versions

    @dev Once the proposal is finalized, it can no longer be editted. The proposer will still be able to add docs and change fundings though.

    @return _isEditable true if the proposal is editable

    */

    function isEditable(bytes32 _proposalId)

        internal

        view

        returns (bool _isEditable)

    {

        bytes32 _finalVersion;

        (,,,,,,,_finalVersion,,) = daoStorage().readProposal(_proposalId);

        _isEditable = _finalVersion == EMPTY_BYTES;

    }



    /**

    @notice returns the balance of DaoFundingManager, which is the wei in DigixDAO

    */

    function weiInDao()

        internal

        view

        returns (uint256 _wei)

    {

        _wei = get_contract(CONTRACT_DAO_FUNDING_MANAGER).balance;

    }



    /**

    @notice Check if it is after the draft voting phase of the proposal

    */

    modifier ifAfterDraftVotingPhase(bytes32 _proposalId) {

        uint256 _start = daoStorage().readProposalDraftVotingTime(_proposalId);

        require(_start > 0); // Draft voting must have started. In other words, proposer must have finalized the proposal

        require(now >= _start.add(getUintConfig(CONFIG_DRAFT_VOTING_PHASE)));

        _;

    }



    modifier ifCommitPhase(bytes32 _proposalId, uint8 _index) {

        requireInPhase(

            daoStorage().readProposalVotingTime(_proposalId, _index),

            0,

            getUintConfig(_index == 0 ? CONFIG_VOTING_COMMIT_PHASE : CONFIG_INTERIM_COMMIT_PHASE)

        );

        _;

    }



    modifier ifRevealPhase(bytes32 _proposalId, uint256 _index) {

      requireInPhase(

          daoStorage().readProposalVotingTime(_proposalId, _index),

          getUintConfig(_index == 0 ? CONFIG_VOTING_COMMIT_PHASE : CONFIG_INTERIM_COMMIT_PHASE),

          getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL)

      );

      _;

    }



    modifier ifAfterProposalRevealPhase(bytes32 _proposalId, uint256 _index) {

      uint256 _start = daoStorage().readProposalVotingTime(_proposalId, _index);

      require(_start > 0);

      require(now >= _start.add(getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL)));

      _;

    }



    modifier ifDraftVotingPhase(bytes32 _proposalId) {

        requireInPhase(

            daoStorage().readProposalDraftVotingTime(_proposalId),

            0,

            getUintConfig(CONFIG_DRAFT_VOTING_PHASE)

        );

        _;

    }



    modifier isProposalState(bytes32 _proposalId, bytes32 _STATE) {

        bytes32 _currentState;

        (,,,_currentState,,,,,,) = daoStorage().readProposal(_proposalId);

        require(_currentState == _STATE);

        _;

    }



    modifier ifDraftNotClaimed(bytes32 _proposalId) {

        require(daoStorage().isDraftClaimed(_proposalId) == false);

        _;

    }



    modifier ifNotClaimed(bytes32 _proposalId, uint256 _index) {

        require(daoStorage().isClaimed(_proposalId, _index) == false);

        _;

    }



    modifier ifNotClaimedSpecial(bytes32 _proposalId) {

        require(daoSpecialStorage().isClaimed(_proposalId) == false);

        _;

    }



    modifier hasNotRevealed(bytes32 _proposalId, uint256 _index) {

        uint256 _voteWeight;

        (, _voteWeight) = daoStorage().readVote(_proposalId, _index, msg.sender);

        require(_voteWeight == uint(0));

        _;

    }



    modifier hasNotRevealedSpecial(bytes32 _proposalId) {

        uint256 _weight;

        (,_weight) = daoSpecialStorage().readVote(_proposalId, msg.sender);

        require(_weight == uint256(0));

        _;

    }



    modifier ifAfterRevealPhaseSpecial(bytes32 _proposalId) {

      uint256 _start = daoSpecialStorage().readVotingTime(_proposalId);

      require(_start > 0);

      require(now.sub(_start) >= getUintConfig(CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL));

      _;

    }



    modifier ifCommitPhaseSpecial(bytes32 _proposalId) {

        requireInPhase(

            daoSpecialStorage().readVotingTime(_proposalId),

            0,

            getUintConfig(CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE)

        );

        _;

    }



    modifier ifRevealPhaseSpecial(bytes32 _proposalId) {

        requireInPhase(

            daoSpecialStorage().readVotingTime(_proposalId),

            getUintConfig(CONFIG_SPECIAL_PROPOSAL_COMMIT_PHASE),

            getUintConfig(CONFIG_SPECIAL_PROPOSAL_PHASE_TOTAL)

        );

        _;

    }



    function daoWhitelistingStorage()

        internal

        view

        returns (DaoWhitelistingStorage _contract)

    {

        _contract = DaoWhitelistingStorage(get_contract(CONTRACT_STORAGE_DAO_WHITELISTING));

    }



    function getAddressConfig(bytes32 _configKey)

        public

        view

        returns (address _configValue)

    {

        _configValue = daoConfigsStorage().addressConfigs(_configKey);

    }



    function getBytesConfig(bytes32 _configKey)

        public

        view

        returns (bytes32 _configValue)

    {

        _configValue = daoConfigsStorage().bytesConfigs(_configKey);

    }



    /**

    @notice Check if a user is a participant in the current quarter

    */

    function isParticipant(address _user)

        public

        view

        returns (bool _is)

    {

        _is =

            (daoRewardsStorage().lastParticipatedQuarter(_user) == currentQuarterNumber())

            && (daoStakeStorage().lockedDGDStake(_user) >= getUintConfig(CONFIG_MINIMUM_LOCKED_DGD));

    }



    /**

    @notice Check if a user is a moderator in the current quarter

    */

    function isModerator(address _user)

        public

        view

        returns (bool _is)

    {

        _is =

            (daoRewardsStorage().lastParticipatedQuarter(_user) == currentQuarterNumber())

            && (daoStakeStorage().lockedDGDStake(_user) >= getUintConfig(CONFIG_MINIMUM_DGD_FOR_MODERATOR))

            && (daoPointsStorage().getReputation(_user) >= getUintConfig(CONFIG_MINIMUM_REPUTATION_FOR_MODERATOR));

    }



    /**

    @notice Calculate the start of a specific milestone of a specific proposal.

    @dev This is calculated from the voting start of the voting round preceding the milestone

         This would throw if the voting start is 0 (the voting round has not started yet)

         Note that if the milestoneIndex is exactly the same as the number of milestones,

         This will just return the end of the last voting round.

    */

    function startOfMilestone(bytes32 _proposalId, uint256 _milestoneIndex)

        internal

        view

        returns (uint256 _milestoneStart)

    {

        uint256 _startOfPrecedingVotingRound = daoStorage().readProposalVotingTime(_proposalId, _milestoneIndex);

        require(_startOfPrecedingVotingRound > 0);

        // the preceding voting round must have started



        if (_milestoneIndex == 0) { // This is the 1st milestone, which starts after voting round 0

            _milestoneStart =

                _startOfPrecedingVotingRound

                .add(getUintConfig(CONFIG_VOTING_PHASE_TOTAL));

        } else { // if its the n-th milestone, it starts after voting round n-th

            _milestoneStart =

                _startOfPrecedingVotingRound

                .add(getUintConfig(CONFIG_INTERIM_PHASE_TOTAL));

        }

    }



    /**

    @notice Calculate the actual voting start for a voting round, given the tentative start

    @dev The tentative start is the ideal start. For example, when a proposer finish a milestone, it should be now

         However, sometimes the tentative start is too close to the end of the quarter, hence, the actual voting start should be pushed to the next quarter

    */

    function getTimelineForNextVote(

        uint256 _index,

        uint256 _tentativeVotingStart

    )

        internal

        view

        returns (uint256 _actualVotingStart)

    {

        uint256 _timeLeftInQuarter = getTimeLeftInQuarter(_tentativeVotingStart);

        uint256 _votingDuration = getUintConfig(_index == 0 ? CONFIG_VOTING_PHASE_TOTAL : CONFIG_INTERIM_PHASE_TOTAL);

        _actualVotingStart = _tentativeVotingStart;

        if (timeInQuarter(_tentativeVotingStart) < getUintConfig(CONFIG_LOCKING_PHASE_DURATION)) { // if the tentative start is during a locking phase

            _actualVotingStart = _tentativeVotingStart.add(

                getUintConfig(CONFIG_LOCKING_PHASE_DURATION).sub(timeInQuarter(_tentativeVotingStart))

            );

        } else if (_timeLeftInQuarter < _votingDuration.add(getUintConfig(CONFIG_VOTE_CLAIMING_DEADLINE))) { // if the time left in quarter is not enough to vote and claim voting

            _actualVotingStart = _tentativeVotingStart.add(

                _timeLeftInQuarter.add(getUintConfig(CONFIG_LOCKING_PHASE_DURATION)).add(1)

            );

        }

    }



    /**

    @notice Check if we can add another non-Digix proposal in this quarter

    @dev There is a max cap to the number of non-Digix proposals CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER

    */

    function checkNonDigixProposalLimit(bytes32 _proposalId)

        internal

        view

    {

        require(isNonDigixProposalsWithinLimit(_proposalId));

    }



    function isNonDigixProposalsWithinLimit(bytes32 _proposalId)

        internal

        view

        returns (bool _withinLimit)

    {

        bool _isDigixProposal;

        (,,,,,,,,,_isDigixProposal) = daoStorage().readProposal(_proposalId);

        _withinLimit = true;

        if (!_isDigixProposal) {

            _withinLimit = daoProposalCounterStorage().proposalCountByQuarter(currentQuarterNumber()) < getUintConfig(CONFIG_NON_DIGIX_PROPOSAL_CAP_PER_QUARTER);

        }

    }



    /**

    @notice If its a non-Digix proposal, check if the fundings are within limit

    @dev There is a max cap to the fundings and number of milestones for non-Digix proposals

    */

    function checkNonDigixFundings(uint256[] _milestonesFundings, uint256 _finalReward)

        internal

        view

    {

        if (!is_founder()) {

            require(_milestonesFundings.length <= getUintConfig(CONFIG_MAX_MILESTONES_FOR_NON_DIGIX));

            require(MathHelper.sumNumbers(_milestonesFundings).add(_finalReward) <= getUintConfig(CONFIG_MAX_FUNDING_FOR_NON_DIGIX));

        }

    }



    /**

    @notice Check if msg.sender can do operations as a proposer

    @dev Note that this function does not check if he is the proposer of the proposal

    */

    function senderCanDoProposerOperations()

        internal

        view

    {

        require(isMainPhase());

        require(isParticipant(msg.sender));

        require(identity_storage().is_kyc_approved(msg.sender));

    }

}



// File: contracts/interactive/DaoInformation.sol

/**

@title Contract (read-only) to read information from DAO

@dev cannot introduce more read methods in other contracts due to deployment gas limit

@author Digix Holdings

*/

contract DaoInformation is DaoCommon {



    constructor(address _resolver)

        public

    {

        require(init(CONTRACT_DAO_INFORMATION, _resolver));

    }



    /**

    @notice Function to read user specific information

    @param _user Ethereum address of the user

    @return {

      "_isParticipant": "Boolean, true if the user is a DigixDAO participant in the current quarter",

      "_isModerator": "Boolean, true if the user is a DigixDAO moderator in the current quarter",

      "_isDigix": "Boolean, true if the user is a Digix founder",

      "_redeemedBadge": "Boolean, true if the user has redeemed a DGD badge in DigixDAO",

      "_lastParticipatedQuarter": "The last quarter in which this user has/had participated in DigixDAO",

      "_lastParticipatedQuarter": "The last quarter in which this user's reputation was updated in DigixDAO, equal to (currentQuarter - 1) if its updated at the moment",

      "_lockedDgdStake": "The locked stage of this user in the current quarter",

      "_lockedDgd": "The actual locked DGDs by this user in our contracts",

      "_reputationPoints": "The cumulative reputation points accumulated by this user in DigixDAO",

      "_quarterPoints": "Quarter points of this user in the current quarter",

      "_claimableDgx": "DGX (in grams) that can be claimed by this user from DigixDAO",

      "_quarterModeratorPoints": "Quarter Moderator points of this user in the current quarter"

    }

    */

    function readUserInfo(address _user)

        public

        view

        returns (

            bool _isParticipant,

            bool _isModerator,

            bool _isDigix,

            bool _redeemedBadge,

            uint256 _lastParticipatedQuarter,

            uint256 _lastQuarterThatReputationWasUpdated,

            uint256 _lockedDgdStake,

            uint256 _lockedDgd,

            uint256 _reputationPoints,

            uint256 _quarterPoints,

            uint256 _claimableDgx,

            uint256 _quarterModeratorPoints

        )

    {

         _lastParticipatedQuarter = daoRewardsStorage().lastParticipatedQuarter(_user);

         _lastQuarterThatReputationWasUpdated = daoRewardsStorage().lastQuarterThatReputationWasUpdated(_user);

         _redeemedBadge = daoStakeStorage().redeemedBadge(_user);

         (_lockedDgd, _lockedDgdStake) = daoStakeStorage().readUserDGDStake(_user);

         _reputationPoints = daoPointsStorage().getReputation(_user);

         _quarterPoints = daoPointsStorage().getQuarterPoint(_user, currentQuarterNumber());

         _quarterModeratorPoints = daoPointsStorage().getQuarterModeratorPoint(_user, currentQuarterNumber());

         _isParticipant = isParticipant(_user);

         _isModerator = isModerator(_user);

         _isDigix = identity_storage().read_user_role_id(_user) == ROLES_FOUNDERS;

         _claimableDgx = daoRewardsStorage().claimableDGXs(_user);

    }



    /**

    @notice Function to read DigixDAO specific information

    @return {

      "_currentQuarterNumber": "The current quarter number of DigixDAO (starts from 1)",

      "_dgxDistributionDay": "The unix timestamp at which the quarter was initialized",

      "_startOfQuarter": "The unix timestamp when the current quarter started",

      "_startOfMainPhase": "The unix timestamp when the main phase of current quarter has/will start",

      "_startOfNextQuarter": "The unix timestamp when the next quarter begins",

      "_isMainPhase": "Boolean, true if this is the main phase, false if this is the locking phase",

      "_isGlobalRewardsSet": "Boolean, true if the global rewards have been set for the quarter",

      "_nModerators": "Number of moderators in DigixDAO",

      "_nParticipants": "Number of participants in DigixDAO"

    }

    */

    function readDaoInfo()

        public

        view

        returns (

            uint256 _currentQuarterNumber,

            uint256 _startOfQuarter,

            uint256 _startOfMainPhase,

            uint256 _startOfNextQuarter,

            bool _isMainPhase,

            bool _isGlobalRewardsSet,

            uint256 _nModerators,

            uint256 _nParticipants

        )

    {

        _currentQuarterNumber = currentQuarterNumber();

        _startOfQuarter = now.sub(currentTimeInQuarter());

        _startOfMainPhase = _startOfQuarter.add(getUintConfig(CONFIG_LOCKING_PHASE_DURATION));

        _startOfNextQuarter = _startOfQuarter.add(getUintConfig(CONFIG_QUARTER_DURATION));

        _isMainPhase = isMainPhase();

        _isGlobalRewardsSet = daoRewardsStorage().readDgxDistributionDay(_currentQuarterNumber) > 0 ? true : false;

        _nModerators = daoStakeStorage().readTotalModerators();

        _nParticipants = daoStakeStorage().readTotalParticipant();

    }

}