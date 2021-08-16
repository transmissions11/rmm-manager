pragma solidity 0.8.6;

/// @title  Borrow Manager
/// @author Primitive

import "@primitivefinance/v2-core/contracts/interfaces/IPrimitiveFactory.sol";
import "@primitivefinance/v2-core/contracts/interfaces/engine/IPrimitiveEngineActions.sol";
import "@primitivefinance/v2-core/contracts/interfaces/engine/IPrimitiveEngineView.sol";
import "@primitivefinance/v2-core/contracts/interfaces/callback/IPrimitiveBorrowCallback.sol";
import "@primitivefinance/v2-core/contracts/libraries/Margin.sol";
import "@primitivefinance/v2-core/contracts/libraries/Position.sol";
import "@primitivefinance/v2-core/contracts/libraries/Transfers.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "../libraries/PositionHouse.sol";

abstract contract BorrowManager is IPrimitiveBorrowCallback {
    using Transfers for IERC20;
    using Margin for mapping(address => Margin.Data);
    using Margin for Margin.Data;
    using Position for Position.Data;
    using Position for mapping(bytes32 => Position.Data);
    using PositionHouse for PositionHouse.Data;
    using PositionHouse for mapping(bytes32 => PositionHouse.Data);
    struct BorrowCallbackData {
        address engine;
        address payer;
        ISwapRouter.ExactInputSingleParams params;
    }

    uint256 public fee;
    address public feeRecipient;

    address public factory;
    ISwapRouter public router;
    mapping(address => Margin.Data) public margins;
    mapping(address => mapping(bytes32 => PositionHouse.Data)) public positions;

    error FeeMaxError();
    error FeeMinError();
    error NotEngineError(address decoded, address from);
    error MaxPremiumError(uint256 maxPremium, uint256 premium);

    function setBorrowFee(uint256 fee_) external {
        if (fee_ > 1500) revert FeeMaxError(); // 0.15%
        if (fee < 100) revert FeeMinError(); // 0.01%
        fee = fee_; // set fee
    }

    /// @notice Borrows liquidity, swaps stable tokens removed liquidity to risky, pays premium
    /// @dev    Charges a fee to the periphery contract's liquidity
    function borrowCallback(
        uint256 delLiquidity,
        uint256 delRisky,
        uint256 delStable,
        bytes calldata data
    ) external override {
        BorrowCallbackData memory decoded = abi.decode(data, (BorrowCallbackData));
        if (decoded.engine != msg.sender) revert NotEngineError(decoded.engine, msg.sender);
        (address risky, address stable) = (
            IPrimitiveEngineView(msg.sender).risky(),
            IPrimitiveEngineView(msg.sender).stable()
        );

        // Swap stable to risky
        uint256 riskyOut = router.exactInputSingle(
            ISwapRouter.ExactInputSingleParams({
                tokenIn: stable,
                tokenOut: risky,
                fee: decoded.params.fee,
                recipient: msg.sender, // send risky proceeds to engine
                deadline: decoded.params.deadline,
                amountIn: delStable,
                amountOutMinimum: decoded.params.amountOutMinimum,
                sqrtPriceLimitX96: decoded.params.sqrtPriceLimitX96
            })
        );

        uint256 riskyNeeded = delLiquidity - delRisky;
        riskyNeeded = riskyOut > riskyNeeded ? riskyNeeded : riskyNeeded - riskyOut;
        IERC20(risky).transferFrom(decoded.payer, feeRecipient, fee); // pay fee
        IERC20(risky).transferFrom(decoded.payer, msg.sender, riskyNeeded); // pay premium
    }

    struct LongParams {
        address engine;
        address payer;
        bytes32 poolId;
        uint256 delLiquidity;
        bool fromMargin;
        uint256 maxPremium;
    }

    event OpenedLong(
        address indexed from,
        address indexed engine,
        bytes32 indexed poolId,
        uint256 delLiquidity,
        uint256 premium
    );

    function openLong(LongParams memory params)
        internal
        returns (
            uint256 delRisky,
            uint256 delStable,
            uint256 premium
        )
    {
        (delRisky, delStable, premium) = IPrimitiveEngineActions(params.engine).borrow(
            params.poolId,
            params.delLiquidity,
            params.fromMargin,
            new bytes(0)
        );

        // withdraw from margin account of msg.sender if paid with margin
        if (params.fromMargin) {
            margins.withdraw(premium, 0);
            margins[msg.sender].deposit(0, delStable);
        }

        if (premium > params.maxPremium) revert MaxPremiumError(params.maxPremium, premium);
        positions[params.engine][Position.getPositionId(msg.sender, params.poolId)].borrow(params.delLiquidity);

        emit OpenedLong(msg.sender, params.engine, params.poolId, params.delLiquidity, premium);
    }
}
