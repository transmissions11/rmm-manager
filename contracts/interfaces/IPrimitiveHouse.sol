// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.0;
pragma abicoder v2;

import "@primitivefinance/primitive-v2-core/contracts/interfaces/callback/IPrimitiveCreateCallback.sol";
import "@primitivefinance/primitive-v2-core/contracts/interfaces/callback/IPrimitiveLendingCallback.sol";
import "@primitivefinance/primitive-v2-core/contracts/interfaces/callback/IPrimitiveLiquidityCallback.sol";
import "@primitivefinance/primitive-v2-core/contracts/interfaces/callback/IPrimitiveMarginCallback.sol";
import "@primitivefinance/primitive-v2-core/contracts/interfaces/callback/IPrimitiveSwapCallback.sol";
import "@primitivefinance/primitive-v2-core/contracts/libraries/Margin.sol";

interface IPrimitiveHouse is 
  IPrimitiveCreateCallback,
  IPrimitiveLendingCallback, 
  IPrimitiveLiquidityCallback, 
  IPrimitiveMarginCallback, 
  IPrimitiveSwapCallback 
{
    // init
    function initialize(address engine_) external;
    // Margin
    function create(uint256 strike, uint64 sigma, uint32 time, uint256 riskyPrice, bytes calldata data) external;
    function deposit(address owner, uint delRisky, uint delStable, bytes calldata data) external;
    function withdraw(uint256 delRisky, uint256 delStable) external;
    function borrow(bytes32 poolId, address owner, uint delLiquidity, uint256 maxPremium, bytes calldata data) external;
    function allocate(bytes32 poolId, address owner, uint256 delLiquidity, bool fromMargin, bytes calldata data) external;
    function repay(bytes32 poolId, address owner, uint256 delLiquidity, bool fromMargin, bytes calldata data) external;
    // Swap
    function swap(bytes32 poolId, bool addXRemoveY, uint256 deltaOut, uint256 maxDeltaIn, bytes calldata data) external;
    function swapXForY(bytes32 poolId, uint deltaOut) external;
    function swapYForX(bytes32 poolId, uint deltaOut) external;
    // Lending
    function margins(address owner) external view returns (Margin.Data memory);
}
