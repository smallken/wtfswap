// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDT is ERC20 {
    uint8 private constant _DECIMALS = 6; // USDT 实际使用 6 位小数

    constructor() ERC20("Tether USD", "USDT") {
        _mint(msg.sender, 1000000 * 10**decimals()); // 初始铸造 100 万 USDT 给部署者
    }

    function decimals() public pure override returns (uint8) {
        return _DECIMALS;
    }

    // 开放给测试脚本调用的铸造函数
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}