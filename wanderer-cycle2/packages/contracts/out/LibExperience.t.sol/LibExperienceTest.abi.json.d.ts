declare const abi: [
  {
    "inputs": [],
    "name": "LibExperience__ExpNotInitialized",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "LibExperience__InvalidLevel",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "length",
        "type": "uint256"
      }
    ],
    "name": "PackedCounter_InvalidLength",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "bytes",
        "name": "data",
        "type": "bytes"
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
    "name": "Slice_OutOfBounds",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "length",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "accessedIndex",
        "type": "uint256"
      }
    ],
    "name": "Store_IndexOutOfBounds",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "bytes2",
        "name": "expected",
        "type": "bytes2"
      },
      {
        "internalType": "ResourceId",
        "name": "resourceId",
        "type": "bytes32"
      },
      {
        "internalType": "string",
        "name": "resourceIdString",
        "type": "string"
      }
    ],
    "name": "Store_InvalidResourceType",
    "type": "error"
  },
  {
    "inputs": [
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
        "internalType": "uint40",
        "name": "fieldLength",
        "type": "uint40"
      }
    ],
    "name": "Store_InvalidSplice",
    "type": "error"
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
        "indexed": false,
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "name": "log",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "name": "log_address",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint256[]",
        "name": "val",
        "type": "uint256[]"
      }
    ],
    "name": "log_array",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "int256[]",
        "name": "val",
        "type": "int256[]"
      }
    ],
    "name": "log_array",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address[]",
        "name": "val",
        "type": "address[]"
      }
    ],
    "name": "log_array",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bytes",
        "name": "",
        "type": "bytes"
      }
    ],
    "name": "log_bytes",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      }
    ],
    "name": "log_bytes32",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "int256",
        "name": "",
        "type": "int256"
      }
    ],
    "name": "log_int",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "key",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "val",
        "type": "address"
      }
    ],
    "name": "log_named_address",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "key",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "uint256[]",
        "name": "val",
        "type": "uint256[]"
      }
    ],
    "name": "log_named_array",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "key",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "int256[]",
        "name": "val",
        "type": "int256[]"
      }
    ],
    "name": "log_named_array",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "key",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "address[]",
        "name": "val",
        "type": "address[]"
      }
    ],
    "name": "log_named_array",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "key",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "bytes",
        "name": "val",
        "type": "bytes"
      }
    ],
    "name": "log_named_bytes",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "key",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "bytes32",
        "name": "val",
        "type": "bytes32"
      }
    ],
    "name": "log_named_bytes32",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "key",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "int256",
        "name": "val",
        "type": "int256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "decimals",
        "type": "uint256"
      }
    ],
    "name": "log_named_decimal_int",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "key",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "val",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "decimals",
        "type": "uint256"
      }
    ],
    "name": "log_named_decimal_uint",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "key",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "int256",
        "name": "val",
        "type": "int256"
      }
    ],
    "name": "log_named_int",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "key",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "string",
        "name": "val",
        "type": "string"
      }
    ],
    "name": "log_named_string",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "key",
        "type": "string"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "val",
        "type": "uint256"
      }
    ],
    "name": "log_named_uint",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "name": "log_string",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "log_uint",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "bytes",
        "name": "",
        "type": "bytes"
      }
    ],
    "name": "logs",
    "type": "event"
  },
  {
    "inputs": [],
    "name": "IS_TEST",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "excludeArtifacts",
    "outputs": [
      {
        "internalType": "string[]",
        "name": "excludedArtifacts_",
        "type": "string[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "excludeContracts",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "excludedContracts_",
        "type": "address[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "excludeSenders",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "excludedSenders_",
        "type": "address[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "failed",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "setUp",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "targetArtifactSelectors",
    "outputs": [
      {
        "components": [
          {
            "internalType": "address",
            "name": "addr",
            "type": "address"
          },
          {
            "internalType": "bytes4[]",
            "name": "selectors",
            "type": "bytes4[]"
          }
        ],
        "internalType": "struct StdInvariant.FuzzSelector[]",
        "name": "targetedArtifactSelectors_",
        "type": "tuple[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "targetArtifacts",
    "outputs": [
      {
        "internalType": "string[]",
        "name": "targetedArtifacts_",
        "type": "string[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "targetContracts",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "targetedContracts_",
        "type": "address[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "targetSelectors",
    "outputs": [
      {
        "components": [
          {
            "internalType": "address",
            "name": "addr",
            "type": "address"
          },
          {
            "internalType": "bytes4[]",
            "name": "selectors",
            "type": "bytes4[]"
          }
        ],
        "internalType": "struct StdInvariant.FuzzSelector[]",
        "name": "targetedSelectors_",
        "type": "tuple[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "targetSenders",
    "outputs": [
      {
        "internalType": "address[]",
        "name": "targetedSenders_",
        "type": "address[]"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint32[3]",
        "name": "addExp",
        "type": "uint32[3]"
      }
    ],
    "name": "testFuzzIncreaseExp",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint32[3]",
        "name": "pstats",
        "type": "uint32[3]"
      }
    ],
    "name": "testFuzzPStats",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "testGetExp",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "testHasExp",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "testIncreaseExp",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "testMaxLevel",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "worldAddress",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
]; export default abi;
