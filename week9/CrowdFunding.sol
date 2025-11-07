// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrowdFunding{
    // 투자자 정보를 저장할 구조체
    struct Investor{
        address addr; // 투자자의 주소
        uint amount; // 투자한 금액
    }
    mapping (uint => Investor) public investors; // 투자자의 정보를 저장할 mapping
    address public owner; // 투자받는 사람의 주소를 저장
    uint public numInvestors; // 투자자의 수
    uint public deadline; // 펀딩 마감 시간
    string public status; // 펀딩의 진행 상태
    bool public ended; // 펀딩의 종료 여부
    uint public goalAmount; // 펀딩의 목표 금액
    uint public totalAmount; // 펀딩의 총 금액
    // 투자가 있을 때마다 저장하는 이벤트
    event Funded(address _addr, uint amount);

    address[] public Inv_arr; // 투자자 저장하는 array

    modifier onlyOwner(){ // owner만 실행할 수 있게 하는 modifier
        require(owner == msg.sender, "Only owner can execute");
        _;
    }
    constructor(uint _duration, uint _goalAmount){
        owner = msg.sender; // owner 정해줌
        deadline = block.timestamp + _duration; // 끝나는 시간 설정
        goalAmount = _goalAmount * (10 ** 18); // ether 단위로 저장하는 목표 금액
        status = "Funding"; // 펀딩의 상태를 Funding으로
        ended = false;
        // 초기화
        numInvestors = 0;
        totalAmount = 0;
    }
    function fund() public payable { // 투자를 받는 함수(ether로 받음)
        // 기한이 지나지 않았을 때만 투자할 수 있음
        require(block.timestamp < deadline, "Funding End!");
        totalAmount += msg.value; // 총 투자 금액에 더해줌
        // 만든 mapping에 보낸 주소와 투자한 금액을 더해줌
        investors[numInvestors].addr = msg.sender;
        investors[numInvestors].amount += msg.value;
        emit Funded(msg.sender, msg.value); // 해당 이벤트 발생
        numInvestors++; // 투자자 수 더해줌
    }
    function checkGoalReached() public onlyOwner{ // 투자가 끝났는지 확인하는 함수(owner만 실행가능)
        // 펀딩이 끝났을 때만 한 번만 실행 가능
        require(block.timestamp >= deadline, "Funding is not ended!");
        require(ended == false, "Already Checked");
        if(totalAmount >= goalAmount){ // 펀딩 목표 달성 시
            // 펀딩 연 사람에게 금액 전달 후 status 변경
            payable(owner).transfer(totalAmount);
            status = "Campaign Succeeded";
        }
        else{ // 목표 달성 실패시
            for(uint i = 0; i<numInvestors; i++){ // mapping을 돌면서 원래 투자자에게 금액 반환
                payable(investors[i].addr).transfer(investors[i].amount);
                investors[i].amount = 0; // mapping의 값은 0으로 돌려줌
            }
            status = "Campaign Failed"; // status 변경
        }
        // 두 경우 모두 ended는 true로 변경하여 한 번만 실행되도록 함
        ended = true;
    }
    function getInvestors() public returns (address[] memory){ // 투자자 목록을 반환하는 함수
        for(uint i = 0; i<numInvestors; i++){ // mapping을 순환하며 array에 추가
            Inv_arr.push(investors[i].addr);
        }
        return Inv_arr; // array 반환
    }
}