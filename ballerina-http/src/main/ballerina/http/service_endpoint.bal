package ballerina.http;

/////////////////////////////
/// HTTP Service Endpoint ///
/////////////////////////////
documentation {
    Represents service endpoint where one or more services can be registered. so that ballerina program can offer service through this endpoint.

    F{{conn}}  - Service endpoint connection.
    F{{config}} - ServiceEndpointConfiguration configurations.
    F{{remote}}  - The details of remote address.
    F{{local}} - The details of local address.
    F{{protocol}}  - The protocol associate with the service endpoint.
}
public type ServiceEndpoint object {
    public {
        @readonly Remote remote;
        @readonly Local local;
        @readonly string protocol;
    }
    private {
        Connection conn;
        ServiceEndpointConfiguration config;
    }
    public function init(ServiceEndpointConfiguration config);

    @Description { value:"Gets called when the endpoint is being initialize during package init time"}
    @Return { value:"Error occured during initialization" }
    public native function initEndpoint() returns (error);

    @Description { value:"Gets called every time a service attaches itself to this endpoint. Also happens at package initialization."}
    @Param { value:"ep: The endpoint to which the service should be registered to" }
    @Param { value:"serviceType: The type of the service to be registered" }
    public native function register(typedesc serviceType);

    @Description { value:"Starts the registered service"}
    public native function start();

    @Description { value:"Returns the connector that client code uses"}
    @Return { value:"The connector that client code uses" }
    public native function getClient() returns (Connection);

    @Description { value:"Stops the registered service"}
    public native function stop();
}

documentation {
    Represents the details of remote address.

    F{{host}}  - The remote server host.
    F{{port}} - The remote server port.
}
public type Remote object {
    public {
        @readonly string host;
        @readonly int port;
    }
}

documentation {
    Represents the details of local address.

    F{{host}}  - The local server host.
    F{{port}} - The local server port.
}
public type Local object {
    public {
        @readonly string host;
        @readonly int port;
    }
}

@Description {value:"Request validation limits configuration for HTTP service endpoint"}
@Field {value:"maxUriLength: Maximum length allowed in the URL"}
@Field {value:"maxHeaderSize: Maximum size allowed in the headers"}
@Field {value:"maxEntityBodySize: Maximum size allowed in the entity body"}
public type RequestLimits object {
    public {
        @readonly int maxUriLength;
        @readonly int maxHeaderSize;
        @readonly int maxEntityBodySize;
    }
}

@Description {value:"Initializes the RequestLimits struct with default values."}
@Param {value:"config: The RequestLimits struct to be initialized"}
public function RequestLimits::RequestLimits() {
    self.maxUriLength = -1;
    self.maxHeaderSize = -1;
    self.maxEntityBodySize = -1;
}

@Description {value:"Configuration for HTTP service endpoint"}
@Field {value:"host: Host of the service"}
@Field {value:"port: Port number of the service"}
@Field {value:"exposeHeaders: The array of allowed headers which are exposed to the client"}
@Field {value:"keepAlive: The keepAlive behaviour of the connection for a particular port"}
@Field {value:"transferEncoding: The types of encoding applied to the response"}
@Field {value:"chunking: The chunking behaviour of the response"}
@Field {value:"ssl: The SSL configurations for the service endpoint"}
@Field {value:"httpVersion: Highest HTTP version supported"}
@Field {value:"requestLimits: Request validation limits configuration"}
@Field {value:"filters: Filters to be applied to the request before dispatched to the actual resource"}
public type ServiceEndpointConfiguration object {
    public {
        string host;
        int port;
        KeepAlive keepAlive;
        TransferEncoding|null transferEncoding;
        Chunking chunking;
        ServiceSecureSocket|null secureSocket;
        string httpVersion;
        RequestLimits|null requestLimits;
        Filter[] filters;
    }
    new () {
        keepAlive = KeepAlive.AUTO;
        chunking = Chunking.AUTO;
        transferEncoding = TransferEncoding.CHUNKING;
        httpVersion = "1.1";
        port = 9090;
    }
}

@Description { value:"SecureSocket struct represents SSL/TLS options to be used for HTTP service" }
@Field {value: "trustStore: TrustStore related options"}
@Field {value: "keyStore: KeyStore related options"}
@Field {value: "protocols: SSL/TLS protocol related options"}
@Field {value: "validateCert: Certificate validation against CRL or OCSP related options"}
@Field {value:"ciphers: List of ciphers to be used. eg: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA"}
@Field {value:"sslVerifyClient: The type of client certificate verification"}
@Field {value:"sessionCreation: Enable/disable new ssl session creation"}
@Field {value:"ocspStapling: Enable/disable ocsp stapling"}
public type ServiceSecureSocket object {
    public {
        TrustStore|null trustStore;
        KeyStore|null keyStore;
        Protocols|null protocols;
        ValidateCert|null validateCert;
        string ciphers;
        string sslVerifyClient;
        boolean sessionCreation;
        ServiceOcspStapling|null ocspStapling;
    }
    new () {
        sessionCreation = true;
    }
}

public type KeepAlive "AUTO"|"ALWAYS"|"NEVER";

@Description { value:"Gets called when the endpoint is being initialized during the package initialization."}
@Param { value:"epName: The endpoint name" }
@Param { value:"config: The ServiceEndpointConfiguration of the endpoint" }
@Return { value:"Error occured during initialization" }
public function ServiceEndpoint::init(ServiceEndpointConfiguration config) {
    self.config = config;
    var err = self.initEndpoint();
    if (err != null) {
        throw err;
    }
    // if filters are defined, call init on them
    if (config.filters != null) {
        foreach filter in config.filters  {
            filter.init();
        }
    }
}

//////////////////////////////////
/// WebSocket Service Endpoint ///
//////////////////////////////////
public type WebSocketEndpoint object {
    public {
        map attributes;
        string id;
        string negotiatedSubProtocol;
        boolean isSecure;
        boolean isOpen;
        map<string> upgradeHeaders;
    }
    private {
        WebSocketConnector conn;
        ServiceEndpointConfiguration config;
        ServiceEndpoint httpEndpoint;
    }
    new () {
        httpEndpoint = {};
    }
    public function init(ServiceEndpointConfiguration config);
    public function register(typedesc serviceType);
    public function start();
    public function getClient() returns (WebSocketConnector);
    public function stop();
}

@Description { value:"Gets called when the endpoint is being initialize during package init time"}
@Param { value:"epName: The endpoint name" }
@Param { value:"config: The ServiceEndpointConfiguration of the endpoint" }
@Return { value:"Error occured during initialization" }
public function WebSocketEndpoint::init(ServiceEndpointConfiguration config) {
    self.attributes = {};
    self.httpEndpoint = {};
    self.httpEndpoint.init(config);
}

@Description { value:"gets called every time a service attaches itself to this endpoint - also happens at package init time"}
@Param { value:"conn: The server connector connection" }
@Param { value:"res: The outbound response message" }
@Return { value:"Error occured during registration" }
public function WebSocketEndpoint::register(typedesc serviceType) {
    self.httpEndpoint.register(serviceType);
}

@Description { value:"Starts the registered service"}
@Return { value:"Error occured during registration" }
public function WebSocketEndpoint::start() {
    self.httpEndpoint.start();
}

@Description { value:"Returns the connector that client code uses"}
@Return { value:"The connector that client code uses" }
@Return { value:"Error occured during registration" }
public function WebSocketEndpoint::getClient() returns (WebSocketConnector) {
    return self.conn;
}

@Description { value:"Stops the registered service"}
@Return { value:"Error occured during registration" }
public function WebSocketEndpoint::stop() {
    self.httpEndpoint.stop();
}