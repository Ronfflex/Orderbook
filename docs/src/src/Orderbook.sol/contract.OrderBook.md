# OrderBook
[Git Source](https://github.com/Ronfflex/Orderbook/blob/5d5047c4d97dd154fd772b4df43024bb34a3efa4/src/OrderBook.sol)

**Inherits:**
Ownable

A decentralized order book for trading between two ERC20 tokens

*This contract allows users to create and cancel buy/sell orders for a pair of ERC20 tokens*


## State Variables
### token1
The first token in the trading pair


```solidity
IERC20 public token1;
```


### token2
The second token in the trading pair


```solidity
IERC20 public token2;
```


### orders
Mapping of order ID to Order struct


```solidity
mapping(uint256 => Order) private orders;
```


### nextOrderId
The ID to be assigned to the next order


```solidity
uint256 private nextOrderId;
```


### userOrders
Mapping to track user orders


```solidity
mapping(address => EnumerableMap.UintToAddressMap) private userOrders;
```


## Functions
### constructor

Initializes the OrderBook with two ERC20 tokens


```solidity
constructor(address _token1, address _token2) Ownable(msg.sender);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token1`|`address`|The address of the first token in the trading pair|
|`_token2`|`address`|The address of the second token in the trading pair|


### createOrder

Creates a new order in the order book

*Transfers tokens from the user to the contract based on the order type*


```solidity
function createOrder(uint256 _amount, uint256 _price, OrderType _orderType) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|The amount of tokens to be traded|
|`_price`|`uint256`|The price per token for the order|
|`_orderType`|`OrderType`|The type of the order (Buy or Sell)|


### cancelOrder

Cancels an existing order

*Returns the tokens to the user based on the order type*


```solidity
function cancelOrder(uint256 _orderId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderId`|`uint256`|The ID of the order to be canceled|


### getOrder

Retrieves an order by its ID


```solidity
function getOrder(uint256 _orderId) external view returns (Order memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_orderId`|`uint256`|The ID of the order to retrieve|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Order`|The Order struct containing the order details|


### getUserOrders

Retrieves all order IDs for a given user


```solidity
function getUserOrders(address _user) external view returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_user`|`address`|The address of the user whose orders to retrieve|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|An array of order IDs belonging to the user|


## Events
### OrderCreated
Emitted when a new order is created


```solidity
event OrderCreated(uint256 orderId, address indexed user, uint256 amount, uint256 price, OrderType orderType);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`orderId`|`uint256`|The ID of the newly created order|
|`user`|`address`|The address of the user who created the order|
|`amount`|`uint256`|The amount of tokens to be traded|
|`price`|`uint256`|The price per token for the order|
|`orderType`|`OrderType`|The type of the order (Buy or Sell)|

### OrderCanceled
Emitted when an order is canceled


```solidity
event OrderCanceled(uint256 orderId);
```

**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`orderId`|`uint256`|The ID of the canceled order|

## Structs
### Order
Struct to represent an order in the order book


```solidity
struct Order {
    address user;
    uint256 amount;
    uint256 price;
    OrderType orderType;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`user`|`address`|The address of the user who created the order|
|`amount`|`uint256`|The amount of tokens to be traded|
|`price`|`uint256`|The price per token for the order|
|`orderType`|`OrderType`|The type of the order (Buy or Sell)|

## Enums
### OrderType
Enum to represent the type of order (Buy or Sell)


```solidity
enum OrderType {
    Buy,
    Sell
}
```

