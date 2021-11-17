// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

// interface of Auth Oracle
contract AuthOracle {
    event AuthRequest(string actionUri, string authUri, bytes32 token);
    event AuthResponse(bytes32 token, bool ok);

    function askOk(
        string calldata actionUri,
        string calldata authUri,
        bytes32 token
    ) external {}

    function logOk(
        string calldata actionUri,
        string calldata authUri,
        bytes32 token
    ) public {}

    function isOK(bytes32 token) external returns (bool ok) {}
}

// Proof of Existence Action Token Contract
contract ActionContract {
    /**
     * structs
     */
    struct Action {
        uint256 id; // internal action id
        string func; // uri of the function to call
        string[] params; // the parameter with which to call the
        string auth; // uri of the authorization info
    }

    /**
     * events
     */
    event Request(address indexed owner, bytes32 token);
    event Redemtion(bytes32 token);

    /**
     * props
     */
    // contract related
    AuthOracle oracle;
    string public uri; // e.g. http://example.org/ActionContract#
    // pattern related
    mapping(bytes32 => Action) public actions;
    uint256 public actionCounter;
    // function related
    mapping(string => string) public proofs;

    /**
     * constructor
     */
    constructor(string memory contractUri, address oracleAddress) {
        uri = contractUri; // the URI to identify the contract on the web, dereferencing yields more information
        oracle = AuthOracle(oracleAddress); // the oracle used in this contract
    }

    /**
     * functions
     */
    //pattern related - external
    function requestActionToken(
        string calldata actionUri, // e.g. http://example.org/ActionContract#store
        string[] calldata params,
        string calldata authUri // e.g. http://example.org/VerifiableCredential#
    ) external returns (bytes32 token) {
        uint256 actionId = actionCounter++;
        token = keccak256(abi.encode(actionId, actionUri, params, authUri));
        actions[token] = Action({
            id: actionId,
            func: actionUri,
            params: params,
            auth: authUri
        });
        oracle.askOk(actionUri, authUri, token);
        emit Request(msg.sender, token);
        return token;
    }

    //pattern related
    function redeemActionToken(bytes32 token) external {
        require(oracle.isOK(token), "Token not ok.");
        if (
            keccak256(abi.encodePacked(actions[token].func)) ==
            keccak256(abi.encodePacked(uri, "store")) // e.g. i.e. // e.g. http://example.org/ActionContract#store
        ) {
            store(actions[token].params[0], actions[token].params[1]);
            emit Redemtion(token);
        }
        // else if other funcs ...
        else {
            revert("How did you trick the oracle...?");
            // this should not happen as oracles should check applicability of function URIs.
        }
    }

    // function related - private
    function store(string memory dataUri, string memory proof) internal {
        proofs[dataUri] = proof;
    }
}
