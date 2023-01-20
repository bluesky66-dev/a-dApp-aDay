pragma solidity ^0.8.0;


/** 
 * @title SupplyChain 
 * @dev Create, store, and track items using a basic supply chain
 */

contract SupplyChain {

    struct Agreement {
        uint stageConfirms;
        uint stagesPaid;
        uint stagesErrors;
        bytes itemName;
    }

    error WrongStep();

    Agreement[] items;

    // Item Id => Stage => Error
    mapping(uint=> mapping(uint => bytes)) internal stageToErrors;
    // Item Id => Stage => Amount paid
    mapping(uint=> mapping(uint => uint)) internal stageToPaid;

    /// @dev creates a new basic item to be tracked
    function createNewItem(bytes calldata _name) external returns(uint) {
        Agreement memory item = Agreement(0,0,0, _name);
        items.push(item);

        return items.length - 1;
    }

    /// @param _id of item in items array
    /// @param _index of stage 
    /// @param _info i.e 0=stageConfirms, 1=stagePaid, 2=stageErrors etc
    /// @param _value that to be paid in wei
    function injectStagePayment(uint _id, uint _index, uint _info, uint _value) external {
        stageToPaid[_id][_index] = _value;
        packSingleBool(true, _index, _id, _info);
    }

    /// @param _id of item in items array
    /// @param _index of stage
    /// @param _info i.e 0=stageConfirms, 1=stagePaid, 2=stageErrors etc
    /// @param _error bytes error message
    function injectStageError(uint _id, uint _index, uint _info, bytes memory _error) external {
        stageToErrors[_id][_index] = _error;
        packSingleBool(true, _index, _id, _info);
    }

    /// @param _id of item in items array
    /// @param _index of stage
    function getStagePayment(uint _id, uint _index) external view returns (uint) {
        return stageToPaid[_id][_index];
    }

    /// @param _id of item in items array
    /// @param _index of stage
    function getStageError(uint _id, uint _index) external view returns (bytes memory) {
        return stageToErrors[_id][_index];
    }

    /// @param _id of item in items array
    function getItem(uint _id) external view returns (Agreement memory) {
        return items[_id];
    }

    /// @param _status is succesful completion of a stage
    /// @param _index is the predefined index of logistic stages
    /// @param _itemId is the id in the items array
    /// @param _info specifies which variable to write into
    function setItemStatus(bool _status, uint _index, uint _itemId, uint _info) external {
        packSingleBool(_status,_index,_itemId,_info);
    }

    /// @param _id of item in items array
    /// @param _index of stage confirmation
    /// @param _info indicates which variable to unpack from
    function retrieveItemStatus(uint _id, uint _index, uint _info) external view returns (bool) {
        if(_info == 0) {
            return unpackSingleBool(items[_id].stageConfirms, _index);
        } else if (_info == 1) {
            return unpackSingleBool(items[_id].stagesPaid, _index);
        } else if (_info == 2) {
            return unpackSingleBool(items[_id].stagesErrors, _index);
        } else {
            revert WrongStep();
        }
    }

    /// @param _packed where the uint that we have packed bools into
    /// @param _index confirmation stage to unpack i.e warehouse, etc
    function unpackSingleBool(uint256 _packed, uint _index) internal pure returns (bool) {
        return (_packed & (1 << _index)) != 0;
    }

    /// @param _singleBool true/false to store in uint
    /// @param _index confirmation stage
    /// @param _id item array id
    /// @param _info which variable to write into
    function packSingleBool(bool _singleBool, uint _index, uint _id, uint _info) internal {
        if(_info == 0) {
            if (_singleBool) {
                items[_id].stageConfirms |= (1 << _index);
            }
        } else if (_info == 1) {
            if (_singleBool) {
                items[_id].stagesPaid |= (1 << _index);
            }
        } else if (_info == 2) {
            if (_singleBool) {
                items[_id].stagesErrors |= (1 << _index);
            }
        }else {
            revert WrongStep();
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
    
    struct AgreementX {
        Stages stageConfirms;
        bool[] stagesPaid;
        bool[] stagesErrors;
        bytes itemName;
    }

    AgreementX[] Xitems;

    enum Stages {Supplier, Manufacturer, Warehouse, FreightForwarder, Carrier, Customs, Distributor, Retailer, Consumer}
    
    mapping(uint => Stages) public itemtoStage;

    function createNewAgreementX(bytes calldata _name) external returns(uint) {
        AgreementX memory item = AgreementX({
            stageConfirms: Stages.Consumer,
            stagesPaid: new bool[](uint(Stages.Consumer)),
            stagesErrors: new bool[](uint(Stages.Consumer)),
            itemName: _name
        });
        Xitems.push(item);

        return Xitems.length - 1;
    }

    function setItemStatusX(uint _id, bool _status, uint _index, uint _info) external {
        if(_info == 0) {
            Xitems[_id].stageConfirms = Stages(_index);
        } else if (_info == 1) {
            Xitems[_id].stagesPaid[_index] = _status;
        } else if (_info == 2) {
            Xitems[_id].stagesErrors[_index] = _status;
        } else {
            revert WrongStep();
        }
    }

    function getStageStatusX(uint _id, uint _index, uint _info) external view returns (bool) {
        if(_info == 0) {
            return Xitems[_id].stageConfirms == Stages(_index);
        } else if (_info == 1) {
            return Xitems[_id].stagesPaid[_index];
        } else if (_info == 2) {
            return Xitems[_id].stagesErrors[_index];
        } else {
            revert WrongStep();
        }
    }    

    function getItemX(uint _id) external view returns (AgreementX memory) {
        return Xitems[_id];
    }


    function setItemStages(uint _itemId, uint id) external {
        itemtoStage[_itemId] = Stages(id);
    }

}