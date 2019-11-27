pragma solidity >=0.4.22 <0.6.0;

contract ShippingContract {
    struct Item {
        uint _id;
        string _name;
        bool _isLoaded;
        bool _isWrapped;
        bool _isDelivered;
        bool _isCleared;
        bool _isCertified;
    }

    mapping(uint => Item) public items;
    uint256 itemsCount = 0;

    function addItem( string memory _name ) public returns (uint, string memory, bool, bool, bool, bool, bool) {
        incrementItemsCount();
        items[itemsCount] = Item(itemsCount, _name, false, false, false, false, false);

        return getItem(items[itemsCount]._id);
    }


    function wrap(uint256 itemId) public returns (uint, string memory, bool, bool, bool, bool, bool) {
        Item storage item = items[itemId];
        if (item._isWrapped == false && item._isLoaded == false){
            item._isWrapped = true   ;
        }

        return getItem(item._id);
    }

    function unWrap(uint256 itemId) public returns (uint256, string memory, bool, bool, bool, bool, bool){
        Item storage item = items[itemId];
        if (item._isWrapped == true && item._isLoaded == false){
            item._isWrapped = false   ;
        }

        return getItem(item._id);
    }

    function load(uint256 itemId) public returns (uint256, string memory, bool, bool, bool, bool, bool){
        Item storage item = items[itemId];
        if (item._isLoaded == false && item._isWrapped == true){
            item._isLoaded = true;
        }

        return getItem(item._id);
    }

    function unLoad(uint256 itemId) public returns (uint256, string memory, bool, bool, bool, bool, bool){
        Item storage item = items[itemId];
        if (item._isLoaded == true && item._isWrapped == true){
            item._isLoaded = false;
        }

        return getItem(item._id);
    }

    function cerifyItem(uint256 itemId) public returns (uint256, string memory, bool, bool, bool, bool, bool){
        Item storage item = items[itemId];
        if (item._isCertified == false){
            item._isCertified = true;
        }

        return getItem(item._id);
    }

    // utils

    function getItem(uint256 itemId) public view returns (uint256, string memory, bool, bool, bool, bool, bool) {
        Item storage i = items[itemId];
        return (i._id, i._name, i._isLoaded, i._isWrapped, i._isDelivered, i._isCleared, i._isCertified);
    }

    function incrementItemsCount() private {
        itemsCount += 1;
    }

}