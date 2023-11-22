declare const abi: [
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "fromNamespaceId",
        "type": "bytes32"
      },
      {
        "internalType": "address",
        "name": "toAddress",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "transferBalanceToAddress",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "fromNamespaceId",
        "type": "bytes32"
      },
      {
        "internalType": "ResourceId",
        "name": "toNamespaceId",
        "type": "bytes32"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "transferBalanceToNamespace",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]; export default abi;
