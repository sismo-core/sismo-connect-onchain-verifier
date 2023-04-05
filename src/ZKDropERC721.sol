// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./libs/zk-connect/SismoConnectLib.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ZKDropERC721 is ERC721, ZkConnect {
  bytes16 public immutable GROUP_ID;
  SismoConnectRequestContent private requestContent;

  string private _baseTokenURI;

  event BaseTokenURIChanged(string baseTokenURI);

  constructor(
    string memory name,
    string memory symbol,
    string memory baseTokenURI,
    bytes16 appId,
    bytes16 groupId
  ) ERC721(name, symbol) ZkConnect(appId) {
    GROUP_ID = groupId;
    _setBaseTokenURI(baseTokenURI);
  }

  function claimWithZkConnect(bytes memory response, address to) public {
    SismoConnectVerifiedResult memory verifiedResult = verify({
      responseBytes: response,
      authRequest: buildAuth({authType: AuthType.ANON}),
      claimRequest: buildClaim({groupId: GROUP_ID}),
      signatureRequest: abi.encode(to)
    });

    uint256 tokenId = verifiedResult.verifiedAuths[0].userId;
    _mint(to, tokenId);
  }

  function transferWithZkConnect(bytes memory response, address to) public {
    SismoConnectVerifiedResult memory verifiedResult = verify({
      responseBytes: response,
      authRequest: buildAuth({authType: AuthType.ANON}),
      claimRequest: buildClaim({groupId: GROUP_ID}),
      signatureRequest: abi.encode(to)
    });

    uint256 tokenId = verifiedResult.verifiedAuths[0].userId;
    address from = ownerOf(tokenId);
    _transfer(from, to, tokenId);
  }

  function tokenURI(uint256) public view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function _setBaseTokenURI(string memory baseURI) private {
    _baseTokenURI = baseURI;
    emit BaseTokenURIChanged(baseURI);
  }
}
