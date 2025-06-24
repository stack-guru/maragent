// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Marsagent is ERC20, Ownable {
    uint256 public immutable MAX_SUPPLY = 1_000_000_000 * 10 ** 18; // 1 billion MRAI
    uint256 public totalMinted;
    mapping(address => bool) public approvedAgents;

    // Track execution history
    struct ExecutionLog {
        address agent;
        uint256 timestamp;
        uint256 commandId;
        string payload;
    }

    ExecutionLog[] public executionLogs;

    event AgentApproved(address agent);
    event AgentRevoked(address agent);
    event AIActionExecuted(address indexed agent, bytes data);

    constructor(
        uint256 initialSupply
    ) ERC20("Marsagent", "MRAI") Ownable(msg.sender) {
        uint256 initialMint = 700_000_000 * 10 ** decimals(); // 70%
        _mint(msg.sender, initialSupply);
        totalMinted += initialMint;
    }

    modifier onlyApprovedAgent() {
        require(approvedAgents[msg.sender], "Not approved");
        _;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function getExecutionCount() external view returns (uint256) {
        return executionLogs.length;
    }

    function getExecutionLog(
        uint256 index
    ) external view returns (ExecutionLog memory) {
        require(index < executionLogs.length, "Invalid index");
        return executionLogs[index];
    }

    // Approve an AI agent
    function approveAgent(address agent) external onlyOwner {
        approvedAgents[agent] = true;
        emit AgentApproved(agent);
    }

    // Revoke an AI agent
    function revokeAgent(address agent) external onlyOwner {
        approvedAgents[agent] = false;
        emit AgentRevoked(agent);
    }

    // Execute AI Action (only approved agent)
    function executeAIAction(bytes calldata data) external onlyApprovedAgent {
        (uint256 commandId, string memory payload) = abi.decode(
            data,
            (uint256, string)
        );
        executionLogs.push(
            ExecutionLog({
                agent: msg.sender,
                timestamp: block.timestamp,
                commandId: commandId,
                payload: payload
            })
        );

        uint256 remaining = MAX_SUPPLY - totalMinted;
        require(remaining > 0, "No tokens left to mint");
        uint256 reward = (remaining * 3) / 100; // 3% of remaining

        // Ensure reward doesn't exceed remaining (paranoia check)
        if (reward > remaining) {
            reward = remaining;
        }

        _mint(msg.sender, reward);
        totalMinted += reward;
        emit AIActionExecuted(msg.sender, data);
    }
}
