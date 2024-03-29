// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Auction {
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    bool public canceled;
    address public highestBidder;
    uint public highestBindingBid;
    mapping(address => uint) public bids;
    bool public auctionEndedByOwner;
    address[] private bidders; // Array to track all bidders

    event BidPlaced(address bidder, uint bid, uint highestBindingBid);
    event AuctionStarted(uint startBlock, uint endBlock);
    event AuctionEnded(address winner, uint highestBindingBid);
    event AuctionCanceled();

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyDuringAuction() {
        require(block.number >= startBlock && block.number <= endBlock, "Auction not active");
        _;
    }

    modifier onlyAfterAuction() {
        require(block.number > endBlock, "Auction not yet ended");
        _;
    }

    modifier onlyNotCanceled() {
        require(!canceled, "Auction canceled");
        _;
    }

    constructor(uint _biddingTime) {
        owner = payable(msg.sender);
        startBlock = block.number;
        endBlock = startBlock + _biddingTime;
        emit AuctionStarted(startBlock, endBlock);
        canceled = false;
        auctionEndedByOwner = false;
    }

    function getCurrentBlockNumber() public view returns (uint) {
        return block.number;
    }

    function placeBid() external payable onlyDuringAuction onlyNotCanceled {
        require(msg.value > highestBindingBid, "Bid not high enough");

        uint newBid = bids[msg.sender] + msg.value;
        require(newBid > highestBindingBid, "Total bid must be higher than current binding bid");

        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }
        bids[msg.sender] = newBid;

        if (newBid <= bids[highestBidder]) {
            highestBindingBid = min(newBid + 1 ether, bids[highestBidder]);
        } else {
            highestBindingBid = min(newBid, bids[highestBidder] + 1 ether);
            highestBidder = msg.sender;
        }

        emit BidPlaced(msg.sender, newBid, highestBindingBid);
    }

    function cancelAuction() external onlyOwner onlyDuringAuction {
        canceled = true;

        for (uint i = 0; i < bidders.length; i++) {
            address bidder = bidders[i];
            uint bidAmount = bids[bidder];

            if (bidAmount > 0) {
                bids[bidder] = 0; // Reset the bid to prevent re-entrancy attack
                payable(bidder).transfer(bidAmount);
            }
        }

        highestBidder = address(0);
        highestBindingBid = 0;
        bidders = new address[](0); // Reset the bidders array

        emit AuctionCanceled();
    }

    function endAuctionByOwner() external onlyOwner onlyDuringAuction onlyNotCanceled {
        auctionEndedByOwner = true;
        emit AuctionEnded(owner, highestBindingBid);
    }

    function autoEndAuction() external onlyOwner onlyNotCanceled {
        require(block.number > endBlock, "Cannot auto-end before endBlock");
        auctionEndedByOwner = true;
        emit AuctionEnded(owner, highestBindingBid);
    }

    function finalizeAuction() external onlyOwner onlyAfterAuction {
        require(!canceled, "Cannot finalize a canceled auction");
        require(highestBidder != address(0), "No bids placed");

        owner.transfer(highestBindingBid);
        emit AuctionEnded(highestBidder, highestBindingBid);
    }

    function withdraw() external onlyAfterAuction {
        uint amount = bids[msg.sender];
        if (msg.sender == highestBidder) {
            amount -= highestBindingBid;
        }

        bids[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function min(uint a, uint b) private pure returns (uint) {
        if (a < b) return a;
        else return b;
    }
}
