// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@account-abstraction/interfaces/PackedUserOperation.sol";
import "@account-abstraction/core/Helpers.sol";
import "../util/EcdsaLib.sol";

library UserOpValidatorLib {

    /**
     * This function parses the given userOpSignature into a DecodedErc20PermitSig data structure.
     * 
     * Once parsed, the function will check for two conditions:
     *      1. is the expected hash found in the signed Permit message's deadline field?
     *      2. is the recovered message signer equal to the expected signer?
     * 
     * If both conditions are met - outside contract can be sure that the expected signer has indeed
     * approved the given hash by signing a given Permit message.
     * 
     * NOTES: This function will revert if either of following is met:
     *    1. the userOpSignature couldn't be abi.decoded into a valid DecodedErc20PermitSig struct as defined in this contract
     *    2. extracted hash wasn't equal to the provided expected hash
     *    3. recovered Permit message signer wasn't equal to the expected signer
     * 
     * Returns true if the expected signer did indeed approve the given expectedHash by signing an on-chain transaction.
     * In that case, the function will also perform the Permit approval on the given token in case the 
     * isPermitTx flag was set to true in the decoded signature struct.
     * 
     * @param userOp UserOp being validated.
     * @param parsedSignature Signature provided as the userOp.signature parameter (minus the prepended tx type byte).
     * @param expectedSigner Signer expected to be recovered when decoding the ERC20OPermit signature.
     */
    function validateUserOp(PackedUserOperation memory userOp, bytes32 userOpHash, bytes memory parsedSignature, address expectedSigner) internal returns (uint256) {
        if (!this.EcdsaLib.isValidSignature(expectedSigner, userOpHash, parsedSignature)) {
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_SUCCESS;
    }

    function validateSignatureForOwner(address expectedSigner, bytes32 hash, bytes memory parsedSignature) internal returns (bool) {
        return this.EcdsaLib.isValidSignature(expectedSigner, hash, parsedSignature);
    }
}