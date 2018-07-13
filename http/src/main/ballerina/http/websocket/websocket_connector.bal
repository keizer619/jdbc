// Copyright (c) 2018 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

# Represents a WebSocket connector in ballerina. This include all connector oriented operations.
public type WebSocketConnector object {
    private boolean isReady = false;

    # Push text to the connection.
    #
    # + text - Text to be sent
    # + final - True if this is a final frame of a (long) message
    # + return - `error` if an error occurs when sending
    public native function pushText(string text, boolean final = true) returns error?;

    # Push binary data to the connection.
    #
    # + data - Binary data to be sent
    # + final - True if this is a final frame of a (long) message
    # + return - `error` if an error occurs when sending
    public native function pushBinary(byte[] data, boolean final = true) returns error?;

    # Ping the connection.
    #
    # + data - Binary data to be sent.
    # + return - `error` if an error occurs when sending
    public native function ping(byte[] data) returns error?;

    # Send pong message to the connection.
    #
    # + data - Binary data to be sent
    # + return - `error` if an error occurs when sending
    public native function pong(byte[] data) returns error?;

    # Close the connection.
    #
    # + statusCode - Status code for closing the connection
    # + reason - Reason for closing the connection
    # + timeoutInSecs - Time to waits for the close frame from the remote endpoint before closing the connection.
    #                   If the timeout exceeds then the connection is terminated even though a close frame
    #                   is not received from the remote endpoint. If the value < 0 (eg: -1) the connection waits
    #                   until a close frame is received. If WebSocket frame is received from the remote endpoint
    #                   within waiting period the connection is terminated immediately.
    # + return - `error` if an error occurs when sending
    public native function close(int statusCode, string reason, int timeoutInSecs = 60) returns error?;

    # Called when the endpoint is ready to receive messages. Can be called only once per endpoint. For the
    # WebSocketListener can be called only in upgrade or onOpen resources.
    #
    # + return - `error` if an error occurs when sending
    public native function ready() returns error?;

};
