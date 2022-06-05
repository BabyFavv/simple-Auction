 // SPDX-License-Identifier: MIT
   pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Timers.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MyAuction {
    address payable public beneficiary;
    uint public autionEndTime;


    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public pendingReturns;
    bool ended = false;

    event highestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor (uint _biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        autionEndTime = block.timestamp + _biddingTime;
    }



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

