// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Strings.sol";

contract TicketManager {
    mapping(string => address[]) private seatOwners;
    mapping(string => bool) private seatAvailableForPurchase;

    constructor() {
        string[8] memory rows = ["A", "B", "C", "D", "E", "F", "G", "H"]; 
        for (uint i=0; i<rows.length; i++) {
            for (uint256 number = 0; number < 10; number ++) {
                seatOwners[rows[i]+Strings.toString(number)];
            }
        }
    }

    function purchaseSeat(string memory seatName) public {
        require(seatOwners[seatName].length != 0, "Seat does not exist");
        seatOwners[seatName].push(msg.sender);
        seatAvailableForPurchase[seatName] = false;
    }

    function sellSeat(string memory seatName) public {
        require(seatOwners[seatName].length != 0, "Seat does not exist");
        seatAvailableForPurchase[seatName] = true;
    }
}
