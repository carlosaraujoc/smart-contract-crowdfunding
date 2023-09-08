//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding{
    address public manager;
    uint public goalAmount;
    uint public deadline;
    uint public totalContributions;
    mapping(address => uint) public contributions;
    bool public fundraisingIsClosed;

    event contributionReceived(address contributor, uint amount);
    event fundraisingSucceeded(uint totalContributions);
    event fundraisingFailed(uint totalContributions);

    modifier onlyManager(){
        require(msg.sender == manager, "Apenas o dono pode executar essa funcao");
        _;
    }

    constructor(uint _goalAmount, uint _duration){
        manager = msg.sender;
        goalAmount = _goalAmount * 1 ether;
        deadline = block.timestamp + (_duration) * 1 days;
        fundraisingIsClosed = false;
    }

    function contributte() external payable {
        require(!fundraisingIsClosed, " Este financiamento foi encerrado");
        require(block.timestamp <= deadline, "Este financiamento foi encerrado");
        require(msg.value > 0, "A contribuicao deve ser maior que 0");

        contributions[msg.sender] = msg.value;
        totalContributions += msg.value;
        emit contributionReceived(msg.sender, msg.value);

        if (totalContributions >= goalAmount){
            fundraisingIsClosed = true;
            emit fundraisingSucceeded(totalContributions);
        }
    }

    function checkGoalReached() external onlyManager{
        require(!fundraisingIsClosed, "Este financiamento foi encerrado");
        require(block.timestamp > deadline, "Financiamento ainda ocorre ");

        if (totalContributions >= goalAmount){
            emit fundraisingSucceeded(totalContributions);
        } else{
            emit fundraisingFailed(totalContributions);
        }
        fundraisingIsClosed = true;
    }

    function withdrawFunds() external onlyManager{
        require(fundraisingIsClosed && totalContributions >= goalAmount, "Saque invalidado");
        payable(manager).transfer(address(this).balance);
    }
}