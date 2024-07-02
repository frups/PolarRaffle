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

    mapping(uint256 => address) private ticketPerRaffleAddressMap;
    mapping(uint256 => address) private raffleRewardsAddressMap;

    constructor(uint256 _maxNoTicketPerRaffle, uint256 _ticketPrice) {
        maxNoTicketPerRaffle = _maxNoTicketPerRaffle;
        ticketPrice = _ticketPrice;
        disposedTicketsPerRaffle = 0;
        raffleId = 0;
    }

    function buyTicket() external payable{
        require(
            msg.value >= ticketPrice,//TODO: ogarnac decimals
            "Sended value must be enough to buy at least one ticket"
        );

        if(_isRaffleFull()) {//draw winner from previous raffle and start a new one
            uint256 winTicketId = _drawTicket();
            raffleRewardsAddressMap[raffleId++]=ticketPerRaffleAddressMap[winTicketId];
            disposedTicketsPerRaffle=0;
        }

        (bool success, uint256 maxNoTicketsSenderCanBuy) = Math.tryDiv(msg.value, ticketPrice);
        require(success==true, "division error was ticketPrice zero ?");
        uint256 valueToReturn = msg.value - maxNoTicketsSenderCanBuy * ticketPrice;
        noTicketsThatLastUserBought = _disposeTickets(msg.sender, maxNoTicketsSenderCanBuy);

        valueToReturn += (maxNoTicketsSenderCanBuy-noTicketsThatLastUserBought) * ticketPrice;

        payable(msg.sender).transfer(valueToReturn);
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

    function isRaffleFull() external view returns(bool){
        return (_isRaffleFull());
    }

    function getMaxNoTicketPerRaffle() external view returns(uint256){
        return (maxNoTicketPerRaffle);
    }

    function getTicketPrice() external view returns(uint256){
        return (ticketPrice);
    }

    function getDisposedTicketsPerRaffle() external view returns(uint256){
        return (disposedTicketsPerRaffle);
    }

    function getRaffleId() external view returns(uint256){
        return (raffleId);
    }

    function getNoTicketsThatLastUserBought() external view returns(uint256){
        return (noTicketsThatLastUserBought);
    }

    function getAddressThatBoughtLastTicket() external view returns(address){
        return ticketPerRaffleAddressMap[disposedTicketsPerRaffle];
    }
}