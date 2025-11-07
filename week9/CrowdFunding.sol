// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFunding{
    struct Investor{
        address addr;
        uint amount;
    }
    mapping (uint => Investor) public investors;
    address public owner;
    uint public numInvestors;
    uint public deadline;
    string public status;
    bool public ended;
    uint public goalAmount;
    uint public totalAmount;
    event Funded(address _addr, uint amount);

    address[] public Inv_arr;

    modifier onlyOwner(){
        require(owner == msg.sender, "Only owner can execute");
        _;
    }
    constructor(uint _duration, uint _goalAmount){
        owner = msg.sender;
        deadline = block.timestamp + _duration;
        goalAmount = _goalAmount * (10 ** 18);
        status = "Funding";
        ended = false;
        numInvestors = 0;
        totalAmount = 0;
    }
    function fund() public payable {
        require(block.timestamp < deadline, "Funding End!");
        totalAmount += msg.value;
        investors[numInvestors].addr = msg.sender;
        investors[numInvestors].amount += msg.value;
        emit Funded(msg.sender, msg.value);
        numInvestors++;
    }
    function checkGoalReached() public onlyOwner{
        require(block.timestamp >= deadline, "Funding is not ended!");
        require(ended == false, "Already Checked");
        if(totalAmount >= goalAmount){
            payable(owner).transfer(totalAmount);
            status = "Campaign Succeeded";
        }
        else{
            for(uint i = 0; i<numInvestors; i++){
                payable(investors[i].addr).transfer(investors[i].amount);
                investors[i].amount = 0;
            }
            status = "Campaign Failed";
        }
        ended = true;
    }
    function getInvestors() public returns (address[] memory){
        for(uint i = 0; i<numInvestors; i++){
            Inv_arr.push(investors[i].addr);
        }
        return Inv_arr;
    }
}