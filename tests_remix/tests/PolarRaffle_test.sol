// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

import "remix_tests.sol"; 
import "remix_accounts.sol";
import "../contracts/PolarRaffle.sol";

contract testSuite is PolarRaffle {
    address acc0 = TestsAccounts.getAccount(0);
    address acc1 = TestsAccounts.getAccount(1);
    address acc2 = TestsAccounts.getAccount(2);
    address acc3 = TestsAccounts.getAccount(3);
    address acc4 = TestsAccounts.getAccount(4);

    constructor() PolarRaffle(10,1) {
    }
    event log(string);

    function afterEach() public {
        Assert.equal(getDisposedTicketsPerRaffle()<=getMaxNoTicketPerRaffle() &&
        getDisposedTicketsPerRaffle()>=0, true, "value disposedTicketsPerRaffle should be between 0 and maxNoTicketPerRaffle");
    }
    //  one player
    /// #value: 1
    /// #sender: account-0
    function testBuyOneTicket() public payable{
        Assert.equal(msg.value, 1 wei, "value should be 1");
        buyTicket();
        Assert.equal(getDisposedTicketsPerRaffle(), 1,"one ticket should be disposed");
        Assert.equal(getNoTicketsThatLastUserBought(), 1,"one ticket should be added");
        Assert.equal(getAddressThatBoughtLastTicket(), msg.sender,"ticket should be assigned to proper address");
    }


    /// #value: 6
    /// #sender: account-0
    function testBuyMoreThanOneTicket() public payable{
        Assert.equal(msg.value, 6, 'value should be 6 Eth');
        buyTicket();
        Assert.equal(getDisposedTicketsPerRaffle(), 7,"six tickets should be disposed");
        Assert.equal(getNoTicketsThatLastUserBought(), 6,"six tickets should be added");
        Assert.equal(getAddressThatBoughtLastTicket(), msg.sender,"ticket should be assigned to proper address");
    }

    /// #value: 9
    /// #sender: account-0
    function testBuyMoreThanAvailableTicket() public payable{
        Assert.equal(msg.value, 9, 'value should be 9 Eth');
        buyTicket();
        Assert.equal(getDisposedTicketsPerRaffle(), 10,"all 10 tickets should be disposed");
        Assert.equal(getNoTicketsThatLastUserBought(), 3,"three tickets should be added");
        Assert.equal(getAddressThatBoughtLastTicket(), msg.sender,"ticket should be assigned to proper address");
        //TODO: jak ogarnac msg.senger kto wysyla jak sie robi test ???
    }

    /// #value: 1
    /// #sender: account-0
    function testBuyTicketWhenNoneIsAvailable() public payable{
        uint256 raffleId = getRaffleId();
        Assert.equal(msg.value, 1, 'value should be 1 Eth');
        buyTicket();
        Assert.equal(getPlayerThatWonLastRaffle(), msg.sender,"player should win last raffle");
        Assert.equal(getRaffleId(), raffleId+1,"next raffle should start");
        Assert.equal(getDisposedTicketsPerRaffle(), 1,"one tickets should be disposed");
        Assert.equal(getNoTicketsThatLastUserBought(), 1,"one ticket should be added");
        Assert.equal(getAddressThatBoughtLastTicket(), msg.sender,"ticket should be assigned to proper address");
    }

    // Now tests with many players - real raffle
    /// #value: 1
    /// #sender: account-1

    function testBuyOneTicket2() public payable{
        Assert.equal(msg.value, 1, "value should be 1");
        buyTicket();
        Assert.equal(getDisposedTicketsPerRaffle(), 2,"two tickets should be already disposed");
        Assert.equal(getNoTicketsThatLastUserBought(), 1,"one ticket should be added to player that bought");
        Assert.equal(getAddressThatBoughtLastTicket(), msg.sender,"ticket should be assigned to proper address");
    }


    /// #value: 6
    /// #sender: account-2
    function testBuyMoreThanOneTicket2() public payable{
        Assert.equal(msg.value, 6, 'value should be 6 Eth');
        buyTicket();
        Assert.equal(getDisposedTicketsPerRaffle(), 8,"six tickets should be already disposed");
        Assert.equal(getNoTicketsThatLastUserBought(), 6,"six tickets should be added to buyer");
        Assert.equal(getAddressThatBoughtLastTicket(), msg.sender,"ticket should be assigned to buyer");
    }

    /// #value: 9
    /// #sender: account-3
    function testBuyMoreThanAvailableTicket2() public payable{
        Assert.equal(msg.value, 9, 'value should be 9 Eth');
        buyTicket();
        Assert.equal(getDisposedTicketsPerRaffle(), 10,"all 10 tickets should be already disposed");
        Assert.equal(getNoTicketsThatLastUserBought(), 2,"three tickets should be added to buyer");
        Assert.equal(getAddressThatBoughtLastTicket(), msg.sender,"ticket should be assigned to buyer");
        //TODO: jak ogarnac msg.senger kto wysyla jak sie robi test ???
    }

    /// #value: 1
    /// #sender: account-4
    function testBuyTicketWhenNoneIsAvailable2() public payable{
        uint256 raffleId = getRaffleId();
        Assert.equal(msg.value, 1, 'value should be 1 Eth');
        buyTicket();
        address playerThatWon = getPlayerThatWonLastRaffle();
        bool anyPlayerWon = (acc1 == playerThatWon)||(acc2 == playerThatWon)||(acc3 == playerThatWon)||(acc4 == playerThatWon);
        Assert.equal(anyPlayerWon, true,"any player should won");
        Assert.equal(getRaffleId(), raffleId+1,"next raffle should start");
        Assert.equal(getDisposedTicketsPerRaffle(), 1,"one tickets should be already disposed");
        Assert.equal(getNoTicketsThatLastUserBought(), 1,"one ticket should be added to buyer");
        Assert.equal(getAddressThatBoughtLastTicket(), msg.sender,"ticket should be assigned to buyer");
    }
}
    