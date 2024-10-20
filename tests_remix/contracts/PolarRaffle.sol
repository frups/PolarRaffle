// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * @title PolarRaffle
 * @dev Handle raffle process, assign tickets for players, draw tickets and assign rewards for players
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract PolarRaffle{
    using Math for uint256;

    uint256 public maxNoTicketPerRaffle;
    uint256 public ticketPrice;
    uint256 public disposedTicketsPerRaffle;
    uint256 public raffleId;
    uint256 public noTicketsThatLastUserBought;

    address public playerThatWonLastRaffle;

    mapping(uint256 => address) private ticketPerRaffleAddressMap;
    mapping(uint256 => address) private raffleRewardsAddressMap;

    constructor(uint256 _maxNoTicketPerRaffle, uint256 _ticketPrice) {
        maxNoTicketPerRaffle = _maxNoTicketPerRaffle;
        ticketPrice = _ticketPrice;
        disposedTicketsPerRaffle = 0;
        raffleId = 0;
        noTicketsThatLastUserBought = 0;
    }

    

    function buyTicket() public payable returns(uint256){
        require(
            msg.value >= ticketPrice,//TODO: ogarnac decimals
            "Sended value must be enough to buy at least one ticket"
        );

        if(_isRaffleFull()) {//draw winner from previous raffle and start a new one
            uint256 winTicketId = _drawTicket();
            playerThatWonLastRaffle = ticketPerRaffleAddressMap[winTicketId];
            raffleRewardsAddressMap[raffleId++]=playerThatWonLastRaffle;
            disposedTicketsPerRaffle=0;
        }

        (bool success, uint256 maxNoTicketsSenderCanBuy) = Math.tryDiv(msg.value, ticketPrice);
        require(success==true, "division error was ticketPrice zero ?");
        uint256 valueToReturn = msg.value - maxNoTicketsSenderCanBuy * ticketPrice;
        noTicketsThatLastUserBought = _disposeTickets(msg.sender, maxNoTicketsSenderCanBuy);

        valueToReturn += (maxNoTicketsSenderCanBuy-noTicketsThatLastUserBought) * ticketPrice;

        //payable(msg.sender).transfer(valueToReturn);
        (bool success2,) = msg.sender.call{value:valueToReturn}("");
        if(!success2){
            revert();
        }
        return noTicketsThatLastUserBought;
    }

    function _disposeTickets(address ticketsOwner, uint256 maxNoTicketsSenderCanBuy) internal returns(uint256){
        uint256 noDisposedTickets = 0;
        while(disposedTicketsPerRaffle<maxNoTicketPerRaffle){
            ticketPerRaffleAddressMap[disposedTicketsPerRaffle++]=ticketsOwner;
            if(++noDisposedTickets>=maxNoTicketsSenderCanBuy) break;
        }
        return noDisposedTickets;
    }

    function _drawTicket() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, raffleId))) % 10;
    }

    function _isRaffleFull() internal view returns(bool){
        return (disposedTicketsPerRaffle>=maxNoTicketPerRaffle);
    }

    function isRaffleFull() public view returns(bool){
        return (_isRaffleFull());
    }

    function getMaxNoTicketPerRaffle() public view returns(uint256){
        return (maxNoTicketPerRaffle);
    }

    function getTicketPrice() public view returns(uint256){
        return (ticketPrice);
    }

    function getDisposedTicketsPerRaffle() public view returns(uint256){
        return (disposedTicketsPerRaffle);
    }

    function getRaffleId() public view returns(uint256){
        return (raffleId);
    }

    function getNoTicketsThatLastUserBought() public view returns(uint256){
        return (noTicketsThatLastUserBought);
    }

    function getAddressThatBoughtLastTicket() public view returns(address){
        return ticketPerRaffleAddressMap[(disposedTicketsPerRaffle-1)];
    }

    function getPlayerThatWonLastRaffle() public view returns(address){
        return playerThatWonLastRaffle;
    }
}