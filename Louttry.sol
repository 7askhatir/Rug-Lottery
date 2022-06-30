contract Lottery{
    using Strings for uint256;
    using SafeMath for uint256;
    struct TiketsForOwner{
        uint idTickets;
        uint from;
        uint to;
        address token;
    }
    struct TicketWiner{
        uint idTikets;
        address ownerContat;

    }
    NFT nftContrat;
    address owner;
    address addressNft;
    mapping(uint=>address) public ownerOfTicket;
    uint256 idTicket=0;
    uint idList=1;
    address adreessToken;
    TiketsForOwner[] public tikets;
    event StartLottery(address[]  tokens);
    address[] tokensForThisMounts;
    constructor(address _adreessNft, address _adreessToken){
          addressNft=_adreessNft;
          nftContrat=NFT(addressNft);
          owner=msg.sender;
          adreessToken=_adreessToken;

      }
     modifier onlyOwner() {
        require(_owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
     function _msgSender() internal view virtual returns (address) {
        return msg.sender;
      }
      function _owner() public view virtual returns (address) {
        return owner;
      }
      function getAllTokensForThisMounts() public view returns(address[] memory){
        return tokensForThisMounts;
      }

    function sendTicketsToUser(uint _numberOfTicket,address _token) public {
      TiketsForOwner memory newTickets=TiketsForOwner(idList,idTicket+1,idTicket+_numberOfTicket,_token);
      tikets.push(newTickets);
      ownerOfTicket[idList]=msg.sender;
      idTicket+=_numberOfTicket;
      idList++;
    }
    
    function returnMultipleById(uint _tokenId,uint _numberOfTicket) public returns(uint256){
     NFT.Nft memory nftCanShared=nftContrat.getNftById(_tokenId);
     require(nftCanShared.hearts>0,"this nft dosn't have healt for this operation");
     uint mulNft=100;
         uint256 numberOfTikets=_numberOfTicket;
         if(_tokenId!=0){
            require(nftContrat.ownerOf(_tokenId)==_msgSender(),"your are not owner of this nft");
            require(nftCanShared.hearts>0,"your are not owner of this nft");
             if(nftCanShared.level==nftContrat.Bronze() && !nftCanShared.Shield){
                 mulNft=intervalRandom(101,105);
             }
             else if(nftCanShared.level==nftContrat.Bronze() && nftCanShared.Shield){
                 mulNft=intervalRandom(106,110);
             }
             else if(nftCanShared.level==nftContrat.Silver() && !nftCanShared.Shield){
                 mulNft=intervalRandom(111,120);
             }
             else if(nftCanShared.level==nftContrat.Silver() && nftCanShared.Shield){
                 mulNft=intervalRandom(121,125);
             }
             else if(nftCanShared.level==nftContrat.Gold()){
                 mulNft=intervalRandom(150,170);
             }
             else if(nftCanShared.level==nftContrat.Diamond()){
                 mulNft=intervalRandom(190,200);
             }
             nftContrat.incrementPoints(_tokenId);
             nftContrat.decrementHearts(_tokenId);
         }
         
         return numberOfTikets*mulNft;

    }
     function intervalRandom(uint _from ,uint _to) public view returns(uint256){
        uint256 hash=112233445566778899**2;
        uint256  rnd=uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,hash)));
        return _from+rnd.mod(_to.sub(_from).add(1));
    }
    function getWinnerId(uint _id) public view returns(TicketWiner memory ){
       TicketWiner memory ticketWiner;
       for(uint indexOfArray=0;indexOfArray<tikets.length;indexOfArray++){
       if(tikets[indexOfArray].from<= _id && _id<=tikets[indexOfArray].to)
        ticketWiner=TicketWiner(tikets[indexOfArray].idTickets,ownerOfTicket[tikets[indexOfArray].idTickets]);
             
     }
      return ticketWiner;
    }
    function LotteryMounth(address[] memory _tokensForThisMounts) public {
        tokensForThisMounts=_tokensForThisMounts;
    }
    function checkBalanceToken(address _tokenAddress,address _user) public view returns(uint ){
         return ERC20(_tokenAddress).balanceOf(_user);
    }
     function approuveThisToken(address _tokenAddress,uint _amount) public {
        ERC20(_tokenAddress).approve(address(this), _amount);
    }
    function getTicketForCharedBalnce(address _tokenAddress,address _user) public returns(uint){
      uint256 tokenAmount = checkBalanceToken(_tokenAddress,_user);
      uint256 gardInoAmount=checkBalanceToken(adreessToken,_user).div(10**18);
      require(tokenAmount>0,"Your balance not suffisant");
      require(gardInoAmount>0,"Your balance GardIno not suffisant");
      require(checkAddressInLotteryMounth(_tokenAddress),"this token not in list of token for this month");
      require(!checkUseralreadyParticipatingForThisToken(_user,_tokenAddress),"you are already Participating For This Token");
      _safeTransferFrom(ERC20(_tokenAddress),_user,owner,tokenAmount);
      return gardInoAmount;
    }
    function enterToLuttory(address _tokenAddress,uint _tokenId) public  {
      uint numberOfTicket=getTicketForCharedBalnce(_tokenAddress,_msgSender());
      sendTicketsToUser(returnMultipleById(_tokenId,numberOfTicket).div(100),_tokenAddress);
      
    }


   function checkAddressInLotteryMounth(address _tokenAddress) public view returns (bool){
        bool check=false;
        for(uint i=0;i<tokensForThisMounts.length;i++)
        if(tokensForThisMounts[i]==_tokenAddress)
        check=true;
        return check;
    }
    function checkUseralreadyParticipatingForThisToken(address _user,address _token) public view returns(bool){
        bool check=false;
        for(uint i=0;i<tikets.length;i++)
        if(tikets[i].token==_token && ownerOfTicket[tikets[i].idTickets]==_user)
        check=true;
        return check;
    }

    function _safeTransferFrom(
        ERC20 token,
        address sender,
        address recipient,
        uint amount
    ) private {
        require(sender != address(0),"address of sender Incorrect ");
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }

} 
