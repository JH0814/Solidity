// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface ERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
interface ERC721 is ERC165 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
interface ERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4);
}


contract ERC721StdNFT is ERC721 {
    address public founder;
    // Mapping from token ID to owner address(각 NFT의 소유자 주소)
    mapping(uint => address) internal _ownerOf; // tokenId → owner
    // Mapping owner address to token count(특정 주소가 보유한 NFT의 개수)
    mapping(address => uint) internal _balanceOf; // owner → number of NFTs
    // Mapping from token ID to approved address(특정 NFT를 대신 전송할 권리를 부여받은 주소를 저장)
    mapping(uint => address) internal _approvals; // tokenId → approved
    // Mapping from owner to operator approvals(특정 주소가 소유자의 모든 NFT를 관리할 권한이 있는지)
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    string public name;
    string public symbol;

    constructor (string memory _name, string memory _symbol) {
        founder = msg.sender; // 토큰 발행한 사람
        name = _name; // 토큰 이름
        symbol = _symbol;
        for (uint tokenID=1; tokenID<=5; tokenID++) { // 1~5번 tokenID를 배포자에게 자동 발행
            _mint(msg.sender, tokenID);
        }
    }

    function _mint(address to, uint id) internal { // 새 토큰 발행 위한 내부 함수
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");
        _balanceOf[to]++;
        _ownerOf[id] = to;
        emit Transfer(address(0), to, id);
    }

    function mintNFT(address to, uint256 tokenID) public { // 새 토큰 발행
        require(msg.sender == founder, "not an authorized minter");
        _mint(to, tokenID);
    }
    function balanceOf(address _owner) external view override returns (uint256){ // 토큰 보유 확인
        require(_owner != address(0), "balance query for the zero address");
        return _balanceOf[_owner];
    }
    function ownerOf(uint256 _tokenId) external view override returns (address){ // 토큰 주인 확인
        address owner = _ownerOf[_tokenId];
        require(owner != address(0), "token doesn't exist");
        return owner;
    }
    function getApproved(uint256 _tokenId) external view override returns (address){ // 위임 여부 확인
        require(_ownerOf[_tokenId] != address(0), "token doesn't exist");
        return _approvals[_tokenId];
    }
    function isApprovedForAll(address _owner, address _operator) external view override returns (bool){
        return _operatorApprovals[_owner][_operator]; // 모두 허용인지 확인
    }

    function approve(address _approved, uint256 _tokenId) external override payable{ // 토큰 전송 다른 id에 허가
        address owner = _ownerOf[_tokenId]; // 토큰 주인 address
        require(msg.sender == owner || _operatorApprovals[owner][msg.sender], "not authorized"); // 소유자나 허가된 경우만 가능
        _approvals[_tokenId] = _approved; // 허가된 address 추가
        emit Approval(owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) override external{ // 운영자의 승인 설정 또는 해제
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) override external payable{
        _transferFrom( _from, _to, _tokenId);
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) private {
        address owner = _ownerOf[_tokenId];
        require(_from == owner, "from != owner");
        require(_to != address(0), "transfer to zero address");
        require(msg.sender == owner|| msg.sender == _approvals[_tokenId] || _operatorApprovals[owner][msg.sender]); //"msg.sender not in {owner,operator,approved}");
        _balanceOf[_from]--; // 보내는 사람 balance 감소
        _balanceOf[_to]++; // 받는 사람 balance 증가
        _ownerOf[_tokenId] = _to; // 토큰 소유자 변경
        _approvals[_tokenId] = address(0); // approval 초기화
        emit Transfer(_from, _to, _tokenId);
    }
    
    // 토큰 ID의 소유권을 안전하게 전송
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) override external payable{
        _transferFrom(_from, _to, _tokenId);
        require(_to.code.length == 0 || // 받는 주소에 코드가 없으면(EOA 지갑)
        ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data) == ERC721TokenReceiver.onERC721Received.selector, "unsafe recipient");

    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) override external payable{
        _transferFrom(_from, _to, _tokenId);
        require(_to.code.length == 0 || // 받는 주소에 코드가 없으면(EOA 지갑)
        ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, "") == ERC721TokenReceiver.onERC721Received.selector, "unsafe recipient");
    }
    // ERC-165 구현
    function supportsInterface(bytes4 interfaceID) external pure override returns (bool){
        return interfaceID == type(ERC721).interfaceId || interfaceID == type(ERC165).interfaceId;
    }
}