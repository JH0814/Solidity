// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Lottery{
    address public manager; // Owner
    address[] public players; // 참가자 정보 저장

    // 단계 표시하는 enum
    enum Status{Enter, Done}
    Status gameStat = Status.Enter;

    event in_player(address _addr); // player 등록 시 event
    event Winner(address _addr, uint amount); // Winner 정한 후 event

    modifier restricted(){ // manager만 접근하도록 하는 modifier
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }

    modifier res_sta(Status game){ // 단계를 맞추기 위한 modifier
        require(gameStat == game, "Need to Same status");
        _;
    }
    constructor(){
        manager = msg.sender; // manager에 배포자 저장
    }
    function getPlayers() public view returns (address[] memory) { // player 목록 반환하는 함수
        return players;
    }

    function next_step() public restricted{ // 다음 단계로 변경해주는 함수(manager만 호출가능)
        // if 문으로 구분하였음
        if(gameStat == Status.Enter) gameStat = Status.Done;
        else gameStat = Status.Enter;
    }

    function enter() public payable res_sta(Status.Enter) { // player를 추가하는 함수
        // 1 ether로만 등록하도록 제한
        require(msg.value == 1 ether, "Only 1 Ether is Allowed");
        // 배포자는 등록 불가
        require(msg.sender != manager, "manager can't bet");
        // for 문으로 array 내에 기존에 등록한 address인지 확인 
        bool t = false;
        for(uint i = 0; i<players.length; i++){
            if(players[i] == msg.sender) t = true;
        }
        // array 내에서 발견되지 않은 경우만 뒤를 실행하도록 함
        require(!t, "You can participate only once.");
        // array에 추가
        players.push(msg.sender);
        emit in_player(msg.sender); // player 추가 이벤트
    }

    function random() private view returns (uint){ // 랜덤 생성 함수
        return uint(keccak256(abi.encodePacked(block.number, block.timestamp, players.length)));
    }
    function pickWinner() public restricted res_sta(Status.Done) { // 승자를 random 함수를 이용해서 고름
        // player가 없는 경우에 대해서 처리
        require(players.length > 0, "No players participated");
        // 승자를 고름
        address winner = players[(random()) % players.length];
        // 컨트랙트에 있는 금액 전부가 상금이므로 저장해둠
        uint prize = address(this).balance;
        // 상금 승자에 전송
        payable(winner).transfer(prize);
        // players 초기화
        delete players;
        emit Winner(winner, prize); // 승자 이벤트
    }
}