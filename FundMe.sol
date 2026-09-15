
// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {

    using PriceConverter for uint256;

    uint256 public constant minimumUsd = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= minimumUsd, "didn't send enough ETH"); // 1e18 = 1 ETH
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
    }

    function withdraw() public onlyOwner {
    
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }


    modifier onlyOwner(){
        if(msg.sender != owner){
            revert NotOwner();
        }
        _;
    }


}
