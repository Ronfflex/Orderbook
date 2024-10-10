// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

/// @title OrderBook
/// @notice A decentralized order book for trading between two ERC20 tokens
/// @dev This contract allows users to create and cancel buy/sell orders for a pair of ERC20 tokens
contract OrderBook is Ownable {
    using EnumerableMap for EnumerableMap.UintToAddressMap;

    /// @notice Enum to represent the type of order (Buy or Sell)
    enum OrderType {
        Buy,
        Sell
    }

    /// @notice Struct to represent an order in the order book
    /// @param user The address of the user who created the order
    /// @param amount The amount of tokens to be traded
    /// @param price The price per token for the order
    /// @param orderType The type of the order (Buy or Sell)
    struct Order {
        address user;
        uint256 amount;
        uint256 price;
        OrderType orderType;
    }

    /// @notice The first token in the trading pair
    IERC20 public token1;

    /// @notice The second token in the trading pair
    IERC20 public token2;

    /// @notice Mapping of order ID to Order struct
    mapping(uint256 => Order) private orders;

    /// @notice The ID to be assigned to the next order
    uint256 private nextOrderId;

    /// @notice Mapping to track user orders
    mapping(address => EnumerableMap.UintToAddressMap) private userOrders;

    /// @notice Emitted when a new order is created
    /// @param orderId The ID of the newly created order
    /// @param user The address of the user who created the order
    /// @param amount The amount of tokens to be traded
    /// @param price The price per token for the order
    /// @param orderType The type of the order (Buy or Sell)
    event OrderCreated(uint256 orderId, address indexed user, uint256 amount, uint256 price, OrderType orderType);

    /// @notice Emitted when an order is canceled
    /// @param orderId The ID of the canceled order
    event OrderCanceled(uint256 orderId);

    /// @notice Initializes the OrderBook with two ERC20 tokens
    /// @param _token1 The address of the first token in the trading pair
    /// @param _token2 The address of the second token in the trading pair
    constructor(address _token1, address _token2) Ownable(msg.sender) {
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
    }

    /// @notice Creates a new order in the order book
    /// @param _amount The amount of tokens to be traded
    /// @param _price The price per token for the order
    /// @param _orderType The type of the order (Buy or Sell)
    /// @dev Transfers tokens from the user to the contract based on the order type
    function createOrder(uint256 _amount, uint256 _price, OrderType _orderType) external {
        require(_amount > 0, "Amount must be greater than zero");

        if (_orderType == OrderType.Buy) {
            require(token2.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        } else {
            require(token1.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        }

        uint256 orderId = nextOrderId++;
        orders[orderId] = Order(msg.sender, _amount, _price, _orderType);

        userOrders[msg.sender].set(orderId, msg.sender);

        emit OrderCreated(orderId, msg.sender, _amount, _price, _orderType);
    }

    /// @notice Cancels an existing order
    /// @param _orderId The ID of the order to be canceled
    /// @dev Returns the tokens to the user based on the order type
    function cancelOrder(uint256 _orderId) external {
        Order memory order = orders[_orderId];
        require(order.user == msg.sender, "Not the order owner");

        if (order.orderType == OrderType.Buy) {
            require(token2.transfer(msg.sender, order.amount), "Transfer failed");
        } else {
            require(token1.transfer(msg.sender, order.amount), "Transfer failed");
        }

        delete orders[_orderId];
        userOrders[msg.sender].remove(_orderId);

        emit OrderCanceled(_orderId);
    }

    /// @notice Retrieves an order by its ID
    /// @param _orderId The ID of the order to retrieve
    /// @return The Order struct containing the order details
    function getOrder(uint256 _orderId) external view returns (Order memory) {
        return orders[_orderId];
    }

    /// @notice Retrieves all order IDs for a given user
    /// @param _user The address of the user whose orders to retrieve
    /// @return An array of order IDs belonging to the user
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
