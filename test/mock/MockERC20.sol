// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    bool public failTransfers;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 * 10**decimals());
    }

    function setFailTransfers(bool _fail) external {
        failTransfers = _fail;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        if (failTransfers) {
            return false;
        }
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        if (failTransfers) {
            return false;
        }
        return super.transferFrom(from, to, amount);
    }
}