pragma solidity >=0.4.22 <0.6.0;

contract ShippingContract {
 
    /////  :> STRUCTS <:  ////////////////////////////////////////////////////////////////////////////////////////////////////
   
    struct Order {
        uint256 _id;
        uint256 itemsCount;
        mapping(uint => Item) items;
    }
    
    struct Item {
        uint256 _id;
        bytes32 _name;
        bool _isLoaded;
        bool _isWrapped;
        bool _isDelivered;
        bool _isCleared;
        bool _isCertified; 
    }
    
    
    
    /////  :> STATE <:  ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    mapping (uint256 => Order) internal ordersList;
    uint256 itemsCount = 0;
    uint256 ordersCount = 0;
    
    
    
    /////  :> FUNCTIONS <:  ////////////////////////////////////////////////////////////////////////////////////////////////////    
    
    function createOrder() public returns (uint256) {
        incrementOrdersCount();
        ordersList[ordersCount] = Order(ordersCount, 0);
        
        return ordersCount;
    }
    
    function addItem(uint256 orderId, bytes32 _name ) public returns (uint256, bytes32, bool, bool, bool, bool, bool) {
        uint256 currentItemIndexinOrder = ordersList[orderId].itemsCount + 1;
        ordersList[orderId].items[currentItemIndexinOrder] = Item(itemsCount,  _name, false, false, false, false, false);
        
        return getItem(orderId, itemsCount);
    }
      
    function recordAction(uint256 orderId, uint256 itemId, bytes32 action) public returns (uint256, bytes32, bool, bool, bool, bool, bool) {
        Item storage item = ordersList[orderId].items[itemId];
        
        if (action == 'wrap' && item._isWrapped == false && item._isLoaded == false){
            item._isWrapped = true; 
        }
        else if (action == 'unwrap' && item._isWrapped == true && item._isLoaded == false){
            item._isWrapped = false;
        }
        else if (action == 'load' && item._isLoaded == false && item._isWrapped == true){
            item._isLoaded = true;
        }
        else if (action =='unload' && item._isLoaded == true && item._isWrapped == true){
            item._isLoaded = false;
        }
        else if (action == 'certify' && item._isCertified == false){
            item._isCertified = true;
        }
        else if (action == 'clear' && item._isCleared == false){
            item._isCleared = true;
        }
        else if (action == 'deliver' && item._isDelivered == false && isOrderDeliverable(orderId) ){
            item._isDelivered = true;
        }
        
        return getItem(orderId, item._id);
    }
    
    
    
    /////  :> VIEWS & UTILITIES <:  ////////////////////////////////////////////////////////////////////////////////////////////////////
    
    function getItem(uint256 orderId, uint256 itemId) public view returns (uint256, bytes32, bool, bool, bool, bool, bool) {
        Item storage i = ordersList[orderId].items[itemId];
        return (i._id, i._name, i._isLoaded, i._isWrapped, i._isDelivered, i._isCleared, i._isCertified);
    }
    
    function isOrderDelivered(uint256 orderId) public view returns (bool){
        bool isDelivered = true;
        
        for (uint index = 0; index < ordersList[orderId].itemsCount; index++) {
          Item storage item = ordersList[orderId].items[index];
          if (item._isDelivered == false) {
              isDelivered = false;
          }
        }
        
        return isDelivered;
    }
    
    function isOrderDeliverable(uint256 orderId) private view returns (bool){
        bool isDeliverbale = true;
        
        for (uint index = 0; index < ordersList[orderId].itemsCount; index++) {
          Item storage item = ordersList[orderId].items[index];
         
          if (isDeliverbale == false){
              break;
          }
          
          if (item._isCertified == false && isDeliverbale == true ) {
              isDeliverbale = false;
          } 
          
          if (item._isWrapped == false && isDeliverbale == true ) {
              isDeliverbale = false;
          } 
          
          if (item._isLoaded == false && isDeliverbale == true ) {
              isDeliverbale = false;
          }
          
          if (item._isCleared == false && isDeliverbale== true ) {
              isDeliverbale = false;
          } 
        }
        
        return isDeliverbale;
    }
    
    function getItemsCountInOrder(uint256 orderId) private view returns (uint256){
        return ordersList[orderId].itemsCount;
    }
    
    function incrementOrdersCount() private returns (uint256){
        return ++ordersCount;
    }
    
    function incrementItemsCount(uint256 orderId) private returns (uint256, uint256){
        return(++itemsCount, ++ordersList[orderId].itemsCount);
    }
    
}
