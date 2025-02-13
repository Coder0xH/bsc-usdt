// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract UsdtOrder is Ownable, ReentrancyGuard {
    IERC20 public usdt;
    address public receiver;

    event PaymentMade(string orderId, address user, uint256 amount, uint256 timestamp);

    event ReceiverUpdated(address oldReceiver, address newReceiver);

    event TokenAddressUpdated(address oldToken, address newToken);

    constructor(address _usdt, address _receiver, address initialOwner) Ownable(initialOwner) {
        require(_usdt != address(0), "Invalid usdt address");
        require(_receiver != address(0), "Invalid receiver address");
        usdt = IERC20(_usdt);
        receiver = _receiver;
    }

    /**
     * @notice Process payment with order ID and amount
     * @param orderId Unique identifier for the order
     * @param amount Amount of tokens to transfer
     */
    function pay(string memory orderId, uint256 amount) external nonReentrant {
        require(bytes(orderId).length > 0, "Invalid order ID");
        require(amount > 0, "Amount must be greater than 0");
        require(usdt.transferFrom(msg.sender, receiver, amount), "Transfer failed");

        emit PaymentMade(orderId, msg.sender, amount, block.timestamp);
    }

    /**
     * @notice Update receiver address, only callable by owner
     * @param newReceiver New address to receive payments
     */
    function setReceiver(address newReceiver) external onlyOwner {
        require(newReceiver != address(0), "Invalid receiver address");
        address oldReceiver = receiver;
        receiver = newReceiver;
        emit ReceiverUpdated(oldReceiver, newReceiver);
    }

    /**
     * @notice Update token contract address, only callable by owner
     * @param newToken New token contract address
     */
    function setTokenAddress(address newToken) external onlyOwner {
        require(newToken != address(0), "Invalid token address");
        address oldToken = address(usdt);
        usdt = IERC20(newToken);
        emit TokenAddressUpdated(oldToken, newToken);
    }
}
