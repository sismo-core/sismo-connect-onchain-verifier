// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./libs/sismo-connect/SismoConnectLib.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ZKDropERC721 is ERC721, SismoConnect {
  using SismoConnectHelper for SismoConnectVerifiedResult;

  bytes16 public immutable GROUP_ID;

  string private _baseTokenURI;

  event BaseTokenURIChanged(string baseTokenURI);

  constructor(
    string memory name,
    string memory symbol,
    string memory baseTokenURI,
    bytes16 appId,
    bytes16 groupId
  ) ERC721(name, symbol) SismoConnect(appId) {
    GROUP_ID = groupId;
    _setBaseTokenURI(baseTokenURI);
  }

  function claimWithSismoConnect(bytes memory response, address to) public {
    SismoConnectVerifiedResult memory result = verify({
      responseBytes: response,
      auth: buildAuth({authType: AuthType.VAULT}),
      claim: buildClaim({groupId: GROUP_ID}),
      signature: buildSignature({message: abi.encode(to)})
    });

    uint256 tokenId = result.getUserId(AuthType.VAULT);
    _mint(to, tokenId);
  }

  function transferWithSismoConnect(bytes memory response, address to) public {
    SismoConnectVerifiedResult memory result = verify({
      responseBytes: response,
      auth: buildAuth({authType: AuthType.VAULT}),
      claim: buildClaim({groupId: GROUP_ID}),
      signature: buildSignature({message: abi.encode(to)})
    });

    uint256 tokenId = result.getUserId(AuthType.VAULT);
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
