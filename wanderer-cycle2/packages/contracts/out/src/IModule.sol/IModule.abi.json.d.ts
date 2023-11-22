declare const abi: [
  {
    "inputs": [],
    "name": "Module_AlreadyInstalled",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "dependency",
        "type": "string"
      }
    ],
    "name": "Module_MissingDependency",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "Module_NonRootInstallNotSupported",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "Module_RootInstallNotSupported",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "getName",
    "outputs": [
      {
        "internalType": "bytes16",
        "name": "name",
        "type": "bytes16"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "args",
        "type": "bytes"
      }
    ],
    "name": "install",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "args",
        "type": "bytes"
      }
    ],
    "name": "installRoot",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes4",
        "name": "interfaceID",
        "type": "bytes4"
      }
    ],
    "name": "supportsInterface",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
]; export default abi;
