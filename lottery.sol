//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

contract Lottery {
    
    address payable[] public players;
    address public manager;
    
    constructor() {
        manager = msg.sender;
    }
    
    receive() external payable {
        require(msg.value == 0.1 ether);
        players.push(payable(msg.sender));
    }
    
    function getBalance() public view returns(uint) {
        require(manager == msg.sender);
        return address(this).balance;
    }
    
    function random() public view returns(uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }
    
    function pickWinner() public {
        require(manager == msg.sender);
        require(players.length >= 3);
        
        address payable winner;
        uint r = random();
        
        uint index = r % players.length;
        winner = players[index];
        
       winner.transfer(getBalance());
        
       players = new address payable[](0);
    }
}