// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.6;

/// @author  Primitive
/// @notice  Small library to compute the address of the engines
library EngineAddress {
    /// @notice Thrown when the target Engine is not deployed
    error EngineNotDeployedError();

    /// @notice Hash of the bytecode of the PrimitiveEngine
    bytes32 internal constant ENGINE_INIT_CODE_HASH =
        0x3187e25cd8f65ad9c44cb7d8c3f78847a93d5e150d0efbd41bca66a6efb16e10;

    /// @notice         Computes the address of an engine
    /// @param factory  Address of the factory
    /// @param risky    Address of the risky token
    /// @param stable   Address of the stable token
    /// @return engine  Computed address of the engine
    function computeAddress(
        address factory,
        address risky,
        address stable
    ) internal pure returns (address engine) {
        engine = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(hex"ff", factory, keccak256(abi.encode(risky, stable)), ENGINE_INIT_CODE_HASH)
                    )
                )
            )
        );
    }
}
