// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

contract OrderBook is Ownable {
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    enum OrderType {
        Buy,
        Sell
    }

    struct Order {
        address user;
        uint256 amount;
        uint256 price;
        OrderType orderType;
    }

    IERC20 public token1;
    IERC20 public token2;

    // Mapping of order ID to Order struct
    mapping(uint256 => Order) private orders;
    uint256 private nextOrderId;

    // Mapping to track user orders
    mapping(address => EnumerableMap.UintToAddressMap) private userOrders;

    event OrderCreated(uint256 orderId, address indexed user, uint256 amount, uint256 price, OrderType orderType);
    event OrderCanceled(uint256 orderId);

    // Constructor now passes msg.sender to Ownable
    constructor(address _token1, address _token2) Ownable(msg.sender) {
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
    }

    function createOrder(uint256 _amount, uint256 _price, OrderType _orderType) external {
        require(_amount > 0, "Amount must be greater than zero");

        // Transfer tokens based on order type
        if (_orderType == OrderType.Buy) {
            require(token2.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        } else {
            require(token1.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        }

        uint256 orderId = nextOrderId++;
        orders[orderId] = Order(msg.sender, _amount, _price, _orderType);

        // Store the order in the user's map
        userOrders[msg.sender].set(orderId, msg.sender);

        emit OrderCreated(orderId, msg.sender, _amount, _price, _orderType);
    }

    function cancelOrder(uint256 _orderId) external {
        Order memory order = orders[_orderId];
        require(order.user == msg.sender, "Not the order owner");

        // Return the tokens to the user based on the order type
        if (order.orderType == OrderType.Buy) {
            require(token2.transfer(msg.sender, order.amount), "Transfer failed");
        } else {
            require(token1.transfer(msg.sender, order.amount), "Transfer failed");
        }

        delete orders[_orderId];
        userOrders[msg.sender].remove(_orderId);

        emit OrderCanceled(_orderId);
    }

    function getOrder(uint256 _orderId) external view returns (Order memory) {
        return orders[_orderId];
    }

    function getUserOrders(address _user) external view returns (uint256[] memory) {
        uint256 orderCount = userOrders[_user].length();
        uint256[] memory orderIds = new uint256[](orderCount);

        for (uint256 i = 0; i < orderCount; i++) {
            (uint256 key,) = userOrders[_user].at(i);
            orderIds[i] = key;
        }
        return orderIds;
    }
}
