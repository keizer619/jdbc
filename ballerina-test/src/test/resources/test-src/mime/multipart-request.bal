import ballerina.net.http;

import ballerina.mime;


@http:configuration {basePath:"/test"}
service<http> helloServer {

    @http:resourceConfig {
        methods:["POST"],
        path:"/textbodypart"
    }
    resource multipart1 (http:Connection conn, http:InRequest request) {
        mime:Entity[] bodyParts = request.getMultiparts();
        string textContent = bodyParts[0].getText();
        http:OutResponse response = {};
        response.setStringPayload(textContent);
        _ = conn.respond(response);
    }

    @http:resourceConfig {
        methods:["POST"],
        path:"/jsonbodypart"
    }
    resource multipart2 (http:Connection conn, http:InRequest request) {
        mime:Entity[] bodyParts = request.getMultiparts();
        json jsonContent = bodyParts[0].getJson();
        http:OutResponse response = {};
        response.setJsonPayload(jsonContent);
        _ = conn.respond(response);
    }

    @http:resourceConfig {
        methods:["POST"],
        path:"/xmlbodypart"
    }
    resource multipart3 (http:Connection conn, http:InRequest request) {
        mime:Entity[] bodyParts = request.getMultiparts();
        xml xmlContent = bodyParts[0].getXml();
        http:OutResponse response = {};
        response.setXmlPayload(xmlContent);
        _ = conn.respond(response);
    }

    @http:resourceConfig {
        methods:["POST"],
        path:"/binarybodypart"
    }
    resource multipart4 (http:Connection conn, http:InRequest request) {
        mime:Entity[] bodyParts = request.getMultiparts();
        blob blobContent = bodyParts[0].getBlob();
        http:OutResponse response = {};
        response.setBinaryPayload(blobContent);
        _ = conn.respond(response);
    }

    @http:resourceConfig {
        methods:["POST"],
        path:"/multipleparts"
    }
    resource multipart5 (http:Connection conn, http:InRequest request) {
        mime:Entity[] bodyParts = request.getMultiparts();
        int i = 0;
        string content = "";
        while (i < lengthof bodyParts) {
            mime:Entity part = bodyParts[i];
            content = content + " -- " + handleContent(part);
            i = i + 1;
        }
        http:OutResponse response = {};
        response.setStringPayload(content);
        _ = conn.respond(response);
    }
}

function handleContent (mime:Entity bodyPart) (string) {
    string contentType = bodyPart.contentType.toString();
    if (mime:APPLICATION_XML == contentType || mime:TEXT_XML == contentType) {
        xml xmlContent = bodyPart.getXml();
        return xmlContent.getTextValue();
    } else if (mime:APPLICATION_JSON == contentType) {
        json jsonContent = bodyPart.getJson();
        var jsonValue, _ = (string)jsonContent.bodyPart;
        return jsonValue;
    } else if (mime:TEXT_PLAIN == contentType) {
        return bodyPart.getText();
    } else if (mime:APPLICATION_OCTET_STREAM == contentType) {
        blob blobContent = bodyPart.getBlob();
        return blobContent.toString(mime:DEFAULT_CHARSET);
    }
    return null;
}
