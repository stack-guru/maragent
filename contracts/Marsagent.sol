// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Marsagent is
    Initializable,
    ERC20Upgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    uint256 public MAX_SUPPLY;
    uint256 public totalMinted;
    uint256 public burnRate;

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

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers(); // Prevent use of constructor logic
    }

    function initialize() public initializer {
        __ERC20_init("Marsagent", "MRAI");
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();

        MAX_SUPPLY = 100_000_000 * 10 ** 18;
        burnRate = 2;
        uint256 initialMint = 50_000_000 * 10 ** decimals();

        _mint(msg.sender, initialMint);
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

    function approveAgent(address agent) external onlyOwner {
        approvedAgents[agent] = true;
        emit AgentApproved(agent);
    }

    function revokeAgent(address agent) external onlyOwner {
        approvedAgents[agent] = false;
        emit AgentRevoked(agent);
    }

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

    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 burnAmount = (amount * burnRate) / 100;
        uint256 sendAmount = amount - burnAmount;

        // Burn the fee from sender
        _burn(_msgSender(), burnAmount);

        // Transfer remaining to recipient
        return super.transfer(recipient, sendAmount);
    }

    function setBurnRate(uint256 rate) external onlyOwner {
        require(rate <= 10, "Too high"); // cap at 10%
        burnRate = rate;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
