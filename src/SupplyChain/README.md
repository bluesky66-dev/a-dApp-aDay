# README

## Introduction

This smart contract is for a minimal logistics supply chain management system, which focuses on packing booleans into a single `uint256` variable to represent the stages of production and transportation of a product. This approach is more gas efficient than using enums as we'll explore further.

## Contract Design

* ```SupplyChainAdv.sol```

```
struct Agreement {
        uint stageConfirms;
        uint stagesPaid;
        uint stagesErrors;
        bytes itemName;
    } 
```

* An Agreement is made up of three uint256 variables inwhich we use to pack booleans representing various parts of the agreement. We do this by calling ```packSingleBool(bool _singleBool, uint _index, uint _id, uint info)```.

```
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
```

* We bitshift using our _index arg which allows us to true/false any given slot within the uint256.

```
    // Item Id => Stage => Error
    mapping(uint=> mapping(uint => bytes)) internal stageToErrors;
    // Item Id => Stage => Amount paid
    mapping(uint=> mapping(uint => uint)) internal stageToPaid;
```

* Using the itemId we can associate data with any given storage slot using these mappings and our injector functions.

```
    /// @param _id of item in items array
    /// @param _index of stage
    /// @param _info i.e 0=stageConfirms, 1=stagePaid, 2=stageErrors etc
    /// @param _error bytes error message
    function injectStageError(uint _id, uint _index, uint _info, bytes memory _error) external {
        stageToErrors[_id][_index] = _error;
        packSingleBool(true, _index, _id, _info);
    }
```

* Here we simply map the error to the stage using the itemId.

```
    /// @param _id of item in items array
    /// @param _index of stage
    function getStageError(uint _id, uint _index) external view returns (bytes memory) {
        return stageToErrors[_id][_index];
    }

```

* Either use this approach of add public visibilty to the mappings to return the error or payment amounts.

```
    /// @param _packed where the uint that we have packed bools into
    /// @param _index confirmation stage to unpack i.e warehouse, etc
    function unpackSingleBool(uint256 _packed, uint _index) internal pure returns (bool) {
        return (_packed & (1 << _index)) != 0;
    }
```

* In order to return whether the slot is true or false we simply take the uint256 variable and bitshift again using our index and ensuring that it's not equal to zero, meaning if it is equal to zero then it is false. By default all values are false.


## Gas results

These are the gas results.

| src/SupplyChain/SupplyChainAdv.sol:SupplyChain contract ||||||
|---------------------------------------------------------|-----------------|-------|--------|-------|---------|
| <h2>Function Name</h2>                                         |min             | avg   | median    | max   | # calls       |
| getStagePayment                                         | 577             | 577   | 577    | 577   | 1       |
| injectStageError                                        | 23910           | 35860 | 35860  | 47810 | 2       |
| injectStagePayment                                      | 23114           | 35064 | 35064  | 47014 | 2       |
| retrieveItemStatus                                      | 787             | 949   | 810    | 2833  | 14      |
| setItemStatus                                           | 440             | 11290 | 7647   | 22798 | 15      |
