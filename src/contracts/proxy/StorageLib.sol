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
library StorageLib {
    // Global namespace for use in deriving storage slot locations
    string internal constant GLOBAL_ERC7201_NAMESPACE = "AgoraDollarErc1967Proxy";

    // Use this function to check hardcoded bytes32 values against the expected formula
    function deriveErc7201StorageSlot(string memory _localNamespace) internal pure returns (bytes32) {
        bytes memory _namespace = abi.encodePacked(GLOBAL_ERC7201_NAMESPACE, ".", _localNamespace);
        return keccak256(abi.encode(uint256(keccak256(_namespace)) - 1)) & ~bytes32(uint256(0xff));
    }

    //==============================================================================
    // Eip3009 Storage Items
    //==============================================================================

    string internal constant EIP3009_NAMESPACE = "Eip3009Storage";

    /// @custom:storage-location erc7201:AgoraDollarErc1967Proxy.Eip3009Storage
    struct Eip3009Storage {
        mapping(address _authorizer => mapping(bytes32 _nonce => bool _isNonceUsed)) isAuthorizationUsed;
    }

    /// @dev keccak256(abi.encode(uint256(keccak256("AgoraDollarErc1967Proxy.Eip3009Storage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant EIP3009_STORAGE_SLOT_ =
        0xbb0a37da742be2e3b68bdb11d195150f4243c03fb37d3cdfa756046082a38600;

    function getPointerToEip3009Storage() internal pure returns (Eip3009Storage storage $) {
        /// @solidity memory-safe-assembly
        assembly {
            $.slot := EIP3009_STORAGE_SLOT_
        }
    }

    //==============================================================================
    // Erc2612 Storage Items
    //==============================================================================

    string internal constant ERC2612_NAMESPACE = "Erc2612Storage";

    /// @custom:storage-location erc7201:AgoraDollarErc1967Proxy.Erc2612Storage
    struct Erc2612Storage {
        mapping(address => uint256) nonces;
    }

    /// @dev keccak256(abi.encode(uint256(keccak256("AgoraDollarErc1967Proxy.Erc2612Storage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant ERC2612_STORAGE_SLOT_ =
        0x69e87f5b9323740fce20cdf574dacd1d10e756da64a1f2df70fd1ace4c7cc300;

    function getPointerToErc2612Storage() internal pure returns (Erc2612Storage storage $) {
        /// @solidity memory-safe-assembly
        assembly {
            $.slot := ERC2612_STORAGE_SLOT_
        }
    }

    //==============================================================================
    // Erc20Core Storage Items
    //==============================================================================

    string internal constant ERC20_CORE_NAMESPACE = "Erc20CoreStorage";

    struct Erc20AccountData {
        bool isFrozen;
        uint248 balance;
    }

    /// @custom:storage-location erc7201:AgoraDollarErc1967Proxy.Erc20CoreStorage
    struct Erc20CoreStorage {
        /// @dev _account the account whose data we are accessing
        /// @dev _accountData the account data for the account
        mapping(address _account => Erc20AccountData _accountData) accountData;
        /// @dev _owner The owner of the tokens
        /// @dev _spender The spender of the tokens
        /// @dev _accountAllowance the allowance of the spender
        mapping(address _owner => mapping(address _spender => uint256 _accountAllowance)) accountAllowances;
        uint256 totalSupply;
    }

    /// @dev keccak256(abi.encode(uint256(keccak256("AgoraDollarErc1967Proxy.Erc20CoreStorage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant ERC20_CORE_STORAGE_SLOT_ =
        0x455730fed596673e69db1907be2e521374ba893f1a04cc5f5dd931616cd6b700;

    function getPointerToErc20CoreStorage() internal pure returns (Erc20CoreStorage storage $) {
        /// @solidity memory-safe-assembly
        assembly {
            $.slot := ERC20_CORE_STORAGE_SLOT_
        }
    }

    //==============================================================================
    // AgoraDollarAccessControl Storage Items
    //==============================================================================

    string internal constant AGORA_DOLLAR_ACCESS_CONTROL_NAMESPACE = "AgoraDollarAccessControlStorage";

    /// @notice The RoleData struct
    /// @param pendingRoleAddress The address of the nominated (pending) role
    /// @param currentRoleAddress The address of the current role
    struct AgoraDollarAccessControlRoleData {
        address pendingRoleAddress;
        address currentRoleAddress;
    }

    /// @custom:storage-location erc7201:AgoraDollarErc1967Proxy.AgoraDollarAccessControlStorage
    struct AgoraDollarAccessControlStorage {
        /// @dev _roleData the data for the role
        mapping(bytes32 _role => AgoraDollarAccessControlRoleData _roleData) roleData;
    }

    /// @dev keccak256(abi.encode(uint256(keccak256("AgoraDollarErc1967Proxy.AgoraDollarAccessControlStorage")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant AGORA_DOLLAR_ACCESS_CONTROL_STORAGE_SLOT_ =
        0x9d28e63f6379c0b2127b14120db65179caba9597ddafa73863de41a4ba1fe700;

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

    /// @custom:storage-location erc1967:eip1967.proxy.admin
    struct AgoraDollarErc1967ProxyAdminStorage {
        address proxyAdminAddress;
    }

    // NOTE: deviates from erc7201 standard because erc1967 defines its own storage slot algorithm
    /// @dev bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1)
    bytes32 internal constant AGORA_DOLLAR_ERC1967_PROXY_ADMIN_STORAGE_SLOT_ =
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

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
    // AgoraDollarErc1967 Implementation Slot Items
    //==============================================================================

    /// @custom:storage-location erc1967:eip1967.proxy.implementation
    struct AgoraDollarErc1967ProxyContractStorage {
        address implementationAddress; // least significant bits first
        uint96 placeholder; // Placeholder for bitmask items defined below
    }

    /// @dev bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
    bytes32 internal constant AGORA_DOLLAR_ERC1967_PROXY_CONTRACT_STORAGE_SLOT_ =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @notice The ```getPointerToAgoraDollarErc1967ProxyContractStorage``` function returns a pointer to the storage slot for the implementation address.
    /// @return contractData The data in the storage slot for the implementation address and other data.
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

    function sloadImplementationSlotDataAsUint256() internal view returns (uint256 _contractData) {
        /// @solidity memory-safe-assembly
        assembly {
            _contractData := sload(AGORA_DOLLAR_ERC1967_PROXY_CONTRACT_STORAGE_SLOT_)
        }
    }

    function sstoreImplementationSlotDataAsUint256(uint256 _contractData) internal {
        /// @solidity memory-safe-assembly
        assembly {
            sstore(AGORA_DOLLAR_ERC1967_PROXY_CONTRACT_STORAGE_SLOT_, _contractData)
        }
    }

    // Contract Access Control masks
    uint256 internal constant IS_MSG_SENDER_FROZEN_CHECK_ENABLED_BIT_POSITION_ = 1 << (255 - 0);
    uint256 internal constant IS_MINT_PAUSED_BIT_POSITION_ = 1 << (255 - 1);
    uint256 internal constant IS_FREEZING_PAUSED_BIT_POSITION_ = 1 << (255 - 2);
    uint256 internal constant IS_TRANSFER_PAUSED_BIT_POSITION_ = 1 << (255 - 3);
    uint256 internal constant IS_SIGNATURE_VERIFICATION_PAUSED_BIT_POSITION_ = 1 << (255 - 4);

    // internal function upgrade masks
    // Erc20
    uint256 internal constant IS_TRANSFER_UPGRADED_BIT_POSITION_ = 1 << (255 - 10);
    uint256 internal constant IS_TRANSFER_FROM_UPGRADED_BIT_POSITION_ = 1 << (255 - 11);

    // Eip 3009
    uint256 internal constant IS_TRANSFER_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION_ = 1 << (255 - 12);
    uint256 internal constant IS_RECEIVE_WITH_AUTHORIZATION_UPGRADED_BIT_POSITION_ = 1 << (255 - 13);

    //==============================================================================
    // Bitmask Functions
    //==============================================================================

    function isMsgSenderFrozenCheckEnabled(uint256 _contractData) internal pure returns (bool) {
        return _contractData & IS_MSG_SENDER_FROZEN_CHECK_ENABLED_BIT_POSITION_ != 0;
    }

    function isMintPaused(uint256 _contractData) internal pure returns (bool) {
        return _contractData & IS_MINT_PAUSED_BIT_POSITION_ != 0;
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

    error TransferPaused();
    error SignatureVerificationPaused();
    error MintPaused();
    error FreezingPaused();
}
