// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";
import {Test, console} from "../lib/openzeppelin-contracts/lib/forge-std/src/Test.sol";

import {Pool} from "../src/Pool.sol";
import {PoolManager} from "../src/PoolManager.sol";
import {PositionManager} from "../src/PositionManager.sol";
import {IPoolManager} from "../src/interfaces/IPoolManager.sol";
import {IPositionManager} from "../src/interfaces/IPositionManager.sol";
import {IPool} from "../src/interfaces/IPool.sol";
import {WETH9} from "../src/WETH9.sol";
import {IWETH} from "../src/interfaces/IWETH9.sol";
import {MyToken} from "../src/MyToken.sol";
import {USDT} from "../src/USDT.sol";
// import "../libraries/TickMath.sol";
//import {encodeSqrtRatioX96} from "@uniswap/v3-core/contracts/libraries/PriceMath.sol";
import {TickMath} from "../lib/v3-core/contracts/libraries/TickMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";




contract PoolTest is Test {
    Pool public pool;
    PoolManager public poolManager;
    PositionManager public positionManager;
    WETH9 public weth;
    USDT public usdt;
    MyToken public token;
    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;
    address internal owner;
    address internal spender;
    uint8[] public intArry;
    function setUp() public {
        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;
        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);
        vm.deal(owner, 5 ether);
        vm.deal(spender, 5 ether);
        vm.startPrank(owner);
        poolManager = new PoolManager();
        positionManager = new PositionManager(address(poolManager));

        weth = new WETH9();
        console.log("weth:", address(weth));
        token = new MyToken();
        console.log("token:", address(token));
        usdt = new USDT();
        console.log("usdt:", address(usdt));
        // IWETH(weth).deposit{value: 1 ether}();
        weth.deposit{value: 1 ether}();
        console.log("owner weth balance:",weth.balanceOf(owner));
        // console.log("owner weth balance: %s ETH", formatEther(weth.balanceOf(owner)));
        uint256 balanceOwner = IERC20(token).balanceOf(owner);
        console.log("owner balance:", balanceOwner/10 ** 18);
        
        IERC20(token).transfer(spender, 10000 * 10 **18);
        uint256 balanceSpender = IERC20(token).balanceOf(spender);
        console.log("balanceSpender balance:", balanceSpender/10 ** 18);
        uint256 balanceAfterOwner = IERC20(token).balanceOf(owner);
        console.log("owner balanceAfterOwner:", balanceAfterOwner/10 ** 18);
        vm.stopPrank();
        vm.prank(spender);
        weth.deposit{value: 1 ether}();
        // IERC20(token).transfer(spender, 1000 * 10 **18);
        console.log("spender weth balance:",weth.balanceOf(spender));
    }

    function test_CreatePool() public {
         address tokenA;
        address tokenB;
        IPoolManager.CreateAndInitializeParams memory params;
        (tokenA, tokenB) = sortToken(address(weth), address(token));
        console.log("tokenA:", tokenA);
        console.log("tokenB:", tokenB);
        uint24 fee = 40000;
        (uint160 sqrtPriceX96, int24 tickLower,int24 tickUpper ) = getSqrt(1, 300000);
        // uint160 sqrtPriceX96 = encodeSqrtRatioX96(1, 300000); // 计算 sqrt(100/1) * 2^96
        // int24 tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        // console.log("sqrtPriceX96:", sqrtPriceX96);
        // console.log("tick:", tick);
        // // 设置价格区间（覆盖 150k ~ 600k token/ETH）
        // int24 tickSpacing = 60;
        // int24 tickLower = ((tick - 500) / tickSpacing) * tickSpacing;
        // int24 tickUpper = ((tick + 500) / tickSpacing) * tickSpacing;
        vm.prank(owner);
        params = IPoolManager.CreateAndInitializeParams({
            token0: tokenA,
            token1: tokenB,
            fee: fee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            sqrtPriceX96: sqrtPriceX96
        });
        console.log("tickerLower:", params.tickLower);
        console.log("tickerUpper:", params.tickUpper);
        address poolAddr = poolManager.createAndInitializePoolIfNecessary(params);
        console.log("pool:", poolAddr); //createAndInitializePoolIfNecessary
        address tokenC;
        address tokenD;
        (tokenC, tokenD) = sortToken(address(weth), address(usdt));
        (uint160 sqrtPriceX, int24 tickL,int24 tickU ) = getSqrt(1, 3000);
        IPoolManager.CreateAndInitializeParams memory paramsUsd;
        paramsUsd = IPoolManager.CreateAndInitializeParams({
            token0: tokenC,
            token1: tokenD,
            fee: 3000,
            tickLower: tickL,
            tickUpper: tickU,
            sqrtPriceX96: sqrtPriceX
        });
        address poolUsdt = poolManager.createAndInitializePoolIfNecessary(paramsUsd);
        console.log("poolUsdt:", poolUsdt); //createAndInitializePoolIfNecessary

        // 获取getPool
        IPoolManager.PoolInfo[] memory poolsInfo = poolManager.getAllPools();
        // for(uint i = 0; i < poolsInfo.length; i++) {
        //     IPool currentPool = IPool(poolsInfo[i]);
        //     console.log("address:",poolsInfo[i]);

        // }

        assertEq(poolsInfo.length, 2);
        // uint8[] memory intArry = new uint8[]{1,2,3,4,5};
        /**
         * s token0;
        address token1;
        uint32 index;
        uint256 amount0Desired;
        uint256 amount1Desired;
        address recipient;
        uint256 deadline;
         */
        // 
        vm.startPrank(spender);
        weth.approve(address(positionManager), 0.11 ether);
        IERC20(token).approve(address(positionManager), 30000  * 10 ** 18);
        weth.approve(address(poolAddr), 0.11 ether);
        IERC20(token).approve(address(poolAddr), 30000  * 10 ** 18);
        IPositionManager.MintParams memory mintParams = IPositionManager.MintParams({
            token0: address(weth),
            token1: address(token),
            index: 0,
            amount0Desired: 0.01 * 10 ** 18,
            amount1Desired: 30000 * 10 ** 18,
            recipient: spender,
            deadline: block.timestamp + 1 days
        });
        /**
         * (uint256 positionId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1)
         */
        (uint256 positionId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1) = positionManager.mint(mintParams);
            console.log("positionId:", positionId);
            console.log("liquidity:", liquidity);
            console.log("amount0:", amount0);
            console.log("amount1:", amount1);
        vm.stopPrank();

    }

    function getSqrt(uint256 amount0, uint256 amount1) internal returns(uint160 sqrtPriceX96,int24 tickLower, int24 tickUpper ) {
        sqrtPriceX96 = encodeSqrtRatioX96(amount0, amount1); // 计算 sqrt(100/1) * 2^96
        int24 tick = TickMath.getTickAtSqrtRatio(sqrtPriceX96);
        console.log("sqrtPriceX96:", sqrtPriceX96);
        console.log("tick:", tick);
        // 设置价格区间（覆盖 150k ~ 600k token/ETH）
        int24 tickSpacing = 60;
        tickLower = ((tick - 500) / tickSpacing) * tickSpacing;
        tickUpper = ((tick + 500) / tickSpacing) * tickSpacing;
    }

    function encodeSqrtRatioX96(uint256 amount0, uint256 amount1) 
        internal 
        pure 
        returns (uint160 sqrtPriceX96) 
    {
        // uint256 ratio = (amount1 << 96) / amount0;
        // sqrtPriceX96 = uint160(sqrt(ratio));
         require(amount0 > 0, "Div by zero");
        uint256 ratio = (amount1 * 2**96) / amount0;
        sqrtPriceX96 = uint160(Math.sqrt(ratio * 2**96)); // 使用高精度平方根
    }

    // 计算平方根（近似算法）
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function sortToken(
        address tokenA,
        address tokenB
    ) private pure returns (address, address) {
        return tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
