declare const abi: [
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      },
      {
        "internalType": "uint8",
        "name": "dynamicFieldIndex",
        "type": "uint8"
      }
    ],
    "name": "getDynamicField",
    "outputs": [
      {
        "internalType": "bytes",
        "name": "",
        "type": "bytes"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      },
      {
        "internalType": "uint8",
        "name": "dynamicFieldIndex",
        "type": "uint8"
      }
    ],
    "name": "getDynamicFieldLength",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      },
      {
        "internalType": "uint8",
        "name": "dynamicFieldIndex",
        "type": "uint8"
      },
      {
        "internalType": "uint256",
        "name": "start",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "end",
        "type": "uint256"
      }
    ],
    "name": "getDynamicFieldSlice",
    "outputs": [
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      },
      {
        "internalType": "uint8",
        "name": "fieldIndex",
        "type": "uint8"
      },
      {
        "internalType": "FieldLayout",
        "name": "fieldLayout",
        "type": "bytes32"
      }
    ],
    "name": "getField",
    "outputs": [
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      },
      {
        "internalType": "uint8",
        "name": "fieldIndex",
        "type": "uint8"
      }
    ],
    "name": "getField",
    "outputs": [
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      }
    ],
    "name": "getFieldLayout",
    "outputs": [
      {
        "internalType": "FieldLayout",
        "name": "fieldLayout",
        "type": "bytes32"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      },
      {
        "internalType": "uint8",
        "name": "fieldIndex",
        "type": "uint8"
      },
      {
        "internalType": "FieldLayout",
        "name": "fieldLayout",
        "type": "bytes32"
      }
    ],
    "name": "getFieldLength",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      },
      {
        "internalType": "uint8",
        "name": "fieldIndex",
        "type": "uint8"
      }
    ],
    "name": "getFieldLength",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      }
    ],
    "name": "getKeySchema",
    "outputs": [
      {
        "internalType": "Schema",
        "name": "keySchema",
        "type": "bytes32"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      },
      {
        "internalType": "FieldLayout",
        "name": "fieldLayout",
        "type": "bytes32"
      }
    ],
    "name": "getRecord",
    "outputs": [
      {
        "internalType": "bytes",
        "name": "staticData",
        "type": "bytes"
      },
      {
        "internalType": "PackedCounter",
        "name": "encodedLengths",
        "type": "bytes32"
      },
      {
        "internalType": "bytes",
        "name": "dynamicData",
        "type": "bytes"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      }
    ],
    "name": "getRecord",
    "outputs": [
      {
        "internalType": "bytes",
        "name": "staticData",
        "type": "bytes"
      },
      {
        "internalType": "PackedCounter",
        "name": "encodedLengths",
        "type": "bytes32"
      },
      {
        "internalType": "bytes",
        "name": "dynamicData",
        "type": "bytes"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      },
      {
        "internalType": "uint8",
        "name": "fieldIndex",
        "type": "uint8"
      },
      {
        "internalType": "FieldLayout",
        "name": "fieldLayout",
        "type": "bytes32"
      }
    ],
    "name": "getStaticField",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      }
    ],
    "name": "getValueSchema",
    "outputs": [
      {
        "internalType": "Schema",
        "name": "valueSchema",
        "type": "bytes32"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
]; export default abi;
