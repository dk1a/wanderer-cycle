declare const abi: [
  {
    "inputs": [],
    "name": "LibRNG__InvalidPrecommit",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "LibRNG__NotRequestOwner",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "requestOwner",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32",
        "name": "requestId",
        "type": "bytes32"
      }
    ],
    "name": "getRandomness",
    "outputs": [],
    "stateMutability": "view",
    "type": "function"
  }
]; export default abi;
