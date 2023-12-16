# Solidity Auction Contract
This repository contains a Solidity smart contract for a decentralized auction system. The contract is designed to run on the Ethereum blockchain and allows users to participate in a secure and transparent auction process.

# Features
**Decentralized Auction**: Runs entirely on the Ethereum blockchain without the need for a central authority.
**Timed Auction**: The auction has a defined start and end block, ensuring a fixed duration.
**Bid Tracking**: Bids are tracked and managed within the contract with the highest bid being binding.
**Owner Controls**: The owner can start, end, or cancel the auction, as well as withdraw the highest bid after the auction ends.
**Automatic and Manual Auction Ending**: The auction can be ended by the owner or automatically after reaching the end block.
**Security Checks**: Includes modifiers to ensure actions are performed by authorized users and within the correct auction state.

# Contract Methods
**placeBid()**: Allows a user to place a bid during the auction.
**cancelAuction()**: The owner can cancel the auction.
**endAuctionByOwner(**): The owner can end the auction manually.
**autoEndAuction()**: Automatically end the auction after the end block.
**finalizeAuction()**: The owner finalizes the auction and transfers funds.
**withdraw()**: Participants can withdraw their bids after the auction.

