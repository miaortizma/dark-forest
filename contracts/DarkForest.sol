//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.11;

import "./verifier.sol";
import "hardhat/console.sol";

contract DarkForest is Verifier {

    struct CellState {
        bool occupied;
        uint256 lastSpawn;
    }

    mapping(address => uint) private playerCell;
    mapping(uint => CellState) worldState;

    event Spawn(address player, uint cell);

    function spawn(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[2] memory input
    ) public {
        
        require(input[1] == 64, "World size isn't 64");
        uint cell = input[0];
        CellState storage state = worldState[cell];
        require(block.timestamp - state.lastSpawn > 5 minutes, "Need 5 minutes between spawns.");
        require(state.occupied == false, "Cell is occupied");
        
        bool proof = verifyProof(a, b, c, input);
        require(proof == true, "Invalid Proof");


        playerCell[msg.sender] = cell;
        state.occupied = true;
        state.lastSpawn = block.timestamp;

        emit Spawn(msg.sender, cell);
    }

    function getPlayerCell(address player) public view returns (bytes memory) {
        return abi.encodePacked(playerCell[player]);
    }

}
