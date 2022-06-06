 // SPDX-License-Identifier: MIT
   pragma solidity ^0.8.1;


interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external;

    function transferFrom(
        address,
        address,
        uint
    ) external;
}


contract MyAuction {
    address payable public beneficiary;
    uint public auctionEndTime;

    IERC721 public nft;

    uint public tokenId;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public pendingReturns;
    bool ended = false;

    event highestBidIncrease(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor (uint _biddingTime, address _beneficiary, address _nft, uint _tokenId){
        beneficiary = payable(_beneficiary);
        auctionEndTime = block.timestamp + _biddingTime;
        nft = IERC721(_nft);
        tokenId = _tokenId;
    }

    modifier canBid {
        require(msg.sender != beneficiary, "You can't bid on your own token");
        require(msg.sender != highestBidder, "You can't outbid yourself");
        require(block.timestamp < auctionEndTime, "The aution has already ended");
        require(ended == false, "The auction is already over");
        require(msg.value > highestBid && msg.value > 0, "You need to bid more than the current bid");
        _;
    }

    modifier canWithdraw {
        uint amount = pendingReturns[msg.sender];
        require(msg.sender != highestBidder, "You can't withdraw as the current highest bidder");
        require(amount > 0, "You have no pending withdrawals");
        _;
    }

    modifier canAuctionEnd {
        require(block.timestamp > auctionEndTime, "There is still time to bid");
        require(ended == false, "Auction is already over");
        require(msg.sender ==  beneficiary, "only the beneficiary can end the auction");
        _;
    }


    function bid() public payable canBid{
        uint currentBid = highestBid;
        highestBid = 0;
        pendingReturns[highestBidder] += currentBid;
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit highestBidIncrease(msg.sender, msg.value);
    }



    function Withdraw() public payable canWithdraw returns (bool){
        uint amount = pendingReturns[msg.sender];
        pendingReturns[msg.sender] = 0;
        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (success == false){
            pendingReturns[msg.sender] = amount;
            return false;
            }
        return true;
    }

    function autionEnd() public payable canAuctionEnd {
        uint amount = highestBid;
        highestBid = 0;
        (bool success,) = beneficiary.call{value: amount}("");
        require(success, "Payment transfer to beneficiary failed");
        nft.safeTransferFrom(beneficiary, highestBidder, tokenId);
        ended = true;
        emit AuctionEnded(highestBidder, amount);
    }

}

