// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Bank {
    // 이벤트에는 address와 amount를 인자로 보내도록 함
    event Deposit(address _address, uint amount);
    event Withdrawal(address _address, uint amount);
    // 계좌별로 금액을 저장할 mapping 자료구조
    mapping (address => uint) private data;
    // 배포자를 저장해둘 변수
    address private owner;
    constructor(){ // owner를 저장함
        owner = msg.sender;
    }
    modifier onlyOwner(){
        // owner를 확인하는 modifier
        require(msg.sender == owner, "Only Owner can access");
        _;
    }
    function deposit() public payable { // 입금 시에 mapping의 account에 더해줌
        emit Deposit(msg.sender, msg.value);
        data[msg.sender] += msg.value;
    }
    function withdraw(uint256 amount) public { // 출금하는 함수
        // amount Ether만큼 출금하기 위해서 기본적으로 wei인 것에 맞춰주기 위한 변수
        uint256 wei_amount = amount * (10 ** 18);
        require(data[msg.sender] >= wei_amount, "Too much withdraw"); // 가진 것보다 더 많이 출금 방지
        emit Withdrawal(msg.sender, wei_amount);
        // 자료구조 내에서도 빼주고 transfer로 사용자에게도 보내줌
        data[msg.sender] -= wei_amount;
        payable(msg.sender).transfer(wei_amount);
    }
    function getBalance() public view returns(uint256){ // wei 단위로 가진 금액 반환
        return data[msg.sender];
    }
    function getContractBalance() public view onlyOwner returns(uint256){ // Bank 전체 금액 wei 단위로 반환
        return address(this).balance;
    }
}