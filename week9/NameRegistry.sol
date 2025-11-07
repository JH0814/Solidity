// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NameRegistry{
    struct ContractInfo{
        address contractOwner;
        address contractAddress;
        string description;
    }
    uint public numContracts;
    mapping (string => ContractInfo) public registeredContracts;

    event ContractRegistered();
    event ContractDeleted();
    event ContractUpdated(string _ev);

    modifier onlyOwner(string memory _name){
        require(registeredContracts[_name].contractOwner == msg.sender, "Only owner can access");
        _;
    }
    constructor(){
        numContracts = 0;
    }
    function registerContract(string memory _name, address _contractAddress, string memory _description) public {
        require(registeredContracts[_name].contractAddress == address(0), "Only new contract!");
        registeredContracts[_name] = ContractInfo(msg.sender, _contractAddress, _description);
        numContracts++;
        emit ContractRegistered();
    }
    function unregisterContract(string memory _name) public onlyOwner(_name){
        require(registeredContracts[_name].contractAddress != address(0), "Only existing contract!");
        delete registeredContracts[_name];
        numContracts--;
        emit ContractDeleted();
    }
    function changeOwner(string memory _name, address _newOwner) public onlyOwner(_name){
        require(_newOwner != address(0), "Only existing account!");
        registeredContracts[_name].contractOwner = _newOwner;
        emit ContractUpdated("change owner");
    }
    function getOwner(string memory _name) public view returns (address){
        return registeredContracts[_name].contractOwner;
    }
    function setAddr(string memory _name, address _addr) public onlyOwner(_name){
        registeredContracts[_name].contractAddress = _addr;
        emit ContractUpdated("change address");
    }
    function getAddr(string memory _name) public view returns (address){
        return registeredContracts[_name].contractAddress;
    }
    function setDescription(string memory _name, string memory _description) public onlyOwner(_name){
        registeredContracts[_name].description = _description;
        emit ContractUpdated("change decription");
    }
    function getDescription(string memory _name) public view returns(string memory) {
         return registeredContracts[_name].description;
    }
}