// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract PariContract {

    address public chairperson;
    uint public contractBalance;

    struct Validator {
        address who;
        bool voted;  // if true, that person already voted
        bool vote;
    }

    struct Pari {
        uint id;
        string action;
        uint winAmount;
        address proposer;
        address executor;
        uint deadline;
        Validator[] validators;
    }

    Pari[] private paris;

    constructor() {
        chairperson = msg.sender;
    }

     // Function to charge the proposer in native tokens (ETH)
    function create(
        address[] memory validators,
        string memory action,
        uint winAmount,
        address payable proposer,
        uint deadlineSeconds) external payable returns (uint) {
        // Ensure that the proposer has sent enough ETH
        require(msg.value >= winAmount, "Insufficient funds sent by proposer.");
        require(validators.length > 2, "At least 3 validators required.");

        Pari storage newPari = paris.push();  // Use storage reference for the new Pari

        newPari.id = block.timestamp;
        newPari.winAmount = winAmount;
        newPari.proposer = proposer;
        newPari.executor = msg.sender;
        newPari.action = action;
        newPari.deadline = block.timestamp + deadlineSeconds;

        // Fill the validators array
        for (uint i = 0; i < validators.length; i++) {
            newPari.validators[i] = Validator({
                who: validators[i],
                voted: false,
                vote: false
            });
        }

        // Transfer the sent amount to the contract's address
        payable(chairperson).transfer(winAmount);

        contractBalance += msg.value;

        return newPari.id;
    }

    function vote(uint id, address who, bool desision) external {
        for (uint i = 0; i < paris.length; i++) {
            if (paris[i].id == id && block.timestamp < paris[i].deadline)
            {
                for (uint j = 0; j < paris[i].validators.length; j++) {
                    if (paris[i].validators[j].who == who) {
                        paris[i].validators[j].vote = desision;
                        paris[i].validators[j].voted = true;
                        return;
                    }
                }
            }
        }
    }

    // function finish() {
        
    // }

    // function _grant() public payable {
    //     // 10% from win for all validators
    //     uint allValidatorsGrant = winAmount / 100 * 10;
    //     uint eachValidatorGrant = allValidatorsGrant / validators.length; 

    //     int positiveVotes = 0;
    //     int voted = 0;
    //     for (uint i = 0; i < validators.length; i++) {
    //         if (validators[i].voted) {
    //             voted++;
    //             if (validators[i].vote) {
    //                 positiveVotes++;
    //             }
                
    //             (bool success, ) = validators[i].who.call{value: eachValidatorGrant}(""); //continue even if failed
    //         }
    //     }

    //     uint proposerWin = winAmount / 100 * 10;
        
    //     if (positiveVotes > voted / 2) {
    //         (bool success, ) = executor.call{value: proposerWin}("");
    //     }
    //     else {
    //         (bool success, ) = proposer.call{value: proposerWin}("");
    //     }
    // }
}