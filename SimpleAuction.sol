  // SPDX-License-Identifier: MIT
   pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Timers.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";



contract AuctionNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("AuctionNFT", "ANFT") {}

    // mint an NFT
    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }


    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    //    destroy an NFT
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    //    return IPFS url of NFT metadata
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

contract MyAuction {
    address payable public beneficiary;
    uint public autionEndTime;
    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) public pendingReturns;
    bool ended = false;
    event highestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);



// constructor when for when sdeploying the contract
    constructor (uint _biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        autionEndTime = block.timestamp + _biddingTime;
    }



// function to bid for an auction
 function bid() public payable{
     if (block.timestamp > autionEndTime){
         revert("The aution has already ended");
     }
   if (msg.value < highestBid){
       revert ("they is already a higher bidder");
   }
   if (highestBid !=0){
       pendingReturns[highestBidder] += highestBid;
   }
   highestBidder = msg.sender;
   highestBid = msg.value;
   emit highestBidIncrease(msg.sender, msg.value);
 }



// function to witdraw from the auction
 function Withdraw() public returns (bool){
     uint amount = pendingReturns[msg.sender];
     if (amount > 0){
         pendingReturns[msg.sender] =0;
        if (payable(msg.sender).send(amount)){
            pendingReturns[msg.sender] = amount;
            return false;
        }
     }
     return true;

 }

// end an auction
 function autionEnd()public {
if (block.timestamp < autionEndTime){
    revert("the aution hasnt ended yet");
}
if (ended){
    revert("the aution has Ended" );
            
}
ended = true;
emit AuctionEnded(highestBidder, highestBid);
beneficiary.transfer(highestBid);
 
     }
  
 }
