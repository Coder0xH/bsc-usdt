// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract BrovotePayment is Ownable, ReentrancyGuard {
    IERC20 public brovote;
    address public receiver;
    
    // 支付事件
    event PaymentMade(
        string orderId,
        address user,
        uint256 amount,
        uint256 timestamp
    );
    
    // 提现事件
    event Withdrawal(
        string withdrawId,     // 提现订单ID
        address user,          // 提现用户
        uint256 amount,        // 提现金额
        uint256 timestamp     // 时间戳
    );
    
    constructor(
        address _brovote, 
        address _receiver,
        address initialOwner
    ) Ownable(initialOwner) {
        require(_brovote != address(0), "Invalid brovote address");
        require(_receiver != address(0), "Invalid receiver address");
        brovote = IERC20(_brovote);
        receiver = _receiver;
    }
    
    // 支付函数
    function pay(string memory orderId, uint256 amount) external nonReentrant {
        require(bytes(orderId).length > 0, "Invalid order ID");
        require(amount > 0, "Amount must be greater than 0");
        
        require(brovote.transferFrom(msg.sender, receiver, amount), "Transfer failed");
        
        emit PaymentMade(
            orderId,
            msg.sender,
            amount,
            block.timestamp
        );
    }
    
    // 提现函数（只能由管理员调用）
    function withdraw(
        string memory withdrawId,
        address user,
        uint256 amount
    ) external onlyOwner nonReentrant {
        require(bytes(withdrawId).length > 0, "Invalid withdraw ID");
        require(user != address(0), "Invalid user address");
        require(amount > 0, "Amount must be greater than 0");
        
        // 检查合约余额
        require(brovote.balanceOf(address(this)) >= amount, "Insufficient balance");
        
        // 执行转账
        require(brovote.transfer(user, amount), "Transfer failed");
        
        // 触发提现事件
        emit Withdrawal(
            withdrawId,
            user,
            amount,
            block.timestamp
        );
    }
    
    // 批量提现（节省gas，一次处理多个提现）
    function batchWithdraw(
        string[] memory withdrawIds,
        address[] memory users,
        uint256[] memory amounts
    ) external onlyOwner nonReentrant {
        require(
            withdrawIds.length == users.length && 
            users.length == amounts.length,
            "Array length mismatch"
        );
        
        uint256 totalAmount = 0;
        for(uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        
        // 检查总余额
        require(brovote.balanceOf(address(this)) >= totalAmount, "Insufficient balance");
        
        // 执行批量转账
        for(uint256 i = 0; i < users.length; i++) {
            require(users[i] != address(0), "Invalid user address");
            require(amounts[i] > 0, "Amount must be greater than 0");
            
            require(brovote.transfer(users[i], amounts[i]), "Transfer failed");
            
            emit Withdrawal(
                withdrawIds[i],
                users[i],
                amounts[i],
                block.timestamp
            );
        }
    }
}