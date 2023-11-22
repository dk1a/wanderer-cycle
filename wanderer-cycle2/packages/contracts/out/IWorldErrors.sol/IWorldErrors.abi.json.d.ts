declare const abi: [
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "resource",
        "type": "string"
      },
      {
        "internalType": "address",
        "name": "caller",
        "type": "address"
      }
    ],
    "name": "World_AccessDenied",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "World_AlreadyInitialized",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "bytes4",
        "name": "functionSelector",
        "type": "bytes4"
      }
    ],
    "name": "World_CallbackNotAllowed",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "delegator",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "delegatee",
        "type": "address"
      }
    ],
    "name": "World_DelegationNotFound",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "bytes4",
        "name": "functionSelector",
        "type": "bytes4"
      }
    ],
    "name": "World_FunctionSelectorAlreadyExists",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "bytes4",
        "name": "functionSelector",
        "type": "bytes4"
      }
    ],
    "name": "World_FunctionSelectorNotFound",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "balance",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "World_InsufficientBalance",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "contractAddress",
        "type": "address"
      },
      {
        "internalType": "bytes4",
        "name": "interfaceId",
        "type": "bytes4"
      }
    ],
    "name": "World_InterfaceNotSupported",
    "type": "error"
  },
  {
    "inputs": [
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
    "name": "World_InvalidResourceId",
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
    "name": "World_InvalidResourceType",
    "type": "error"
  },
  {
    "inputs": [
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
    "name": "World_ResourceAlreadyExists",
    "type": "error"
  },
  {
    "inputs": [
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
    "name": "World_ResourceNotFound",
    "type": "error"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "system",
        "type": "address"
      }
    ],
    "name": "World_SystemAlreadyExists",
    "type": "error"
  },
  {
    "inputs": [],
    "name": "World_UnlimitedDelegationNotAllowed",
    "type": "error"
  }
]; export default abi;
