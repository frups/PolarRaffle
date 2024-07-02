// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/PolarRaffle.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    PolarRaffle polarRaffle;
    uint256 ticketPrice = 10^18;

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        polarRaffle = new PolarRaffle(10, ticketPrice); // deploy a new instance of your contract with constructor parameters
    }

    function afterEach() public {
        Assert.equal(polarRaffle.getDisposedTicketsPerRaffle()<=polarRaffle.getMaxNoTicketPerRaffle() &&
        polarRaffle.getDisposedTicketsPerRaffle()>=0, true, "value disposedTicketsPerRaffle should be between 0 and maxNoTicketPerRaffle");
    }

    function testBuyTicketWithTooLessValue() public {
        uint256 noDisposedTickets = polarRaffle.getDisposedTicketsPerRaffle();
        (bool success, ) = address(polarRaffle).call{value: ticketPrice-1}(abi.encodeWithSignature("buyTicket()"));
        Assert.equal(polarRaffle.getDisposedTicketsPerRaffle(), noDisposedTickets,"no ticket should be disposed");
        Assert.equal(polarRaffle.getNoTicketsThatLastUserBought(), 0,"no ticket should be added");
        //TODO: ogarnac jak sprawdzic zwrot kasy
    }

    function testBuyOneTicket() public {
        uint256 noDisposedTickets = polarRaffle.getDisposedTicketsPerRaffle();
        (bool success, ) = address(polarRaffle).call{value: ticketPrice}(abi.encodeWithSignature("buyTicket()"));
        Assert.ok(success, "buying one ticket should succeed");
        Assert.equal(polarRaffle.getDisposedTicketsPerRaffle(), noDisposedTickets+1,"one ticket should be disposed");
        Assert.equal(polarRaffle.getNoTicketsThatLastUserBought(), 1,"one ticket should be added");
        Assert.equal(polarRaffle.getAddressThatBoughtLastTicket(), msg.sender,"ticket should be assigned to proper address");
    }

    function testBuyMoreThanOneTicket() public {
        uint256 noDisposedTickets = polarRaffle.getDisposedTicketsPerRaffle();
        (bool success, ) = address(polarRaffle).call{value: 6*ticketPrice}(abi.encodeWithSignature("buyTicket()"));
        Assert.ok(success, "buying three tickets should succeed");
        Assert.equal(polarRaffle.getDisposedTicketsPerRaffle(), noDisposedTickets+3,"three tickets should be disposed");
        Assert.equal(polarRaffle.getNoTicketsThatLastUserBought(), 3,"three tickets should be added");
        Assert.equal(polarRaffle.getAddressThatBoughtLastTicket(), msg.sender,"ticket should be assigned to proper address");
    }

    function testBuyMoreThanAvailableTicket() public {
        uint256 noDisposedTickets = polarRaffle.getDisposedTicketsPerRaffle();
        (bool success, ) = address(polarRaffle).call{value: 9*ticketPrice}(abi.encodeWithSignature("buyTicket()"));
        Assert.ok(success, "buying only three tickets should succeed");
        Assert.equal(polarRaffle.getDisposedTicketsPerRaffle(), noDisposedTickets+3,"three tickets should be disposed");
        Assert.equal(polarRaffle.getNoTicketsThatLastUserBought(), 3,"three tickets should be added");
        Assert.equal(polarRaffle.getAddressThatBoughtLastTicket(), msg.sender,"ticket should be assigned to proper address");
        //TODO: jak ogarnac msg.senger kto wysyla jak sie robi test ???
    }

    function testBuyTicketWhenNoneIsAvailable() public {
        uint256 noDisposedTickets = polarRaffle.getDisposedTicketsPerRaffle();
        uint256 raffleId = polarRaffle.getRaffleId();
        (bool success, ) = address(polarRaffle).call{value: ticketPrice}(abi.encodeWithSignature("buyTicket()"));
        Assert.ok(success, "buying one ticket should succeed");
        Assert.equal(polarRaffle.getDisposedTicketsPerRaffle(), noDisposedTickets+1,"one tickets should be disposed");
        Assert.equal(polarRaffle.getNoTicketsThatLastUserBought(), 1,"one ticket should be added");
        Assert.equal(polarRaffle.getRaffleId(), raffleId+1,"next raffle should start");
        Assert.equal(polarRaffle.getAddressThatBoughtLastTicket(), msg.sender,"ticket should be assigned to proper address");
    }
}
    