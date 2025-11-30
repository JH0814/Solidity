// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract ERC20StdToken{
    mapping (address => uint256) balances; // 계정별 토큰수 저장
    mapping (address => mapping (address => uint256)) allowed; // 위임허용 토큰 저장
    uint256 private total; // 전체 토큰
    string public name; // 토큰 이름
    string public symbol; // 토큰 단위
    uint8 public decimals;
    // 토큰 받거나 허용하는 이벤트
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    constructor (string memory _name, string memory _symbol, uint _totalSupply){
        total = _totalSupply;
        name = _name;
        symbol = _symbol;
        decimals = 0;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0x0), msg.sender, _totalSupply); // 초기 토큰 생성 이벤트
    }
    function totalSupply() public view returns (uint256){ // 전체 토큰 리턴
        return total;
    }
    function balanceOf(address _owner) public view returns (uint256 balance){// 계정의 토큰보유량 리턴
        return balances[_owner];
    }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){ // 위임 토큰양 리턴
        return allowed[_owner][_spender];
    }
    function transfer(address _to, uint256 _value) public returns (bool success){ // 토큰 전송
        require(balances[msg.sender] >= _value, "Require more token"); // 가진 토큰 이상으로 보내는지 확인
        if(balances[_to] + _value >= balances[_to]){ // 오버플로우 체크
            // mapping에서 빼주는 방식
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value); // 이벤트 발생
            return true;
        }
        else{
            return false;
        }
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){// 위임해서 전송
        require(balances[_from] >= _value, "Require more token"); // 가진 양보다 많이 보내는지 확인
        require(allowance(_from, msg.sender) >= _value, "Require more allow"); // 허용된 양보다 많이 보내는지 확인
        if(balances[_to] + _value >= balances[_to]){ // 오버플로우 체크
            balances[_from] -= _value;
            balances[_to] += _value;
            allowed[_from][msg.sender] -= _value; // 허용양에서도 빼줌
            emit Transfer(_from, _to, _value); // 이벤트 발생
            return true;
        }
        else{
            return false;
        }
    }
    function approve(address _spender, uint256 _value) public returns (bool success){ // 위임할 토큰양 허용하는 함수
        allowed[msg.sender][_spender] = _value; // =로 표기
        emit Approval(msg.sender, _spender, _value); // 이벤트 발생
        return true;
    }
}