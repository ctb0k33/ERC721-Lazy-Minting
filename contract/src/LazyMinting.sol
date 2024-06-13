// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {ERC721Burnable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

/**
 * @title LazyNFT Contract implement lazy minting mechanism with EIP712 voucher signature
 * @dev This implementation allow user to mint NFT with voucher signed by minter
 * voucher must be signed by minter (From backend server)
 */
contract LazyNFT is ERC721, ERC721URIStorage, ERC721Burnable, EIP712 {
    error LazyNFT__WrongSignature();
    error LazyNFT__NotEnoughEtherSent();

    // Defines a unique namespace for the signatures used with this contract
    string private constant SIGNING_DOMAIN = "Voucher-Domain";
    string private constant SIGNATURE_VERSION = "1";
    address public minter;

    /*
    * @param _minter Signer of the voucher. Contract with check if the voucher is signed by this address 
    * before minting the NFT. 
    */
    constructor(address _minter) ERC721("LazyNFT", "LNFT") EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        minter = _minter;
    }

    struct LazyNFTVoucher {
        uint256 tokenId;
        uint256 price;
        string uri;
        address buyer;
        bytes signature;
    }

    function recover(LazyNFTVoucher calldata voucher) public view returns (address) {
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256("LazyNFTVoucher(uint256 tokenId,uint256 price,string uri,address buyer)"),
                    voucher.tokenId,
                    voucher.price,
                    keccak256(bytes(voucher.uri)),
                    voucher.buyer
                )
            )
        );
        address signer = ECDSA.recover(digest, voucher.signature);
        return signer;
    }

    function safeMint(LazyNFTVoucher calldata voucher) public payable {
        if (minter != recover(voucher)) {
            revert LazyNFT__WrongSignature();
        }
        if (msg.value < voucher.price) {
            revert LazyNFT__NotEnoughEtherSent();
        }

        _safeMint(voucher.buyer, voucher.tokenId);
        _setTokenURI(voucher.tokenId, voucher.uri);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
