// SPDX-License-Identifier: MIT
//pragma
pragma solidity ^0.8.0;

// imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

// error codes
error FundMe__NotOwner();
error FundMe__NotEnoughETH();

//interfaces, libarary and contracts

/**@title A contract for crowd funding
 * @author Neel Patel
 * @notice this is a demo contract for creating crowd funding
 * @dev this implements price feeds as our library
 */

contract FundMe {
    using PriceConverter for uint256; //mapped library functions on uint256 data types

    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address private immutable i_owner;

    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address _priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    //what if someone accidentally transfer money into this contract

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     * @notice this function funds contract
     * @dev this implement price feed as library
     */

    function fund() public payable {
        //want to be able to set a minimum fund amount in INR
        if (!(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD)) {
            revert FundMe__NotEnoughETH();
        }
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    /**
     * @notice This function allows owner to widraw the funds
     */
    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        //reset array
        s_funders = new address[](0);
        //actually widraw the funds
        // //transfer: return error and revert the transation if fails
        // payable(msg.sender).transfer(address(this).balance);
        // //send: return boolean and we have to explicitly write require to revert transaction
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send Failed");

        //call:
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
    }

    function efficientWithdraw() public onlyOwner {
        address[] memory funders = s_funders;

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        //reset array
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
    }

    //view and pure functions

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
