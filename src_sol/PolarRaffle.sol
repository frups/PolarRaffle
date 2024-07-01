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
        
        uint256 maxNoTicketsSenderCanBuy = msg.value / ticketPrice;
        uint256 valueToReturn = msg.value - maxNoTicketsSenderCanBuy * ticketPrice;
        uint256 realNoTicketsSenderReceived = _disposeTickets(msg.sender, maxNoTicketsSenderCanBuy);

        valueToReturn += (maxNoTicketsSenderCanBuy-realNoTicketsSenderReceived) * ticketPrice;

        payable(msg.sender).transfer(valueToReturn);
    }

    function isRaffleFull() external view returns(bool){
        return (_isRaffleFull());
    }

    function _disposeTickets(address ticketsOwner, uint256 maxNoTicketsSenderCanBuy) internal returns(uint256){
        uint256 noDisposedTickets = 0;
        while(disposedTicketsPerRaffle<maxNoTicketPerRaffle){
            ticketPerRaffleAddressMap[disposedTicketsPerRaffle++]=ticketsOwner;
            if(++noDisposedTickets>=maxNoTicketsSenderCanBuy) break;
        }
        return noDisposedTickets;
    }

    function _isRaffleFull() internal view returns(bool){
        return (disposedTicketsPerRaffle>=maxNoTicketPerRaffle);
    }

    function _drawTicket() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, raffleId))) % 10;
    }
}