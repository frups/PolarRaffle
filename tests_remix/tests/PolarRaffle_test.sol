// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "hardhat/console.sol";
import "../contracts/PolarRaffle.sol";

contract PolarRaffleTest {
    PolarRaffle polarRaffle;

    function beforeAll() public {
        polarRaffle = new PolarRaffle(10, 1000000000000000000); // deploy a new instance of your contract with constructor parameters
    }
}