# README

## Introduction

This smart contract is for a minimal logistics supply chain management system, which focuses on packing booleans into a single `uint256` variable to represent the stages of production and transportation of a product. This approach is more gas efficient than using enums as we'll explore further.

## Contract Design
TODO


## Gas comparison results

These are the gas comparison results.

| Deployment Cost| Deployment Size |       |        |       |         |
| 162808         | 845             |       |        |       |         |
| Function Name  | min             | avg   | median | max   | # calls |
| setItemStages  | 22528           | 22528 | 22528  | 22528 | 1       |
| setItemStatus  | 7620            | 16353 | 20720  | 20720 | 3       |