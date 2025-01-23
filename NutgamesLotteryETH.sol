// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: @openzeppelin/contracts/utils/Address.sol

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol

pragma solidity ^0.8.0;

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}







// File: @chainlink/contracts@2.12.0/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol

pragma solidity ^0.8.4;

// End consumer library.
library VRFV2PlusClient {
  // extraArgs will evolve to support new features
  bytes4 public constant EXTRA_ARGS_V1_TAG = bytes4(keccak256("VRF ExtraArgsV1"));
  struct ExtraArgsV1 {
    bool nativePayment;
  }

  struct RandomWordsRequest {
    bytes32 keyHash;
    uint256 subId;
    uint16 requestConfirmations;
    uint32 callbackGasLimit;
    uint32 numWords;
    bytes extraArgs;
  }

  function _argsToBytes(ExtraArgsV1 memory extraArgs) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(EXTRA_ARGS_V1_TAG, extraArgs);
  }
}

// File: @chainlink/contracts@2.12.0/src/v0.8/vrf/dev/interfaces/IVRFV2PlusWrapper.sol

pragma solidity ^0.8.0;

interface IVRFV2PlusWrapper {
  /**
   * @return the request ID of the most recent VRF V2 request made by this wrapper. This should only
   * be relied option within the same transaction that the request was made.
   */
  function lastRequestId() external view returns (uint256);

  /**
   * @notice Calculates the price of a VRF request with the given callbackGasLimit at the current
   * @notice block.
   *
   * @dev This function relies on the transaction gas price which is not automatically set during
   * @dev simulation. To estimate the price at a specific gas price, use the estimatePrice function.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   * @param _numWords is the number of words to request.
   */
  function calculateRequestPrice(uint32 _callbackGasLimit, uint32 _numWords) external view returns (uint256);

  /**
   * @notice Calculates the price of a VRF request in native with the given callbackGasLimit at the current
   * @notice block.
   *
   * @dev This function relies on the transaction gas price which is not automatically set during
   * @dev simulation. To estimate the price at a specific gas price, use the estimatePrice function.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   * @param _numWords is the number of words to request.
   */
  function calculateRequestPriceNative(uint32 _callbackGasLimit, uint32 _numWords) external view returns (uint256);

  /**
   * @notice Estimates the price of a VRF request with a specific gas limit and gas price.
   *
   * @dev This is a convenience function that can be called in simulation to better understand
   * @dev pricing.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   * @param _numWords is the number of words to request.
   * @param _requestGasPriceWei is the gas price in wei used for the estimation.
   */
  function estimateRequestPrice(
    uint32 _callbackGasLimit,
    uint32 _numWords,
    uint256 _requestGasPriceWei
  ) external view returns (uint256);

  /**
   * @notice Estimates the price of a VRF request in native with a specific gas limit and gas price.
   *
   * @dev This is a convenience function that can be called in simulation to better understand
   * @dev pricing.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   * @param _numWords is the number of words to request.
   * @param _requestGasPriceWei is the gas price in wei used for the estimation.
   */
  function estimateRequestPriceNative(
    uint32 _callbackGasLimit,
    uint32 _numWords,
    uint256 _requestGasPriceWei
  ) external view returns (uint256);

  /**
   * @notice Requests randomness from the VRF V2 wrapper, paying in native token.
   *
   * @param _callbackGasLimit is the gas limit for the request.
   * @param _requestConfirmations number of request confirmations to wait before serving a request.
   * @param _numWords is the number of words to request.
   */
  function requestRandomWordsInNative(
    uint32 _callbackGasLimit,
    uint16 _requestConfirmations,
    uint32 _numWords,
    bytes calldata extraArgs
  ) external payable returns (uint256 requestId);

  function link() external view returns (address);
  function linkNativeFeed() external view returns (address);
}

// File: @chainlink/contracts@2.12.0/src/v0.8/shared/interfaces/LinkTokenInterface.sol

pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);
}

// File: @chainlink/contracts@2.12.0/src/v0.8/vrf/dev/VRFV2PlusWrapperConsumerBase.sol

pragma solidity ^0.8.0;

/**
 *
 * @notice Interface for contracts using VRF randomness through the VRF V2 wrapper
 * ********************************************************************************
 * @dev PURPOSE
 *
 * @dev Create VRF V2+ requests without the need for subscription management. Rather than creating
 * @dev and funding a VRF V2+ subscription, a user can use this wrapper to create one off requests,
 * @dev paying up front rather than at fulfillment.
 *
 * @dev Since the price is determined using the gas price of the request transaction rather than
 * @dev the fulfillment transaction, the wrapper charges an additional premium on callback gas
 * @dev usage, in addition to some extra overhead costs associated with the VRFV2Wrapper contract.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFV2PlusWrapperConsumerBase. The consumer must be funded
 * @dev with enough LINK or ether to make the request, otherwise requests will revert. To request randomness,
 * @dev call the 'requestRandomWords' function with the desired VRF parameters. This function handles
 * @dev paying for the request based on the current pricing.
 *
 * @dev Consumers must implement the fullfillRandomWords function, which will be called during
 * @dev fulfillment with the randomness result.
 */
abstract contract VRFV2PlusWrapperConsumerBase {
  error OnlyVRFWrapperCanFulfill(address have, address want);

  LinkTokenInterface internal immutable i_linkToken;
  IVRFV2PlusWrapper public immutable i_vrfV2PlusWrapper;

  /**
   * @param _vrfV2PlusWrapper is the address of the VRFV2Wrapper contract
   */
  constructor(address _vrfV2PlusWrapper) {
    IVRFV2PlusWrapper vrfV2PlusWrapper = IVRFV2PlusWrapper(_vrfV2PlusWrapper);

    i_linkToken = LinkTokenInterface(vrfV2PlusWrapper.link());
    i_vrfV2PlusWrapper = vrfV2PlusWrapper;
  }

  /**
   * @dev Requests randomness from the VRF V2+ wrapper.
   *
   * @param _callbackGasLimit is the gas limit that should be used when calling the consumer's
   *        fulfillRandomWords function.
   * @param _requestConfirmations is the number of confirmations to wait before fulfilling the
   *        request. A higher number of confirmations increases security by reducing the likelihood
   *        that a chain re-org changes a published randomness outcome.
   * @param _numWords is the number of random words to request.
   *
   * @return requestId is the VRF V2+ request ID of the newly created randomness request.
   */
  // solhint-disable-next-line chainlink-solidity/prefix-internal-functions-with-underscore
  function requestRandomness(
    uint32 _callbackGasLimit,
    uint16 _requestConfirmations,
    uint32 _numWords,
    bytes memory extraArgs
  ) internal returns (uint256 requestId, uint256 reqPrice) {
    reqPrice = i_vrfV2PlusWrapper.calculateRequestPrice(_callbackGasLimit, _numWords);
    i_linkToken.transferAndCall(
      address(i_vrfV2PlusWrapper),
      reqPrice,
      abi.encode(_callbackGasLimit, _requestConfirmations, _numWords, extraArgs)
    );
    return (i_vrfV2PlusWrapper.lastRequestId(), reqPrice);
  }

  // solhint-disable-next-line chainlink-solidity/prefix-internal-functions-with-underscore
  function requestRandomnessPayInNative(
    uint32 _callbackGasLimit,
    uint16 _requestConfirmations,
    uint32 _numWords,
    bytes memory extraArgs
  ) internal returns (uint256 requestId, uint256 requestPrice) {
    requestPrice = i_vrfV2PlusWrapper.calculateRequestPriceNative(_callbackGasLimit, _numWords);
    return (
      i_vrfV2PlusWrapper.requestRandomWordsInNative{value: requestPrice}(
        _callbackGasLimit,
        _requestConfirmations,
        _numWords,
        extraArgs
      ),
      requestPrice
    );
  }

  /**
   * @notice fulfillRandomWords handles the VRF V2 wrapper response. The consuming contract must
   * @notice implement it.
   *
   * @param _requestId is the VRF V2 request ID.
   * @param _randomWords is the randomness result.
   */
  // solhint-disable-next-line chainlink-solidity/prefix-internal-functions-with-underscore
  function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) external {
    address vrfWrapperAddr = address(i_vrfV2PlusWrapper);
    if (msg.sender != vrfWrapperAddr) {
      revert OnlyVRFWrapperCanFulfill(msg.sender, vrfWrapperAddr);
    }
    fulfillRandomWords(_requestId, _randomWords);
  }

  /// @notice getBalance returns the native balance of the consumer contract
  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }

  /// @notice getLinkToken returns the link token contract
  function getLinkToken() public view returns (LinkTokenInterface) {
    return i_linkToken;
  }
}


// File: contracts/NutgamesLottery.sol

pragma solidity ^0.8.4;
pragma abicoder v2;

/** @title Nutgames Lottery.
 * @notice It is a contract for a lottery system using
 * randomness provided externally by ChainLink VRF (Verifiable Random Function).
 * @dev ReentrancyGuard used due to external calls to some contracts handled by third parties (like ChainLink) or upgradable bridged tokens
 */
contract NutgamesLottery is ReentrancyGuard, VRFV2PlusWrapperConsumerBase {

    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    struct RequestStatus {
        uint256 paid; // amount paid in native token (ether)
        bool fulfilled; // whether the request has been successfully fulfilled
        uint32 randomResult;
        uint8 bracketCalculatorActiveLength; // from 1 to 8
    }
    mapping(uint256 => RequestStatus) public requests; /* requestId --> requestStatus */
    mapping(address => mapping(uint256 => uint256)) public lotteryIdToRequestId; /* lotteryBuilder --> lotteryId --> requestId */

    uint32 public constant MIN_VRF_CALLBACK_GAS_LIMIT = 100000;
    uint32 public constant MAX_VRF_CALLBACK_GAS_LIMIT = 2500000;
    uint16 public constant MIN_VRF_REQUEST_CONFIRMATIONS = 1;
    uint16 public constant MAX_VRF_REQUEST_CONFIRMATIONS = 200;
    uint32 public constant VRF_NUM_WORDS = 1; // random value number to retrieve from ChainLink VRF
    address public constant VRF_V2_PLUS_WRAPPER = 0x02aae1A04f9828517b3007f83f6181900CaD910c; // Direct Funding VRF Wrapper (https://docs.chain.link/vrf/v2-5/supported-networks#arbitrum-mainnet)
 


    uint256 public constant MAX_TICKETS_TO_BUY_OR_CLAIM = 100; // must be < MIN_DISCOUNT_DIVISOR (to avoid zero & negative tickets prices if bulk tickets bought) and not too high to avoid block gas limit errors
    uint256 public constant MIN_DISCOUNT_DIVISOR = 300; // e.g. 33% discount if 100 tickets bought & discountDivisor set to min value: 300 (which means the max discount)
    uint256 public constant MIN_LENGTH_LOTTERY = 180 seconds;
    uint256 public constant MAX_LENGTH_LOTTERY = 4 weeks;
    uint256 public constant SAFETY_DELAY = 60 seconds; // to avoid edge cases where exploiter buy a winning ticket & close a lottery (getting the winning number) in the same block 
    uint256 public constant MAX_TREASURY_FEE = 3000; // 30%
    uint8 public constant MIN_BRACKET_CALCULATOR_ACTIVE_LENGTH = 1;
    uint8 public constant MAX_BRACKET_CALCULATOR_ACTIVE_LENGTH = 8;
    address public constant TREASURY_PROTOCOL_ADDRESS = 0x10E73efD455Be0C47A99625cDe2639C5Bb19E204;
    uint256 public constant OPERATOR_PROTOCOL_FEE = 0.0001 ether;

    enum Symbol {
        USDT,
        WBTC,
        WETH,
        ARB,
        NCASH,
        NUT,
        WEN,
        NUTS404
    }

    enum Status {
        Open,
        Close,
        Cancel,
        Claimable
    }

    struct Config {
        Symbol symbol;
        uint256 duration;
        uint256 priceTicket;
        uint256 discountDivisor;
        uint256[8] rewardsBreakdown; // 0: 1 matching number // 7: 8 matching numbers
        uint256 treasuryFee; // 500: 5% // 200: 2% // 50: 0.5%
        address treasuryBuilderAddress;
        bool isNextLotteryInjected; // true if reinjecting remaning fund not won into next lottery (vs. redistributing it to current lottery winners proportionally on active rewards breakdown)
        uint8 bracketCalculatorActiveLength;
        uint32 vrfCallbackGasLimit;
        uint16 vrfResquestConfirmations;
    }

    struct Lottery {
        Status status;
        uint256 startTime;
        uint256[8] tokenPerBracket; // token prize to send for one winning ticket for a given bracket
        uint256[8] countWinnersPerBracket;
        uint256 firstTicketId;
        uint256 firstTicketIdNextLottery;
        uint256 tokenCollected;
        uint32 finalNumber;
    }

    struct Ticket {
        uint32 number;
        address owner;
    }

    struct History {
        uint256 builderCounter;
        mapping(uint256 => address) lotteryBuilders; /* builderCounter (from 1) --> lotteryBuilder */
        mapping(address => uint256) lotteryIdCounters; /* lotteryBuilder --> lotteryIdCounter (from 1) */
        mapping(address => mapping(uint256 => uint256)) lotteryIds; /* lotteryBuilder --> lotteryIdCounter --> lotteryId */
    }

    uint256 public builderCounter;
    mapping(Symbol => address) public token;
    mapping(uint256 => address) public lotteryBuilders; /* builderCounter (from 1) --> lotteryBuilder */
    mapping(address => uint256) public currentLotteryId; // per lotteryBuilder (from 1)
    mapping(address => uint256) public currentTicketId; // per lotteryBuilder (from 0)
    mapping(address => uint256) public pendingInjectionNextLottery; // per lotteryBuilder
    mapping(address => Config) public configs; // per lotteryBuilder
    mapping(address => mapping(uint256 => Lottery)) public lotteries; /* lotteryBuilder --> lotteryId --> lottery */
    mapping(address => mapping(uint256 => Ticket)) public tickets; /* lotteryBuilder --> ticketId --> ticket */

    // Keeps track of ticket count per unique transformed number combination for each lotteryId per builder
    mapping(address => mapping(uint256 => mapping(uint32 => uint256))) public ticketsCountPerLotteryId; /* lotteryBuilder --> lotteryId --> ticketTransformedNb --> ticketCountBought */ 

    // Keep track of user ticket ids for a given lotteryId per builder
    mapping(address => mapping(address => mapping(uint256 => uint256[]))) public userTicketIdsPerLotteryId; /* lotteryBuilder --> user --> lotteryId --> ticketIds */

    // Keep track of users lottery builders and lottery ids history
    mapping (address => History) public usersHistory;

    // Bracket calculator is used for verifying claims for ticket prizes among all possible built lotteries
    // Allows to differentiate the number combinations with: ticketNumber % 10**(bracket+1) by adding series of 1 depending on bracket
    // (e.g. 1,234,501 % 100 = 1 & 1,234,561 % 10 = 1, these 2 tickets with 2 different combinations & bracket can't be saved correctly in _ticketsCountPerLotteryId without _bracketCalculator transformation)
    mapping(uint32 => uint32) private _bracketCalculator;
    
    

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    /* ========== ERRORS ========== */

    error NonExistentLotteryBuilder(address have);
    error InvalidLotteryStatus(Status have, Status want);
    error InvalidLotteryTimeState();
    error InvalidTicketIdsBracketsLength();
    error TicketNumberOutsideRange();
    error NoTicketSpecified();
    error TooManyTickets();
    error RandomNumberNotDrawn();

    /* ========== EVENTS ========== */
    
    event RequestSent(uint256 indexed requestId);
    event RequestFulfilled(uint256 indexed requestId, uint256 randomResult, uint256 payment);

    event LotteryOpen(
        address indexed lotteryBuilder,
        uint256 indexed lotteryId,
        uint256 startTime,
        uint256 firstTicketId,
        uint256 injectedAmount
    );
    event LotteryInjection(address indexed lotteryBuilder, uint256 indexed lotteryId, uint256 injectedAmount);
    event LotteryClose(address indexed lotteryBuilder, uint256 indexed lotteryId, uint256 firstTicketIdNextLottery);
    event LotteryCancel(address indexed lotteryBuilder, uint256 indexed lotteryId, uint256 firstTicketId);
    event LotteryNumberDrawn(address indexed lotteryBuilder, uint256 indexed lotteryId, uint256 finalNumber, uint256 totalPrizeDistributed);
    event TicketsPurchase(address indexed buyer, address indexed lotteryBuilder, uint256 indexed lotteryId, uint256 numberTickets);
    event TicketsClaim(address indexed claimer, uint256 amount, address indexed lotteryBuilder, uint256 indexed lotteryId, uint256 numberTickets);

    /* ========== CONSTRUCTOR ========== */
  
    constructor() VRFV2PlusWrapperConsumerBase(VRF_V2_PLUS_WRAPPER) {

        token[Symbol.USDT] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        token[Symbol.WBTC] = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
        token[Symbol.WETH] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        token[Symbol.ARB] = 0xB50721BCf8d664c30412Cfbc6cf7a15145234ad1;
        token[Symbol.NCASH] = 0xd105c45BCC7211F847Ae73B187A41b7D8184aDE2;
        token[Symbol.NUT] = 0x473F4068073Cd5b2aB0E4Cc8E146F9EDC6fb52CC;
        token[Symbol.WEN] = 0xEBA6145367b33e9FB683358E0421E8b7337D435f;
        token[Symbol.NUTS404] = 0x25559f0aBBaf2A928239D2F419181147Cc2dAd74;

        _bracketCalculator[0] = 1;
        _bracketCalculator[1] = 11;
        _bracketCalculator[2] = 111;
        _bracketCalculator[3] = 1111;
        _bracketCalculator[4] = 11111;
        _bracketCalculator[5] = 111111;
        _bracketCalculator[6] = 1111111;
        _bracketCalculator[7] = 11111111;
    }

    function _requestRandomWord(address _lotteryBuilder, uint256 _lotteryId) private returns (uint256) {
        bytes memory extraArgs = VRFV2PlusClient._argsToBytes(
            VRFV2PlusClient.ExtraArgsV1({nativePayment: true})
        );
        Config memory config = configs[_lotteryBuilder];

        uint256 requestId;
        uint256 reqPrice;

        (requestId, reqPrice) = requestRandomnessPayInNative(
            config.vrfCallbackGasLimit,
            config.vrfResquestConfirmations,
            VRF_NUM_WORDS,
            extraArgs
        );

        requests[requestId] = RequestStatus({
            paid: reqPrice,
            randomResult: 0,
            fulfilled: false,
            bracketCalculatorActiveLength: config.bracketCalculatorActiveLength
        });
        lotteryIdToRequestId[_lotteryBuilder][_lotteryId] = requestId;
        emit RequestSent(requestId);
        return requestId; // unique request hash id
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        RequestStatus storage request = requests[_requestId];
        require(request.paid > 0, "request not found");

        request.fulfilled = true;
        uint32 lowerBound = uint32(10)**request.bracketCalculatorActiveLength;
         // randomResult from lowerBound to 2*lowerBound - 1
        request.randomResult = uint32(lowerBound  + (_randomWords[0] % lowerBound));
        emit RequestFulfilled(_requestId, request.randomResult, request.paid);
    }




    /**
     * @notice Buy tickets for the current lottery
     * @param _lotteryBuilder: lottery builder address
     * @param _lotteryId: lottery id
     * @param _ticketNumbers: array of ticket numbers between 10**bracketLength to 2 * 10**bracketLength - 1
     * @dev Callable by users
     */
    function buyTickets(address _lotteryBuilder, uint256 _lotteryId, uint32[] calldata _ticketNumbers)
        external
        notContract
        nonReentrant
    {
        Config memory config = configs[_lotteryBuilder];
        Lottery storage lottery = lotteries[_lotteryBuilder][_lotteryId];

        if(isNonExistentBuilder(_lotteryBuilder)) revert NonExistentLotteryBuilder(_lotteryBuilder);
        if(lottery.status != Status.Open) revert InvalidLotteryStatus(lottery.status, Status.Open);
        if(block.timestamp >= (lottery.startTime + config.duration - SAFETY_DELAY)) revert InvalidLotteryTimeState(); // lottery is over
        if(_ticketNumbers.length == 0) revert NoTicketSpecified();
        if(_ticketNumbers.length > MAX_TICKETS_TO_BUY_OR_CLAIM) revert TooManyTickets();


        // Calculate number of TOKEN to send to this contract
        uint256 amountToTransfer = _calculateTotalPriceForBulkTickets(config.discountDivisor, config.priceTicket, _ticketNumbers.length);

        // Transfer amount of chosen TOKEN to this contract
        IERC20(token[config.symbol]).safeTransferFrom(address(msg.sender), address(this), amountToTransfer);

        // Increment the total amount collected for the lottery round
        lottery.tokenCollected += amountToTransfer;

        uint32 lowerBound = uint32(10)**config.bracketCalculatorActiveLength;
        uint32 upperBound = 2 * lowerBound - 1;
        mapping(uint32 => uint256) storage ticketCountPerTransformedNb = ticketsCountPerLotteryId[_lotteryBuilder][_lotteryId];
        uint256[] storage ticketIds = userTicketIdsPerLotteryId[_lotteryBuilder][msg.sender][_lotteryId];
        mapping(uint256 => Ticket) storage ticketsBuilder = tickets[_lotteryBuilder];

        uint256 ticketIdsLengthInit = ticketIds.length; 

        for (uint256 i = 0; i < _ticketNumbers.length; i++) {
            uint32 thisTicketNumber = _ticketNumbers[i];
            if(thisTicketNumber < lowerBound || thisTicketNumber > upperBound) revert TicketNumberOutsideRange();

            for (uint32 j = 0; j < config.bracketCalculatorActiveLength; j++) {
                ticketCountPerTransformedNb[_bracketCalculator[j] + (thisTicketNumber % (uint32(10)**(j + 1)))]++;
            }
        
            ticketIds.push(currentTicketId[_lotteryBuilder]); // first ticketId for a given builder will be 0
            ticketsBuilder[currentTicketId[_lotteryBuilder]] = Ticket({number: thisTicketNumber, owner: msg.sender});
            currentTicketId[_lotteryBuilder]++;
        }

        // Update user lottery builders and lottery ids history
        History storage userHistory = usersHistory[msg.sender];
        if(userHistory.lotteryIdCounters[_lotteryBuilder] == 0) { // builder does not exist for user history (so lottery ids neither)

            userHistory.builderCounter++;
            userHistory.lotteryBuilders[userHistory.builderCounter] = _lotteryBuilder;
        }

        if (ticketIdsLengthInit == 0) { // lottery id does not exists for user history

            userHistory.lotteryIdCounters[_lotteryBuilder]++;
            uint256 lotteryIdCounter = userHistory.lotteryIdCounters[_lotteryBuilder];
            userHistory.lotteryIds[_lotteryBuilder][lotteryIdCounter] = _lotteryId;
        }
        
        emit TicketsPurchase(msg.sender, _lotteryBuilder, _lotteryId, _ticketNumbers.length);
    }

    /**
     * @notice Claim a set of winning tickets for a lottery (all without exception must be winning tickets, otherwise revert)
     * @param _lotteryBuilder: lottery builder address
     * @param _lotteryId: lottery id
     * @param _ticketIds: array of ticket ids
     * @param _brackets: array of brackets for the ticket ids
     * @dev Callable by users only, not contract!
     */
    function claimTickets(
        address _lotteryBuilder,
        uint256 _lotteryId,
        uint256[] calldata _ticketIds,
        uint32[] calldata _brackets
    ) external notContract nonReentrant {

        Config memory config = configs[_lotteryBuilder];
        Lottery storage lottery = lotteries[_lotteryBuilder][_lotteryId];

        if(isNonExistentBuilder(_lotteryBuilder)) revert NonExistentLotteryBuilder(_lotteryBuilder);
        if(lottery.status != Status.Claimable) revert InvalidLotteryStatus(lottery.status, Status.Claimable);
        if(_ticketIds.length != _brackets.length) revert InvalidTicketIdsBracketsLength();
        if(_ticketIds.length == 0) revert NoTicketSpecified();
        if(_ticketIds.length > MAX_TICKETS_TO_BUY_OR_CLAIM) revert TooManyTickets();

        // Initializes the rewardInTokenToTransfer
        uint256 rewardInTokenToTransfer;
        mapping(uint256 => Ticket) storage ticketsBuilder = tickets[_lotteryBuilder];

        for (uint256 i = 0; i < _ticketIds.length; i++) {

            uint256 thisTicketId = _ticketIds[i];
            Ticket storage ticket = ticketsBuilder[thisTicketId];

            require(_brackets[i] < config.bracketCalculatorActiveLength, "Bracket out of range"); // Must be between 0  & bracketCalculatorActiveLength (which is 1 to 8) -1
            require(thisTicketId < lottery.firstTicketIdNextLottery && thisTicketId >= lottery.firstTicketId, "TicketId too high or too low");
            require(msg.sender == ticket.owner, "Not the owner");

            // Update the lottery ticket owner to 0x address (to avoid multiple claim for same winning ticket)
            ticket.owner = address(0);

            uint256 rewardForTicketId = _calculateRewardsForTicketId(_lotteryBuilder, _lotteryId, thisTicketId, _brackets[i]);
            
            // Check user is claiming the correct bracket
            require(rewardForTicketId != 0, "No prize for this bracket");
            
            if (_brackets[i] < config.bracketCalculatorActiveLength - 1) {
                require(
                    _calculateRewardsForTicketId(_lotteryBuilder, _lotteryId, thisTicketId, _brackets[i] + 1) == 0,
                    "Bracket must be higher"
                ); // if revert, it means that the ticket can potentially claim higher prize (due to higher bracket) and so the inputs were wrong (not correct suitable brackets associated to the tickets)
            }

            // Increment the reward to transfer
            rewardInTokenToTransfer += rewardForTicketId;
        }

        // Transfer money to msg.sender
        IERC20(token[config.symbol]).safeTransfer(msg.sender, rewardInTokenToTransfer);

        emit TicketsClaim(msg.sender, rewardInTokenToTransfer, _lotteryBuilder, _lotteryId, _ticketIds.length);
    }

    /**
     * @notice Close or cancel lottery
     * @param _lotteryBuilder: lottery builder address
     * @param _lotteryId: lottery id
     * @dev Callable by users
     */
    function closeOrCancelLottery(address _lotteryBuilder, uint256 _lotteryId) external payable nonReentrant {
        
        Config memory config = configs[_lotteryBuilder];
        Lottery storage lottery = lotteries[_lotteryBuilder][_lotteryId];

        if(isNonExistentBuilder(_lotteryBuilder)) revert NonExistentLotteryBuilder(_lotteryBuilder);
        if(lottery.status != Status.Open) revert InvalidLotteryStatus(lottery.status, Status.Open);
        if(block.timestamp < (lottery.startTime + config.duration + SAFETY_DELAY)) revert InvalidLotteryTimeState(); // lottery is not over

        if (currentTicketId[_lotteryBuilder] == lottery.firstTicketId) {
            _sendOperatorProtocolFee(true);

            // No ticket has been bought during the delay so cancel the lottery and save gas fees by not requesting useless random word
            lottery.status = Status.Cancel;
            // Save tokenCollected which might not be zero if injection done in injectFunds or startLottery (with previous collected) and do not apply fee 
            pendingInjectionNextLottery[_lotteryBuilder] = lottery.tokenCollected; 
            emit LotteryCancel(_lotteryBuilder, _lotteryId, currentTicketId[_lotteryBuilder]);
        } else {
            _sendOperatorProtocolFee(false); // excess not handled here so that it will be used to pay Chainlink VRF randomness

            // Request a random number from Chainlink VRF contracts and close lottery
            lottery.firstTicketIdNextLottery = currentTicketId[_lotteryBuilder];
            _requestRandomWord(_lotteryBuilder, _lotteryId);
            lottery.status = Status.Close;
            emit LotteryClose(_lotteryBuilder, _lotteryId, currentTicketId[_lotteryBuilder]);
        }
    }

    /**
     * @notice Draw the final number, calculate reward in TOKEN per group, and make lottery claimable
     * @param _lotteryBuilder: lottery builder address
     * @param _lotteryId: lottery id
     * @dev Callable by users
     */
    function drawFinalNumberAndMakeLotteryClaimable(address _lotteryBuilder, uint256 _lotteryId) external payable nonReentrant {

        Config memory config = configs[_lotteryBuilder];
        Lottery storage lottery = lotteries[_lotteryBuilder][_lotteryId];
        
        if(isNonExistentBuilder(_lotteryBuilder)) revert NonExistentLotteryBuilder(_lotteryBuilder);
        if(lottery.status != Status.Close) revert InvalidLotteryStatus(lottery.status, Status.Close);
        if(!requests[lotteryIdToRequestId[_lotteryBuilder][_lotteryId]].fulfilled) revert RandomNumberNotDrawn();

        _sendOperatorProtocolFee(true);

        // Set finalNumber from ChainLink's randomResult
        uint32 finalNumber = requests[lotteryIdToRequestId[_lotteryBuilder][_lotteryId]].randomResult;

        // Initialize a variable to count transformedWinningNumber in the previous higher bracket (so that winning tickets of higher brackets won't be counted in lower brackets)
        uint256 countInPreviousBracket;

        // Initialize variables to track total distribution and active brackets
    	uint256 totalPrizeDistributed;
	    uint256 totalActiveRewardsBreakdown;

        // Calculate the total prize pool available after treasury fee
        uint256 totalPrizePool = (lottery.tokenCollected * (10000 - config.treasuryFee)) / 10000;
        
        // Calculate prizes in TOKEN for each bracket by starting from the highest one
        for (uint32 i = 0; i < config.bracketCalculatorActiveLength; i++) {
            uint32 j = config.bracketCalculatorActiveLength - 1 - i;
            uint32 transformedWinningNumber = _bracketCalculator[j] + (finalNumber % (uint32(10)**(j + 1)));

            uint256 winningTicketCount = ticketsCountPerLotteryId[_lotteryBuilder][_lotteryId][transformedWinningNumber];
            lottery.countWinnersPerBracket[j] = winningTicketCount - countInPreviousBracket;

            // A. If number of winners for this _bracket number is superior to 0 AND if rewards at this bracket are > 0
            if (lottery.countWinnersPerBracket[j] > 0 && config.rewardsBreakdown[j] > 0) {
                // Calculate token prize to distribute
                uint256 prizeForBracket = (config.rewardsBreakdown[j] * totalPrizePool) / 10000;
                lottery.tokenPerBracket[j] = prizeForBracket / lottery.countWinnersPerBracket[j];
                totalPrizeDistributed += prizeForBracket;
                totalActiveRewardsBreakdown += config.rewardsBreakdown[j];

                // Update countInPreviousBracket
                countInPreviousBracket = winningTicketCount;
                
            // B. No TOKEN to distribute
            } else {
                lottery.tokenPerBracket[j] = 0;
            }
        }

        // Redistrubte remaining prize to existing winners or next lottery pool
        uint256 remainingPrizePool = totalPrizePool - totalPrizeDistributed;
	    if (remainingPrizePool > 0) {
            // A. No winners at all or pendingInjectionNextLottery = true so redistribute to next lottery
            if(config.isNextLotteryInjected || totalPrizeDistributed == 0) {
                pendingInjectionNextLottery[_lotteryBuilder] = remainingPrizePool;
                
            // B. Redistribute remaining fund from totalPrizePool proportionally to the winners based on active rewards breakdown
            } else {
                for (uint32 i = 0; i < config.bracketCalculatorActiveLength; i++) {
                    if (lottery.countWinnersPerBracket[i] > 0 && config.rewardsBreakdown[i] > 0) {
                        // Calculate additional distribution based on the active bracket's share of the total active rewards
                        uint256 additionalDistribution = (remainingPrizePool * config.rewardsBreakdown[i]) / totalActiveRewardsBreakdown;
                        lottery.tokenPerBracket[i] += additionalDistribution / lottery.countWinnersPerBracket[i];
                    }
                }
            }
	    }

        // Update internal statuses for lottery
        lottery.finalNumber = finalNumber;
        lottery.status = Status.Claimable;

        // Calculate the TOKEN amount to send to treasuries
        if (config.treasuryFee > 0) {
            uint256 amountToWithdrawToTreasuries = lottery.tokenCollected - totalPrizePool;
            uint256 amountToWithdrawToProtocolTreasury = amountToWithdrawToTreasuries / 3;
            uint256 amountToWithdrawToBuilderTreasury =  amountToWithdrawToTreasuries - amountToWithdrawToProtocolTreasury; // can be a little bit more than 2/3 of treasuries due to potential previous Solidity truncation but will never exceed the total treasuries 

            // Transfer TOKEN to treasuries
            if(amountToWithdrawToBuilderTreasury > 0) IERC20(token[config.symbol]).safeTransfer(config.treasuryBuilderAddress, amountToWithdrawToBuilderTreasury);
            if(amountToWithdrawToProtocolTreasury > 0) IERC20(token[config.symbol]).safeTransfer(TREASURY_PROTOCOL_ADDRESS, amountToWithdrawToProtocolTreasury);
        }

        emit LotteryNumberDrawn(_lotteryBuilder, _lotteryId, finalNumber, remainingPrizePool > 0 && !config.isNextLotteryInjected && totalPrizeDistributed != 0 ? totalPrizePool : totalPrizeDistributed);
    }

    /**
     * @notice Inject funds
     * @param _lotteryBuilder: lottery builder address
     * @param _lotteryId: lottery id
     * @param _amount: amount to inject in TOKEN
     * @dev Callable by users
     */
    function injectFunds(address _lotteryBuilder, uint256 _lotteryId, uint256 _amount) external payable nonReentrant {

        Lottery storage lottery = lotteries[_lotteryBuilder][_lotteryId];
       
        if(isNonExistentBuilder(_lotteryBuilder)) revert NonExistentLotteryBuilder(_lotteryBuilder);
        if(lottery.status != Status.Open) revert InvalidLotteryStatus(lottery.status, Status.Open);

        _sendOperatorProtocolFee(true);

        IERC20(token[configs[_lotteryBuilder].symbol]).safeTransferFrom(address(msg.sender), address(this), _amount);
        lottery.tokenCollected += _amount;

        emit LotteryInjection(_lotteryBuilder, _lotteryId, _amount);
    }

    /**
     * @notice Start the lottery
     * @dev Callable by users
     * @param _lotteryBuilder: existing lottery builder address or msg.sender to (re)start a lottery created by a given builder
     * @param _symbol: token symbol (USDT, WBTC, WETH, NCASH, NUT, WEN, NUTS404)
     * @param _duration: duration of the lottery (from 1h to 4 weeks)
     * @param _priceTicket: price of a ticket in the chosen token (> 0)
     * @param _discountDivisor: the divisor to calculate the discount magnitude for bulks (>= 300 or 0)
     * @param _rewardsBreakdown: breakdown of rewards per bracket (must sum to 10,000)
     * @param _treasuryFee: treasury fee (<= 3000 = 30%)
     * @param _treasuryBuilderAddress: treasury address
     * @param _isNextLotteryInjected: true if reinjecting remaning fund not won into next lottery (vs. redistributing it to current lottery winners proportionally  on active rewards breakdown) 
     * @param _bracketCalculatorActiveLength: bracket calculator active length (from 1 to 8)
     * @param _vrfCallbackGasLimit: Chainlink VRF callback gas limit
     * @param _vrfResquestConfirmations: Chainlink VRF request confirmations number
     */
    function startLottery(
        address _lotteryBuilder,
        Symbol _symbol,
        uint256 _duration,
        uint256 _priceTicket,
        uint256 _discountDivisor,
        uint256[8] calldata _rewardsBreakdown,
        uint256 _treasuryFee,
        address _treasuryBuilderAddress,
        bool _isNextLotteryInjected,
        uint8 _bracketCalculatorActiveLength,
        uint32 _vrfCallbackGasLimit,
        uint16 _vrfResquestConfirmations
    ) external payable {

        // Check _lotteryBuilder arg which gives the ability to any user to restart an existing lottery as long as he provides an existing lottery builder address
        require(_lotteryBuilder == address(msg.sender) || !isNonExistentBuilder(_lotteryBuilder), "Invalid _lotteryBuilder arg");

        Lottery memory currentLottery = lotteries[_lotteryBuilder][currentLotteryId[_lotteryBuilder]];
        require(
            currentLotteryId[_lotteryBuilder] == 0 
                || currentLottery.status == Status.Claimable   
                || currentLottery.status == Status.Cancel,
            "Not time to (re)start lottery"
        );

        _sendOperatorProtocolFee(true);
        
        // Initialize config lottery and keep constant rules for all lotteries of a given builder
        if(currentLotteryId[_lotteryBuilder] == 0) {

            require( uint8(_symbol) <= uint8(Symbol.NUTS404), "Invalid token lottery symbol");
            require(_duration >= MIN_LENGTH_LOTTERY && _duration <= MAX_LENGTH_LOTTERY, "Duration outside of range");
            require(_priceTicket > 0, "Ticket price is zero");
            require(_discountDivisor >= MIN_DISCOUNT_DIVISOR || _discountDivisor == 0, "Must be >= MIN_DISCOUNT_DIVISOR or 0");
            require(_treasuryFee <= MAX_TREASURY_FEE, "Treasury fee too high");
            require(_bracketCalculatorActiveLength >= MIN_BRACKET_CALCULATOR_ACTIVE_LENGTH && _bracketCalculatorActiveLength <= MAX_BRACKET_CALCULATOR_ACTIVE_LENGTH, "Bracket length outside of range");
            require(_vrfCallbackGasLimit >= MIN_VRF_CALLBACK_GAS_LIMIT && _vrfCallbackGasLimit <= MAX_VRF_CALLBACK_GAS_LIMIT, "Gas limit outside range");
            require(_vrfResquestConfirmations >= MIN_VRF_REQUEST_CONFIRMATIONS && _vrfResquestConfirmations <= MAX_VRF_REQUEST_CONFIRMATIONS, "Request confirmations outside range");
            uint256 rewardsBreakdownTotal;
            for (uint8 i = 0; i < _bracketCalculatorActiveLength; i++) {
                rewardsBreakdownTotal += _rewardsBreakdown[i];
            }
            require(rewardsBreakdownTotal == 10000, "Rewards must equal 10000"); // on active length of _bracketCalculator

            configs[_lotteryBuilder] = Config({
                symbol: _symbol,
                duration: _duration,
                priceTicket: _priceTicket,
                discountDivisor: _discountDivisor,
                rewardsBreakdown: _rewardsBreakdown,
                treasuryFee: _treasuryFee,
                treasuryBuilderAddress: _treasuryBuilderAddress,
                isNextLotteryInjected: _isNextLotteryInjected,
                bracketCalculatorActiveLength: _bracketCalculatorActiveLength,
                vrfCallbackGasLimit: _vrfCallbackGasLimit,
                vrfResquestConfirmations: _vrfResquestConfirmations
            });
            
            builderCounter++; 
            lotteryBuilders[builderCounter] = _lotteryBuilder;
        }

        currentLotteryId[_lotteryBuilder]++; // first lotteryId per builder will be 1 
        uint256 lotteryId = currentLotteryId[_lotteryBuilder];
        uint256 ticketId = currentTicketId[_lotteryBuilder];
        uint256 injectedAmount = pendingInjectionNextLottery[_lotteryBuilder];

        lotteries[_lotteryBuilder][lotteryId] = Lottery({
            status: Status.Open,
            startTime: block.timestamp,
            tokenPerBracket: [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)],
            countWinnersPerBracket: [uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0), uint256(0)],
            firstTicketId: ticketId,
            firstTicketIdNextLottery: ticketId,
            tokenCollected: injectedAmount, // Injection here of previous lottery funds not won by users
            finalNumber: 0
        });

        emit LotteryOpen(
            _lotteryBuilder,
            lotteryId,
            block.timestamp,
            ticketId,
            injectedAmount
        );

        pendingInjectionNextLottery[_lotteryBuilder] = 0;
    }


    /**
     * @notice Check if an address is an existing lottery builder address
     */
    function isNonExistentBuilder(address _addr) public view returns (bool) {
        return currentLotteryId[_addr] == 0;
    }

    /**
     * @notice View lottery config details
     * @param _lotteryBuilder: lottery builder address
     */
    function viewConfig(address _lotteryBuilder) external view returns (Config memory) {
        return configs[_lotteryBuilder];
    }

    /**
     * @notice View lottery details
     * @param _lotteryBuilder: lottery builder address
     * @param _lotteryId: lottery id
     */
    function viewLottery(address _lotteryBuilder, uint256 _lotteryId) external view returns (Lottery memory) {
        return lotteries[_lotteryBuilder][_lotteryId];
    }

    /**
     * @notice Calculate price of a set of tickets
     * @param _discountDivisor: divisor for the discount
     * @param _priceTicket price of a ticket (in chosen TOKEN)
     * @param _numberTickets number of tickets to buy
     */
    function calculateTotalPriceForBulkTickets(
        uint256 _discountDivisor,
        uint256 _priceTicket,
        uint256 _numberTickets
    ) external pure returns (uint256) {
        require(_discountDivisor >= MIN_DISCOUNT_DIVISOR || _discountDivisor == 0, "Must be >= MIN_DISCOUNT_DIVISOR or 0");
        require(_numberTickets != 0, "Number of tickets must be > 0");

        return _calculateTotalPriceForBulkTickets(_discountDivisor, _priceTicket, _numberTickets);
    }

    /**
     * @notice View ticket statuses and numbers for an array of ticket ids
     * @param _lotteryBuilder: lottery builder address
     * @param _ticketIds: array of _ticketId
     */
    function viewNumbersAndStatusesForTicketIds(address _lotteryBuilder, uint256[] calldata _ticketIds)
        external
        view
        returns (uint32[] memory, bool[] memory)
    {
        uint256 length = _ticketIds.length;
        uint32[] memory ticketNumbers = new uint32[](length);
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            ticketNumbers[i] = tickets[_lotteryBuilder][_ticketIds[i]].number;
            if (tickets[_lotteryBuilder][_ticketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true; // claimed
            } else {
                ticketStatuses[i] = false; // not claimed
            }
        }

        return (ticketNumbers, ticketStatuses);
    }

    /**
     * @notice View rewards for a given ticket, providing a bracket, and lottery id
     * @dev Computations are mostly offchain. This is used to verify a ticket!
     * @param _lotteryBuilder: lottery builder address
     * @param _lotteryId: lottery id
     * @param _ticketId: ticket id
     * @param _bracket: bracket for the ticketId to verify the claim and calculate rewards
     */
    function viewRewardsForTicketId(
        address _lotteryBuilder,
        uint256 _lotteryId,
        uint256 _ticketId,
        uint32 _bracket
    ) external view returns (uint256) {
        // Check lottery is in claimable status
        if (lotteries[_lotteryBuilder][_lotteryId].status != Status.Claimable) {
            return 0;
        }

        // Check ticketId is within range
        if (
            (lotteries[_lotteryBuilder][_lotteryId].firstTicketIdNextLottery < _ticketId) &&
            (lotteries[_lotteryBuilder][_lotteryId].firstTicketId >= _ticketId)
        ) {
            return 0;
        }

        return _calculateRewardsForTicketId(_lotteryBuilder, _lotteryId, _ticketId, _bracket);
    }

    /**
     * @notice View user ticket ids, numbers, and statuses of user for a given lottery from a given builder
     * @param _user: user address
     * @param _lotteryBuilder: lottery builder address
     * @param _lotteryId: lottery id
     * @param _cursor: cursor to start where to retrieve the tickets
     * @param _size: the number of tickets to retrieve
     */
    function viewUserInfoForLotteryId(
        address _user,
        address _lotteryBuilder,
        uint256 _lotteryId,
        uint256 _cursor,
        uint256 _size
    )
        external
        view
        returns (
            uint256[] memory,
            uint32[] memory,
            bool[] memory,
            uint256
        )
    {
        uint256 length = _size;
        uint256 numberTicketsBoughtAtLotteryId = userTicketIdsPerLotteryId[_lotteryBuilder][_user][_lotteryId].length;

        if (length > (numberTicketsBoughtAtLotteryId - _cursor)) {
            length = numberTicketsBoughtAtLotteryId - _cursor;
        }

        uint256[] memory lotteryTicketIds = new uint256[](length);
        uint32[] memory ticketNumbers = new uint32[](length);
        bool[] memory ticketStatuses = new bool[](length);

        for (uint256 i = 0; i < length; i++) {
            lotteryTicketIds[i] = userTicketIdsPerLotteryId[_lotteryBuilder][_user][_lotteryId][i + _cursor];
            ticketNumbers[i] = tickets[_lotteryBuilder][lotteryTicketIds[i]].number;

            if (tickets[_lotteryBuilder][lotteryTicketIds[i]].owner == address(0)) {
                ticketStatuses[i] = true; // claimed
            } else {
                ticketStatuses[i] = false; // not claimed (includes the ones that cannot be claimed: cases where lotteries are open or closed and not in clamable status)
            }
        }

        return (lotteryTicketIds, ticketNumbers, ticketStatuses, numberTicketsBoughtAtLotteryId);
    }

    /**
     * @notice View lotteryBuilders subset
     * @param _start: start index from lotteryBuilders mapping
     * @param _end: end index from lotteryBuilders mapping
     */
    function viewLotteryBuilders(uint256 _start, uint256 _end) external view returns (address[] memory) {
        require(_start >= 1, "Start index can't be less than 1");
        require(_end >= _start, "Invalid indices");
        require(_end <= builderCounter, "End index out of bounds");
        
        uint256 length = _end - _start + 1; // mapping starts from 1
        address[] memory buildersSubset = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            buildersSubset[i] = lotteryBuilders[_start + i];
        }
        return buildersSubset;
    }
    
    /**
     * @notice View user history builderCounter
     * @param _user: user address
     */
    function viewUserHistoryBuilderCounter(address _user) external view returns (uint256) {
        return  usersHistory[_user].builderCounter;
    }

    /**
     * @notice View viewUserHistory subset
     * @param _user: user address
     * @param _startBuilders: start index from user lotteryBuilders mapping
     * @param _endBuilders: end index from user lotteryBuilders mapping
     * @param _cursorIds: cursors to start where to retrieve the user lotteryIds (starting from 1) for lotteryBuilders subset
     * @param _sizeLimitIds: subset limit size of user lotteryIds to retrieved
     */
    function viewUserHistory(
    	address _user,
        uint256 _startBuilders, 
        uint256 _endBuilders, 
        uint256[] calldata _cursorIds,
        uint256[] calldata _sizeLimitIds
    ) 
        external 
        view 
        returns (
            address[] memory, 
            uint256[][] memory,
            uint256[] memory
        ) 
    {
        History storage userHistory = usersHistory[_user];
        require(_startBuilders >= 1, "Start builders index can't be less than 1");
        require(_endBuilders >= _startBuilders, "Invalid indices");
        require(_endBuilders <= userHistory.builderCounter, "End builders index out of bounds");
    
        uint256 lengthBuilders = _endBuilders - _startBuilders + 1; // mapping starts from 1

        require(_sizeLimitIds.length == lengthBuilders && _cursorIds.length == lengthBuilders, "Invalid _cursorIds or _sizeLimitIds length");

        address[] memory buildersSubset = new address[](lengthBuilders);
        uint256[][] memory idsSubset = new uint256[][](lengthBuilders);
        uint256[] memory sizeIds = new uint256[](lengthBuilders);

        for (uint256 i = 0; i < lengthBuilders; i++) {
            address builder = userHistory.lotteryBuilders[_startBuilders + i];
            buildersSubset[i] = builder; 


            uint256 lengthIds = _sizeLimitIds[i];
            sizeIds[i] = userHistory.lotteryIdCounters[builder];
            if (lengthIds > (sizeIds[i] - _cursorIds[i] + 1)) {
                lengthIds = sizeIds[i] - _cursorIds[i] + 1;
            }

            idsSubset[i] = new uint256[](lengthIds);
            for (uint256 j = 0; j < lengthIds; j++){
                idsSubset[i][j] = userHistory.lotteryIds[builder][j+_cursorIds[i]]; 
            }

        }
        return (buildersSubset, idsSubset, sizeIds);
    }

    /**
     * @notice Calculate rewards for a given ticket
     * @param _lotteryBuilder: lottery builder address
     * @param _lotteryId: lottery id
     * @param _ticketId: ticket id
     * @param _bracket: bracket for the ticketId to verify the claim and calculate rewards
     */
    function _calculateRewardsForTicketId(
        address _lotteryBuilder,
        uint256 _lotteryId,
        uint256 _ticketId,
        uint32 _bracket
    ) internal view returns (uint256) {
        // Retrieve the winning number combination
        uint32 winningTicketNumber = lotteries[_lotteryBuilder][_lotteryId].finalNumber;

        // Retrieve the user number combination from the ticketId
        uint32 userNumber = tickets[_lotteryBuilder][_ticketId].number;

        // Apply transformation to verify the claim provided by the user is true
        uint32 transformedWinningNumber = _bracketCalculator[_bracket] + (winningTicketNumber % (uint32(10)**(_bracket + 1)));

        uint32 transformedUserNumber = _bracketCalculator[_bracket] + (userNumber % (uint32(10)**(_bracket + 1)));

        // Confirm that the two transformed numbers are the same, if not throw
        if (transformedWinningNumber == transformedUserNumber) {
            return lotteries[_lotteryBuilder][_lotteryId].tokenPerBracket[_bracket];
        } else {
            return 0;
        }
    }

    /**
     * @notice Calculate final price for bulk of tickets
     * @param _discountDivisor: divisor for the discount (the smaller it is, the greater the discount is)
     * @param _priceTicket: price of a ticket
     * @param _numberTickets: number of tickets purchased
     */
    function _calculateTotalPriceForBulkTickets(
        uint256 _discountDivisor,
        uint256 _priceTicket,
        uint256 _numberTickets
    ) internal pure returns (uint256) {
        return _discountDivisor != 0 ? (_priceTicket * _numberTickets * (_discountDivisor + 1 - _numberTickets)) / _discountDivisor : _priceTicket * _numberTickets;
    }

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    /**
     * @notice Internal function to send operator fee to protocol and handle excess.
     */
    function _sendOperatorProtocolFee(bool isExcessHandled) internal {

        require(msg.value >= OPERATOR_PROTOCOL_FEE, "Insufficient Ether provided for the operator protocol fee");

        // Send the fixed fee to the protocol.
        (bool sent, ) = TREASURY_PROTOCOL_ADDRESS.call{value: OPERATOR_PROTOCOL_FEE}("");
        require(sent, "Failed to send operator fee to the protocol");

        if (isExcessHandled) {
            // Refund any excess Ether sent to the function back to the sender.
            uint256 excessAmount = msg.value - OPERATOR_PROTOCOL_FEE;
            if (excessAmount > 0) {
                (bool refundSent, ) = payable(msg.sender).call{value: excessAmount}("");
                require(refundSent, "Failed to refund excess Ether");
            }
        }
        
    }
}
