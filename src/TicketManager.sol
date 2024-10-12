// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TicketManager is ERC721URIStorage, Ownable {
    // Struct to hold event details
    struct Event {
        string name;
        uint ticketPrice;
        address owner;
        uint soldCount;
        mapping(string => uint256) seatNFT; // Mapping of seat names to NFT IDs
    }

    // Mapping to store events using UUID as key
    mapping(string => Event) private events;

    // Events
    event EventCreated(string uuid, string eventName);
    event LogEvent(string message, string uuid);

    constructor() ERC721("TicketManager", "NFTicket") Ownable(msg.sender) {}

    // Create a new event
    function createEvent(string calldata eventName, uint ticketPrice) public returns (string memory) {
        // Generate a unique UUID for the event
        string memory uuid = _generateUUID(); // Generate UUID
        Event storage newEvent = events[uuid]; // Reference to the new event
        newEvent.name = eventName; // Store event name
        newEvent.ticketPrice = ticketPrice; // Store ticket price
        newEvent.owner = msg.sender; // Store event owner

        emit EventCreated(uuid, eventName); // Emit event creation
        emit LogEvent("Event created successfully", uuid);
        return uuid; // Return the UUID
    }

    // Get event details by UUID
    function getEvent(string calldata eventUuid) public view returns (string memory eventName, uint ticketPrice, uint soldCount) {
        Event storage evt = events[eventUuid]; // Reference to the event
        return (evt.name, evt.ticketPrice, evt.soldCount); // Return event details
    }

    // Get seat NFT for an event
    function getSeatNFT(string calldata eventUuid, string calldata seatName) public view returns (uint256 nft) {
        require(events[eventUuid].seatNFT[seatName] != 0, "Seat isn't minted!"); // Check if the seat is minted
        return events[eventUuid].seatNFT[seatName]; // Return NFT ID for the seat
    }

    // Purchase a seat (mint new NFT)
    function purchaseSeat(string calldata eventUuid, string calldata seatName) public payable returns (uint256) {
        Event storage evt = events[eventUuid]; // Reference to the event
        require(msg.value == evt.ticketPrice, "Insufficient payment for minting"); // Check payment
        require(evt.seatNFT[seatName] == 0, "Seat already minted!");

        // Construct the tokenURI with dynamic variables
        string memory tokenURI = string(
            abi.encodePacked(
                '{"name": "NFTicket", ',
                '"description": "Entry to ', evt.name, ' for seat ', seatName, '", ',
                '"image": "https://static.hbo.com/2024-09/money-electric-the-bitcoin-mystery-ka-1920.jpg", ',
                '"attributes": []}'
            )
        );
        uint256 newTokenId = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, seatName))); // Generate token ID
        _mint(msg.sender, newTokenId);          // Mint the NFT
        _setTokenURI(newTokenId, tokenURI);     // Assign metadata (URI) to the NFT

        evt.soldCount++; // Increment sold ticket count
        evt.seatNFT[seatName] = newTokenId; // Store minted NFT for the seat

        return newTokenId; // Return the minted token ID
    }

    // Withdraw funds for the event owner
    function withdraw(string calldata eventUuid) public {
        Event storage evt = events[eventUuid]; // Reference to the event
        require(msg.sender == evt.owner, "Only the event owner can withdraw"); // Check ownership
        uint payableTicketCount = evt.soldCount; // Calculate payable ticket count
        payable(msg.sender).transfer(evt.ticketPrice * payableTicketCount); // Withdraw funds
        evt.soldCount = 0;
    }

    // Generate a short unique UUID (10 characters)
    function _generateUUID() internal view returns (string memory) {
        // Create a random number by using a combination of block parameters and the sender's address
        bytes32 randomHash = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        
        // Convert the hash to a hexadecimal string
        string memory hexString = Strings.toHexString(uint256(randomHash));

        // Create a new bytes array to hold the first 10 characters (excluding the '0x' prefix)
        bytes memory uuidBytes = new bytes(10);
        for (uint i = 0; i < 10; i++) {
            uuidBytes[i] = bytes(hexString)[i + 2]; // Skip "0x"
        }
        
        return string(uuidBytes);
    }
}
