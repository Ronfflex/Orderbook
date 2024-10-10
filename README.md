- [OrderBook](./docs/src/src/OrderBook.sol/contract.OrderBook.md)

# OrderBook Smart Contract

## Overview

The OrderBook smart contract is a decentralized exchange (DEX) implementation that allows users to create and manage buy and sell orders for a pair of ERC20 tokens. It provides a simple yet effective way to facilitate token trading without the need for a centralized authority.

## Features

- Create buy and sell orders for a pair of ERC20 tokens
- Cancel existing orders
- View order details
- Retrieve all orders for a specific user

## Contract Structure

The OrderBook contract is built using Solidity and inherits from OpenZeppelin's `Ownable` contract for basic access control. It uses two main data structures:

1. `Order`: A struct that represents an individual order in the order book.
2. `OrderType`: An enum that distinguishes between buy and sell orders.

## How It Works

### Order Creation

1. Users call the `createOrder` function, specifying:
   - Amount of tokens to trade
   - Price per token
   - Order type (buy or sell)

2. The contract verifies that the order amount is greater than zero.

3. Depending on the order type:
   - For buy orders: The contract transfers the required amount of token2 from the user to the contract.
   - For sell orders: The contract transfers the specified amount of token1 from the user to the contract.

4. The order is stored in the contract's state with a unique order ID.

5. The order ID is associated with the user's address for easy retrieval.

6. An `OrderCreated` event is emitted with the order details.

### Order Cancellation

1. Users call the `cancelOrder` function with the ID of the order they wish to cancel.

2. The contract verifies that the caller is the original creator of the order.

3. Depending on the order type:
   - For buy orders: The contract returns the locked token2 to the user.
   - For sell orders: The contract returns the locked token1 to the user.

4. The order is removed from the contract's state.

5. The order ID is disassociated from the user's address.

6. An `OrderCanceled` event is emitted with the order ID.

### Viewing Orders

- Users can call `getOrder` with an order ID to retrieve the details of a specific order.
- Users can call `getUserOrders` with a user address to get an array of all order IDs associated with that user.

## Security Considerations

- The contract uses OpenZeppelin's secure implementations for standard functionalities.
- Access control is implemented to ensure only order creators can cancel their own orders.
- The contract assumes that the ERC20 tokens being traded are trusted and implement the standard correctly.

## Limitations

- The contract does not include an automatic matching engine for orders.
- There is no partial order fulfillment; orders must be filled completely or not at all.
- The contract does not implement any fee mechanism for trades.

## How to Use

1. Deploy the OrderBook contract, providing the addresses of the two ERC20 tokens to be traded.

2. To create an order:
   - Approve the OrderBook contract to spend your tokens (token1 for sell orders, token2 for buy orders).
   - Call `createOrder` with the desired amount, price, and order type.

3. To cancel an order:
   - Call `cancelOrder` with the ID of the order you wish to cancel.

4. To view orders:
   - Call `getOrder` with an order ID to see details of a specific order.
   - Call `getUserOrders` with a user address to see all order IDs for that user.

## Development and Testing

This contract is developed using the Foundry framework. To set up the development environment and run tests:

1. Install Foundry: https://book.getfoundry.sh/getting-started/installation.html

2. Clone the repository:
   ```
   git clone <repository-url>
   cd <repository-directory>
   ```

3. Install dependencies:
   ```
   forge install
   ```

4. Run tests:
   ```
   forge test
   ```

5. Generate documentation:
   ```
   forge doc
   ```

## License

This project is licensed under the MIT License.