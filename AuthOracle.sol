// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract AuthOracle {
    // Authentication and Authorization Oracle

    event AuthRequest(string actionUri, string authUri, bytes32 token);
    event AuthResponse(bytes32 token, bool ok);

    mapping(bytes32 => bool) public tokens;

    function askOk(
        string calldata actionUri,
        string calldata authUri,
        bytes32 token
    ) external {
        emit AuthRequest(actionUri, authUri, token);
    }

    function logOk(
        bytes32 token,
        bool ok
    ) public {
        tokens[token] = ok;
        emit AuthResponse(token, ok);
    }

    function isOK(bytes32 token) external view returns (bool ok) {
        return tokens[token];
    }
}
