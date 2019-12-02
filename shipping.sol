pragma solidity >=0.4.22 <0.6.0;

contract ShippingContract {
 
    /////  :> STRUCTS <:  ////////////////////////////////////////////////////////////////////////////////////////////////////
   
    struct Shipment {
        uint256 _id;
        uint256 _itemsCount;
        string _companyName;
        uint256 _orderId;
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
    
    mapping (uint256 => Shipment) private shipmentsList;
    uint256 private itemsCount = 0;
    uint256 private shipmentsCount = 0;

    
    
    /////  :> FUNCTIONS <:  ////////////////////////////////////////////////////////////////////////////////////////////////////    
    
    function createShipment(string memory companyName, uint256 orderId) public returns (uint256, uint256, string memory, bool) {
        incrementShipmentsCount();
        shipmentsList[shipmentsCount - 1] = Shipment(shipmentsCount, 0, companyName, orderId);
        
        return getShipment(shipmentsCount);
    }
    
    
    
    function addItem(uint256 shipmentId, string memory _name ) public returns (uint256, string memory, bool, bool, bool, bool, bool) {
        incrementItemsCount();
        uint256 currentItemIndexinOrder = shipmentsList[shipmentId - 1]._itemsCount;
        Item memory newItem = Item(itemsCount, _name, false, false, false, false, false);
        
        shipmentsList[shipmentId - 1].items[currentItemIndexinOrder] = newItem;
        incrementItemsCountInOrder(shipmentId);
        
        return getItem(shipmentId, itemsCount);
    }
      
      
      
    function recordAction(uint256 shipmentId, uint256 itemId, string memory action) public returns (uint256, string memory, bool, bool, bool, bool, bool) {
        uint256 itemIndex = getIndexAtItem(shipmentId, itemId);
        Item memory item = shipmentsList[shipmentId - 1].items[itemIndex];

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
        else if (keccak256(abi.encodePacked((action))) == keccak256(abi.encodePacked(("deliver"))) && item._isDelivered == false && isShipmentDeliverable(shipmentId) ){
            item._isDelivered = true;
        }
            
        shipmentsList[shipmentId - 1].items[itemIndex] = item;
        return getItem(shipmentId, item._id);
    }
    
    
    
    /////  :> VIEWS & UTILITIES <:  ////////////////////////////////////////////////////////////////////////////////////////////////////

    function getItem(uint256 shipmentsId, uint256 itemId) public view returns (uint256, string memory, bool, bool, bool, bool, bool){
        for(uint256 index = 0; index < shipmentsList[shipmentsId - 1]._itemsCount; index++){
            if (shipmentsList[shipmentsId - 1].items[index]._id == itemId){
                return getItemAtIndex(shipmentsId, index);
            }
        }
    }
    
    function isShipmentDelivered(uint256 shipmentsId) public view returns (bool){
        bool isDelivered = true;
        
        if (shipmentsList[shipmentsId - 1].items[0]._id == 0){
            isDelivered = false;
        }
        
        for (uint index = 0; index < shipmentsList[shipmentsId - 1]._itemsCount; index++) {
          if (shipmentsList[shipmentsId - 1].items[index]._isDelivered == false) {
              isDelivered = false;
          }
        }
        
        return isDelivered;
    }
    
    function getShipment(uint256 shipmentsId) public view returns (uint256, uint256, string memory, bool){
        Shipment memory shipment = shipmentsList[shipmentsId - 1];
        bool isDelivered = isShipmentDelivered(shipmentsId);
        return(shipment._id, shipment._itemsCount, shipment._companyName, isDelivered);
    }
    
    function getItemAtIndex(uint256 shipmentsId, uint256 index) public view returns (uint256, string memory, bool, bool, bool, bool, bool){
        Item storage i = shipmentsList[shipmentsId - 1].items[index];
        return (i._id, i._name, i._isCertified, i._isWrapped, i._isLoaded, i._isCleared, i._isDelivered);
    }
    
    function getIndexAtItem(uint256 shipmentsId, uint256 itemId) private view returns (uint256){
        for(uint256 index = 0; index < shipmentsList[shipmentsId - 1]._itemsCount; index++){
            if (shipmentsList[shipmentsId - 1].items[index]._id == itemId){
                return index;
            }
        }
    }
    
    function isShipmentDeliverable(uint256 shipmentsId) private view returns (bool){
        bool isDeliverable = true;
        
        for (uint index = 0; index < shipmentsList[shipmentsId - 1]._itemsCount; index++) {
          Item memory item = shipmentsList[shipmentsId - 1].items[index];

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
    
    function getItemsCountInShipment(uint256 orderId) private view returns (uint256){
        return shipmentsList[orderId - 1]._itemsCount;
    }
    
    function incrementItemsCountInOrder(uint256 orderId) private returns (uint256){
        shipmentsList[orderId - 1]._itemsCount++;
        return shipmentsList[orderId - 1]._itemsCount;
    }
    
    function incrementShipmentsCount() private returns (uint256){
        shipmentsCount = shipmentsCount + 1;
        return shipmentsCount;
    }
    
    function incrementItemsCount() private returns (uint256){
        itemsCount = itemsCount + 1;
        return itemsCount;
    }
    
}
