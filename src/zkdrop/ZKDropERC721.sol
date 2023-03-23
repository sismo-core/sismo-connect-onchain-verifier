// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {
    ZkConnect, DataRequest, ClaimRequestLib, ZkConnectResponse, ZkConnectVerifiedResult
} from "../libs/SismoLib.sol";
import {ERC721} from "solmate/tokens/ERC721.sol";

contract ZKDropERC721 is ERC721, ZkConnect {
    DataRequest public dataRequest;

    string private _baseTokenURI;

    constructor(string memory name, string memory symbol, string memory baseTokenURI, bytes16 appId, bytes16 groupId)
        ERC721(name, symbol)
        ZkConnect(appId)
    {
        dataRequest = DataRequestLib.build(groupId);
        _setBaseTokenUri(baseTokenURI);
    }

    function claimWithZkConnect(ZkConnectResponse memory zkConnectResponse) public {
        ZkConnectVerifiedResult memory zkConnectVerifiedResult = verify(zkConnectResponse, dataRequest);

        address to = abi.decode(zkConnectVerifiedResult.signedMessage, (address));
        uint256 tokenId = zkConnectVerifiedResult.vaultId;

        _mint(to, tokenId);
    }

    function transferWithZkConnect(ZkConnectResponse memory zkConnectResponse) public {
        ZkConnectVerifiedResult memory zkConnectVerifiedResult = verify(zkConnectResponse, dataRequest);

        address to = abi.decode(zkConnectVerifiedResult.signedMessage, (address));
        uint256 tokenId = zkConnectVerifiedResult.vaultId;
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
