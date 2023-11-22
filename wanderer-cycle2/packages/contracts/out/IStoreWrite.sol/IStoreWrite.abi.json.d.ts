declare const abi: [
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      }
    ],
    "name": "Store_DeleteRecord",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      },
      {
        "indexed": false,
        "internalType": "bytes",
        "name": "staticData",
        "type": "bytes"
      },
      {
        "indexed": false,
        "internalType": "PackedCounter",
        "name": "encodedLengths",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "internalType": "bytes",
        "name": "dynamicData",
        "type": "bytes"
      }
    ],
    "name": "Store_SetRecord",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      },
      {
        "indexed": false,
        "internalType": "uint48",
        "name": "start",
        "type": "uint48"
      },
      {
        "indexed": false,
        "internalType": "uint40",
        "name": "deleteCount",
        "type": "uint40"
      },
      {
        "indexed": false,
        "internalType": "PackedCounter",
        "name": "encodedLengths",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "name": "Store_SpliceDynamicData",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "ResourceId",
        "name": "tableId",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "internalType": "bytes32[]",
        "name": "keyTuple",
        "type": "bytes32[]"
      },
      {
        "indexed": false,
        "internalType": "uint48",
        "name": "start",
        "type": "uint48"
      },
      {
        "indexed": false,
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "name": "Store_SpliceStaticData",
    "type": "event"
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
    "name": "deleteRecord",
    "outputs": [],
    "stateMutability": "nonpayable",
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
        "name": "byteLengthToPop",
        "type": "uint256"
      }
    ],
    "name": "popFromDynamicField",
    "outputs": [],
    "stateMutability": "nonpayable",
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
        "internalType": "bytes",
        "name": "dataToPush",
        "type": "bytes"
      }
    ],
    "name": "pushToDynamicField",
    "outputs": [],
    "stateMutability": "nonpayable",
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
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "name": "setDynamicField",
    "outputs": [],
    "stateMutability": "nonpayable",
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
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "name": "setField",
    "outputs": [],
    "stateMutability": "nonpayable",
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
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "internalType": "FieldLayout",
        "name": "fieldLayout",
        "type": "bytes32"
      }
    ],
    "name": "setField",
    "outputs": [],
    "stateMutability": "nonpayable",
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
    "name": "setRecord",
    "outputs": [],
    "stateMutability": "nonpayable",
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
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      },
      {
        "internalType": "FieldLayout",
        "name": "fieldLayout",
        "type": "bytes32"
      }
    ],
    "name": "setStaticField",
    "outputs": [],
    "stateMutability": "nonpayable",
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
        "internalType": "uint40",
        "name": "startWithinField",
        "type": "uint40"
      },
      {
        "internalType": "uint40",
        "name": "deleteCount",
        "type": "uint40"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "name": "spliceDynamicData",
    "outputs": [],
    "stateMutability": "nonpayable",
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
        "internalType": "uint48",
        "name": "start",
        "type": "uint48"
      },
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
      }
    ],
    "name": "spliceStaticData",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]; export default abi;
