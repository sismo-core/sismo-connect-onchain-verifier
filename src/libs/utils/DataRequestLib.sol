// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "src/libs/utils/Structs.sol";

library DataRequestLib {
    function build(Claim memory claimRequest, Auth memory authRequest) public pure returns (DataRequest memory) {
        return DataRequest({claimRequest: claimRequest, authRequest: authRequest, messageSignatureRequest: ""});
    }

    function build(Claim memory claimRequest, bytes memory messageSignatureRequest)
        public
        pure
        returns (DataRequest memory)
    {
        Auth memory authRequest;
        return DataRequest({
            claimRequest: claimRequest,
            authRequest: authRequest,
            messageSignatureRequest: messageSignatureRequest
        });
    }

    function build(Auth memory authRequest, bytes memory messageSignatureRequest)
        public
        pure
        returns (DataRequest memory)
    {
        Claim memory claimRequest;
        return DataRequest({
            claimRequest: claimRequest,
            authRequest: authRequest,
            messageSignatureRequest: messageSignatureRequest
        });
    }

    function build(Claim memory claimRequest) public pure returns (DataRequest memory) {
        Auth memory authRequest;
        bytes memory messageSignatureRequest = "";
        return DataRequest({
            claimRequest: claimRequest,
            authRequest: authRequest,
            messageSignatureRequest: messageSignatureRequest
        });
    }

    function build(Auth memory authRequest) public pure returns (DataRequest memory) {
        Claim memory claimRequest;
        bytes memory messageSignatureRequest = "";
        return DataRequest({
            claimRequest: claimRequest,
            authRequest: authRequest,
            messageSignatureRequest: messageSignatureRequest
        });
    }

    function build(bytes memory messageSignatureRequest) public pure returns (DataRequest memory) {
        Claim memory claimRequest;
        Auth memory authRequest;
        return DataRequest({
            claimRequest: claimRequest,
            authRequest: authRequest,
            messageSignatureRequest: messageSignatureRequest
        });
    }
}
