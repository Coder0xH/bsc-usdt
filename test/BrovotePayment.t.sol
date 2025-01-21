// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BrovotePayment.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Ownable errors
error OwnableUnauthorizedAccount(address account);

// Mock token for testing
contract MockToken is ERC20 {
    constructor() ERC20("Mock Brovote", "BROV") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }
}

contract BrovotePaymentTest is Test {
    BrovotePayment public payment;
    MockToken public token;
    address public owner;
    address public receiver;
    address public user;

    event PaymentMade(
        string orderId,
        address user,
        uint256 amount,
        uint256 timestamp
    );

    event ReceiverUpdated(
        address oldReceiver,
        address newReceiver
    );

    event TokenAddressUpdated(
        address oldToken,
        address newToken
    );

    function setUp() public {
        // Setup accounts
        owner = makeAddr("owner");
        receiver = makeAddr("receiver");
        user = makeAddr("user");

        // Deploy mock token
        token = new MockToken();

        // Deploy payment contract
        vm.prank(owner);
        payment = new BrovotePayment(
            address(token),
            receiver,
            owner
        );

        // Give user some tokens
        token.transfer(user, 1000 * 10**token.decimals());
    }

    function test_InitialState() public view {
        assertEq(address(payment.brovote()), address(token));
        assertEq(payment.receiver(), receiver);
        assertEq(payment.owner(), owner);
    }

    function test_Pay() public {
        uint256 amount = 100 * 10**token.decimals();
        string memory orderId = "ORDER_001";

        // Approve tokens
        vm.startPrank(user);
        token.approve(address(payment), amount);

        // Expect PaymentMade event
        vm.expectEmit(true, true, true, true);
        emit PaymentMade(orderId, user, amount, block.timestamp);

        // Make payment
        payment.pay(orderId, amount);
        vm.stopPrank();

        // Verify receiver balance
        assertEq(token.balanceOf(receiver), amount);
    }

    function test_SetReceiver() public {
        address newReceiver = makeAddr("newReceiver");

        // Only owner can set receiver
        vm.prank(owner);
        
        // Expect ReceiverUpdated event
        vm.expectEmit(true, true, true, true);
        emit ReceiverUpdated(receiver, newReceiver);

        payment.setReceiver(newReceiver);
        assertEq(payment.receiver(), newReceiver);
    }

    function test_SetTokenAddress() public {
        MockToken newToken = new MockToken();

        // Only owner can set token address
        vm.prank(owner);
        
        // Expect TokenAddressUpdated event
        vm.expectEmit(true, true, true, true);
        emit TokenAddressUpdated(address(token), address(newToken));

        payment.setTokenAddress(address(newToken));
        assertEq(address(payment.brovote()), address(newToken));
    }

    function test_RevertWhen_PayWithInvalidOrderId() public {
        vm.prank(user);
        vm.expectRevert("Invalid order ID");
        payment.pay("", 100);
    }

    function test_RevertWhen_PayWithZeroAmount() public {
        vm.prank(user);
        vm.expectRevert("Amount must be greater than 0");
        payment.pay("ORDER_001", 0);
    }

    function test_RevertWhen_SetReceiverNonOwner() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, user));
        payment.setReceiver(makeAddr("newReceiver"));
    }

    function test_RevertWhen_SetTokenAddressNonOwner() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, user));
        payment.setTokenAddress(makeAddr("newToken"));
    }

    function test_RevertWhen_SetReceiverZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert("Invalid receiver address");
        payment.setReceiver(address(0));
    }

    function test_RevertWhen_SetTokenAddressZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert("Invalid token address");
        payment.setTokenAddress(address(0));
    }
}
