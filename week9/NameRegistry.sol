// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NameRegistry{
    // 컨트랙트 정보를 저장하는 구조체
    struct ContractInfo{
        address contractOwner; // 컨트랙트 소유자의 주소
        address contractAddress; // 컨트랙트의 주소
        string description; // 컨트랙트에 대한 설명
    }
    uint public numContracts; // 저장된 컨트랙트의 개수
    mapping (string => ContractInfo) public registeredContracts; // 컨트랙트 저장하는 mapping

    event ContractRegistered(string _name); // 컨트랙트 등록 시 이벤트
    event ContractDeleted(string _name); // 컨트랙트 삭제 시 이벤트
    event ContractUpdated(string _name, string _ev); // 컨트랙트 업데이트 시 이벤트

    modifier onlyOwner(string memory _name){ // 컨트랙트의 owner만 접근하도록 하는 modifier
        require(registeredContracts[_name].contractOwner == msg.sender, "Only owner can access");
        _;
    }
    constructor(){ // 컨트랙트 개수를 0으로 초기화
        numContracts = 0;
    }
    // 컨트랙트를 등록하는 함수
    function registerContract(string memory _name, address _contractAddress, string memory _description) public {
        // 빈 주소인 경우에만 등록하도록 함
        require(registeredContracts[_name].contractAddress == address(0), "Only new contract!");
        // 구조체로 mapping에 추가(_name이 키)
        registeredContracts[_name] = ContractInfo(msg.sender, _contractAddress, _description);
        numContracts++;
        emit ContractRegistered(_name);
    }
    // 컨트랙트를 삭제하는 함수(컨트랙트 owner만 가능)
    function unregisterContract(string memory _name) public onlyOwner(_name){
        // 없는 컨트랙트가 아닐 때만 삭제
        require(registeredContracts[_name].contractAddress != address(0), "Only existing contract!");
        // mapping에서 삭제
        delete registeredContracts[_name];
        numContracts--; // 개수 줄이기
        emit ContractDeleted(_name);
    }
    // owner를 변경하는 함수(컨트랙트 owner만 가능)
    function changeOwner(string memory _name, address _newOwner) public onlyOwner(_name){
        // 존재하는 컨트랙트만 owner를 바꾸도록 함
        require(_newOwner != address(0), "Only existing account!");
        registeredContracts[_name].contractOwner = _newOwner; // 새로운 owner로 바꿈
        emit ContractUpdated(_name, "change owner");
    }
    // 컨트랙트의 owner를 확인할 수 있는 함수
    function getOwner(string memory _name) public view returns (address){
        return registeredContracts[_name].contractOwner;
    }
    // 컨트랙트의 주소를 변경할 수 있는 함수(컨트랙트의 owner만 접근 가능)
    function setAddr(string memory _name, address _addr) public onlyOwner(_name){
        registeredContracts[_name].contractAddress = _addr; // 컨트랙트 주소 변경
        emit ContractUpdated(_name, "change address");
    }
    // 컨트랙트의 주소를 반환하는 함수
    function getAddr(string memory _name) public view returns (address){
        return registeredContracts[_name].contractAddress;
    }
    // 컨트랙트의 설명을 변경하는 함수(컨트랙트의 owner만 가능)
    function setDescription(string memory _name, string memory _description) public onlyOwner(_name){
        registeredContracts[_name].description = _description; // 컨트랙트의 설명 변경
        emit ContractUpdated(_name, "change decription");
    }
    // 컨트랙트의 설명을 반환하는 함수
    function getDescription(string memory _name) public view returns(string memory) {
         return registeredContracts[_name].description;
    }
}