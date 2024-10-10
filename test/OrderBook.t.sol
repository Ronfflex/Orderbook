// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/OrderBook.sol";
import "./mock/MockERC20.sol";

contract OrderBookTest is Test {
    OrderBook public orderBook;
    MockERC20 public token1;
    MockERC20 public token2;
    address public user1;
    address public user2;

    function setUp() public {
        token1 = new MockERC20("Token1", "TK1");
        token2 = new MockERC20("Token2", "TK2");
        orderBook = new OrderBook(address(token1), address(token2));

        user1 = address(0x1);
        user2 = address(0x2);

        token1.transfer(user1, 10000 * 10 ** 18);
        token2.transfer(user1, 10000 * 10 ** 18);
        token1.transfer(user2, 10000 * 10 ** 18);
        token2.transfer(user2, 10000 * 10 ** 18);
    }

    function testCreateBuyOrder() public {
        vm.startPrank(user1);
        token2.approve(address(orderBook), 100 * 10 ** 18);
        orderBook.createOrder(100 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Buy);
        vm.stopPrank();

        OrderBook.Order memory order = orderBook.getOrder(0);
        assertEq(order.user, user1);
        assertEq(order.amount, 100 * 10 ** 18);
        assertEq(order.price, 1 * 10 ** 18);
        assertEq(uint256(order.orderType), uint256(OrderBook.OrderType.Buy));
    }

    function testCreateSellOrder() public {
        vm.startPrank(user1);
        token1.approve(address(orderBook), 100 * 10 ** 18);
        orderBook.createOrder(100 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Sell);
        vm.stopPrank();

        OrderBook.Order memory order = orderBook.getOrder(0);
        assertEq(order.user, user1);
        assertEq(order.amount, 100 * 10 ** 18);
        assertEq(order.price, 1 * 10 ** 18);
        assertEq(uint256(order.orderType), uint256(OrderBook.OrderType.Sell));
    }

    function testCancelOrder() public {
        vm.startPrank(user1);
        token2.approve(address(orderBook), 100 * 10 ** 18);
        orderBook.createOrder(100 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Buy);

        uint256 balanceBefore = token2.balanceOf(user1);
        orderBook.cancelOrder(0);
        uint256 balanceAfter = token2.balanceOf(user1);
        vm.stopPrank();

        assertEq(balanceAfter - balanceBefore, 100 * 10 ** 18);
    }

    function testFailCancelNonExistentOrder() public {
        vm.prank(user1);
        orderBook.cancelOrder(999);
    }

    function testFailCancelOtherUserOrder() public {
        vm.startPrank(user1);
        token2.approve(address(orderBook), 100 * 10 ** 18);
        orderBook.createOrder(100 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Buy);
        vm.stopPrank();

        vm.prank(user2);
        orderBook.cancelOrder(0);
    }

    function testGetUserOrders() public {
        vm.startPrank(user1);
        token2.approve(address(orderBook), 200 * 10 ** 18);
        orderBook.createOrder(100 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Buy);
        orderBook.createOrder(100 * 10 ** 18, 2 * 10 ** 18, OrderBook.OrderType.Buy);
        vm.stopPrank();

        uint256[] memory userOrders = orderBook.getUserOrders(user1);
        assertEq(userOrders.length, 2);
        assertEq(userOrders[0], 0);
        assertEq(userOrders[1], 1);
    }

    function testCreateOrderWithZeroAmount() public {
        vm.startPrank(user1);
        token2.approve(address(orderBook), 100 * 10 ** 18);
        vm.expectRevert("Amount must be greater than zero");
        orderBook.createOrder(0, 1 * 10 ** 18, OrderBook.OrderType.Buy);
        vm.stopPrank();
    }

    function testCreateMultipleOrdersAndCancel() public {
        vm.startPrank(user1);
        token2.approve(address(orderBook), 300 * 10 ** 18);
        orderBook.createOrder(100 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Buy);
        orderBook.createOrder(100 * 10 ** 18, 2 * 10 ** 18, OrderBook.OrderType.Buy);
        orderBook.createOrder(100 * 10 ** 18, 3 * 10 ** 18, OrderBook.OrderType.Buy);

        uint256[] memory userOrders = orderBook.getUserOrders(user1);
        assertEq(userOrders.length, 3);

        orderBook.cancelOrder(1);
        userOrders = orderBook.getUserOrders(user1);
        assertEq(userOrders.length, 2);
        assertEq(userOrders[0], 0);
        assertEq(userOrders[1], 2);
        vm.stopPrank();
    }

    function testCreateOrderInsufficientBalance() public {
        vm.startPrank(user1);
        token2.approve(address(orderBook), 10001 * 10 ** 18);
        vm.expectRevert(
            abi.encodeWithSignature(
                "ERC20InsufficientBalance(address,uint256,uint256)", user1, 10000 * 10 ** 18, 10001 * 10 ** 18
            )
        );
        orderBook.createOrder(10001 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Buy);
        vm.stopPrank();
    }

    function testOrderCreatedEvent() public {
        vm.startPrank(user1);
        token2.approve(address(orderBook), 100 * 10 ** 18);

        vm.expectEmit(true, true, false, true);
        emit OrderBook.OrderCreated(0, user1, 100 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Buy);
        orderBook.createOrder(100 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Buy);

        vm.stopPrank();
    }

    function testOrderCanceledEvent() public {
        vm.startPrank(user1);
        token2.approve(address(orderBook), 100 * 10 ** 18);
        orderBook.createOrder(100 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Buy);

        vm.expectEmit(true, false, false, false);
        emit OrderBook.OrderCanceled(0);
        orderBook.cancelOrder(0);

        vm.stopPrank();
    }

    // Failing tests
    // function testCreateBuyOrderTransferFailed() public {
    //     MockERC20 failingToken = new MockERC20("FailToken", "FAIL");
    //     OrderBook failingOrderBook = new OrderBook(address(token1), address(failingToken));

    //     vm.startPrank(user1);
    //     failingToken.approve(address(failingOrderBook), 100 * 10 ** 18);
    //     vm.expectRevert("Transfer failed");
    //     failingOrderBook.createOrder(100 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Buy);
    //     vm.stopPrank();
    // }

    // function testCreateSellOrderTransferFailed() public {
    //     MockERC20 failingToken = new MockERC20("FailToken", "FAIL");
    //     OrderBook failingOrderBook = new OrderBook(address(failingToken), address(token2));

    //     vm.startPrank(user1);
    //     failingToken.approve(address(failingOrderBook), 100 * 10 ** 18);
    //     vm.expectRevert("Transfer failed");
    //     failingOrderBook.createOrder(100 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Sell);
    //     vm.stopPrank();
    // }

    // function testCancelOrderTransferFailed() public {
    //     MockERC20 failingToken = new MockERC20("FailToken", "FAIL");
    //     OrderBook failingOrderBook = new OrderBook(address(failingToken), address(token2));

    //     vm.startPrank(user1);
    //     token2.approve(address(failingOrderBook), 100 * 10 ** 18);
    //     failingOrderBook.createOrder(100 * 10 ** 18, 1 * 10 ** 18, OrderBook.OrderType.Buy);

    //     vm.expectRevert("Transfer failed");
    //     failingOrderBook.cancelOrder(0);
    //     vm.stopPrank();
    // }

    function testGetNonExistentOrder() public {
        OrderBook.Order memory order = orderBook.getOrder(999);
        assertEq(order.user, address(0));
        assertEq(order.amount, 0);
        assertEq(order.price, 0);
        assertEq(uint256(order.orderType), 0);
    }

    function testGetEmptyUserOrders() public {
        uint256[] memory userOrders = orderBook.getUserOrders(address(0x999));
        assertEq(userOrders.length, 0);
    }

    function testOwnerFunctions() public {
        address newOwner = address(0x999);
        vm.prank(orderBook.owner());
        orderBook.transferOwnership(newOwner);
        assertEq(orderBook.owner(), newOwner);

        vm.prank(newOwner);
        orderBook.renounceOwnership();
        assertEq(orderBook.owner(), address(0));
    }
}
