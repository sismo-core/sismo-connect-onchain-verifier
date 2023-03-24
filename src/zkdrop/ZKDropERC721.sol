// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {
    ZkConnect,
    ZkConnectRequestContentLib,
    Claim,
    Auth,
    DataRequest,
    ClaimRequestLib,
    LogicalOperator,
    ZkConnectRequestContent,
    ZkConnectResponse,
    ZkConnectVerifiedResult
} from "../libs/SismoLib.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

contract ZKDropERC721 is ERC721, ZkConnect {
    ZkConnectRequestContent private zkConnectRequestContent;

    string private _baseTokenURI;

    constructor(string memory name, string memory symbol, string memory baseTokenURI, bytes16 appId, bytes16 groupId)
        ERC721(name, symbol)
        ZkConnect(appId)
    {
        Claim memory claim = ClaimRequestLib.build({groupId: groupId});
        Auth memory auth;
        DataRequest[] memory dataRequests = new DataRequest[](1);
        dataRequests[0] = DataRequest({claimRequest: claim, authRequest: auth, messageSignatureRequest: ""});

        zkConnectRequestContent =
            ZkConnectRequestContentLib.build({dataRequests: dataRequests, operator: LogicalOperator.AND});

        _setBaseTokenUri(baseTokenURI);
    }

    function claimWithZkConnect(ZkConnectResponse memory zkConnectResponse) public {
        ZkConnectVerifiedResult memory zkConnectVerifiedResult = verify(zkConnectResponse, zkConnectRequestContent);

        address to = abi.decode(zkConnectVerifiedResult.signedMessages[0], (address));
        uint256 tokenId = zkConnectVerifiedResult.verifiedAuths[0].userId;

        _mint(to, tokenId);
    }

    function transferWithZkConnect(ZkConnectResponse memory zkConnectResponse) public {
        ZkConnectVerifiedResult memory zkConnectVerifiedResult = verify(zkConnectResponse, zkConnectRequestContent);

        address to = abi.decode(zkConnectVerifiedResult.signedMessages[0], (address));
        uint256 tokenId = zkConnectVerifiedResult.verifiedAuths[0].userId;
        address from = ownerOf(tokenId);

        // _transferFrom(from, to, tokenId);
    }

    function tokenURI(uint256 id) public view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseTokenUri(string memory baseUri) public {
        _setBaseTokenUri(baseUri);
    }

    function _setBaseTokenUri(string memory baseUri) private {
        _baseTokenURI = baseUri;
        // emit BaseTokenUriChanged(baseUri);
    }
}
