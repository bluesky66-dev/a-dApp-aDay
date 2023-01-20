pragma solidity ^0.8.0;


/** 
 * @title SupplyChain 
 * @dev Create, store, and track items using a basic supply chain
 */

contract SupplyChain {

    struct Item {
        /* 
            0 = Supplier; 
            1 = Manufacturer; 
            2 = Warehouse;
            3 = FreightForwarder; 
            4 = Carrier; 
            5 = Customs; 
            6 = Distributor;
            7 = Retailer; 
            8 = Consumer;
        */
        uint stageConfirms; 
    }

    Item[] items;

    /// @dev creates a new basic item to be tracked
    function createNewItem() external returns(uint) {
        Item memory item = Item(0);
        items.push(item);

        return items.length - 1;
    }

    /// @param _status is succesful completion of a stage
    /// @param _index is the predefined index of logistic stages i.e 0=pre-delivery, 1=delivery stage 1....
    function setItemStatus(bool _status, uint _index, uint _itemId) external {
        packSingleBool(_status,_index,_itemId);
    }

    /// @param _id of item in items array
    /// @param _index of stage confirmation
    function retrieveItemStatus(uint _id, uint _index) external view returns (bool) {
        return unpackSingleBool(items[_id].stageConfirms, _index);
    }

    /// @param _packed where the uint that we have packed bools into
    /// @param _index confirmation stage to unpack i.e warehouse, etc
    function unpackSingleBool(uint256 _packed, uint _index) internal pure returns (bool) {
        return (_packed & (1 << _index)) != 0;
    }

    /// @param _singleBool true/false to store in uint
    /// @param _index confirmation stage
    /// @param _id item array id
    function packSingleBool(bool _singleBool, uint _index, uint _id) internal {
        if (_singleBool) {
            items[_id].stageConfirms |= (1 << _index);
        }
    }

    /*********************************/
    /********* Gas Comparison ********/
    /*********************************/

    /*
    | Deployment Cost| Deployment Size |       |        |       |         |
    | 162808         | 845             |       |        |       |         |
    | Function Name  | min             | avg   | median | max   | # calls |
    | setItemStages  | 22528           | 22528 | 22528  | 22528 | 1       |
    | setItemStatus  | 7620            | 16353 | 20720  | 20720 | 3       |
    */
    
    
    enum Stages {Supplier, Manufacturer, Warehouse, FreightForwarder, Carrier, Customs, Distributor, Retailer, Consumer}

    mapping(uint => Stages) public itemtoStage;

    function setItemStages(uint _itemId, uint id) external {
        itemtoStage[_itemId] = Stages(id);
    }
}