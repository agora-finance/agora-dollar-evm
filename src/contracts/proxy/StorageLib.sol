// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.21;

// ====================================================================
//             _        ______     ___   _______          _
//            / \     .' ___  |  .'   `.|_   __ \        / \
//           / _ \   / .'   \_| /  .-.  \ | |__) |      / _ \
//          / ___ \  | |   ____ | |   | | |  __ /      / ___ \
//        _/ /   \ \_\ `.___]  |\  `-'  /_| |  \ \_  _/ /   \ \_
//       |____| |____|`._____.'  `.___.'|____| |___||____| |____|
// ====================================================================
// ============================ StorageLib ============================
// ====================================================================

/**
 * This library contains information for accessing unstructured storage following erc1967
 * and erc7201 standards.
 *
 * The erc1967 storage slots are defined using their own formula/namespace.
 * These are listed last in the contract.
 *
 * The erc7201 namespace is defined as <ContractName>.<Namespace>
 * The deriveErc7201StorageSlot() function is used to derive the storage slot for a given namespace
 * and to check that value against the hard-coded bytes32 value for the slot location in testing frameworks
 * Each inherited contract has its own struct of the form <ContractName>Storage which matches <Namespace>
 * from above. Each struct is held in a unique namespace and has a unique storage slot.
 * See: https://eips.ethereum.org/EIPS/eip-7201 for additional information regarding this standard
 */
/// @title StorageLib
/// @dev Implements pure functions for calculating and accessing storage slots according to eip1967 and eip7201
/// @author Agora
library StorageLib {
    /// @notice Global namespace for use in deriving storage slot locations
    string internal constant GLOBAL_ERC7201_NAMESPACE = "AgoraDollarErc1967Proxy";

    // Use this function to check hardcoded bytes32 values against the expected formula
    function deriveErc7201StorageSlot(string memory _localNamespace) internal pure returns (bytes32) {
        bytes memory _namespace = abi.encodePacked(GLOBAL_ERC7201_NAMESPACE, ".", _localNamespace);
        return keccak256(abi.encode(uint256(keccak256(_namespace)) - 1)) & ~bytes32(uint256(0xff));
    }

    //==============================================================================
    // Eip3009 Storage Items
    //==============================================================================

    /// @notice The EIP3009 namespace
    string internal constant EIP3009_NAMESPACE = "Eip3009Storage";

    /// @notice The Eip3009Storage struct
    /// @param isAuthorizationUsed A mapping of authorizer to nonce to boolean to indicate if the nonce has been used
    /// @custom:storage-location erc7201:AgoraDollarErc1967Proxy.Eip3009Storage
    struct Eip3009Storage {
        mapping(address _authorizer => mapping(bytes32 _nonce => bool _isNonceUsed)) isAuthorizationUsed;
    }

    /// @notice The ```EIP3009_STORAGE_SLOT_``` is the storage slot for the Eip3009Storage struct
    /// @dev keccak256(abi.encode(uint256(keccak256("AgoraDollarErc1967Proxy.Eip3009Storage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant EIP3009_STORAGE_SLOT_ =
        0xbb0a37da742be2e3b68bdb11d195150f4243c03fb37d3cdfa756046082a38600;

    /// @notice The ```getPointerToEip3009Storage``` function returns a pointer to the Eip3009Storage struct
    /// @return $ A pointer to the Eip3009Storage struct
    function getPointerToEip3009Storage() internal pure returns (Eip3009Storage storage $) {
        /// @solidity memory-safe-assembly
        assembly {
            $.slot := EIP3009_STORAGE_SLOT_
        }
    }

    //==============================================================================
    // Erc2612 Storage Items
    //==============================================================================

    /// @notice The Erc2612 namespace
    string internal constant ERC2612_NAMESPACE = "Erc2612Storage";

    /// @notice The Erc2612Storage struct
    /// @param nonces A mapping of signer address to uint256 to store the nonce
    /// @custom:storage-location erc7201:AgoraDollarErc1967Proxy.Erc2612Storage
    struct Erc2612Storage {
        mapping(address _signer => uint256 _nonce) nonces;
    }

    /// @notice The ```ERC2612_STORAGE_SLOT_``` is the storage slot for the Erc2612Storage struct
    /// @dev keccak256(abi.encode(uint256(keccak256("AgoraDollarErc1967Proxy.Erc2612Storage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant ERC2612_STORAGE_SLOT_ =
        0x69e87f5b9323740fce20cdf574dacd1d10e756da64a1f2df70fd1ace4c7cc300;

    /// @notice The ```getPointerToErc2612Storage``` function returns a pointer to the Erc2612Storage struct
    /// @return $ A pointer to the Erc2612Storage struct
    function getPointerToErc2612Storage() internal pure returns (Erc2612Storage storage $) {
        /// @solidity memory-safe-assembly
        assembly {
            $.slot := ERC2612_STORAGE_SLOT_
        }
    }

    //==============================================================================
    // Erc20Core Storage Items
    //==============================================================================

    /// @notice The Erc20Core namespace
    string internal constant ERC20_CORE_NAMESPACE = "Erc20CoreStorage";

    /// @notice The Erc20AccountData struct
    /// @param isFrozen A boolean to indicate if the account is frozen
    /// @param balance A uint248 to store the balance of the account
    struct Erc20AccountData {
        bool isFrozen;
        uint248 balance;
    }

    /// @notice The Erc20CoreStorage struct
    /// @param accountData A mapping of address to Erc20AccountData to store account data
    /// @param accountAllowances A mapping of owner to spender to uint256 to store the allowance
    /// @param totalSupply A uint256 to store the total supply of tokens
    /// @custom:storage-location erc7201:AgoraDollarErc1967Proxy.Erc20CoreStorage
    struct Erc20CoreStorage {
        /// @dev _account The account whose data we are accessing
        /// @dev _accountData The account data for the account
        mapping(address _account => Erc20AccountData _accountData) accountData;
        /// @dev _owner The owner of the tokens
        /// @dev _spender The spender of the tokens
        /// @dev _accountAllowance The allowance of the spender
        mapping(address _owner => mapping(address _spender => uint256 _accountAllowance)) accountAllowances;
        /// @dev The total supply of tokens
        uint256 totalSupply;
    }

    /// @notice The ```ERC20_CORE_STORAGE_SLOT_``` is the storage slot for the Erc20CoreStorage struct
    /// @dev keccak256(abi.encode(uint256(keccak256("AgoraDollarErc1967Proxy.Erc20CoreStorage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant ERC20_CORE_STORAGE_SLOT_ =
        0x455730fed596673e69db1907be2e521374ba893f1a04cc5f5dd931616cd6b700;

    /// @notice The ```getPointerToErc20CoreStorage``` function returns a pointer to the Erc20CoreStorage struct
    /// @return $ A pointer to the Erc20CoreStorage struct
    function getPointerToErc20CoreStorage() internal pure returns (Erc20CoreStorage storage $) {
        /// @solidity memory-safe-assembly
        assembly {
            $.slot := ERC20_CORE_STORAGE_SLOT_
        }
    }

    //==============================================================================
    // AgoraDollarAccessControl Storage Items
    //==============================================================================

    /// @notice The AgoraDollarAccessControl namespace
    string internal constant AGORA_DOLLAR_ACCESS_CONTROL_NAMESPACE = "AgoraDollarAccessControlStorage";

    /// @notice The RoleData struct
    /// @param pendingRoleAddress The address of the nominated (pending) role
    /// @param currentRoleAddress The address of the current role
    struct AgoraDollarAccessControlRoleData {
        address pendingRoleAddress;
        address currentRoleAddress;
    }

    /// @notice The AgoraDollarAccessControlStorage struct
    /// @param roleData A mapping of role identifier to AgoraDollarAccessControlRoleData to store role data
    /// @custom:storage-location erc7201:AgoraDollarErc1967Proxy.AgoraDollarAccessControlStorage
    struct AgoraDollarAccessControlStorage {
        mapping(bytes32 _role => AgoraDollarAccessControlRoleData _roleData) roleData;
    }

    /// @notice The ```AGORA_DOLLAR_ACCESS_CONTROL_STORAGE_SLOT_``` is the storage slot for the AgoraDollarAccessControlStorage struct
    /// @dev keccak256(abi.encode(uint256(keccak256("AgoraDollarErc1967Proxy.AgoraDollarAccessControlStorage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant AGORA_DOLLAR_ACCESS_CONTROL_STORAGE_SLOT_ =
        0x9d28e63f6379c0b2127b14120db65179caba9597ddafa73863de41a4ba1fe700;

    /// @notice The ```getPointerToAgoraDollarAccessControlStorage``` function returns a pointer to the AgoraDollarAccessControlStorage struct
    /// @return $ A pointer to the AgoraDollarAccessControlStorage struct
    function getPointerToAgoraDollarAccessControlStorage()
        internal
        pure
        returns (AgoraDollarAccessControlStorage storage $)
    {
        /// @solidity memory-safe-assembly
        assembly {
            $.slot := AGORA_DOLLAR_ACCESS_CONTROL_STORAGE_SLOT_
        }
    }

    //==============================================================================
    // AgoraDollarErc1967 Admin Slot Items
    //==============================================================================

    /// @notice The AgoraDollarErc1967ProxyAdminStorage struct
    /// @param proxyAdminAddress The address of the proxy admin contract
    /// @custom:storage-location erc1967:eip1967.proxy.admin
    struct AgoraDollarErc1967ProxyAdminStorage {
        address proxyAdminAddress;
    }

    /// @notice The ```AGORA_DOLLAR_ERC1967_PROXY_ADMIN_STORAGE_SLOT_``` is the storage slot for the AgoraDollarErc1967ProxyAdminStorage struct
    /// @dev NOTE: deviates from erc7201 standard because erc1967 defines its own storage slot algorithm
    /// @dev bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1)
    bytes32 internal constant AGORA_DOLLAR_ERC1967_PROXY_ADMIN_STORAGE_SLOT_ =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /// @notice The ```getPointerToAgoraDollarErc1967ProxyAdminStorage``` function returns a pointer to the AgoraDollarErc1967ProxyAdminStorage struct
    /// @return adminSlot A pointer to the AgoraDollarErc1967ProxyAdminStorage struct
    function getPointerToAgoraDollarErc1967ProxyAdminStorage()
        internal
        pure
        returns (AgoraDollarErc1967ProxyAdminStorage storage adminSlot)
    {
        /// @solidity memory-safe-assembly
        assembly {
            adminSlot.slot := AGORA_DOLLAR_ERC1967_PROXY_ADMIN_STORAGE_SLOT_
        }
    }

    //==============================================================================
    // AgoraDollarErc1967Proxy Implementation Slot Items
    //==============================================================================

    /// @notice The AgoraDollarErc1967ProxyContractStorage struct
    /// @param implementationAddress The address of the implementation contract
    /// @param placeholder A placeholder for bits to be used as bitmask items
    /// @custom:storage-location erc1967:eip1967.proxy.implementation
    struct AgoraDollarErc1967ProxyContractStorage {
        address implementationAddress; // least significant bits first
        uint96 placeholder; // Placeholder for bitmask items defined below
    }

    /// @notice The ```AGORA_DOLLAR_ERC1967_PROXY_CONTRACT_STORAGE_SLOT_``` is the storage slot for the AgoraDollarErc1967ProxyContractStorage struct
    /// @dev bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
    bytes32 internal constant AGORA_DOLLAR_ERC1967_PROXY_CONTRACT_STORAGE_SLOT_ =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @notice The ```getPointerToAgoraDollarErc1967ProxyContractStorage``` function returns a pointer to the storage slot for the implementation address
    /// @return contractData A pointer to the data in the storage slot for the implementation address and other contract data
    function getPointerToAgoraDollarErc1967ProxyContractStorage()
        internal
        pure
        returns (AgoraDollarErc1967ProxyContractStorage storage contractData)
    {
        /// @solidity memory-safe-assembly
        assembly {
            contractData.slot := AGORA_DOLLAR_ERC1967_PROXY_CONTRACT_STORAGE_SLOT_
        }
    }

    /// @notice The ```sloadImplementationSlotDataAsUint256``` function returns the data at the implementation slot as a uint256
    /// @dev Named this way to draw attention to the sload call
    /// @return _contractData The data at the implementation slot as a uint256
    function sloadImplementationSlotDataAsUint256() internal view returns (uint256 _contractData) {
        /// @solidity memory-safe-assembly
        assembly {
            _contractData := sload(AGORA_DOLLAR_ERC1967_PROXY_CONTRACT_STORAGE_SLOT_)
        }
    }

    /// @notice The ```sstoreImplementationSlotDataAsUint256``` function stores the data at the implementation slot
    /// @dev Named this way to draw attention to the sstore call
    /// @param _contractData The data to store at the implementation slot, given as a uint256
    function sstoreImplementationSlotDataAsUint256(uint256 _contractData) internal {
        /// @solidity memory-safe-assembly
        assembly {
            sstore(AGORA_DOLLAR_ERC1967_PROXY_CONTRACT_STORAGE_SLOT_, _contractData)
        }
    }

    // Contract Access Control masks
    uint256 internal constant IS_MSG_SENDER_FROZEN_CHECK_ENABLED_BIT_POSITION_ = 1 << (255 - 95);
    uint256 internal constant IS_MINT_PAUSED_BIT_POSITION_ = 1 << (255 - 94);
    uint256 internal constant IS_BURN_FROM_PAUSED_BIT_POSITION_ = 1 << (255 - 93);
    uint256 internal constant IS_FREEZING_PAUSED_BIT_POSITION_ = 1 << (255 - 92);
    uint256 internal constant IS_TRANSFER_PAUSED_BIT_POSITION_ = 1 << (255 - 91);
    uint256 internal constant IS_SIGNATURE_VERIFICATION_PAUSED_BIT_POSITION_ = 1 << (255 - 90);

    // internal function upgrade masks
    // Erc20
    uint256 internal constant IS_TRANSFER_UPGRADED_BIT_POSITION_ = 1 << (255 - 89);
    uint256 internal constant IS_TRANSFER_FROM_UPGRADED_BIT_POSITION_ = 1 << (255 - 88);

    // Eip 3009
    uint256 internal constant IS_TRANSFER_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION_ = 1 << (255 - 87);
    uint256 internal constant IS_RECEIVE_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION_ = 1 << (255 - 86);

    //==============================================================================
    // Bitmask Functions
    //==============================================================================

    // These function use a bitmask to check if a specific bit is set in the contract data
    function isMsgSenderFrozenCheckEnabled(uint256 _contractData) internal pure returns (bool) {
        return _contractData & IS_MSG_SENDER_FROZEN_CHECK_ENABLED_BIT_POSITION_ != 0;
    }

    function isMintPaused(uint256 _contractData) internal pure returns (bool) {
        return _contractData & IS_MINT_PAUSED_BIT_POSITION_ != 0;
    }

    function isBurnFromPaused(uint256 _contractData) internal pure returns (bool) {
        return _contractData & IS_BURN_FROM_PAUSED_BIT_POSITION_ != 0;
    }

    function isFreezingPaused(uint256 _contractData) internal pure returns (bool) {
        return _contractData & IS_FREEZING_PAUSED_BIT_POSITION_ != 0;
    }

    function isTransferPaused(uint256 _contractData) internal pure returns (bool) {
        return _contractData & IS_TRANSFER_PAUSED_BIT_POSITION_ != 0;
    }

    function isSignatureVerificationPaused(uint256 _contractData) internal pure returns (bool) {
        return _contractData & IS_SIGNATURE_VERIFICATION_PAUSED_BIT_POSITION_ != 0;
    }

    function isTransferUpgraded(uint256 _contractData) internal pure returns (bool) {
        return _contractData & IS_TRANSFER_UPGRADED_BIT_POSITION_ != 0;
    }

    function isTransferFromUpgraded(uint256 _contractData) internal pure returns (bool) {
        return _contractData & IS_TRANSFER_FROM_UPGRADED_BIT_POSITION_ != 0;
    }

    function isTransferWithAuthorizationUpgraded(uint256 _contractData) internal pure returns (bool) {
        return _contractData & IS_TRANSFER_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION_ != 0;
    }

    function isReceiveWithAuthorizationUpgraded(uint256 _contractData) internal pure returns (bool) {
        return _contractData & IS_RECEIVE_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION_ != 0;
    }

    function implementation(uint256 _contractData) internal pure returns (address) {
        // return least significant 160 bits and cast to an address
        return address(uint160(_contractData));
    }

    function setBitWithMask(
        uint256 _original,
        uint256 _bitToSet,
        bool _setBitToOne
    ) internal pure returns (uint256 _new) {
        // Sets the specified bit to 1 or 0
        _new = _setBitToOne ? _original | _bitToSet : _original & ~_bitToSet;
    }

    //==============================================================================
    // Errors
    //==============================================================================

    /// @notice The ```TransferPaused``` error is emitted when transfers are paused during an attempted transfer
    error TransferPaused();

    /// @notice The ```SignatureVerificationPaused``` error is emitted when signature verification is paused during an attempted transfer
    error SignatureVerificationPaused();

    /// @notice The ```MintPaused``` error is emitted when minting is paused during an attempted mint
    error MintPaused();

    /// @notice The ```BurnFromPaused``` error is emitted when burning is paused during an attempted burn
    error BurnFromPaused();

    /// @notice The ```FreezingPaused``` error is emitted when freezing is paused during an attempted call to freeze() or unfreeze()
    error FreezingPaused();
}
