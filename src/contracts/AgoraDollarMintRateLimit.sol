// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.28;

// ====================================================================
//             _        ______     ___   _______          _
//            / \     .' ___  |  .'   `.|_   __ \        / \
//           / _ \   / .'   \_| /  .-.  \ | |__) |      / _ \
//          / ___ \  | |   ____ | |   | | |  __ /      / ___ \
//        _/ /   \ \_\ `.___]  |\  `-'  /_| |  \ \_  _/ /   \ \_
//       |____| |____|`._____.'  `.___.'|____| |___||____| |____|
// ====================================================================
// ==================== AgoraDollarMintRateLimit ======================
// ====================================================================

import { AgoraDollarAccessControl } from "./AgoraDollarAccessControl.sol";

import { StorageLib } from "./proxy/StorageLib.sol";

/// @notice The ```AgoraDollarMintRateLimit``` contract implements a linear decay rate limit for the  `_mint` functionality.
/// @dev Inspired by the LayerZero rate limiter:
/// https://github.com/LayerZero-Labs/devtools/blob/main/packages/oapp-evm/contracts/oapp/utils/RateLimiter.sol
abstract contract AgoraDollarMintRateLimit is AgoraDollarAccessControl {
    /// @notice Rate Limit Configuration struct.
    /// @param address The address of the minter
    /// @param limit This represents the maximum allowed amount within a given window.
    /// @param window Defines the duration of the rate limiting window.
    struct MintRateLimitConfig {
        address minter;
        uint256 limit;
        uint256 window;
    }

    //==============================================================================
    // Internal Procedural Functions
    //==============================================================================

    /// @notice Sets the Rate Limit.
    /// @param _rateLimitConfig A `MintRateLimitConfig` struct representing the rate limit configuration.
    /// - `minter`: The minter address for which the rate limit is being set.
    /// - `limit`: This represents the maximum allowed amount within a given window.
    /// - `window`: Defines the duration of the rate limiting window.
    function _setMintRateLimit(MintRateLimitConfig memory _rateLimitConfig) internal {
        StorageLib.RateLimit storage rateLimit = StorageLib.getPointerToMintRateLimitStorage().rateLimits[
            _rateLimitConfig.minter
        ];

        // @dev Ensure we checkpoint the existing rate limit as to not retroactively apply the new decay rate.
        _outflow({ _minter: _rateLimitConfig.minter, _amount: 0 });

        // @dev Does NOT reset the amountInFlight/lastUpdated of an existing rate limit.
        rateLimit.limit = _rateLimitConfig.limit;
        rateLimit.window = _rateLimitConfig.window;
        emit MintRateLimitChanged(_rateLimitConfig);
    }

    /// @notice Checks current amount in flight and amount that can be minted for a given rate limit window.
    /// @param _amountInFlight The amount in the current window.
    /// @param _lastUpdated Timestamp representing the last time the rate limit was checked or updated.
    /// @param _limit This represents the maximum allowed amount within a given window.
    /// @param _window Defines the duration of the rate limiting window.
    /// @return currentAmountInFlight The amount in the current window.
    /// @return amountCanBeMinted The amount that can be minted.
    function _amountCanBeMinted(
        uint256 _amountInFlight,
        uint256 _lastUpdated,
        uint256 _limit,
        uint256 _window
    ) internal view returns (uint256 currentAmountInFlight, uint256 amountCanBeMinted) {
        //slither-disable-next-line timestamp
        uint256 _timeSinceLastMint = block.timestamp - _lastUpdated;
        // @dev Presumes linear decay.
        uint256 _decay = (_limit * _timeSinceLastMint) / (_window > 0 ? _window : 1); // prevent division by zero
        currentAmountInFlight = _amountInFlight <= _decay ? 0 : _amountInFlight - _decay;
        // @dev In the event the _limit is lowered, and the 'in-flight' amount is higher than the _limit, set to 0.
        amountCanBeMinted = _limit <= currentAmountInFlight ? 0 : _limit - currentAmountInFlight;
    }

    /// @notice Verifies whether the specified amount falls within the rate limit constraints for the targeted
    /// minter address. On successful verification, it updates amountInFlight and lastUpdated. If the amount exceeds
    /// the rate limit, the operation reverts.
    /// @param _minter The address of the minter
    /// @param _amount The amount to check for rate limit constraints.
    function _outflow(address _minter, uint256 _amount) internal {
        StorageLib.RateLimit storage rateLimit = StorageLib.getPointerToMintRateLimitStorage().rateLimits[_minter];

        (uint256 currentAmountInFlight, uint256 amountCanBeMinted) = _amountCanBeMinted({
            _amountInFlight: rateLimit.amountInFlight,
            _lastUpdated: rateLimit.lastUpdated,
            _limit: rateLimit.limit,
            _window: rateLimit.window
        });
        if (_amount > amountCanBeMinted) revert RateLimitExceeded();

        rateLimit.amountInFlight = currentAmountInFlight + _amount;
        rateLimit.lastUpdated = block.timestamp;
    }

    /// @notice Get the current amount that can be sent to this destination endpoint id for the given rate limit window.
    /// @param _minter The address of the minter
    /// @return currentAmountInFlight The current amount in the current window.
    /// @return amountCanBeMinted The amount that can be minted.
    /// @dev Returns (0, 0) if _minter does not have BRIDGE_MINTER_ROLE or MINTER_ROLE
    function getAmountCanBeMinted(
        address _minter
    ) external view returns (uint256 currentAmountInFlight, uint256 amountCanBeMinted) {
        // Check if _minter has BRIDGE_MINTER_ROLE or MINTER_ROLE
        if (
            !_isRole({ _role: BRIDGE_MINTER_ROLE, _member: _minter }) &&
            !_isRole({ _role: MINTER_ROLE, _member: _minter })
        ) return (0, 0);

        StorageLib.RateLimit memory rateLimit = StorageLib.getPointerToMintRateLimitStorage().rateLimits[_minter];
        return
            _amountCanBeMinted({
                _amountInFlight: rateLimit.amountInFlight,
                _lastUpdated: rateLimit.lastUpdated,
                _limit: rateLimit.limit,
                _window: rateLimit.window
            });
    }

    /// @notice Gets the rate limit for a given minter address.
    /// @param _minter The address of the minter
    /// @return The rate limit config for the given minter address.
    function getMintRateLimit(address _minter) external view returns (StorageLib.RateLimit memory) {
        return StorageLib.getPointerToMintRateLimitStorage().rateLimits[_minter];
    }

    /// @notice Sets the rate limits based on MintRateLimitConfig array.
    /// @dev Must be called by an address holding `RATE_LIMIT_MANAGER_ROLE`
    /// @dev These values are stored in the StorageLib.RateLimit struct for each minter address.
    /// @dev Does NOT reset the amountInFlight/lastUpdated of an existing rate limit.
    /// @dev Disabling the rate limit should be achieved by setting it to a large value (uint128.max)
    /// @param _rateLimitConfig structure defining the rate limits for inbound transfers.
    function setMintRateLimit(MintRateLimitConfig calldata _rateLimitConfig) external {
        /// Checks: Only `RATE_LIMIT_MANAGER_ROLE` can set the rate limits
        _requireSenderIsRole(RATE_LIMIT_MANAGER_ROLE);

        /// Effects: Set the rate limits
        _setMintRateLimit(_rateLimitConfig);
    }

    //==============================================================================
    // Errors
    //==============================================================================

    /// @notice The ```RateLimitExceeded``` error is emitted when a rate limit is exceeded during an attempted mint
    error RateLimitExceeded();

    //==============================================================================
    // Events
    //==============================================================================

    /// @notice Emitted when _setMintRateLimit occurs
    /// @param rateLimitConfig A `MintRateLimitConfig` struct representing the rate limit configurations set.
    /// - `address`: The minter address for which the rate limit is being set.
    /// - `limit`: This represents the maximum allowed amount within a given window.
    /// - `window`: Defines the duration of the rate limiting window.
    event MintRateLimitChanged(MintRateLimitConfig rateLimitConfig);
}
