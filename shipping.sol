pragma solidity >=0.4.22 <0.6.0;

contract ShippingContract {
 
    /////  :> STRUCTS <:  ////////////////////////////////////////////////////////////////////////////////////////////////////
   
    struct Order {
        uint256 _id;
        uint256 _itemsCount;
        string _companyName;
        mapping(uint => Item) items;
    }
    
    struct Item {
        uint256 _id;
        string  _name;
        bool _isLoaded;
        bool _isWrapped;
        bool _isDelivered;
        bool _isCleared;
        bool _isCertified; 
    }
    
    
    
    /////  :> STATE <:  ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    mapping (uint256 => Order) public ordersList;
    uint256 private itemsCount = 0;
    uint256 private ordersCount = 0;
    
    
    
    /////  :> FUNCTIONS <:  ////////////////////////////////////////////////////////////////////////////////////////////////////    
    
    function createOrder(string memory  companyName) public returns (uint256) {
        incrementOrdersCount();
        ordersList[ordersCount - 1] = Order(ordersCount, 0, companyName);
        
        return ordersCount;
    }
    
    
    
    function addItem(uint256 orderId, string memory _name ) public returns (uint256, string memory, bool, bool, bool, bool, bool) {
        incrementItemsCount();
        uint256 currentItemIndexinOrder = ordersList[orderId - 1]._itemsCount;
        Item memory newItem = Item(itemsCount, _name, false, false, false, false, false);
        
        ordersList[orderId - 1].items[currentItemIndexinOrder] = newItem;
        incrementItemsCountInOrder(orderId);
        
        return getItem(orderId, itemsCount);
    }
      
      
      
    function recordAction(uint256 orderId, uint256 itemId, string memory action) public returns (uint256, string memory, bool, bool, bool, bool, bool) {
        uint256 itemIndex = getIndexAtItem(orderId, itemId);
        Item storage item = ordersList[orderId - 1].items[itemIndex];

        if (keccak256(abi.encodePacked((action))) == keccak256(abi.encodePacked(("wrap"))) && item._isWrapped == false && item._isLoaded == false){
            item._isWrapped = true; 
        }
        else if (keccak256(abi.encodePacked((action))) == keccak256(abi.encodePacked(("unwrap"))) && item._isWrapped == true && item._isLoaded == false){
            item._isWrapped = false;
        }
        else if (keccak256(abi.encodePacked((action))) == keccak256(abi.encodePacked(("load"))) && item._isLoaded == false && item._isWrapped == true){
            item._isLoaded = true;
        }
        else if (keccak256(abi.encodePacked((action))) == keccak256(abi.encodePacked(("unload"))) && item._isLoaded == true && item._isWrapped == true){
            item._isLoaded = false;
        }
        else if (keccak256(abi.encodePacked((action))) == keccak256(abi.encodePacked(("certify"))) && item._isCertified == false){
            item._isCertified = true;
        }
        else if (keccak256(abi.encodePacked((action))) == keccak256(abi.encodePacked(("clear"))) && item._isCleared == false){
            item._isCleared = true;
        }
        else if (keccak256(abi.encodePacked((action))) == keccak256(abi.encodePacked(("deliver"))) && item._isDelivered == false && isOrderDeliverable(orderId) ){
            item._isDelivered = true;
        }
        
        // item._isWrapped = true;
        
        ordersList[orderId - 1].items[itemIndex] = item;
        
        return getItem(orderId, item._id);
    }
    
    
    
    /////  :> VIEWS & UTILITIES <:  ////////////////////////////////////////////////////////////////////////////////////////////////////

    function getItem(uint256 orderId, uint256 itemId) public view returns (uint256, string memory, bool, bool, bool, bool, bool){
        for(uint256 index = 0; index < ordersList[orderId - 1]._itemsCount; index++){
            if (ordersList[orderId - 1].items[index]._id == itemId){
                return getItemAtIndex(orderId, index);
            }
        }
    }
    
    function isOrderDelivered(uint256 orderId) public view returns (bool){
        bool isDelivered = true;
        
        for (uint index = 0; index < ordersList[orderId - 1]._itemsCount; index++) {
          Item storage item = ordersList[orderId].items[index];
          if (item._isDelivered == false) {
              isDelivered = false;
          }
        }
        
        return isDelivered;
    }
    
    function getItemAtIndex(uint256 orderId, uint256 index) private view returns (uint256, string memory, bool, bool, bool, bool, bool){
        Item storage i = ordersList[orderId - 1].items[index];
        return (i._id, i._name, i._isCertified, i._isWrapped, i._isLoaded, i._isCleared, i._isDelivered);
    }
    
    function getIndexAtItem(uint256 orderId, uint256 itemId) private view returns (uint256){
        for(uint256 index = 0; index < ordersList[orderId - 1]._itemsCount; index++){
            if (ordersList[orderId - 1].items[index]._id == itemId){
                return index;
            }
        }
    }
    
    function isOrderDeliverable(uint256 orderId) private view returns (bool){
        bool isDeliverable = true;
        
        for (uint index = 0; index < ordersList[orderId - 1]._itemsCount; index++) {
          Item storage item = ordersList[orderId - 1].items[index];

          if (isDeliverable == false){
            return false;
          }

          if (item._isCertified == false && isDeliverable == true ) {
              isDeliverable = false;
          } 
          
          if (item._isWrapped == false && isDeliverable == true ) {
              isDeliverable = false;
          } 
          
          if (item._isLoaded == false && isDeliverable == true ) {
              isDeliverable = false;
          }
          
          if (item._isCleared == false && isDeliverable== true ) {
              isDeliverable = false;
          } 
        }
        
        return isDeliverable;
    }
    
    function getItemsCountInOrder(uint256 orderId) private view returns (uint256){
        return ordersList[orderId - 1]._itemsCount;
    }
    
    function incrementItemsCountInOrder(uint256 orderId) private returns (uint256){
        ordersList[orderId - 1]._itemsCount++;
        return ordersList[orderId - 1]._itemsCount;
    }
    
    function incrementOrdersCount() private returns (uint256){
        ordersCount = ordersCount + 1;
        return ordersCount;
    }
    
    function incrementItemsCount() private returns (uint256){
        itemsCount = itemsCount + 1;
        return itemsCount;
    }
    
}
