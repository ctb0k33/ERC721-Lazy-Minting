import {ethers} from 'ethers';
    // This should match with the contract
    const SIGNING_DOMAIN_NAME = "Voucher-Domain"
    const SIGNING_DOMAIN_VERSION = "1"
    const chainId = 1
    const contractAddress = "0xe2899bddFD890e320e643044c6b95B9B0b84157A" // Put the address here from remix
    const signer = new ethers.Wallet("503f38a9c967ed597e47fe25643985f032b072db8075426a92110f82df48dfcb") // private key that I use for address 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

    // voucher example 
    const tokenId = 4;
    const recieveAddress = "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"
    const mintPrice = 0;
    const uri = "uri";

    const domain = {
      name: SIGNING_DOMAIN_NAME,
      version: SIGNING_DOMAIN_VERSION,
      verifyingContract: contractAddress,
      chainId
    }

    async function createVoucher(tokenId, price, uri, buyer) {
      const voucher = { tokenId, price, uri, buyer }
      const types = {
        LazyNFTVoucher: [
          {name: "tokenId", type: "uint256"},
          {name: "price", type: "uint256"},
          {name: "uri", type: "string"},
          {name: "buyer", type: "address"}
        ]
      }

      // Contract will verify this signature sign by the signer (aka admin)
      const signature = await signer.signTypedData(domain, types, voucher)
      return {
        ...voucher,
        signature
      }
    }

    async function main() {
      const voucher = await createVoucher(tokenId, mintPrice, uri, recieveAddress) // the address is the address which receives the NFT
      console.log(`[${voucher.tokenId}, ${voucher.price}, "${voucher.uri}", "${voucher.buyer}", "${voucher.signature}"]`)
    }

main()