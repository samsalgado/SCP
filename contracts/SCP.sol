// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;
 import "./IERC721.sol";
 import "./IERC721Receiver.sol";
 


 contract SupplyChainProtocol is IERC721 {
  
    string public override constant name = "SupplyChainProtocol";
    string public override constant symbol= "SCP";
    bytes4 internal constant MAGIC_ERC721_RECEIVED = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
   uint256 public orderId;
    
    /**
     *  bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *  bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *  bytes4(keccak256('approve(address, uint256)')) == 0x095ea7b3
     *  bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *  bytes4(keccak256('setApprovalForAll(address, bool)')) == 0xa22cb465
     *  bytes4(keccak256('isApprovedForAll(address, address)')) == 0xe985e9c5
     *  bytes4(keccak256('transferFrom(address, address, uint256)')) == 0x23b872dd
     *  bytes4(keccak256('safeTransferFrom(address, address, uint256)')) == 0x42842e0e
     *  bytes4(keccak256('safeTransferFrom(address, address, uint256, bytes)')) == 0xb88d4fde
     *  
     *  => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *     0xa22cb465 ^ 0xe985e9c5 ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /**
     *  bytes4(keccak256('supportsInterface(bytes4)'));
    */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    
  struct Order{
      uint256 id;
      uint64 cost;
      string productName;
      string description;
      uint64 leadTime_in_days;
    }
    Order[] private orderVolume;
    
   
   
    mapping(address => uint256) private balances;
    mapping(address => uint256) private OrderIncites;
    mapping(uint256 => address) private orderIdMapping;
    mapping(uint256 => address) private orderIndexToApproved;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
   event OrderMade(address owner,
     uint256 OrderVolumeId,
      uint256 cost,
      string productName,
      string description,
      uint256 leadTime_in_days
    );
    function _createOrder(uint256 _ID,
        uint64 _cost,
        string memory _productName,
        string memory _description,
        uint64 _leadTime_in_days,
        address _owner
       ) external returns (uint256) {
           
         Order memory _order = Order({
             id:_ID,
             cost: uint32(_cost),
             productName: string(_productName),
             description: string (_description),
             leadTime_in_days: uint32(_leadTime_in_days)
             });
             
          orderVolume.push(_order);
          uint256 newOrderVolumeId=orderVolume.length - 1;
          emit OrderMade(_owner, newOrderVolumeId, _cost, _productName, _description, _leadTime_in_days);
          _transfer(address(0), _owner, newOrderVolumeId);
          orderId++;
          return newOrderVolumeId;  

    }
  
    function getOrder(uint256 _id) external view returns(
        uint256 id,
        uint256 cost,
        string memory productName,
        string memory description,
        uint256 leadTime_in_days
    ) {
        return (
            orderVolume[_id].id,
            orderVolume[_id].cost,
            orderVolume[_id].productName,
            orderVolume[_id].description,
            orderVolume[_id].leadTime_in_days
        );
    } 
    function getOrderId() public returns (uint256) {
        uint256 newOrderVolumeId=orderVolume.length - 1;
        return newOrderVolumeId;
    }
 
    function totalSupply() external view override returns (uint256 total){
        return orderVolume.length;
    }
 
    function balanceOf(address owner) external view override returns (uint256 balance){
        return OrderIncites[owner];
    }
    function ownerOf(uint256 tokenId) public view returns (address owner){
        return orderIdMapping[tokenId];
        
    }
 

    
    function transfer( address to, uint256 tokenId) external override{
        require(address(to) != address(0));
        require(to != address(this));
        require(_owns(msg.sender, tokenId));
        _transfer(msg.sender,to,tokenId);
    }
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        balances[_to]++;
        _to=orderIdMapping[_tokenId];
        if(_from != address(0)) {
            balances[_from]--;
            delete orderIndexToApproved[_tokenId];
        }
        emit Transfer(_from, _to, _tokenId);

    }
    function _owns(address _claimant, uint256 _tokenId) internal view returns(bool){
        return orderIdMapping[_tokenId] == _claimant;
    }
     function approve(address _approved, uint256 _tokenId)public override payable {
        require(_approved != address(0));
        require(_owns(msg.sender, _tokenId));
        _approve(_approved, _tokenId);
        emit Approval(orderIdMapping[_tokenId], _approved, _tokenId);
    }
    
     function setApprovalForAll(address operator, bool _approved) external override{ 
        require(operator != address(0));
        require(operator != msg.sender);
        _setApprovalForAll(operator, _approved);
        emit ApprovalForAll(msg.sender, operator, _approved);
    }

    function _setApprovalForAll(address _operator, bool _approved) internal{
        _operatorApprovals[msg.sender][_operator] = _approved;
    }

    function getApproved(uint256 _tokenId) external view override returns (address){
        require(_tokenId < orderVolume.length);//check that the token exists
        return orderIndexToApproved[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) external override view returns (bool){
        //returns the mapping status for these inputs
        return _operatorApprovals[_owner][_operator];
    } 
    function _checkERC721Support(address _from, address _to, uint256 _tokenId, bytes memory _data) internal returns (bool) {
        if (!_isContract(_to)) {
            return true;
        }

        // Call onERC721Received in the _to contract
        bytes4 returnData = IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
        return returnData == MAGIC_ERC721_RECEIVED;
    }
     function _isContract(address _to) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_to)
        }
        return size > 0;
    }
    
    
    function safeTransferFrom(address _from, address  _to, uint256 _tokenId, bytes memory data) public override payable {
        require(_isApprovedOrOwner(msg.sender, _from, _to, _tokenId));
        _safeTransfer(_from, _to, _tokenId, data);

    }
     function transferFrom(address _from, address _to, uint256 _tokenId) external override payable{
        require(_to != address(0));
        address owner = orderIdMapping[_tokenId];
        require(_to != owner); // not sending to the owner
        require(msg.sender == _from || approvedFor(msg.sender, _tokenId) || this.isApprovedForAll(owner, msg.sender)); // currenct address is the owner of the token
        require(_owns(_from, _tokenId), "From is not the owner of the token");
        require(_tokenId < orderVolume.length, "Token ID is not valid");

        _transfer(_from, _to, _tokenId);
    }
    
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(from, to, tokenId);
        require(_checkERC721Support(from, to, tokenId, _data));
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external override payable {
        safeTransferFrom(_from, _to, _tokenId,"");

    }

    function _approve(address _approved, uint256 _tokenId) private {
        orderIndexToApproved[_tokenId] = _approved;
    }
    function approvedFor(address claimant, uint256 tokenId) internal view returns(bool){
        return orderIndexToApproved[tokenId] == claimant;
    }

    function _isApprovedOrOwner(address spender, address _from, address _to, uint256 _tokenId) private view returns(bool) {
        require(_tokenId < orderVolume.length);
        require(_to != address(0));
        address owner = orderIdMapping[_tokenId];
        require(_to != owner);
        require(_owns(_from, _tokenId));
        //Error at approve(spender, _tokenId)
        return (spender == _from || approvedFor(spender, _tokenId) || this.isApprovedForAll(owner, spender) );
    }
  
   
    
 }    


 
   
