
# Threat Model

## AgoraDollarAccessControl

**Attacker's goal** - Gain unauthorized access to privileged roles (ADMIN_ROLE, MINTER_ROLE, BURNER_ROLE, PAUSER_ROLE, FREEZER_ROLE)

-   Method 1: Exploit vulnerabilities in the `transferRole` function
    
    -   Requires the attacker to be the current role holder or the admin
        
        -   The attacker is the current role holder
        
        -   Or the attacker is the admin
    -   And the `transferRole` function is not properly implemented
        -   The access control checks are missing or incorrect
        -   The function logic has vulnerabilities (e.g., reentrancy)
    
    -   **Mitigated** by proper access control checks and secure function implementation.
    
-   Method 2: Exploit vulnerabilities in the `acceptTransferRole` function
    
    -   Requires the attacker to be the pending role address
        -   The attacker can manipulate the `_setPendingRoleAddress` function
            
            -   There are vulnerabilities in the `_setPendingRoleAddress` function
            
            > E.g., if the function doesn't check if the caller is authorized to set the pending role
            
        -   Or the attacker can directly set the pending role address in the contract storage
            
            -   There are vulnerabilities that allow direct storage modification
            
            > E.g., if the contract uses delegatecall or has insecure low-level operations
            
    -   And the `acceptTransferRole` function is not properly implemented
        -   The access control checks are missing or incorrect
        -   The function logic has vulnerabilities (e.g., reentrancy)
    
    -   **Mitigated** by proper access control checks and secure function implementation.

----------------------------------------------


## AgoraPrivilagedAccessControl

1.  **Unauthorized Minting**
    
    -   **Threat:** An attacker could attempt to perform unauthorized minting of tokens.
    -   **Mitigation:** Implement proper access control checks in the mint function to ensure only authorized minter roles can mint tokens.
      
2.  **Exceeding Minting Throttle**
    
    -   **Threat:** An attacker could attempt to exceed the maximum allowed mint amount within a specified minting window.
    -   **Mitigation:** Enforce proper throttling mechanisms in the mint function to limit the amount of tokens that can be minted within a certain time frame.
      
3.  **Unauthorized Burning**
    
    -   **Threat:** An attacker could try to burn tokens from arbitrary accounts without proper authorization.
    -   **Mitigation:** Implement access control checks in the burnFrom function to restrict burning privileges to authorized roles only.
      
4.  **Unauthorized Freezing**
    
    -   **Threat:** An attacker may attempt to freeze arbitrary accounts without proper authorization.
    -   **Mitigation:** Enforce access control mechanisms in the freezeAccount function to ensure that only authorized roles can freeze accounts.

----------------------------------------------


## Erc20Privilaged

**Attacker's goal** - Gain unauthorized access to privileged roles (MINTER_ROLE, BURNER_ROLE, FREEZER_ROLE) and perform unauthorized actions such as minting, burning, or freezing/unfreezing accounts.

-   Method 1: Exploit vulnerabilities in the `batchMint` or `mint` functions
    -   Requires the attacker to bypass the `_requireSenderIsRole` check for `MINTER_ROLE`
        -   The attacker gains access to an account with the `MINTER_ROLE`
        -   Or the `_requireSenderIsRole` function has vulnerabilities
            -   The access control checks are missing or incorrect
            -   The function logic has vulnerabilities (e.g., reentrancy)
    -   And the `isMintPaused` flag is not set or can be bypassed
    -   **Mitigated** by proper access control checks, secure implementation of `_requireSenderIsRole`, and ensuring the integrity of the `isMintPaused` flag.
-   Method 2: Exploit vulnerabilities in the `batchBurnFrom` or `burnFrom` functions
    -   Requires the attacker to bypass the `_requireSenderIsRole` check for `BURNER_ROLE`
        -   The attacker gains access to an account with the `BURNER_ROLE`
        -   Or the `_requireSenderIsRole` function has vulnerabilities
            -   The access control checks are missing or incorrect
            -   The function logic has vulnerabilities (e.g., reentrancy)
    -   And the account being burned from is frozen or the `isFrozen` check can be bypassed
    -   **Mitigated** by proper access control checks, secure implementation of `_requireSenderIsRole`, and ensuring the integrity of the `isFrozen` flag.
-   Method 3: Exploit vulnerabilities in the `freeze` or `unfreeze` functions
    -   Requires the attacker to bypass the `_requireSenderIsRole` check for `FREEZER_ROLE`
        -   The attacker gains access to an account with the `FREEZER_ROLE`
        -   Or the `_requireSenderIsRole` function has vulnerabilities
            -   The access control checks are missing or incorrect
            -   The function logic has vulnerabilities (e.g., reentrancy)
    -   And the `isFreezingPaused` flag is not set or can be bypassed
    -   **Mitigated** by proper access control checks, secure implementation of `_requireSenderIsRole`, and ensuring the integrity of the `isFreezingPaused` flag.


----------------------------------------------

## Eip3009

**Attacker's goal** - Exploit vulnerabilities in the gas-abstracted transfer mechanisms to perform unauthorized transfers or drain funds from user accounts.

-   Method 1: Exploit vulnerabilities in the `_transferWithAuthorization` function
    -   Requires the attacker to bypass the authorization checks
        -   The attacker can generate valid signatures for unauthorized transfers
            -   The attacker has access to the private keys of the authorizer
            -   Or the signature verification process has vulnerabilities
                -   The `_requireIsValidSignatureNow` function is not properly implemented
                -   The `SignatureChecker` library has vulnerabilities
        -   Or the attacker can bypass the nonce check
            -   The `_requireUnusedAuthorization` function is not properly implemented
            -   The `isAuthorizationUsed` mapping has vulnerabilities or can be manipulated
    -   And the attacker can bypass the time-based validity checks
        -   The `_validAfter` and `_validBefore` checks are not properly implemented or can be bypassed
    -   **Mitigated** by secure implementation of signature verification, nonce checks, and time-based validity checks, as well as protecting the private keys of authorizers.
-   Method 2: Exploit vulnerabilities in the `_receiveWithAuthorization` function
    -   Requires the attacker to bypass the authorization checks (similar to Method 1)
    -   And the attacker can bypass the payee address check
        -   The `_to` address check against `msg.sender` is not properly implemented or can be bypassed
    -   **Mitigated** by secure implementation of the payee address check and the same mitigations as Method 1.
-   Method 3: Exploit vulnerabilities in the `_cancelAuthorization` function
    -   Requires the attacker to bypass the authorization checks
        -   The attacker can generate valid signatures for unauthorized cancellations
            -   The attacker has access to the private keys of the authorizer
            -   Or the signature verification process has vulnerabilities (similar to Method 1)
    -   And the attacker can manipulate the `isAuthorizationUsed` mapping
        -   The mapping has vulnerabilities or can be manipulated directly
    -   **Mitigated** by secure implementation of signature verification and protecting the integrity of the `isAuthorizationUsed` mapping.


----------------------------------------------


## Erc20Core

**Attacker's goal** - Exploit vulnerabilities in the core ERC20 functionality to perform unauthorized transfers, manipulate balances, or bypass access controls.

-   Method 1: Exploit vulnerabilities in the `_transfer` function
    -   Requires the attacker to bypass the contract-wide access control checks
        -   The `isTransferPaused` flag is not properly set or can be manipulated
            -   The `StorageLib` library has vulnerabilities that allow modifying the flag
            -   Or the `_isTransferPaused` variable is not properly initialized or protected
    -   And the attacker can bypass the account freezing checks
        -   The `isFrozen` flag for the `_from` or `_to` account is not properly set or can be manipulated
            -   The `StorageLib` library has vulnerabilities that allow modifying the flag
            -   Or the `isFrozen` flag is not properly initialized or protected
    -   And the attacker can manipulate the balance checks or updates
        -   The `_accountDataFrom.balance` check is not properly implemented or can be bypassed
        -   The balance updates for the `_from` and `_to` accounts are not properly implemented or can be manipulated
    -   **Mitigated** by secure implementation of contract-wide access controls, account freezing checks, balance checks, and balance updates, as well as protecting the integrity of the `StorageLib` library.
-   Method 2: Exploit vulnerabilities in the `_approve` function
    -   Requires the attacker to manipulate the allowance storage
        -   The `accountAllowances` mapping in the `StorageLib` library has vulnerabilities or can be manipulated directly
    -   **Mitigated** by ensuring the integrity and proper access control of the `accountAllowances` mapping in the `StorageLib` library.
-   Method 3: Exploit vulnerabilities in the `_spendAllowance` function
    -   Requires the attacker to manipulate the allowance storage (similar to Method 2)
    -   And the attacker can bypass the allowance checks
        -   The `_currentAllowance` check is not properly implemented or can be bypassed
    -   **Mitigated** by secure implementation of allowance checks and ensuring the integrity of the `accountAllowances` mapping.


----------------------------------------------

## ERC2612

**Attacker's goal** - Exploit vulnerabilities in the permit function to perform unauthorized token approvals or manipulate allowances.

-   Method 1: Bypass the signature verification due to missing return value check
    -   The `isValidSignatureNow` function is called, but its return value is not checked
        -   The attacker can provide invalid or malicious signatures that are not properly verified
            -   The signature verification can fail, but the contract continues execution without reverting
            -   The attacker can proceed with unauthorized token approvals or allowance manipulations
    -   **Mitigated** by adding a proper check for the return value of `isValidSignatureNow` and reverting the transaction if the signature verification fails.
-   Method 2: Exploit vulnerabilities in the deadline check
    -   The deadline check is not properly implemented or can be bypassed
        -   The attacker can provide a deadline that is far in the future or manipulate the block timestamp
            -   The deadline comparison is incorrect or can be manipulated
            -   The block timestamp can be manipulated by miners or through network attacks
    -   **Mitigated** by ensuring that the deadline check is properly implemented and using a reasonably short deadline to limit the validity period of the permit.
-   Method 3: Exploit vulnerabilities in the nonce management
    -   The nonce increment and storage are not properly implemented or can be manipulated
        -   The attacker can reuse or manipulate nonces to perform replay attacks or duplicate permits
            -   The nonce increment is not properly handled or can be bypassed
            -   The nonce storage in `StorageLib` has vulnerabilities or can be manipulated
    -   **Mitigated** by ensuring that the nonce increment is properly implemented and the nonce storage is secure and cannot be tampered with.
-   Method 4: Exploit vulnerabilities in the `_approve` function
    -   The `_approve` function has vulnerabilities that allow unauthorized approval or manipulation of allowances
        -   The attacker can manipulate the `_owner`, `_spender`, or `_value` parameters to perform unintended approvals
            -   The `_approve` function does not properly validate the input parameters
            -   The `_approve` function has logic errors or can be exploited through reentrancy or other attacks
    -   **Mitigated** by ensuring that the `_approve` function is properly implemented, validates input parameters, and follows best practices for secure token approvals.

 ----------------------------------------------

## AgoraDollarCore

 **Attacker's goal** - Exploit vulnerabilities in the contract to gain unauthorized access, manipulate contract state, or perform malicious actions.

-   Method 1: Exploit improper initialization or lack of access control during the `initialize` function
    -   Requires the attacker to be able to call the `initialize` function multiple times or as an unauthorized address
        -   The `initialize` function lacks proper checks to ensure it can only be called once
            -   The attacker can manipulate the contract's initial state or gain privileged roles
        -   Or the `initialize` function lacks proper access control mechanisms
            -   The attacker can call the function as an unauthorized address
    -   **Mitigated** by ensuring that the `initialize` function can only be called once and by authorized addresses, and implementing proper access control mechanisms.
-   Method 2: Exploit insufficient or improper access control checks for privileged functions
    -   Requires the attacker to be able to execute privileged functions without proper authorization
        -   The contract fails to properly check roles or permissions for functions like `setIsMsgSenderCheckEnabled`, `setIsMintPaused`, `setIsFreezingPaused`, etc.
            -   The attacker can gain unauthorized control over critical contract functionalities
    -   **Mitigated** by implementing robust access control mechanisms, such as role-based access control (RBAC), and thoroughly testing and auditing the access control logic.
-   Method 3: Exploit unhandled or untrusted external calls
    -   Requires the contract to make external calls to untrusted contracts or fail to properly handle the results of external calls
        -   The attacker can manipulate the external calls to perform reentrancy attacks or exploit vulnerabilities in the called contracts
            -   The contract's state can be unexpectedly modified or funds can be stolen
    -   **Mitigated** by avoiding external calls to untrusted contracts, properly handling the results of external calls, and implementing reentrancy guards or using reentrancy-safe patterns.
-   Method 4: Exploit arithmetic operations that may result in integer overflow or underflow
    -   Requires the contract to perform unchecked arithmetic operations
        -   The attacker can provide malicious input values that cause integer overflow or underflow
            -   The contract's behavior can be unexpectedly altered or funds can be lost
    -   **Mitigated** by using safe math libraries or built-in overflow/underflow protection mechanisms, and performing proper input validation and bounds checking.
-   Method 5: Exploit improper signature verification for functions like `permit`, `transferWithAuthorization`, `receiveWithAuthorization`, and `cancelAuthorization`
    -   Requires the signature verification logic to be flawed or bypassable
        -   The attacker can provide invalid or malicious signatures that are not properly verified
            -   The attacker can execute unauthorized actions or forge signatures
    -   **Mitigated** by implementing robust signature verification mechanisms, such as the EIP-712 standard, and thoroughly testing and auditing the signature verification logic.
-   Method 6: Exploit missing or improper event emission
    -   Requires the contract to fail to emit events for critical actions or state changes
        -   The attacker can perform malicious actions without leaving a traceable record
            -   The transparency and auditability of the contract's behavior can be hindered
    -   **Mitigated** by ensuring that appropriate events are emitted for all significant actions and state changes, and following best practices for event emission.

----------------------------------------------



## Invariants

  

**Erc20Privilaged contract:**

  

-  Only  accounts  with  the  MINTER_ROLE  can  mint  tokens.

-  Minting  should  be  pausable  and  only  possible  when  not  paused.

-  The  total  supply  should  always  equal  the  sum  of  all  account  balances.

-  Burning  tokens  should  only  be  allowed  by  accounts  with  the  BURNER_ROLE.

-  Burning  tokens  should  only  be  possible  from  frozen  accounts.

-  Freezing  and  unfreezing  accounts  should  only  be  allowed  by  accounts  with  the  FREEZER_ROLE.

-  Freezing  and  unfreezing  should  be  pausable  and  only  possible  when  not  paused.

-  The  zero  address (address(0)) should  not  be  a  valid  recipient  for  minting  or  burning.

-  Minting  and  burning  should  emit  the  appropriate  events  with  correct  data.

-  Account  balances  should  be  properly  updated  after  minting  and  burning.

  
  

**ERC2612 contract :**

  

-  The  permit  function  should  only  accept  valid  signatures  that  match  the  provided  parameters  (owner,  spender,  value,  nonce,  deadline).

-  The  permit  function  should  revert  if  the  provided  deadline  has  passed  (block.timestamp > deadline).

-  The  nonce  for  each  owner  should  increment  after  a  successful  permit  call  to  prevent  replay  attacks.

-  The  permit  function  should  update  the  token  allowances  correctly  after  a  successful  call.

- The  permit  function  should  accept  both  EIP-712  signatures (v, r, s) and  packed  signatures (bytes).

  

**Erc1967Proxy contract :**

  

-  The  constructor  should  set  up  the  proxy  admin  address  correctly  and  emit  the  AdminChanged  event.

-  The  constructor  should  call  the  _upgradeToAndCall  function  with  the  provided  implementation  address  and  calldata.

- The  fallback  function  should  delegate  calls  to  the  current  implementation  address.

- The  fallback  function  should  only  allow  the  proxy  admin  to  call  the  upgradeToAndCall  function.

- The  _upgradeToAndCall  function  should  update  the  implementation  address  and  emit  the  Upgraded  event.

- The  _upgradeToAndCall  function  should  delegate  the  call  to  the  new  implementation  with  the  provided  calldata.

- The  sloadImplementationSlotDataAsUint256  function  should  return  the  correct  value  of  the  implementation  slot  data.

- The  ERC20  functions (transfer, transferFrom) should  delegate  to  the  upgraded  implementation  if  the  corresponding  upgrade  flag  is  set.

-  The  ERC20  functions  should  revert  if  the  sender's account is frozen and the frozen check is enabled.

-  The  EIP-3009  functions (transferWithAuthorization, receiveWithAuthorization, cancelAuthorization) should  delegate  to  the  upgraded  implementation  if  the  corresponding  upgrade  flag  is  set.

-  The  EIP-3009  functions  should  revert  if  the  sender's account is frozen and the frozen check is enabled.

-  The  StorageLib  functions  should  correctly  derive  and  access  the  storage  slots  for  various  contracts  and  data  structures.

-  The  StorageLib  functions  should  correctly  interpret  the  bitmasks  and  flags  stored  in  the  implementation  slot  data.

  

**AgoraPrivilegedRole contract :**

  

-  The  constructor  should  set  the  owner  address  and  the  AgoraDollar  contract  address  correctly.

-  Only  the  owner  should  be  able  to  call  the  setMinterThrottleInfo  function  to  set  the  throttle  parameters  for  a  minter.

- The  setMinterThrottleInfo  function  should  emit  the  SetMinterThrottleInfo  event  with  the  correct  parameters.

- The  batchMint  function  should  only  be  callable  by  accounts  with  the  appropriate  role.

- The  batchMint  function  should  revert  if  the  total  mint  amount  exceeds  the  minter's  throttle  limit  within  the  specified  time  window.

-  The  batchMint  function  should  delegate  the  call  to  the  AgoraDollar  contract's  batchMint  function  with  the  provided  parameters.

- The  mint  function  should  only  be  callable  by  accounts  with  the  appropriate  role.

- The  mint  function  should  revert  if  the  mint  amount  exceeds  the  minter's  throttle  limit  within  the  specified  time  window.

-  The  mint  function  should  update  the  historical  mints  for  the  minter  and  delegate  the  call  to  the  AgoraDollar  contract's  mint  function.

- The  _getSumOfMints  function  should  correctly  calculate  the  sum  of  mints  for  a  minter  within  the  specified  time  window.

- The  batchBurnFrom  function  should  only  be  callable  by  accounts  with  the  appropriate  role  and  delegate  the  call  to  the  AgoraDollar  contract's  batchBurnFrom  function.

- The  burnFrom  function  should  only  be  callable  by  accounts  with  the  appropriate  role  and  delegate  the  call  to  the  AgoraDollar  contract's  burnFrom  function.

- The  freezeAccount  and  unfreezeAccount  functions  should  only  be  callable  by  accounts  with  the  appropriate  role  and  delegate  the  calls  to  the  AgoraDollar  contract's freeze and unfreeze functions, respectively.

-  The  setIsMintPaused, setIsFreezingPaused, and  setIsTransferPaused  functions  should  only  be  callable  by  accounts  with  the  appropriate  role  and  delegate  the  calls  to  the  AgoraDollar  contract's corresponding functions.

**Agora Dollar Core**

-   The constructor should set the immutable variables _name, _symbol, and decimals correctly based on the provided parameters.
-   The initialize function should only be callable once and should set the initialized flag in storage.
-   The initialize function should call the _initializeAgoraDollarAccessControl function with the provided initial admin address.
-   The approve function should update the allowance for the given owner and spender addresses.
-   The transfer and transferFrom functions should be implemented in the proxy contract and should not be directly accessible in AgoraDollarCore.
-   The EIP-3009 functions (transferWithAuthorization, receiveWithAuthorization, cancelAuthorization) should be implemented in the proxy contract and should not be directly accessible in AgoraDollarCore.
-   The setIsMsgSenderCheckEnabled function should only be callable by the account with the ADMIN_ROLE and should update the corresponding bit in the contract data.
-   The setIsMintPaused function should only be callable by the account with the PAUSER_ROLE and should update the corresponding bit in the contract data.
-   The setIsFreezingPaused function should only be callable by the account with the PAUSER_ROLE and should update the corresponding bit in the contract data.
-   The setIsTransferPaused function should only be callable by the account with the PAUSER_ROLE and should update the corresponding bit in the contract data.
-   The setIsTransferUpgraded function should only be callable by the account with the ADMIN_ROLE and should update the corresponding bit in the contract data.
-   The setIsTransferFromUpgraded function should only be callable by the account with the ADMIN_ROLE and should update the corresponding bit in the contract data.
-   The setIsTransferWithAuthorizationUpgraded function should only be callable by the account with the ADMIN_ROLE and should update the corresponding bit in the contract data.
-   The setIsReceiveWithAuthorizationUpgraded function should only be callable by the account with the ADMIN_ROLE and should update the corresponding bit in the contract data.
-   The setIsCancelAuthorizationUpgraded function should only be callable by the account with the ADMIN_ROLE and should update the corresponding bit in the contract data.

# Diagrams

![Diagrams](images/ContractsOverview.png) 


## Roles Overview

![Roles Overview](images/RolesOverview.png)


## Class Diagram

![image](images/ClassDiagram.png)
