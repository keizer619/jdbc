/*
 *  Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package org.ballerinalang.net.grpc.nativeimpl.connection.server;

import org.ballerinalang.bre.Context;
import org.ballerinalang.connector.api.BLangConnectorSPIUtil;
import org.ballerinalang.connector.api.Service;
import org.ballerinalang.connector.api.Struct;
import org.ballerinalang.model.types.TypeKind;
import org.ballerinalang.model.values.BValue;
import org.ballerinalang.natives.annotations.Argument;
import org.ballerinalang.natives.annotations.BallerinaFunction;
import org.ballerinalang.natives.annotations.Receiver;
import org.ballerinalang.natives.annotations.ReturnType;
import org.ballerinalang.net.grpc.GrpcServicesBuilder;
import org.ballerinalang.net.grpc.MessageConstants;
import org.ballerinalang.net.grpc.exception.GrpcServerException;
import org.ballerinalang.net.grpc.exception.GrpcServerValidationException;
import org.ballerinalang.net.grpc.nativeimpl.AbstractGrpcNativeFunction;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import static org.ballerinalang.net.grpc.GrpcServicesBuilder.registerService;

/**
 * Native function to respond the caller.
 *
 * @since 0.96.1
 */
@BallerinaFunction(
        packageName = "ballerina.net.grpc",
        functionName = "start",
        receiver = @Receiver(type = TypeKind.STRUCT, structType = MessageConstants.SERVER_CONNECTION,
                structPackage = MessageConstants.PROTOCOL_PACKAGE_GRPC),
        args = {@Argument(name = "response", type = TypeKind.STRING)},
        returnType = @ReturnType(type = TypeKind.STRUCT, structType = "ConnectorError",
                structPackage = MessageConstants.PROTOCOL_PACKAGE_GRPC),
        isPublic = true
)
public class start extends AbstractGrpcNativeFunction {
    private static final Logger log = LoggerFactory.getLogger(start.class);
    
    @java.lang.Override
    public BValue[] execute(Context context) {
        Struct serviceEndpoint = BLangConnectorSPIUtil.getConnectorEndpointStruct(context);
        io.grpc.ServerBuilder serverBuilder = getServiceBuilder(serviceEndpoint);
        try {
            GrpcServicesBuilder.start(serverBuilder);
        } catch (GrpcServerException e) {
            throw new GrpcServerValidationException("Error in starting gRPC service.", e);
        }
        return new BValue[] {null};
    }
}
