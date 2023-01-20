# README

## Introduction

This smart contract is for a minimal logistics supply chain management system, which focuses on using bitwise operations to pack boolean values into a single uint256 variable. This approach is more gas efficient than using enums as it reduces storage usage.

## Contract Design

The contract is implemented in the SupplyChainAdv.sol file and features an Agreement struct that is composed of three uint256 variables. These variables are used to store boolean values that represent various stages of the agreement. The packSingleBool() function is used to pack these values, taking in a boolean value, an index, an item array id, and an information variable as parameters.

The contract also features mappings that allow for associating data with specific storage slots using itemIds. Injector functions are used to map error messages to specific stages using the itemId. To retrieve the error message, getter functions are used.

***

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

***

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

***


```
    // Item Id => Stage => Error
    mapping(uint=> mapping(uint => bytes)) internal stageToErrors;
    // Item Id => Stage => Amount paid
    mapping(uint=> mapping(uint => uint)) internal stageToPaid;
```

* Using the itemId we can associate data with any given storage slot using these mappings and our injector functions.

***


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

***


```
    /// @param _id of item in items array
    /// @param _index of stage
    function getStageError(uint _id, uint _index) external view returns (bytes memory) {
        return stageToErrors[_id][_index];
    }

```

* Either use this approach of add public visibilty to the mappings to return the error or payment amounts.

***


```
    /// @param _packed where the uint that we have packed bools into
    /// @param _index confirmation stage to unpack i.e warehouse, etc
    function unpackSingleBool(uint256 _packed, uint _index) internal pure returns (bool) {
        return (_packed & (1 << _index)) != 0;
    }
```

* In order to return whether the slot is true or false we simply take the uint256 variable and bitshift again using our index and ensuring that it's not equal to zero, meaning if it is equal to zero then it is false. By default all values are false.

***



## Gas results

These are the gas results.

| src/SupplyChain/SupplyChainAdv.sol:SupplyChain contract |                 |        |        |        |         |
|---------------------------------------------------------|-----------------|--------|--------|--------|---------|
| Deployment Cost                                         | Deployment Size |        |        |        |         |
| 986621                                                  | 4960            |        |        |        |         |
| Function Name                                           | min             | avg    | median | max    | # calls |
| createNewAgreementX                                     | 141219          | 141219 | 141219 | 141219 | 1       |
| createNewItem                                           | 52275           | 52275  | 52275  | 52275  | 5       |
| getItem                                                 | 4168            | 4168   | 4168   | 4168   | 1       |
| getItemX                                                | 9122            | 9122   | 9122   | 9122   | 1       |
| getStageError                                           | 1514            | 1514   | 1514   | 1514   | 2       |
| getStagePayment                                         | 578             | 578    | 578    | 578    | 1       |
| getStageStatusX                                         | 1018            | 1048   | 1054   | 1068   | 4       |
| injectStageError                                        | 23910           | 35860  | 35860  | 47810  | 2       |
| injectStagePayment                                      | 23115           | 35065  | 35065  | 47015  | 2       |
| retrieveItemStatus                                      | 743             | 905    | 766    | 2789   | 14      |
| setItemStatus                                           | 498             | 11939  | 14255  | 22856  | 16      |
| setItemStatusX                                          | 724             | 7631   | 1110   | 21060  | 3       |

***

## Findings

Testing has shown that using bitwise operations to pack boolean values into a single uint256 variable is more gas efficient than using enums. The gas cost difference between creating an agreement with three uint256 variables and one with 2 boolean arrays and an enum is significant, resulting in a near 3x reduction in gas usage. Additionally, we have found that getter functions are more expensive than their counterpart functions and that changing the value of an array of booleans and the value of an enum is less gas intensive than packing booleans into uint256 slots.

## Further Scope
...